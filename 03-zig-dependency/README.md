# Base32 dependency example

Run your build:

- `bazel build //...` or `bazel build //:binary`

And run your target:

- `bazel-bin/binary` or `bazel run //:binary`

- `bazel run @com_github_zigtools_zls//:zls -- zls --version`
- `bazel build @com_github_gernest_base32//:base32` and
  `bazel build @com_github_zigtools_zls//:zls`
