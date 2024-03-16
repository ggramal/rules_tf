"""
This module contains build rules for tf init.
"""

load("//tf/rules:providers.bzl", "TerraformInitInfo")

_TF_INIT_SCRIPT = """#!/usr/bin/env bash
set -o pipefail -o errexit -o nounset

{tf_cmd}
{tar_path} -C {tf_dir} -czf {out_tar} .terraform .terraform.lock.hcl
"""

def _impl(ctx):
    tar = ctx.toolchains["@aspect_bazel_lib//lib:tar_toolchain_type"]
    tf = ctx.toolchains["@rules_tf//:tf_toolchain_type"].runtime

    backend = "false"
    if ctx.attr.backend:
        backend = "true"

    tf_cmd = "{tf_path} -chdir={tf_dir} init -backend={tf_backend} > /dev/null"

    if ctx.attr.verbose:
        tf_cmd = "{tf_path} -chdir={tf_dir} init -backend={tf_backend}"

    out = ctx.actions.declare_file("init_%s.tar.gz" % ctx.label.name)

    launcher = ctx.actions.declare_file("init_%s.sh" % ctx.label.name)

    script = _TF_INIT_SCRIPT.format(
        out_tar = out.path,
        tar_path = tar.tarinfo.binary.path,
        tf_cmd = tf_cmd.format(
	    tf_path = tf.exec.path,
	    tf_dir  = ctx.label.package,
	    tf_backend = backend,
	),
        tf_dir = ctx.label.package,
    )

    ctx.actions.write(
        output = launcher,
        content = script,
        is_executable = True,
    )

    deps = depset(direct = ctx.files.srcs + tar.default.files.to_list())
    ctx.actions.run(
        executable = launcher,
        inputs = deps,
        use_default_shell_env = True,
        tools = [tar.tarinfo.binary, tf.exec],
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
    },
    toolchains = [
        "@aspect_bazel_lib//lib:tar_toolchain_type",
        "@rules_tf//:tf_toolchain_type",
    ],
)
