"""
Public toolchain definitions
"""

load("@rules_tf//tf/toolchains/terraform:toolchain.bzl", _terraform_toolchain = "terraform_toolchain")

platforms = {
    "linux_amd64": {
        "exec_compatible_with": [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        "target_compatible_with": [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
    },
    "linux_arm64": {
        "exec_compatible_with": [
            "@platforms//os:linux",
            "@platforms//cpu:arm64",
        ],
        "target_compatible_with": [
            "@platforms//os:linux",
            "@platforms//cpu:arm64",
        ],
    },
    "darwin_amd64": {
        "exec_compatible_with": [
            "@platforms//os:osx",
            "@platforms//cpu:x86_64",
        ],
        "target_compatible_with": [
            "@platforms//os:osx",
            "@platforms//cpu:x86_64",
        ],
    },
    "darwin_arm64": {
        "exec_compatible_with": [
            "@platforms//os:osx",
            "@platforms//cpu:aarch64",
        ],
        "target_compatible_with": [
            "@platforms//os:osx",
            "@platforms//cpu:aarch64",
        ],
    },
}

terraform_toolchain = _terraform_toolchain
