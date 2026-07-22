# Q011 Phase 7K — RPM Trust Repair Rollback

**Status:** historical prepared rollback; not invoked because every trust gate passed  
**Prepared:** 2026-07-21  
**Execution result:** 2026-07-21, rollback not required  
**Paired change window:**
[Phase 7K RPM trust repair](q011-phase7k-rpm-trust-repair-change-window.md)

## Rollback Boundary

Phase 7G proved RPM's trust list was empty before the executed window. This
would have allowed Phase 7K to identify every post-import entry as newly
created by that one change. The reviewed rollback deletes only those newly
listed entries. It does not
remove a package, cache file, repository, registration, NetworkManager
profile, DHCP reservation, VM, VHDX, ISO, or checkpoint.

The fresh Phase 7K preflight confirmed native `rpmkeys --delete` support
before import. Every post-import gate passed, so this rollback did not run.
The stored commands are the historical contingency and are not authority to
delete the retained trust set now.

## Reviewed Automatic Rollback Triggers

The executed same-block function would have run rollback immediately if:

- import exit is nonzero;
- the post-import list is not exactly three entries;
- any expected key ID is absent or another entry appears;
- either cached RPM signature/digest verification fails;
- `NOKEY`, `NOTTRUSTED`, or `NOT OK` remains after import; or
- the result is ambiguous.

Do not run DNF before rollback.

## Historical Delete-Only Procedure

This procedure was prepared for the same guest SSH session but was not
invoked:

```bash
set -o pipefail

phase7k_rollback_keys() {
  rollback_handles_text=$(
    rpm -qa 'gpg-pubkey*' --qf '%{VERSION}-%{RELEASE}\n' 2>&1
  )
  rollback_handles_exit=$?
  mapfile -t rollback_handles < <(
    printf '%s\n' "$rollback_handles_text" |
      sed '/^[[:space:]]*$/d'
  )

  printf '%s\n' "$rollback_handles_text"
  printf 'rollback_handles_exit=%s\n' "$rollback_handles_exit"
  printf 'rollback_handle_count=%s\n' "${#rollback_handles[@]}"

  if test "$rollback_handles_exit" -ne 0; then
    printf '%s\n' 'rollback_query_gate=false'
    return 31
  fi

  rollback_delete_failed=false
  for handle in "${rollback_handles[@]}"; do
    if ! printf '%s\n' "$handle" |
         grep -E '^[[:xdigit:]]+-[[:xdigit:]]+$' >/dev/null; then
      printf 'unexpected_rollback_handle=%s\n' "$handle"
      return 31
    fi
    sudo rpmkeys --delete "$handle" || rollback_delete_failed=true
  done

  remaining_keys=$(rpmkeys --list 2>&1)
  remaining_keys_exit=$?
  remaining_handles=$(
    rpm -qa 'gpg-pubkey*' --qf '%{VERSION}-%{RELEASE}\n' 2>&1
  )
  remaining_handles_exit=$?

  Phase7KKeyRollbackPass=false
  if test "$rollback_delete_failed" = false && \
     test "$remaining_keys_exit" -eq 0 && \
     test -z "$remaining_keys" && \
     test "$remaining_handles_exit" -eq 0 && \
     test -z "$remaining_handles"; then
    Phase7KKeyRollbackPass=true
  fi

  printf 'rollback_delete_failed=%s\n' "$rollback_delete_failed"
  printf 'remaining_key_count=%s\n' "$(printf '%s' "$remaining_keys" | grep -c . || true)"
  printf 'remaining_handle_count=%s\n' "$(printf '%s' "$remaining_handles" | grep -c . || true)"
  printf 'Phase7KKeyRollbackPass=%s\n' "$Phase7KKeyRollbackPass"

  test "$Phase7KKeyRollbackPass" = true || return 32
}

phase7k_rollback_keys
phase7k_rollback_exit=$?
printf 'phase7k_rollback_exit=%s\n' "$phase7k_rollback_exit"
```

If the query/format gate exits `31`, do not guess a handle or use a broad RPM erase.
Immediately proceed to network containment and request an exact recovery
approval. If deletion exits `32`, preserve the output, isolate Q011, and stop.

## Verify Return To The Diagnostic Baseline

Only after `Phase7KKeyRollbackPass=true`, rerun `rpmkeys -Kv` against the same
two exact cached files from the change window. Require both recorded key IDs
to return `NOKEY`, all four digests per sample to remain `OK`, and both command
exits to be `1`. This proves return to the Phase 7G trust baseline without
deleting or modifying either cached RPM.

## Normal Shutdown And Hyper-V Isolation

Request normal shutdown:

```bash
sudo systemctl poweroff
```

Use Phase 7K-E to wait up to three minutes, disconnect only Q011, restore
Untagged VLAN 0, and verify the final Off/DVD-empty/checkpoint-free state. If
normal shutdown times out, disconnect Q011 and restore VLAN 0 before stopping;
forced power-off requires separate approval.

## Actual Retained Changes On Successful Repair

`Phase7KTrustPass=true`, so no rollback ran. The three exact Red Hat trust
certificates remain intentionally imported. Q011 shut down and returned to
disconnected Untagged VLAN 0 with `Phase7KEndStatePass=True`. DNF retry remains
separately gated by Phase 7P.
