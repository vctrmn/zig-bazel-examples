#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")"
exec bazel run @zls_x86_64-macos//:zls_executable -- zig "${@}"