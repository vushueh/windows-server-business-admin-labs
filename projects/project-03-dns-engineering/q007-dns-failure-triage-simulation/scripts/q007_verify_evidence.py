#!/usr/bin/env python3
"""Independently decode and verify the saved Q007 DNS evidence."""

from __future__ import annotations

import argparse
import ipaddress
import json
import struct
from pathlib import Path


CORRECT_IP = "10.77.7.10"
WRONG_IP = "10.77.7.99"


def skip_name(packet: bytes, offset: int) -> int:
    while True:
        length = packet[offset]
        if length & 0xC0 == 0xC0:
            return offset + 2
        offset += 1
        if length == 0:
            return offset
        offset += length


def independently_decode(raw_hex: str) -> dict[str, object]:
    packet = bytes.fromhex(raw_hex)
    query_id, flags, qdcount, ancount, nscount, arcount = struct.unpack("!HHHHHH", packet[:12])
    offset = 12
    for _ in range(qdcount):
        offset = skip_name(packet, offset) + 4
    answers: list[str] = []
    for _ in range(ancount):
        offset = skip_name(packet, offset)
        rtype, rclass, _ttl, length = struct.unpack("!HHIH", packet[offset : offset + 10])
        offset += 10
        rdata = packet[offset : offset + length]
        offset += length
        if rtype == 1 and rclass == 1 and length == 4:
            answers.append(str(ipaddress.ip_address(rdata)))
    if offset != len(packet):
        raise AssertionError("packet has unparsed trailing data")
    return {
        "transaction_id": query_id,
        "flags": flags,
        "rcode": flags & 0x000F,
        "qdcount": qdcount,
        "ancount": ancount,
        "nscount": nscount,
        "arcount": arcount,
        "answers": answers,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("results", type=Path)
    args = parser.parse_args()
    evidence = json.loads(args.results.read_text(encoding="utf-8"))

    if evidence["result"] != "PASS" or any(value != "PASS" for value in evidence["tests"].values()):
        raise AssertionError("saved drill test result is not PASS")

    baseline = independently_decode(evidence["baseline"]["raw_response_hex"])
    fault = independently_decode(evidence["fault"]["raw_response_hex"])
    repaired = [independently_decode(item["raw_response_hex"]) for item in evidence["repair_retests"]]
    nxdomain = independently_decode(evidence["nxdomain"]["raw_response_hex"])

    assert baseline["flags"] == 0x8500 and baseline["answers"] == [CORRECT_IP]
    assert fault["flags"] == 0x8500 and fault["answers"] == [WRONG_IP, CORRECT_IP]
    assert evidence["fault"]["naive_client_selected"] == WRONG_IP
    assert len(repaired) == 3
    assert all(item["flags"] == 0x8500 and item["answers"] == [CORRECT_IP] for item in repaired)
    assert nxdomain["flags"] == 0x8503 and nxdomain["ancount"] == 0 and nxdomain["answers"] == []
    assert evidence["tests"]["udp_port_released_after_cleanup"] == "PASS"

    print("Q007_EVIDENCE_VERIFY=PASS")
    print("authoritative_flags=PASS")
    print("baseline_answers=10.77.7.10")
    print("fault_answers=10.77.7.99,10.77.7.10")
    print("fault_client_selected=10.77.7.99")
    print("repair_retests=3")
    print("nxdomain_rcode=3")
    print("cleanup_port_release=PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
