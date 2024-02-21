"""
This module contains run rules for tf apply.
"""

load("//tf/rules:providers.bzl", "TerraformInitInfo", "TerraformPlanInfo")

def _impl(ctx):
    tf_init_tar = ctx.attr.init[TerraformInitInfo].init_archive
    tf_plan_file = ctx.attr.plan[TerraformPlanInfo].plan

    tf_init_tar_path = "{dir}/{file}".format(
        dir = ctx.label.package,
        file = tf_init_tar.basename,
    )

    tar = ctx.toolchains["@aspect_bazel_lib//lib:tar_toolchain_type"]
    coreutils = ctx.toolchains["@aspect_bazel_lib//lib:coreutils_toolchain_type"].coreutils_info
    tf = ctx.toolchains["@rules_tf//:tf_toolchain_type"].runtime

    launcher = ctx.actions.declare_file("apply_%s.sh" % ctx.label.name)

    ctx.actions.expand_template(
        template = ctx.file._template,
        output = launcher,
        is_executable = True,
        substitutions = {
            "{{tf_init_tar}}": tf_init_tar_path,
            "{{tar_path}}": tar.tarinfo.binary.path,
            "{{tf_path}}": tf.exec.path,
            "{{tf_parallelism}}": ctx.attr.parallelism,
            "{{tf_dir}}": ctx.label.package,
            "{{tf_plan}}": tf_plan_file.basename,
            "{{coreutils_path}}": coreutils.bin.path,
        },
    )

    deps = ctx.files.srcs + ctx.files.init + ctx.files.plan + tar.default.files.to_list() + [
        tf.exec,
        tar.tarinfo.binary,
        coreutils.bin,
    ]

    return [DefaultInfo(
        runfiles = ctx.runfiles(files = deps),
        executable = launcher,
    )]

tf_apply = rule(
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
        "plan": attr.label(
            mandatory = True,
            providers = [TerraformPlanInfo],
        ),
        "parallelism": attr.string(
            default = "10",
        ),
        "_template": attr.label(default = ":apply.sh.tpl", allow_single_file = True),
    },
    toolchains = [
        "@aspect_bazel_lib//lib:tar_toolchain_type",
        "@rules_tf//:tf_toolchain_type",
        "@aspect_bazel_lib//lib:coreutils_toolchain_type",
    ],
    executable = True,
)
