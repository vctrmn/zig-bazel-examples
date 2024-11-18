"""
Module extension for zls.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Define ZLS version and SHA256 hashes for different architectures
_VERSION = "0.13.0"
_ARCHS = {
    "x86_64-linux": struct(
        sha256 = "ec4c1b45caf88e2bcb9ebb16c670603cc596e4f621b96184dfbe837b39cd8410",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
    ),
    "aarch64-macos": struct(
        sha256 = "9848514524f5e5d33997ac280b7d92388407209d4b8d4be3866dc3cf30ca6ca8",
        exec_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:aarch64",
        ],
    ),
    "x86_64-macos": struct(
        sha256 = "4b63854d6b76810abd2563706e7d768efc7111e44dd8b371d49198e627697a13",
        exec_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
    ),
}

# Define the repository rules to download the correct ZLS binary
def _zls_repo_impl(mctx):
    for arch, config in _ARCHS.items():
        http_archive(
            name = "zls_{}".format(arch),
            url = "https://github.com/zigtools/zls/releases/download/{version}/zls-{arch}.tar.xz".format(
                version = _VERSION,
                arch = arch,
            ),
            sha256 = config.sha256,
            build_file_content = """
filegroup(
    name = "zls_binary",
    srcs = ["zls"],  # Reference the downloaded binary
    visibility = ["//visibility:public"],
)

genrule(
    name = "make_zls_executable",
    srcs = [":zls_binary"],
    outs = ["zls_executable"],
    cmd = "chmod +x $(location zls_binary) && cp $(location zls_binary) $(location zls_executable)",
    visibility = ["//visibility:public"],
)
            """,
        )

    #     http_archive(
    #         name = "zls_archive",
    #         url = "https://github.com/zigtools/zls/releases/download/{version}/zls-{arch}.tar.xz".format(
    #             version = _VERSION,
    #             arch = "x86_64-macos",
    #         ),
    #         sha256 = "4b63854d6b76810abd2563706e7d768efc7111e44dd8b371d49198e627697a13",
    #         build_file_content = """
    # filegroup(
    #     name = "zls_binary",
    #     srcs = ["zls"],  # Reference the downloaded binary
    #     visibility = ["//visibility:public"],
    # )
    #
    # genrule(
    #     name = "make_zls_executable",
    #     srcs = [":zls_binary"],
    #     outs = ["zls_executable"],
    #     cmd = "chmod +x $(location zls_binary) && cp $(location zls_binary) $(location zls_executable)",
    #     visibility = ["//visibility:public"],
    # )
    #         """,
    #     )

    return mctx.extension_metadata(
        reproducible = True,
        root_module_direct_deps = "all",
        root_module_direct_dev_deps = [],
    )

# Declare the module extension
zls_archive = module_extension(
    implementation = _zls_repo_impl,
)
