"""
This module contains run rules for running tf.
"""

load("//tf/rules:providers.bzl", "TerraformInitInfo")

_TF_SCRIPT = """#!/usr/bin/env bash
set -o pipefail -o errexit -o nounset

{tar_cmd}
{tf_cmd} "$@"
"""

def _impl(ctx):
    tar = ctx.toolchains["@aspect_bazel_lib//lib:tar_toolchain_type"]
    tar_path = tar.tarinfo.binary.path.replace("external","..",1)
    tar_cmd = ""
    tf_init_tar_path = ""

    if ctx.attr.init:
        tf_init_tar = ctx.attr.init[TerraformInitInfo].init_archive
        tf_init_tar_path = tf_init_tar.path.removeprefix(ctx.bin_dir.path + "/")
        tar_cmd = "{tar_path} -C {tf_dir} -xzf {tf_init_tar_path}"

    tf = ctx.toolchains["@rules_tf//:tf_toolchain_type"].runtime
    tf_path = tf.exec.path.replace("external","..",1)

    tf_cmd = "{tf_path}"

    if ctx.attr.chdir:
        tf_cmd = "{tf_path} -chdir={tf_dir}"

    launcher = ctx.actions.declare_file("bin_%s.sh" % ctx.label.name)

    script = _TF_SCRIPT.format(
        tar_cmd = tar_cmd.format(
            tf_init_tar_path = tf_init_tar_path,
            tar_path = "tar" if ctx.attr.system_utils else tar_path,
            tf_dir = ctx.label.package,
        ),
        tf_cmd = tf_cmd.format(
            tf_path = tf_path,
            tf_dir = ctx.label.package,
        ),
    )

    ctx.actions.write(
        output = launcher,
        content = script,
        is_executable = True,
    )

    deps = ctx.files.srcs + ctx.files.init + tar.default.files.to_list() + [
        tf.exec,
        tar.tarinfo.binary,
    ]

    return [DefaultInfo(
        runfiles = ctx.runfiles(files = deps),
        executable = launcher,
    )]

tf_binary = rule(
    implementation = _impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
        ),
        "init": attr.label(
            providers = [TerraformInitInfo],
        ),
        "system_utils": attr.bool(
            default = False,
        ),
        "chdir": attr.bool(
            default = True,
            doc = "Change to package dirictory when executing tf",
        ),
    },
    toolchains = [
        "@aspect_bazel_lib//lib:tar_toolchain_type",
        "@rules_tf//:tf_toolchain_type",
    ],
    executable = True,
)
