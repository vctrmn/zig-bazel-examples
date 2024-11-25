"""
Module extension for base32.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

_VERSION = "0.2.0"
_SHA256 = "45f79a743bf14e049d6f3b51609f189e80d289357b0c9bb17d008bf519c55607"
_BUILD_FILE_CONTENT = """
load("@rules_zig//zig:defs.bzl", "zig_module")

zig_module(
    name = "base32",
    srcs = glob(["src/**/*.zig"]),
    main = "src/base32.zig",
    visibility = ["//visibility:public"],
)
"""

def _base32_impl(mctx):
    http_archive(
        name = "base32",
        url = "https://github.com/gernest/base32/archive/refs/tags/v{version}.tar.gz".format(version = _VERSION),
        strip_prefix = "base32-{version}".format(version = _VERSION),
        sha256 = _SHA256,
        build_file_content = _BUILD_FILE_CONTENT,
    )

    return mctx.extension_metadata(
        reproducible = True,
        root_module_direct_deps = "all",
        root_module_direct_dev_deps = [],
    )

base32 = module_extension(implementation = _base32_impl)
