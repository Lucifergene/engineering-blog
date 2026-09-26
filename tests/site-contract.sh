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

assert_count() {
  local file="$1"
  local expected="$2"
  local count="$3"
  local actual
  actual="$(grep -Foc "$expected" "$file" || true)"

  if [[ "$actual" != "$count" ]]; then
    echo "Expected '$expected' $count time(s) in $file, found $actual" >&2
    exit 1
  fi
}

HUGO_CACHEDIR="$cache_dir" hugo \
  --source "$site_root" \
  --contentDir "$site_root/tests/fixtures/content" \
  --destination "$output_dir" \
  --environment production \
  --baseURL "https://lucifergene.github.io/systems-in-practice/" \
  --gc \
  --minify

home_page="$output_dir/index.html"

test -f "$home_page"
test -f "$output_dir/index.xml"
assert_contains "$home_page" "Systems in Practice"
assert_contains "$home_page" "Architecture, debugging, and hard-earned lessons from the systems I build."
assert_contains "$home_page" "avik-eiffel"
assert_contains "$home_page" "Portrait of the author"
assert_contains "$home_page" "Recent Posts"
assert_contains "$home_page" "/systems-in-practice/posts/"
assert_contains "$home_page" "https://avikkundu.com"
assert_contains "$home_page" "Featured Build Article"
assert_contains "$home_page" "Archive Build Article"
assert_contains "$home_page" "/systems-in-practice/posts/featured-build-article/"
assert_not_contains "$home_page" "Draft Build Article"
assert_not_contains "$home_page" "All articles"

canonical_page="$output_dir/posts/canonical-mirror-article/index.html"
sitemap="$output_dir/sitemap.xml"

test -f "$canonical_page"
assert_contains "$canonical_page" '<link rel=canonical href=https://example.com/original-article>'
assert_count "$canonical_page" 'rel=canonical' 1
assert_not_contains "$sitemap" "/systems-in-practice/posts/canonical-mirror-article/"
