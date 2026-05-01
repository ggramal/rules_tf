"""
This module contains build rules for tf_output .
"""

load("//tf/rules:providers.bzl", "TerraformInitInfo", "TerraformOutputInfo")

_TF_SCRIPT = """#!/usr/bin/env bash
set -o pipefail -o errexit -o nounset

#There are some cases in which we would
#like to use .tf files after they are processed
#by other targets (for example setting tf backend
#attributes). By design for build rules like init,plan,
#those files are placed under bazel-out/cpu-compilation_mode/bin
#In order to use those .tf files we need to put
#them inside execpath

{coreutils_path} cp -r {bin_dir}/* .

{tar_path} -C {tf_dir} -xzf {tf_init_tar}
{tf_cmd}
"""

def _impl(ctx):
    tf_init_tar = ctx.attr.init[TerraformInitInfo].init_archive

    tar = ctx.toolchains["@aspect_bazel_lib//lib:tar_toolchain_type"]
    coreutils = ctx.toolchains["@aspect_bazel_lib//lib:coreutils_toolchain_type"].coreutils_info
    tf = ctx.toolchains["@rules_tf//:tf_toolchain_type"].runtime
    out = ctx.actions.declare_file(
        "{name}.json".format(name = ctx.label.name),
    )

    launcher = ctx.actions.declare_file("output_%s.sh" % ctx.label.name)

    tf_cmd = "{tf_path} -chdir={tf_dir} output -json"

    if ctx.attr.std_out:
        tf_cmd = tf_cmd + " | {coreutils_path} tee {tf_out}"
    else:
        tf_cmd = tf_cmd + " > {tf_out}"

    script = _TF_SCRIPT.format(
        bin_dir = ctx.bin_dir.path,
        tf_init_tar = tf_init_tar.path,
        tar_path = "tar" if ctx.attr.system_utils else tar.tarinfo.binary.path,
        tf_cmd = tf_cmd.format(
            tf_path = tf.exec.path,
            tf_dir = ctx.label.package,
            tf_out = out.path,
            coreutils_path = "" if ctx.attr.system_utils else coreutils.bin.path,
        ),
        tf_dir = ctx.label.package,
        coreutils_path = "" if ctx.attr.system_utils else coreutils.bin.path,
    )

    ctx.actions.write(
        output = launcher,
        content = script,
        is_executable = True,
    )

    deps = depset(
        ctx.files.srcs +
        ctx.files.init,
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
        mnemonic = "TerraformOutput",
    )

    return [
        DefaultInfo(files = depset([out])),
        TerraformOutputInfo(output = out),
    ]

tf_output = rule(
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
        "std_out": attr.bool(
            doc = "Output data to standard output",
            default = False,
        ),
        "system_utils": attr.bool(
            default = False,
        ),
    },
    toolchains = [
        "@aspect_bazel_lib//lib:tar_toolchain_type",
        "@aspect_bazel_lib//lib:coreutils_toolchain_type",
        "@rules_tf//:tf_toolchain_type",
    ],
)
