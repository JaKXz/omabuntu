#!/bin/bash

set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$ROOT/install/preflight/supported-versions.sh"

pass() {
  printf 'ok - %s\n' "$1"
}

fail() {
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

for version in "24.04" "26.04"; do
  if omakub_ubuntu_version_supported "$version"; then
    pass "Ubuntu $version is supported"
  else
    fail "Ubuntu $version should be supported"
  fi
done

for version in "22.04" "25.10" "26.10" ""; do
  if omakub_ubuntu_version_supported "$version"; then
    fail "Ubuntu $version should not be supported"
  else
    pass "Ubuntu ${version:-<empty>} is not supported"
  fi
done
