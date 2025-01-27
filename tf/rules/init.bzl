"""
This module contains build rules for tf init.
"""

load("//tf/rules:providers.bzl", "TerraformInitInfo")

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
{tf_cmd}
{tar_path} -C {tf_dir} -czf {out_tar} .terraform .terraform.lock.hcl
"""

def _impl(ctx):
    tar = ctx.toolchains["@aspect_bazel_lib//lib:tar_toolchain_type"]
    tf = ctx.toolchains["@rules_tf//:tf_toolchain_type"].runtime
    coreutils = ctx.toolchains["@aspect_bazel_lib//lib:coreutils_toolchain_type"].coreutils_info

    backend = "false"
    if ctx.attr.backend:
        backend = "true"

    tf_cmd = "{tf_path} -chdir={tf_dir} init -backend={tf_backend}"

    if ctx.attr.backend_configs:
        for k, v in ctx.attr.backend_configs.items():
            tf_cmd = tf_cmd + ' -backend-config="{}={}"'.format(k, v)

    if ctx.attr.verbose == False:
        tf_cmd = tf_cmd + " > /dev/null"

    out = ctx.actions.declare_file("init_%s.tar.gz" % ctx.label.name)

    launcher = ctx.actions.declare_file("init_%s.sh" % ctx.label.name)

    script = _TF_SCRIPT.format(
        bin_dir = ctx.bin_dir.path,
        coreutils_path = "" if ctx.attr.system_utils else coreutils.bin.path,
        tf_cmd = tf_cmd.format(
            tf_path = tf.exec.path,
            tf_dir = ctx.label.package,
            tf_backend = backend,
        ),
        tar_path = "tar" if ctx.attr.system_utils else tar.tarinfo.binary.path,
        out_tar = out.path,
        tf_dir = ctx.label.package,
    )

    ctx.actions.write(
        output = launcher,
        content = script,
        is_executable = True,
    )

    deps = depset(direct = ctx.files.srcs)
    ctx.actions.run(
        executable = launcher,
        inputs = deps,
        use_default_shell_env = True,
        tools = [tar.tarinfo.binary, tf.exec, coreutils.bin],
        outputs = [out],
        mnemonic = "TerraformInitialize",
    )

    return [
        DefaultInfo(files = depset([out])),
        TerraformInitInfo(init_archive = out),
    ]

tf_init = rule(
    implementation = _impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
        ),
        "backend": attr.bool(
            default = True,
        ),
        "verbose": attr.bool(
            default = False,
        ),
        "system_utils": attr.bool(
            default = False,
        ),
        "backend_configs": attr.string_dict(
            default = {},
        ),
    },
    toolchains = [
        "@aspect_bazel_lib//lib:tar_toolchain_type",
        "@aspect_bazel_lib//lib:coreutils_toolchain_type",
        "@rules_tf//:tf_toolchain_type",
    ],
)
