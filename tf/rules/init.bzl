"""
This module contains build rules for tf init.
"""

load("//tf/rules:providers.bzl", "TerraformInitInfo")

def _impl(ctx):
    tar = ctx.toolchains["@aspect_bazel_lib//lib:tar_toolchain_type"]
    tf = ctx.toolchains["@rules_tf//:tf_toolchain_type"].runtime

    out = ctx.actions.declare_file("init.tar.gz")

    launcher = ctx.actions.declare_file("init_%s.sh" % ctx.label.name)

    ctx.actions.expand_template(
        template = ctx.file._template,
        output = launcher,
        is_executable = True,
        substitutions = {
            "{{out_tar}}": out.path,
            "{{tar_path}}": tar.tarinfo.binary.path,
            "{{tf_path}}": tf.exec.path,
            "{{tf_dir}}": ctx.label.package,
        },
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
        "_template": attr.label(default = ":init.sh.tpl", allow_single_file = True),
    },
    toolchains = [
        "@aspect_bazel_lib//lib:tar_toolchain_type",
        "@rules_tf//:tf_toolchain_type",
    ],
)
