#!/usr/bin/env bash

set -euo pipefail

workflow="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.github/workflows/hugo.yaml"

if ! awk '
  /echo "\$\{RUNNER_TEMP\}\/hugo" >> "\$GITHUB_PATH"/ { saw_path = 1; next }
  saw_path && /export PATH="\$\{RUNNER_TEMP\}\/hugo:\$PATH"/ { saw_export = 1; next }
  saw_export && /hugo version/ { found = 1 }
  END { exit !found }
' "$workflow"; then
  echo "The Hugo installer must export its temporary binary directory before invoking Hugo in the same step." >&2
  exit 1
fi
