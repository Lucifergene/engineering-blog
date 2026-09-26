#!/usr/bin/env bash

set -euo pipefail

site_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output_dir="$(mktemp -d)"
cache_dir="$(mktemp -d)"

cleanup() {
  rm -rf "$output_dir" "$cache_dir"
}
trap cleanup EXIT

assert_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    echo "Expected '$expected' in $file" >&2
    exit 1
  fi
}

assert_not_contains() {
  local file="$1"
  local unexpected="$2"

  if grep -Fq "$unexpected" "$file"; then
    echo "Did not expect '$unexpected' in $file" >&2
    exit 1
  fi
}

HUGO_CACHEDIR="$cache_dir" hugo \
  --source "$site_root" \
  --contentDir "$site_root/tests/fixtures/content" \
  --destination "$output_dir" \
  --environment production \
  --baseURL "https://lucifergene.github.io/engineering-blog/" \
  --gc \
  --minify

home_page="$output_dir/index.html"

test -f "$home_page"
test -f "$output_dir/index.xml"
assert_contains "$home_page" "Systems in Practice"
assert_contains "$home_page" "Architecture, debugging, and hard-earned lessons from the systems I build."
assert_contains "$home_page" "avik-eiffel"
assert_contains "$home_page" "Portrait of the author"
assert_contains "$home_page" "Featured Build Article"
assert_contains "$home_page" "Archive Build Article"
assert_contains "$home_page" "/engineering-blog/posts/featured-build-article/"
assert_not_contains "$home_page" "Draft Build Article"

featured_count="$(awk -v needle='Featured Build Article' '
  {
    line = $0
    while ((position = index(line, needle)) > 0) {
      count++
      line = substr(line, position + length(needle))
    }
  }
  END { print count + 0 }
' "$home_page")"
if [[ "$featured_count" -lt 2 ]]; then
  echo "Expected the featured article in both featured and archive sections" >&2
  exit 1
fi
