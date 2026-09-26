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
  --destination "$output_dir" \
  --environment production \
  --baseURL "https://lucifergene.github.io/engineering-blog/" \
  --gc \
  --minify

article_dir="$output_dir/posts/how-we-built-integration-testing-for-fast-moving-ai-backend"
article_page="$article_dir/index.html"
sitemap="$output_dir/sitemap.xml"

test -f "$article_page"
test ! -e "$article_dir/cover.png"
test -s "$article_dir/sentinel-success.png"
test -s "$article_dir/sentinel-failure.png"
assert_contains "$article_page" '<link rel=canonical href=https://lucifergene.github.io/engineering-blog/posts/how-we-built-integration-testing-for-fast-moving-ai-backend/>'
assert_count "$article_page" 'rel=canonical' 1
assert_contains "$article_page" '<meta name=robots content="noindex,follow">'
assert_contains "$article_page" '"name":"Avik Kundu"'
assert_contains "$article_page" '"mainEntityOfPage":"https://lucifergene.github.io/engineering-blog/posts/how-we-built-integration-testing-for-fast-moving-ai-backend/"'
assert_contains "$article_page" 'How do you keep your backend compatible with an upstream dependency that changes its API every week?'
assert_contains "$article_page" 'The problem: Our mocks were lying to us'
assert_contains "$article_page" 'LlamaStack Compatibility Sentinel'
assert_contains "$article_page" 'A Slack notification showing a successful verification from LlamaStack Compatibility Sentinel.'
assert_contains "$article_page" 'A Slack notification showing a failed verification from LlamaStack Compatibility Sentinel.'
assert_contains "$article_page" 'Figure 1: This is the workflow with successful verification.'
assert_contains "$article_page" 'Figure 2: This is the workflow with failed verification.'
assert_contains "$article_page" 'sentinel-success.png'
assert_contains "$article_page" 'sentinel-failure.png'
assert_not_contains "$article_page" 'Red Hat'
assert_not_contains "$article_page" 'redhat.com'
assert_not_contains "$article_page" 'OpenShift'
assert_not_contains "$sitemap" '/engineering-blog/posts/how-we-built-integration-testing-for-fast-moving-ai-backend/'
