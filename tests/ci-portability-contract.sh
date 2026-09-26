#!/usr/bin/env bash

set -euo pipefail

tests_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if grep -Eq '^[[:space:]]*rg[[:space:]]' "$tests_dir"/*.sh; then
  echo "The site contract must use only standard shell tools available on GitHub Actions runners." >&2
  exit 1
fi
