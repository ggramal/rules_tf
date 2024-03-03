"""
This module contains run rules for running tf.
"""

load("//tf/rules:providers.bzl", "TerraformInitInfo")

_TF_BINARY_SCRIPT = """
#!/usr/bin/env bash
set -o pipefail -o errexit -o nounset

{tar_path} -C {tf_dir} -xzf {tf_init_tar}
{tf_path} -chdir={tf_dir} $@
"""

def _impl(ctx):
    tf_init_tar = ctx.attr.init[TerraformInitInfo].init_archive

    tf_init_tar_path = "{dir}/{file}".format(
        dir = ctx.label.package,
        file = tf_init_tar.basename,
    )

    tar = ctx.toolchains["@aspect_bazel_lib//lib:tar_toolchain_type"]
    tf = ctx.toolchains["@rules_tf//:tf_toolchain_type"].runtime

    launcher = ctx.actions.declare_file("bin_%s.sh" % ctx.label.name)

    script = _TF_BINARY_SCRIPT.format(
        tf_init_tar = tf_init_tar_path,
        tar_path = tar.tarinfo.binary.path,
        tf_dir = ctx.label.package,
        tf_path = tf.exec.path,
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
            mandatory = True,
            providers = [TerraformInitInfo],
        ),
    },
    toolchains = [
        "@aspect_bazel_lib//lib:tar_toolchain_type",
        "@rules_tf//:tf_toolchain_type",
    ],
    executable = True,
)
