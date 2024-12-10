# v0.5.0

features:
  * `tf_fmt` rule


# v0.4.1

fixes:
  * fixed issue when executable/test rules are referencing `init` from another package https://github.com/ggramal/rules_tf/issues/5


# v0.4.0

changes:
  * `tf_init`/`tf_plan` rules now copy files from bazel-out to exec path https://github.com/ggramal/rules_tf/issues/1
  * bazel lint targets are renamed to `lint/lint_check`
  * `MODULE.bazel.lock` file is removed
  * default value of `system_utils` attribute for all rules is now `False`. Which means tar/coreutils toolchains are being used
  * rule name attribute is added to `toolchain` module extension tag
  * dependency versions are updated
    * `aspect_bazel_lib` - 2.5.0 -> 2.9.4
    * `plaforms` - `0.0.8` -> `0.0.10`
    * `buildifier_prebuilt` - `6.4.0` -> `7.3.1`
