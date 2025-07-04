load("@bazel_skylib//lib:selects.bzl", "selects")
load("@envoy//bazel/wasm:wasm.bzl", "envoy_wasm_cc_binary")

licenses(["notice"])  # Apache 2

exports_files(["module.rst", "module.yaml"])

envoy_wasm_cc_binary(
    name = "hello.wasm",
    srcs = ["hello.cc"],
)

filegroup(
    name = "files",
    srcs = glob(["**/*"], exclude = ["module.rst", "module.yaml", "BUILD"]),
    visibility = ["//visibility:public"],
)

alias(
    name = "module",
    actual = ":hello.wasm",
    visibility = ["//visibility:public"],
)
