#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")"
exec bazel run //third_party/zig:zig_runner "${@}"