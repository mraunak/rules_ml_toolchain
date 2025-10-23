package(default_visibility = ["//visibility:public"])

load("@rules_cc//cc:defs.bzl", "cc_toolchain")
load("@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl", "cc_toolchain_import")
load("@rules_ml_toolchain//third_party/rules_cc_toolchain/features:features.bzl", "cc_toolchain_import_feature")
load("@rules_ml_toolchain//third_party/rules_cc_toolchain:toolchain_config.bzl", "cc_toolchain_config")
load("@local_config_sycl//:nonhermetic_includes.bzl", "NONHERMETIC_INCLUDES")

# Tools
alias(name = "clang",   actual = "compiler/2025.1/bin/compiler/clang")
alias(name = "clang++", actual = "compiler/2025.1/bin/compiler/clang++")
alias(name = "ld",      actual = "compiler/2025.1/bin/compiler/ld.lld")
alias(name = "ar",      actual = "compiler/2025.1/bin/compiler/llvm-ar")

# Built-in include roots (Bazel builtin, not flags)
cc_toolchain_import(
    name = "includes",
    builtin_includes = NONHERMETIC_INCLUDES,
)

cc_toolchain_import_feature(
    name = "includes_feature",
    enabled = True,
    toolchain_import = ":includes",
    use_lld = True,               # keep lld, driven by driver
    inject_cxx_runtime = False,   # not needed if 'ld' is clang++
)

# Optional: your normal binary flags/paths feature
cc_toolchain_import_feature(
    name = "binaries",
    enabled = True,
    toolchain_import = ":includes",
)

# Toolchain config: NO sysroot; ld tool is clang++ driver
cc_toolchain_config(
    name = "toolchain_cfg",
    target_system_name = "local",
    target_cpu = "x86_64",
    includes_feature = ":includes_feature",
    compiler_features = [
        ":binaries",
        ":includes_feature",
        # Optional convenience feature that sets -fuse-ld=lld on link actions:
        # "//third_party/rules_cc_toolchain/features:use_lld",
        # Optional: tiny "cxx_runtime" feature if you insist on driving pure ld.lld (not needed when ld=clang++)
    ],
    tool_paths = {
        "gcc": "compiler/2025.1/bin/compiler/clang",
        "cpp": "compiler/2025.1/bin/compiler/clang++",
        "ld":  "compiler/2025.1/bin/compiler/clang++",  # drive lld via driver
        "ar":  "compiler/2025.1/bin/compiler/llvm-ar",
    },
    c_compiler = ":clang",
    cc_compiler = ":clang++",
    linker     = ":ld",
    archiver   = ":ar",
)

# A small filegroup of the tools
filegroup(
    name = "all",
    srcs = [":clang", ":clang++", ":ld", ":ar"],
)

cc_toolchain(
    name = "oneapi_cc_toolchain",
    toolchain_identifier = "oneapi_nonhermetic_cc",
    toolchain_config = ":toolchain_cfg",
    all_files = ":all",
    ar_files = ":all",
    as_files = ":all",
    compiler_files = ":all",
    dwp_files = ":all",
    linker_files = ":all",
    objcopy_files = ":all",
    strip_files = ":all",
    supports_param_files = 1,
    visibility = ["//visibility:public"],
)

toolchain(
    name = "oneapi_cc_toolchain_registration",
    toolchain = ":oneapi_cc_toolchain",
    toolchain_type = "@rules_cc//cc:toolchain_type",
    visibility = ["//visibility:public"],
)

# A simple lib bundle other repos reference (ensure it's present)
cc_library(
    name = "libs",
    srcs = [],
    linkopts = [
        "-Wl,--enable-new-dtags",
        # Add oneAPI lib search path(s) as needed
        # "-Lmkl/2025.1/lib/intel64",
        # "-Wl,-rpath,mkl/2025.1/lib/intel64",
        # "-lmkl_intel_ilp64", "-lmkl_core", "-lmkl_sequential",
    ],
)
