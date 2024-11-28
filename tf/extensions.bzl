"""
module extensions
"""

load("@rules_tf//tf:utils.bzl", "detect_host_platform")
load("@rules_tf//tf/toolchains/terraform:toolchain.bzl", "terraform_download")

def _impl(ctx):
    host_os, host_arch = detect_host_platform(ctx)

    for module in ctx.modules:
        for index, tag in enumerate(module.tags.toolchain):  # buildifier: disable=unused-variable
            terraform_download(
                name = tag.name,
                version = tag.version,
                os = host_os,
                arch = host_arch,
            )

_version = tag_class(
    attrs = {
        "version": attr.string(mandatory = True),
        "name": attr.string(default = "tf_executable")
    },
)

tf = module_extension(
    implementation = _impl,
    tag_classes = {
        "toolchain": _version,
    },
    os_dependent = True,
    arch_dependent = True,
)
