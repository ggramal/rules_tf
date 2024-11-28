* v0.4.0

changes:
  * `tf_init`/`tf_plan` rules now copy files from bazel-out to exec path https://github.com/ggramal/rules_tf/issues/1
  * bazel lint targets are renamed to `lint/lint_check`
  * `MODULE.bazel.lock` file is removed
  * default value of `system_utils` attribute for all rules is now `False`. Which means tar/coreutils toolchains are being used
  * rule name attribute is added to `toolchain` module extension tag
