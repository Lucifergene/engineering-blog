#!/usr/bin/env bash

set -euo pipefail

workflow="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.github/workflows/hugo.yaml"

if ! rg --multiline --quiet 'echo "\$\{RUNNER_TEMP\}/hugo" >> "\$GITHUB_PATH"\n          export PATH="\$\{RUNNER_TEMP\}/hugo:\$PATH"\n          hugo version' "$workflow"; then
  echo "The Hugo installer must export its temporary binary directory before invoking Hugo in the same step." >&2
  exit 1
fi
