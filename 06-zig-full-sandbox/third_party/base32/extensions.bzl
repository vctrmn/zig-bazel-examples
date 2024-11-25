"""
Module extension for base32.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

_VERSION = "0.2.0"
_SHA256 = "45f79a743bf14e049d6f3b51609f189e80d289357b0c9bb17d008bf519c55607"
_BUILD_FILE_CONTENT = """
load("@rules_zig//zig:defs.bzl", "zig_module")

# Replace with ZigModuleInfo
zig_module(
    name = "base32_archive",
    main = "src/base32.zig",
    srcs = glob(["**/*.zig"]),
    visibility = ["//visibility:public"],
)

# filegroup(
#     name = "base32_archive",
#     srcs = glob(["**/*"]),
#     visibility = ["//visibility:public"],
# )

exports_files(glob(["src/**/*.zig"]))
"""

def _base32_impl(ctx):
    http_archive(
        name = "base32_archive",
        url = "https://github.com/gernest/base32/archive/refs/tags/v{version}.tar.gz".format(version = _VERSION),
        strip_prefix = "base32-{version}".format(version = _VERSION),
        sha256 = _SHA256,
        build_file_content = _BUILD_FILE_CONTENT,
    )

    return ctx.extension_metadata(
        reproducible = True,
        root_module_direct_deps = "all",
        root_module_direct_dev_deps = [],
    )

base32_archive = module_extension(implementation = _base32_impl)
