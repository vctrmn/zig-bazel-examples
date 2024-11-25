"""
This module sets up the ZLS (Zig Language Server) toolchain and provides rules for using ZLS and Zig.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Define the ZIG version to be used in ZLS
ZIG_VERSION = "0.13.0"

# Architecture-specific configurations for ZLS, including SHA256 checksums and platform compatibility
ZLS_ARCH_CONFIG = {
    # "aarch64-linux": struct(
    #     sha256 = "8e258711168c2e3e7e81d6074663cfe291309b779928aaa4c66aed1affeba1aa",
    #     exec_compatible_with = [
    #         "@platforms//os:linux",
    #         "@platforms//cpu:aarch64",
    #     ],
    # ),
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

# Build file content for the ZLS toolchain
# ZLS_BUILD_FILE_CONTENT = """
# load("//third_party/zls:zls.bzl", "zls_toolchain")
# zls_toolchain(name = "toolchain", zls = "zls")
# """

ZLS_BUILD_FILE_CONTENT = """
load("//third_party/zls:zls.bzl", "zls_toolchain")
zls_toolchain(name = "toolchain", zls = "zls")

filegroup(
    name = "zls_binary",
    srcs = ["zls"],
    visibility = ["//:__pkg__"],
)

genrule(
    name = "copy_binary",
    srcs = [":zls_binary"],
    outs = ["zls_executable"],
    cmd = "cp $(location :zls_binary) $@ && chmod +x $@",
    visibility = ["//visibility:public"],
)
"""

# Define a provider to expose ZLS binary information
ZlsInfo = provider(
    doc = "Provides information about the ZLS binary.",
    fields = {"bin": "Path to the ZLS binary."},
)

# Implementation of the ZLS toolchain rule
def _zls_toolchain_impl(ctx):
    default_info = DefaultInfo(files = depset(direct = [ctx.file.zls]))
    zls_info = ZlsInfo(bin = ctx.file.zls)
    toolchain_info = platform_common.ToolchainInfo(
        default_info = default_info,
        zls_info = zls_info,
    )

    return [
        default_info,
        zls_info,
        toolchain_info,
    ]

# Rule to define the ZLS toolchain
zls_toolchain = rule(
    implementation = _zls_toolchain_impl,
    attrs = {
        "zls": attr.label(
            executable = True,
            allow_single_file = True,
            cfg = "exec",
        ),
    },
)

# Implementation of the ZLS repository module extension
def _zls_repo_impl(mctx):
    for arch, config in ZLS_ARCH_CONFIG.items():
        http_archive(
            name = "zls_{}".format(arch),
            url = "https://github.com/zigtools/zls/releases/download/{version}/zls-{arch}.tar.xz".format(
                version = ZIG_VERSION,
                arch = arch,
            ),
            sha256 = config.sha256,
            build_file_content = ZLS_BUILD_FILE_CONTENT,
        )
    return mctx.extension_metadata(
        reproducible = True,
        root_module_direct_deps = "all",
        root_module_direct_dev_deps = [],
    )

# Define the ZLS repository extension
zls_repo = module_extension(implementation = _zls_repo_impl)

# Function to create toolchain targets for each architecture
def create_zls_toolchain_targets(name):
    for arch, config in ZLS_ARCH_CONFIG.items():
        native.toolchain(
            name = "toolchain_{}".format(arch),
            exec_compatible_with = config.exec_compatible_with,
            target_compatible_with = config.exec_compatible_with,
            toolchain = "@zls_{}//:toolchain".format(arch),
            toolchain_type = "//third_party/zls:toolchain_type",
        )

## ZIG RUNNER

# Template for creating Zig runner scripts
ZIG_RUNNER_TEMPLATE = """
#!/bin/bash

if [[ "${{1}}" == "build" ]]; then
    for arg in "${{@:2}}"; do
        if [[ "${{arg}}" == "-Dcmd="* ]]; then
            cd ${{BUILD_WORKSPACE_DIRECTORY}}
            exec ${{arg/-Dcmd=/}}
        fi
    done
fi

export ZIG_GLOBAL_CACHE_DIR="$(realpath {zig_cache})"
export ZIG_LOCAL_CACHE_DIR="$(realpath {zig_cache})"
export ZIG_LIB_DIR="$(realpath {zig_lib_path})"
exec {zig_exe_path} "${{@}}"
"""

# Implementation of the Zig runner rule
def _zig_runner_impl(ctx):
    zig_toolchain_info = ctx.toolchains["@rules_zig//zig:toolchain_type"].zigtoolchaininfo

    # print("zig_toolchain_info.zig_cache : ", zig_toolchain_info.zig_cache)
    # print("zig_toolchain_info.zig_exe_path : ", zig_toolchain_info.zig_exe_path)
    # print("zig_toolchain_info.zig_lib_path : ", zig_toolchain_info.zig_lib_path)

    zig_runner = ctx.actions.declare_file(ctx.label.name + ".zig_runner.sh")
    ctx.actions.write(
        output = zig_runner,
        content = ZIG_RUNNER_TEMPLATE.format(
            zig_cache = zig_toolchain_info.zig_cache,
            zig_exe_path = zig_toolchain_info.zig_exe_path,
            zig_lib_path = zig_toolchain_info.zig_lib_path,
        ),
    )

    return [
        DefaultInfo(
            files = depset([zig_runner]),
            executable = zig_runner,
            runfiles = ctx.runfiles(
                files = [zig_runner],
                transitive_files = depset(zig_toolchain_info.zig_files),
            ),
        ),
    ]

# Rule to define the Zig runner
zig_runner = rule(
    implementation = _zig_runner_impl,
    executable = True,
    toolchains = [
        "@rules_zig//zig:toolchain_type",
    ],
)

## ZLS RUNNER

_RUNNER_TPL = """
#!/bin/bash
set -eo pipefail

zig() {{
    if [[ "${{1}}" == "build" ]]; then
        for arg in "${{@:2}}"; do
            if [[ "${{arg}}" == "-Dcmd="* ]]; then
                cd ${{BUILD_WORKSPACE_DIRECTORY}}
                exec ${{arg/-Dcmd=/}}
            fi
        done
    fi

    export ZIG_GLOBAL_CACHE_DIR="$(realpath {zig_cache})"
    export ZIG_LOCAL_CACHE_DIR="$(realpath {zig_cache})"
    export ZIG_LIB_DIR="$(realpath {zig_lib_path})"
    exec {zig_exe_path} "${{@}}"
}}

zls() {{
    json_config="$(mktemp)"
    ZLS_ARGS=("--config-path" "${{json_config}}")

    cat <<EOF > ${{json_config}}
{{
    "zig_lib_path": "$(realpath {zig_lib_path})",
    "zig_exe_path": "$(realpath {zig_exe_path})",
    "global_cache_path": "$(realpath {zig_cache})"
}}
EOF

    while ((${{#}})); do
        case "${{1}}" in
        --config-path)
            cat "${{2}}" >> "${{json_config}}"
            {jq} -s add "${{json_config}}" > "${{json_config}}.tmp"
            mv "${{json_config}}.tmp" "${{json_config}}"
            shift 2
            ;;
        *)
            ZLS_ARGS+=("${{1}}")
            shift
            ;;
        esac
    done

    exec {zls} "${{ZLS_ARGS[@]}}"
}}

case $1 in
    zig)
        shift
        zig "${{@}}"
        ;;
    zls)
        shift
        zls "${{@}}"
        ;;
esac
"""

def _zls_runner_impl(ctx):
    jqinfo = ctx.toolchains["@aspect_bazel_lib//lib:jq_toolchain_type"].jqinfo
    zigtoolchaininfo = ctx.toolchains["@rules_zig//zig:toolchain_type"].zigtoolchaininfo
    zlsinfo = ctx.toolchains["@//third_party/zls:toolchain_type"].zls_info
    print(zlsinfo.bin.short_path)

    zls_runner = ctx.actions.declare_file(ctx.label.name + ".zls_runner.sh")
    ctx.actions.write(zls_runner, _RUNNER_TPL.format(
        jq = jqinfo.bin.short_path,
        zig_cache = zigtoolchaininfo.zig_cache,
        zig_exe_path = zigtoolchaininfo.zig_exe_path,
        zig_lib_path = zigtoolchaininfo.zig_lib_path,
        zls = zlsinfo.bin.short_path,
    ))

    return [
        DefaultInfo(
            files = depset([zls_runner]),
            executable = zls_runner,
            runfiles = ctx.runfiles(
                files = [
                    ctx.executable.zig,
                    jqinfo.bin,
                    zlsinfo.bin,
                ],
                transitive_files = zigtoolchaininfo.zig_files,
            ),
        ),
    ]

zls_runner = rule(
    implementation = _zls_runner_impl,
    attrs = {
        "zig": attr.label(mandatory = True, executable = True, cfg = "exec"),
    },
    executable = True,
    toolchains = [
        "@rules_zig//zig:toolchain_type",
        "@aspect_bazel_lib//lib:jq_toolchain_type",
        "//third_party/zls:toolchain_type",
    ],
)
