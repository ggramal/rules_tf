"""
This module contains test rules for tf validate.
"""

load("//tf/rules:providers.bzl", "TerraformInitInfo")

_TF_SCRIPT = """#!/usr/bin/env bash
set -o pipefail -o errexit -o nounset

{tar_path} -C {tf_dir} -xzf {tf_init_tar}
{tf_path} -chdir={tf_dir} validate
"""

def _impl(ctx):
    tf_init_tar = ctx.attr.init[TerraformInitInfo].init_archive

    tf_init_tar_path = tf_init_tar.path.removeprefix(ctx.bin_dir.path + "/")

    tar = ctx.toolchains["@aspect_bazel_lib//lib:tar_toolchain_type"]
    tf = ctx.toolchains["@rules_tf//:tf_toolchain_type"].runtime
    tar_path = tar.tarinfo.binary.path.replace("external","..",1)
    tf_path  = tf.exec.path.replace("external","..",1)

    launcher = ctx.actions.declare_file("validate_%s.sh" % ctx.label.name)

    script = _TF_SCRIPT.format(
        tf_init_tar = tf_init_tar_path,
        tar_path = "tar" if ctx.attr.system_utils else tar_path,
        tf_path = tf_path,
        tf_dir = ctx.label.package,
    )

    ctx.actions.write(
        output = launcher,
        content = script,
        is_executable = True,
    )

    deps = ctx.files.srcs + ctx.files.init + [
        tf.exec,
        tar.tarinfo.binary,
    ]

    return [DefaultInfo(
        runfiles = ctx.runfiles(files = deps),
        executable = launcher,
    )]

tf_validate_test = rule(
    implementation = _impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
        ),
        "init": attr.label(
            mandatory = True,
            providers = [TerraformInitInfo],
        ),
        "system_utils": attr.bool(
            default = False,
        ),
    },
    test = True,
    toolchains = [
        "@aspect_bazel_lib//lib:tar_toolchain_type",
        "@rules_tf//:tf_toolchain_type",
    ],
)
