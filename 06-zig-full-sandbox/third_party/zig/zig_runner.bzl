"""
This module provides a Bazel rule for generating a zig executable script.
"""

# Template for creating Zig runner scripts.
ZIG_RUNNER_TEMPLATE = """\
#!/bin/bash

# Handle the Zig 'build' command and execute the specified build target.
if [[ "${{1}}" == "build" ]]; then    
    for arg in "${{@:2}}"; do
        if [[ "${{arg}}" == "-Dcmd="* ]]; then
            cd "${{BUILD_WORKSPACE_DIRECTORY}}"
            exec "${{arg/-Dcmd=/}}"
        fi
    done
fi

export ZIG_GLOBAL_CACHE_DIR="$(realpath {zig_cache})"
export ZIG_LOCAL_CACHE_DIR="$(realpath {zig_cache})"
export ZIG_LIB_DIR="$(realpath {zig_lib_path})"
exec "{zig_exe_path}" "${{@}}"
"""

# Implementation of the Zig runner rule
def _zig_runner_impl(ctx):
    zig_toolchain_info = ctx.toolchains["@rules_zig//zig:toolchain_type"].zigtoolchaininfo
    zig_runner_file = ctx.actions.declare_file(ctx.label.name + ".sh")

    ctx.actions.write(
        output = zig_runner_file,
        content = ZIG_RUNNER_TEMPLATE.format(
            zig_cache = zig_toolchain_info.zig_cache,
            zig_exe_path = zig_toolchain_info.zig_exe_path,
            zig_lib_path = zig_toolchain_info.zig_lib_path,
        ),
    )

    return [
        DefaultInfo(
            files = depset([zig_runner_file]),
            executable = zig_runner_file,
            runfiles = ctx.runfiles(
                files = [zig_runner_file],
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
