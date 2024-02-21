"""
This module contains build rules for tf plan.
"""

load("//tf/rules:providers.bzl", "TerraformInitInfo", "TerraformPlanInfo")

def _impl(ctx):
    tf_init_tar = ctx.attr.init[TerraformInitInfo].init_archive

    tar = ctx.toolchains["@aspect_bazel_lib//lib:tar_toolchain_type"]
    coreutils = ctx.toolchains["@aspect_bazel_lib//lib:coreutils_toolchain_type"].coreutils_info
    tf = ctx.toolchains["@rules_tf//:tf_toolchain_type"].runtime
    out = ctx.actions.declare_file(
        "{name}".format(name = ctx.label.name),
    )

    launcher = ctx.actions.declare_file("plan_%s.sh" % ctx.label.name)

    ctx.actions.expand_template(
        template = ctx.file._template,
        output = launcher,
        is_executable = True,
        substitutions = {
            "{{tf_init_tar}}": tf_init_tar.path,
            "{{tar_path}}": tar.tarinfo.binary.path,
            "{{tf_path}}": tf.exec.path,
            "{{tf_parallelism}}": ctx.attr.parallelism,
            "{{tf_dir}}": ctx.label.package,
            "{{tf_out}}": out.path,
            "{{coreutils_path}}": coreutils.bin.path,
        },
    )

    deps = depset(
        ctx.files.srcs +
        ctx.files.init +
        tar.default.files.to_list(),
    )

    ctx.actions.run(
        executable = launcher,
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
        "_template": attr.label(default = ":plan.sh.tpl", allow_single_file = True),
    },
    toolchains = [
        "@aspect_bazel_lib//lib:tar_toolchain_type",
        "@aspect_bazel_lib//lib:coreutils_toolchain_type",
        "@rules_tf//:tf_toolchain_type",
    ],
)
