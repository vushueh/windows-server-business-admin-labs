#!/usr/bin/env python3
"""Run the Q007 DNS failure-triage drill entirely on loopback.

The script implements a deliberately small authoritative DNS responder and a
client with Python's standard library. It never reads or changes host DNS
configuration. The responder binds only to 127.0.0.1 on a high UDP port.
"""

from __future__ import annotations

import argparse
import datetime as dt
import ipaddress
import json
import socket
import struct
import threading
import time
from pathlib import Path


LAB_NAME = "files.q007.test"
UNKNOWN_NAME = "old-files.q007.test"
CORRECT_IP = "10.77.7.10"
WRONG_IP = "10.77.7.99"
DEFAULT_BIND = "127.0.0.1"
DEFAULT_PORT = 10553


def encode_name(name: str) -> bytes:
    encoded = bytearray()
    for label in name.rstrip(".").split("."):
        label_bytes = label.encode("ascii")
        if not label_bytes or len(label_bytes) > 63:
            raise ValueError(f"invalid DNS label: {label!r}")
        encoded.append(len(label_bytes))
        encoded.extend(label_bytes)
    encoded.append(0)
    return bytes(encoded)


def decode_name(packet: bytes, offset: int) -> tuple[str, int]:
    labels: list[str] = []
    original_end: int | None = None
    seen: set[int] = set()
    while True:
        if offset >= len(packet):
            raise ValueError("DNS name exceeds packet length")
        length = packet[offset]
        if length & 0xC0 == 0xC0:
            if offset + 1 >= len(packet):
                raise ValueError("truncated DNS compression pointer")
            pointer = ((length & 0x3F) << 8) | packet[offset + 1]
            if pointer in seen:
                raise ValueError("DNS compression loop")
            seen.add(pointer)
            if original_end is None:
                original_end = offset + 2
            offset = pointer
            continue
        if length & 0xC0:
            raise ValueError("unsupported DNS label type")
        offset += 1
        if length == 0:
            return ".".join(labels), original_end if original_end is not None else offset
        if offset + length > len(packet):
            raise ValueError("truncated DNS label")
        labels.append(packet[offset : offset + length].decode("ascii"))
        offset += length


def build_query(name: str, query_id: int) -> bytes:
    header = struct.pack("!HHHHHH", query_id, 0x0100, 1, 0, 0, 0)
    question = encode_name(name) + struct.pack("!HH", 1, 1)
    return header + question


def parse_query(packet: bytes) -> tuple[int, str, int, int, bytes]:
    if len(packet) < 12:
        raise ValueError("truncated DNS header")
    query_id, _flags, qdcount, _ancount, _nscount, _arcount = struct.unpack(
        "!HHHHHH", packet[:12]
    )
    if qdcount != 1:
        raise ValueError("exactly one question is required")
    name, end = decode_name(packet, 12)
    if end + 4 > len(packet):
        raise ValueError("truncated DNS question")
    qtype, qclass = struct.unpack("!HH", packet[end : end + 4])
    return query_id, name.lower(), qtype, qclass, packet[12 : end + 4]


def build_response(query: bytes, records: dict[str, list[str]]) -> bytes:
    query_id, name, qtype, qclass, question = parse_query(query)
    answers = records.get(name)
    if qtype != 1 or qclass != 1 or answers is None:
        flags = 0x8503  # Standard response, authoritative, RD echoed, NXDOMAIN.
        return struct.pack("!HHHHHH", query_id, flags, 1, 0, 0, 0) + question

    flags = 0x8500  # Standard response, authoritative, RD echoed, no recursion claim.
    body = bytearray(struct.pack("!HHHHHH", query_id, flags, 1, len(answers), 0, 0))
    body.extend(question)
    for address in answers:
        body.extend(b"\xc0\x0c")
        body.extend(struct.pack("!HHIH", 1, 1, 30, 4))
        body.extend(ipaddress.ip_address(address).packed)
    return bytes(body)


def decode_response(packet: bytes) -> dict[str, object]:
    if len(packet) < 12:
        raise ValueError("truncated DNS response header")
    query_id, flags, qdcount, ancount, nscount, arcount = struct.unpack(
        "!HHHHHH", packet[:12]
    )
    offset = 12
    question_name = ""
    for _ in range(qdcount):
        question_name, offset = decode_name(packet, offset)
        if offset + 4 > len(packet):
            raise ValueError("truncated response question")
        offset += 4

    answers: list[str] = []
    for _ in range(ancount):
        _name, offset = decode_name(packet, offset)
        if offset + 10 > len(packet):
            raise ValueError("truncated resource-record header")
        rtype, rclass, _ttl, rdlength = struct.unpack("!HHIH", packet[offset : offset + 10])
        offset += 10
        if offset + rdlength > len(packet):
            raise ValueError("truncated resource-record data")
        rdata = packet[offset : offset + rdlength]
        offset += rdlength
        if rtype == 1 and rclass == 1 and rdlength == 4:
            answers.append(str(ipaddress.ip_address(rdata)))

    return {
        "transaction_id": f"0x{query_id:04x}",
        "flags": f"0x{flags:04x}",
        "rcode": flags & 0x000F,
        "qdcount": qdcount,
        "ancount": ancount,
        "nscount": nscount,
        "arcount": arcount,
        "question": question_name,
        "answers": answers,
        "raw_response_hex": packet.hex(),
    }


class LoopbackDnsServer:
    def __init__(self, bind_address: str, port: int) -> None:
        self.bind_address = bind_address
        self.port = port
        self.records: dict[str, list[str]] = {LAB_NAME: [CORRECT_IP]}
        self.malformed_packets = 0
        self._records_lock = threading.Lock()
        self._running = threading.Event()
        self._socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self._socket.bind((bind_address, port))
        self._socket.settimeout(0.1)
        self._thread = threading.Thread(target=self._serve, name="q007-dns", daemon=True)

    def start(self) -> None:
        self._running.set()
        self._thread.start()

    def set_answers(self, answers: list[str]) -> None:
        with self._records_lock:
            self.records[LAB_NAME] = list(answers)

    def _serve(self) -> None:
        while self._running.is_set():
            try:
                packet, peer = self._socket.recvfrom(4096)
            except socket.timeout:
                continue
            except OSError:
                break
            try:
                with self._records_lock:
                    snapshot = {name: list(values) for name, values in self.records.items()}
                response = build_response(packet, snapshot)
                self._socket.sendto(response, peer)
            except (UnicodeDecodeError, ValueError, struct.error):
                self.malformed_packets += 1

    def stop(self) -> None:
        self._running.clear()
        self._thread.join(timeout=1.0)
        self._socket.close()

    @property
    def thread_alive(self) -> bool:
        return self._thread.is_alive()


def query(bind_address: str, port: int, name: str, query_id: int) -> dict[str, object]:
    packet = build_query(name, query_id)
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as client:
        client.settimeout(1.0)
        client.sendto(packet, (bind_address, port))
        response, source = client.recvfrom(4096)
    decoded = decode_response(response)
    decoded["source"] = f"{source[0]}:{source[1]}"
    return decoded


class Recorder:
    def __init__(self) -> None:
        self.lines: list[str] = []

    def add(self, line: str = "") -> None:
        self.lines.append(line)
        print(line)

    def packet(self, label: str, result: dict[str, object]) -> None:
        self.add(f"{label}_raw_response_hex={result['raw_response_hex']}")
        self.add(
            f"{label}_decoded_header="
            f"transaction_id:{result['transaction_id']},flags:{result['flags']},"
            f"rcode:{result['rcode']},qdcount:{result['qdcount']},"
            f"ancount:{result['ancount']},nscount:{result['nscount']},"
            f"arcount:{result['arcount']}"
        )
        self.add(f"{label}_question={result['question']}")
        self.add(f"{label}_answers={','.join(result['answers']) or '<none>'}")


def assert_test(condition: bool, name: str, tests: dict[str, str], recorder: Recorder) -> None:
    status = "PASS" if condition else "FAIL"
    tests[name] = status
    recorder.add(f"TEST {name}={status}")
    if not condition:
        raise AssertionError(name)


def run(bind_address: str, port: int, output_dir: Path) -> int:
    started = dt.datetime.now(dt.timezone.utc).replace(microsecond=0)
    recorder = Recorder()
    tests: dict[str, str] = {}
    evidence: dict[str, object] = {
        "simulation": "Q007 / SIM-N3-DNS",
        "started_utc": started.isoformat(),
        "boundary": f"loopback-only UDP DNS on {bind_address}:{port}",
        "correct_ip": CORRECT_IP,
        "wrong_ip": WRONG_IP,
    }

    recorder.add("Q007 DNS FAILURE TRIAGE SIMULATION")
    recorder.add(f"started_utc={started.isoformat()}")
    recorder.add(f"boundary=loopback-only UDP DNS on {bind_address}:{port}")
    recorder.add("live_dns_or_host_configuration_changed=NO")
    recorder.add("evidence_client=Python standard-library UDP client plus raw packet hex")
    recorder.add()

    server: LoopbackDnsServer | None = None
    try:
        recorder.add("PHASE bind-collision stop test")
        blocker = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        blocker.bind((bind_address, port))
        collision_stopped = False
        try:
            LoopbackDnsServer(bind_address, port)
        except OSError:
            collision_stopped = True
        finally:
            blocker.close()
        assert_test(collision_stopped, "startup_aborts_when_port_in_use", tests, recorder)

        server = LoopbackDnsServer(bind_address, port)
        server.start()
        time.sleep(0.05)
        recorder.add()
        recorder.add("PHASE healthy baseline")
        baseline = query(bind_address, port, LAB_NAME, 0x7001)
        recorder.packet("baseline", baseline)
        assert_test(
            baseline["rcode"] == 0 and baseline["answers"] == [CORRECT_IP],
            "baseline_returns_exactly_one_correct_a_record",
            tests,
            recorder,
        )
        evidence["baseline"] = baseline

        recorder.add()
        recorder.add("PHASE malformed-packet survival")
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as malformed_client:
            malformed_client.sendto(b"\x00\x01broken", (bind_address, port))
        time.sleep(0.1)
        survival = query(bind_address, port, LAB_NAME, 0x7002)
        recorder.packet("post_malformed", survival)
        assert_test(server.malformed_packets >= 1, "malformed_packet_is_counted", tests, recorder)
        assert_test(
            survival["answers"] == [CORRECT_IP] and server.thread_alive,
            "malformed_packet_does_not_crash_server",
            tests,
            recorder,
        )
        evidence["malformed_packet_count"] = server.malformed_packets

        recorder.add()
        recorder.add("PHASE inject extra wrong A record and diagnose impact")
        server.set_answers([WRONG_IP, CORRECT_IP])
        fault = query(bind_address, port, LAB_NAME, 0x7003)
        recorder.packet("fault", fault)
        selected = fault["answers"][0] if fault["answers"] else None
        fault["naive_client_selected"] = selected
        recorder.add(f"fault_naive_client_selected={selected}")
        recorder.add(f"fault_user_impact=client targets wrong host {selected} instead of {CORRECT_IP}")
        assert_test(
            fault["answers"] == [WRONG_IP, CORRECT_IP],
            "fault_response_contains_wrong_and_correct_records",
            tests,
            recorder,
        )
        assert_test(selected == WRONG_IP, "fault_demonstrates_wrong_answer_consumption", tests, recorder)
        evidence["fault"] = fault

        recorder.add()
        recorder.add("PHASE repair and repeat positive retest")
        server.set_answers([CORRECT_IP])
        repair_retests: list[dict[str, object]] = []
        for attempt, query_id in enumerate((0x7004, 0x7005, 0x7006), start=1):
            result = query(bind_address, port, LAB_NAME, query_id)
            recorder.packet(f"repair_{attempt}", result)
            repair_retests.append(result)
        assert_test(
            all(result["rcode"] == 0 and result["answers"] == [CORRECT_IP] for result in repair_retests),
            "three_post_repair_queries_return_only_correct_record",
            tests,
            recorder,
        )
        assert_test(
            all(WRONG_IP not in result["answers"] for result in repair_retests),
            "post_repair_answers_exclude_wrong_record",
            tests,
            recorder,
        )
        evidence["repair_retests"] = repair_retests

        recorder.add()
        recorder.add("PHASE negative retest")
        nxdomain = query(bind_address, port, UNKNOWN_NAME, 0x7007)
        recorder.packet("nxdomain", nxdomain)
        assert_test(
            nxdomain["rcode"] == 3 and nxdomain["ancount"] == 0 and nxdomain["answers"] == [],
            "unknown_name_returns_nxdomain",
            tests,
            recorder,
        )
        evidence["nxdomain"] = nxdomain
    except Exception as exc:
        recorder.add(f"Q007_RESULT=FAIL ({type(exc).__name__}: {exc})")
        evidence["error"] = f"{type(exc).__name__}: {exc}"
    finally:
        recorder.add()
        recorder.add("PHASE cleanup")
        if server is not None:
            server.stop()
            stopped = not server.thread_alive
            tests["server_thread_stopped"] = "PASS" if stopped else "FAIL"
            recorder.add(f"TEST server_thread_stopped={tests['server_thread_stopped']}")
        port_released = False
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as rebind:
                rebind.bind((bind_address, port))
                port_released = True
        except OSError as cleanup_error:
            evidence["cleanup_error"] = f"{type(cleanup_error).__name__}: {cleanup_error}"
        tests["udp_port_released_after_cleanup"] = "PASS" if port_released else "FAIL"
        recorder.add(
            "TEST udp_port_released_after_cleanup="
            f"{tests['udp_port_released_after_cleanup']}"
        )

    passed = bool(tests) and all(value == "PASS" for value in tests.values()) and "error" not in evidence
    completed = dt.datetime.now(dt.timezone.utc).replace(microsecond=0)
    evidence["completed_utc"] = completed.isoformat()
    evidence["tests"] = tests
    evidence["result"] = "PASS" if passed else "FAIL"
    recorder.add(f"completed_utc={completed.isoformat()}")
    recorder.add(f"Q007_RESULT={evidence['result']}")

    output_dir.mkdir(parents=True, exist_ok=True)
    transcript = output_dir / "q007-sanitized-transcript.txt"
    results = output_dir / "q007-run-results.json"
    recorder.lines.extend(
        [
            f"transcript_file={transcript.name}",
            f"results_file={results.name}",
        ]
    )
    transcript.write_text("\n".join(recorder.lines) + "\n", encoding="utf-8")
    results.write_text(json.dumps(evidence, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return 0 if passed else 1


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--bind", default=DEFAULT_BIND)
    parser.add_argument("--port", default=DEFAULT_PORT, type=int)
    parser.add_argument("--output-dir", type=Path, default=Path("evidence"))
    args = parser.parse_args()
    if args.bind != DEFAULT_BIND:
        parser.error("Q007 is fail-closed to 127.0.0.1")
    if not 1024 <= args.port <= 65535:
        parser.error("use a non-privileged UDP port from 1024 through 65535")
    return run(args.bind, args.port, args.output_dir)


if __name__ == "__main__":
    raise SystemExit(main())
