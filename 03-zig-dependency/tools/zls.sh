#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")"
exec bazel run --config=silent //third_party/zls:zls -- zls "${@}"
