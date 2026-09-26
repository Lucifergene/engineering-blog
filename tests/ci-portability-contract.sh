#!/usr/bin/env bash

set -euo pipefail

site_contract="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/tests/site-contract.sh"

if grep -Fq 'rg ' "$site_contract"; then
  echo "The site contract must use only standard shell tools available on GitHub Actions runners." >&2
  exit 1
fi
