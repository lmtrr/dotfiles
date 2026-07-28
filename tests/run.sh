#!/usr/bin/env sh

set -eu

TEST_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

for test_file in "$TEST_DIR"/*_test.sh; do
  sh "$test_file"
done
