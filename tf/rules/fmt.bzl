"""
This module contains test rules for tf fmt.
"""

def _impl(ctx):
    launcher = ctx.actions.declare_file("fmt_%s.sh" % ctx.label.name)
    tf = ctx.toolchains["@rules_tf//:tf_toolchain_type"].runtime

    args = "fmt -recursive -check"
    if ctx.attr.generator_function == "tf_fmt":
        args = "fmt -recursive {check}".format(
            check = "" if ctx.attr.fix else "-check",
        )

    cmd = "{tf} {args}".format(
        tf = tf.exec.path,
        args = args,
    )

    ctx.actions.write(
        output = launcher,
        content = cmd,
        is_executable = True,
    )

    deps = ctx.files.srcs + [
        tf.exec,
    ]

    return [DefaultInfo(
        runfiles = ctx.runfiles(files = deps),
        executable = launcher,
    )]

tf_fmt_test = rule(
    implementation = _impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
        ),
    },
    test = True,
    toolchains = [
        "@rules_tf//:tf_toolchain_type",
    ],
)

tf_fmt = rule(
    implementation = _impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
        ),
        "fix": attr.bool(
            mandatory = True,
        ),
    },
    executable = True,
    toolchains = [
        "@rules_tf//:tf_toolchain_type",
    ],
)
