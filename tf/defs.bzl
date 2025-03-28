"""
Publicly exposed module definitions
"""

load("@rules_tf//tf/rules:apply.bzl", _tf_apply = "tf_apply")
load("@rules_tf//tf/rules:binary.bzl", _tf_binary = "tf_binary")
load("@rules_tf//tf/rules:fmt.bzl", _tf_fmt = "tf_fmt", _tf_fmt_test = "tf_fmt_test")
load("@rules_tf//tf/rules:init.bzl", _tf_init = "tf_init")
load("@rules_tf//tf/rules:plan.bzl", _tf_plan = "tf_plan")
load("@rules_tf//tf/rules:validate.bzl", _tf_validate_test = "tf_validate_test")

tf_init = _tf_init
tf_plan = _tf_plan
tf_apply = _tf_apply
tf_binary = _tf_binary

#we wrap tf_fmt in order to use
#generator_function in fmt _impl
#funciton
def tf_fmt(**kwargs):
    _tf_fmt(**kwargs)

def tf_validate_test(size = "small", **kwargs):
    _tf_validate_test(size = size, **kwargs)

def tf_fmt_test(size = "small", **kwargs):
    _tf_fmt_test(size = size, **kwargs)
