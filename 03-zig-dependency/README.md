# Hello World

This code is a simple _hello world_ compilation :

Run your build:

- `bazel build //...` or `bazel build //:hello_world_binary`

And run your target:

- `bazel-bin/hello_world_bin_host` or `bazel run //:hello_world_binary`

`bazel clean --expunge` `bazel build //:hello_world_binary --verbose_failures`

backend_binary
