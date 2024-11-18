# Base32 dependency example

Run your build:

- `bazel build //...` or `bazel build //:binary`

And run your target:

- `bazel-bin/binary` or `bazel run //:binary`

- `bazel run @zls_archive//:zls_executable -- --version`
- `bazel run @zls_x86_64-macos//:zls_executable -- --version`
