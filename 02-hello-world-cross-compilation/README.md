# Hello World cross architecture compilation

The example code is setup to cross compile from :

- {darwin, x86_64} -> {linux, x86_64}
- {darwin, x86_64} -> {linux, aarch64}

_TO TEST_:

- {linux, x86_64} -> {linux, x86_64}
- {linux, x86_64} -> {linux, aarch64}
- {darwin, aarch64 (Apple Silicon)} -> {linux, x86_64}
- {darwin, aarch64 (Apple Silicon)} -> {linux, aarch64}

Run your build:

- `bazel build //:binary_host_architecture`
- `bazel build //:binary_linux_aarch64`
- `bazel build //:binary_linux_x86_64`

or `bazel build //:all_binaries`

And run your target:

- `bazel-bin/binary_host_architecture` or
  `bazel run //:binary_host_architecture`
