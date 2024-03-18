# rules_tf 

Bazel rules for running terraform plan/apply/validate/fmt and terraform binary itself


## Installation

To import rules_tf in your project, you first need to add it to your `MODULE.bazel` file:

```python
bazel_dep(name = "rules_tf")
git_override(
    module_name = "rules_tf",
    remote      = "https://github.com/ggramal/rules_tf",
    commit      = "...",
)

tf = use_extension("@rules_tf//tf:extensions.bzl", "tf")
tf.toolchain(version = "1.5.4")
use_repo(tf, "tf_executable")
```

## Usage

Once imported you can use the tf rules in your `BUILD` files like so

```python
#path/to/tf/BUILD

load(
    "@rules_tf//tf:defs.bzl",
    "tf_apply",
    "tf_init",
    "tf_plan",
)

filegroup(
    name = "srcs",
    srcs = glob(
        [
            "*.tf",
            "*.tfvars",
        ],
    )
    visibility = ["//visibility:__pkg__"],
)

tf_init(
    name = "init",
    srcs = [
        "main.tf", #Files where modules are defined
    ],
)

tf_plan(
    name = "plan",
    srcs = [":srcs"],
    init = ":init",
    parallelism = "10",
)

tf_apply(
    name = "apply",
    srcs = [":srcs"],
    init = ":init",
    plan = ":plan",
)
```

Then to run init and plan and cache the results you can do

```
bazel build //...
```

Or 

```
bazel build //path/to/tf:plan
```

`tf_plan` rules generate plan files (`terraform plan -out=./plan`) that can be then passed to `tf_apply`. To run apply use `bazel run //path/to/tf:apply`


**IMPORTANT NOTE**: plan files are cached by bazel. If other member of your team runs `terraform apply` or `bazel build //... && bazel run //path/to/tf:apply` plan file will become stale and your local `bazel run //path/to/tf:apply` will always fail until you either

* run `bazel clean`
* edit files you have passed in `srcs`

To mitigate this `tf_apply` rule always tries to delete the `tf_plan` output file thus invalidating `tf_plan` cache

### validate/fmt

To run validate/fmt tests add this to your BUILD file

```
#path/to/tf/BUILD

load(
    "@rules_tf//tf:defs.bzl",
    ....
    "tf_fmt_test",
    "tf_init",
    "tf_validate_test",
)

filegroup(
    name = "srcs",
    srcs = glob(
        [
            "*.tf",
            "*.tfvars",
        ],
    )
    visibility = ["//visibility:__pkg__"],
)

tf_validate_test(
    name = "validate",
    srcs = [":srcs"],
    init = ":init",
)

tf_fmt_test(
    name = "fmt",
    srcs = [":srcs"],
)

tf_init(
    name = "init",
    srcs = [
        "main.tf", #Files where modules are defined
    ],
)
```

Then you can run tests using `bazel test //...` or `bazel test //path/to/tf:*`

### Using local modules

If you have local modules (dir path in `source`) you can use this approach

```python
#modules/BUILD

filegroup(
    name = "modules",
    srcs = glob(["**"]), #Add all files in all subfolder in modules/ dir
    visibility = ["//visibility:public"],
)
```

```python
#path/to/tf/BUILD
load(
    "@rules_tf//tf:defs.bzl",
    "tf_apply",
    "tf_fmt_test",
    "tf_init",
    "tf_plan",
    "tf_validate_test",
)

filegroup(
    name = "srcs",
    srcs = glob(
        [
            "*.tf",
            "*.tfvars",
        ],
    ) + [
        "//modules", #pass filegroup from modules dir
    ],
    visibility = ["//visibility:__pkg__"],
)

tf_validate_test(
    name = "validate",
    srcs = [":srcs"],
    init = ":init",
)

tf_fmt_test(
    name = "fmt",
    srcs = [":srcs"],
)

tf_init(
    name = "init",
    srcs = [
        "main.tf",
        "//modules", #pass filegroup from modules dir
    ],
)

tf_plan(
    name = "plan",
    srcs = [":srcs"],
    init = ":init",
    parallelism = "100",
)

tf_apply(
    name = "apply",
    srcs = [":srcs"],
    init = ":init",
    plan = ":plan",
)
```

### Running tf binary

It is possible to run arbitrary tf commands. This is a BUILD example

```python
#path/to/tf/BUILD

load(
    "@rules_tf//tf:defs.bzl",
    "tf_binary",
    "tf_init",
)

filegroup(
    name = "srcs",
    srcs = glob(
        [
            "*.tf",
            "*.tfvars",
        ],
    ) + [
        "//modules",
    ],
    visibility = ["//visibility:__pkg__"],
)

tf_init(
    name = "init",
    srcs = [
        "main.tf",
        "//modules",
    ],
)

tf_binary(
    name = "tf",
    srcs = [":srcs"],
    init = ":init",
)

```

then

`bazel run //path/to/tf:tf -- plan -output $(pwd)/plan` 

`bazel run //path/to/tf:tf -- import '...'`

### Terraform backend

`terraform init` needs to initialize the backend (state storage). For this, user executing the command needs access to tf backend. Its very common to store secrets in terraform state. So in most cases you should restrict access to your state file. Nevertheless developers should be able to run commands like `bazel test //...` etc. In order to achive that You can specify `backend = False` in `tf_init` rule like so

```python
load(
    "@rules_tf//tf:defs.bzl",
    "tf_apply",
    "tf_binary",
    "tf_fmt_test",
    "tf_init",
    "tf_plan",
    "tf_validate_test",
)

filegroup(
    name = "srcs",
    srcs = glob(
        [
            "*.tf",
            "*.tfvars",
        ],
    ) + [
        "//infra/terraform/modules",
    ],
    visibility = ["//visibility:__pkg__"],
)

tf_validate_test(
    name = "validate",
    srcs = [":srcs"],
    init = ":init_for_tests",
)

tf_fmt_test(
    name = "fmt",
    srcs = [":srcs"],
)

tf_init(
    name = "init_for_tests",
    srcs = [
        "main.tf",
        "//infra/terraform/modules",
    ],
    backend = False,
)

tf_init(
    name = "init",
    srcs = [
        "main.tf",
        "//infra/terraform/modules",
    ],
    tags = ["manual"],
)

tf_plan(
    name = "plan",
    srcs = [":srcs"],
    init = ":init",
    parallelism = "100",
    tags = ["manual"],
)

tf_apply(
    name = "apply",
    srcs = [":srcs"],
    init = ":init",
    plan = ":plan",
    tags = ["manual"],
)

tf_binary(
    name = "tf",
    srcs = [":srcs"],
    init = ":init",
    tags = ["manual"],
)
```
