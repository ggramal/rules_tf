load("@rules_tf//tf:toolchains.bzl", "terraform_toolchain", "platforms")

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "terraform",
    srcs = ["terraform/terraform"],
    visibility = ["//visibility:public"]
)

terraform_toolchain(
   name = "tf_toolchain",
   tf = ":terraform",
)

toolchain(
  name = "toolchain",
  exec_compatible_with = platforms["{os}_{arch}"]["exec_compatible_with"],
  target_compatible_with = platforms["{os}_{arch}"]["target_compatible_with"],
  toolchain = ":tf_toolchain",
  toolchain_type = "@rules_tf//:tf_toolchain_type",
  visibility = ["//visibility:public"],
)
