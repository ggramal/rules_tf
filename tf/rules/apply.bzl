"""
This module contains run rules for tf apply.
"""

load("//tf/rules:providers.bzl", "TerraformInitInfo", "TerraformPlanInfo")

_TF_APPLY_SCRIPT = """#!/usr/bin/env bash

{tar_path} -C {tf_dir} -xzf {tf_init_tar}
{tf_path} -chdir={tf_dir} apply -parallelism={tf_parallelism} {tf_plan}

TF_EXIT=$?

# Invalidate plan build cache.
# This is needed because after apply 
# generated plan file becomes stale 
# and output of tf_plan target is cached
# so it will not be rebuilt
{coreutils_path} rm -f $({coreutils_path} readlink {tf_dir}/{tf_plan})

exit $TF_EXIT
"""

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

    script = _TF_APPLY_SCRIPT.format(
        tf_init_tar = tf_init_tar_path,
        tar_path = "tar" if ctx.attr.system_utils else tar.tarinfo.binary.path,
        tf_path = tf.exec.path,
        tf_parallelism = ctx.attr.parallelism,
        tf_dir = ctx.label.package,
        tf_plan = tf_plan_file.basename,
        coreutils_path = "" if ctx.attr.system_utils else coreutils.bin.path,
    )

    ctx.actions.write(
        output = launcher,
        content = script,
        is_executable = True,
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
        "system_utils": attr.bool(
            default = True,
        ),
    },
    toolchains = [
        "@aspect_bazel_lib//lib:tar_toolchain_type",
        "@rules_tf//:tf_toolchain_type",
        "@aspect_bazel_lib//lib:coreutils_toolchain_type",
    ],
    executable = True,
)
