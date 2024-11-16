"""
Module extension for base32.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

VERSION = "0.2.0"
SHA556 = "45f79a743bf14e049d6f3b51609f189e80d289357b0c9bb17d008bf519c55607"

def _base32_impl(mctx):
    http_archive(
        name = "base32",
        url = "https://github.com/gernest/base32/archive/refs/tags/v{version}.tar.gz".format(version = VERSION),
        strip_prefix = "base32-{version}".format(version = VERSION),
        sha256 = SHA556,
        build_file_content = """
load("@rules_zig//zig:defs.bzl", "zig_module")

zig_module(
    name = "base32",
    srcs = glob(["src/**/*.zig"]),
    main = "src/base32.zig",
    visibility = ["//visibility:public"],
)
        """,
    )

    return mctx.extension_metadata(
        reproducible = True,
        root_module_direct_deps = "all",
        root_module_direct_dev_deps = [],
    )

base32 = module_extension(implementation = _base32_impl)
