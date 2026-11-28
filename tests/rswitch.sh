#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
export MOCK_LOG="$tmp/log" MOCK_OUT="$tmp/system" MOCK_ROOT="$root"
export PATH="$tmp:$PATH"
mkdir -p "$MOCK_OUT/bin"
printf '#!/bin/sh\nexit 99\n' > "$MOCK_OUT/bin/switch-to-configuration"
tee "$tmp/uname" >/dev/null <<'MOCK'
#!/bin/sh
printf '%s\n' "${MOCK_OS:-Linux}"
MOCK
printf '#!/bin/sh\necho fixture\n' > "$tmp/hostname"
tee "$tmp/sudo" >/dev/null <<'MOCK'
#!/bin/sh
case "$1" in
  nix)
    [ "$2" = build ] || exit 99
    if [ "${MOCK_FORWARD:-}" = yes ]; then
      shift 6
      [ "$#" = 4 ] && [ "$1" = --host ] && [ "$2" = other ] &&
        [ "$3" = --option ] && [ "$4" = 'a b' ] || exit 99
    fi
    echo build >> "$MOCK_LOG"
    case "${MOCK_FAILURE:-}" in
      build) exit 1 ;;
      empty) exit 0 ;;
      invalid) echo "$MOCK_OUT/missing"; exit 0 ;;
    esac
    echo "$MOCK_OUT"
    ;;
  nix-env)
    [ "$*" = "nix-env --profile /nix/var/nix/profiles/system --set $MOCK_OUT" ] || exit 99
    echo register >> "$MOCK_LOG"
    [ "${MOCK_FAILURE:-}" != register ]
    ;;
  "$MOCK_OUT/bin/switch-to-configuration") echo "activate $2" >> "$MOCK_LOG" ;;
  -H)
    [ "$2 $3 $4" = 'nix run --no-update-lock-file' ] || exit 99
    [ "$5" = "$MOCK_ROOT#darwinConfigurations.fixture.config.system.build.darwin-rebuild" ] || exit 99
    [ "$6" = -- ] || exit 99
    echo "darwin $7" >> "$MOCK_LOG"
    ;;
  *) exit 99 ;;
esac
MOCK
chmod +x "$tmp/uname" "$tmp/hostname" "$tmp/sudo" "$MOCK_OUT/bin/switch-to-configuration"

expect_log() {
  if [[ $(< "$MOCK_LOG") != "$1" ]]; then
    printf 'Expected:\n%s\nGot:\n%s\n' "$1" "$(< "$MOCK_LOG")" >&2
    exit 1
  fi
}

: > "$MOCK_LOG"
bash "$root/bin/rswitch" --help > "$tmp/help"
grep -q '^Usage:' "$tmp/help"
for bad in swtich 'test boot' '--host --force-host' '--host' '--host other' '--show-trace'; do
  read -r -a bad_args <<< "$bad"
  if bash "$root/bin/rswitch" "${bad_args[@]}" 2>"$tmp/error"; then
    echo "Unexpected success for $bad" >&2
    exit 1
  fi
done
expect_log ''
MOCK_FORWARD=yes bash "$root/bin/rswitch" test -- --host other --option 'a b'
expect_log $'build\nactivate test'

for action in switch boot test; do
  : > "$MOCK_LOG"
  bash "$root/bin/rswitch" "$action"
  if [[ $action = test ]]; then
    expect_log "$(printf 'build\nactivate test')"
  else
    expect_log "$(printf 'build\nregister\nactivate %s' "$action")"
  fi
done

for failure in build empty invalid register; do
  : > "$MOCK_LOG"
  if MOCK_FAILURE=$failure bash "$root/bin/rswitch" switch 2>"$tmp/error"; then
    printf 'Unexpected success for %s failure\n' "$failure" >&2
    exit 1
  fi
  if [[ $failure = register ]]; then
    expect_log $'build\nregister'
  else
    expect_log build
  fi
done

: > "$MOCK_LOG"
MOCK_OS=Darwin bash "$root/bin/rswitch" switch
MOCK_OS=Darwin bash "$root/bin/rswitch" test
expect_log $'darwin switch\ndarwin check'
if MOCK_OS=Darwin bash "$root/bin/rswitch" boot 2>"$tmp/error"; then
  echo 'Unexpected success for Darwin boot' >&2
  exit 1
fi
expect_log $'darwin switch\ndarwin check'
printf 'rswitch tests passed\n'
