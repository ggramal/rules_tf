"""
This module contains build rules for tf plan.
"""

load("//tf/rules:providers.bzl", "TerraformInitInfo", "TerraformPlanInfo")

_TF_SCRIPT = """#!/usr/bin/env bash
set -o pipefail -o errexit -o nounset

readonly TF_OUT_FILE=$({coreutils_path} basename {tf_out})

{tar_path} -C {tf_dir} -xzf {tf_init_tar}
{tf_cmd}
{coreutils_path} cp {tf_dir}/$TF_OUT_FILE {tf_out}
"""

def _impl(ctx):
    tf_init_tar = ctx.attr.init[TerraformInitInfo].init_archive

    tar = ctx.toolchains["@aspect_bazel_lib//lib:tar_toolchain_type"]
    coreutils = ctx.toolchains["@aspect_bazel_lib//lib:coreutils_toolchain_type"].coreutils_info
    tf = ctx.toolchains["@rules_tf//:tf_toolchain_type"].runtime
    out = ctx.actions.declare_file(
        "{name}".format(name = ctx.label.name),
    )

    launcher = ctx.actions.declare_file("plan_%s.sh" % ctx.label.name)

    tf_cmd = "{tf_path} -chdir={tf_dir} plan -out=$TF_OUT_FILE -parallelism={tf_parallelism}"

    if ctx.attr.silent_refresh:
        tf_cmd = "{tf_path} -chdir={tf_dir} plan -out=$TF_OUT_FILE -parallelism={tf_parallelism} > /dev/null && {tf_path} -chdir={tf_dir} show $TF_OUT_FILE || exit $?"

    script = _TF_SCRIPT.format(
        tf_init_tar = tf_init_tar.path,
        tar_path = "tar" if ctx.attr.system_utils else tar.tarinfo.binary.path,
        tf_path = tf.exec.path,
        tf_cmd = tf_cmd.format(
            tf_parallelism = ctx.attr.parallelism,
            tf_path = tf.exec.path,
            tf_dir = ctx.label.package,
        ),
        tf_dir = ctx.label.package,
        tf_out = out.path,
        coreutils_path = "" if ctx.attr.system_utils else coreutils.bin.path,
    )

    ctx.actions.write(
        output = launcher,
        content = script,
        is_executable = True,
    )

    deps = depset(
        ctx.files.srcs +
        ctx.files.init +
        tar.default.files.to_list(),
    )

    ctx.actions.run(
        executable = launcher,
        use_default_shell_env = True,
        inputs = deps,
        tools = [
            tar.tarinfo.binary,
            tf.exec,
            coreutils.bin,
        ],
        outputs = [out],
        mnemonic = "TerraformPlan",
    )

    return [
        DefaultInfo(files = depset([out])),
        TerraformPlanInfo(plan = out),
    ]

tf_plan = rule(
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
        "parallelism": attr.string(
            default = "10",
        ),
        "silent_refresh": attr.bool(
            default = True,
        ),
        "system_utils": attr.bool(
            default = True,
        ),
    },
    toolchains = [
        "@aspect_bazel_lib//lib:tar_toolchain_type",
        "@aspect_bazel_lib//lib:coreutils_toolchain_type",
        "@rules_tf//:tf_toolchain_type",
    ],
)
