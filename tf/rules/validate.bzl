"""
This module contains test rules for tf validate.
"""

load("//tf/rules:providers.bzl", "TerraformInitInfo")

def _impl(ctx):
    tf_init_tar = ctx.attr.init[TerraformInitInfo].init_archive

    tf_init_tar_path = "{dir}/{file}".format(
        dir = ctx.label.package,
        file = tf_init_tar.basename,
    )

    tar = ctx.toolchains["@aspect_bazel_lib//lib:tar_toolchain_type"]
    tf = ctx.toolchains["@rules_tf//:tf_toolchain_type"].runtime
    launcher = ctx.actions.declare_file("validate_%s.sh" % ctx.label.name)

    ctx.actions.expand_template(
        template = ctx.file._template,
        output = launcher,
        is_executable = True,
        substitutions = {
            "{{tf_init_tar}}": tf_init_tar_path,
            "{{tar_path}}": tar.tarinfo.binary.path,
            "{{tf_path}}": tf.exec.path,
            "{{tf_dir}}": ctx.label.package,
        },
    )

    deps = ctx.files.srcs + ctx.files.init + tar.default.files.to_list() + [
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
        "_template": attr.label(default = ":validate.sh.tpl", allow_single_file = True),
    },
    test = True,
    toolchains = [
        "@aspect_bazel_lib//lib:tar_toolchain_type",
        "@rules_tf//:tf_toolchain_type",
    ],
)
