package(default_visibility = ["//visibility:public"])

load(
    "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl",
    "cc_toolchain_import",
)
load("@bazel_tools//tools/cpp:cc_toolchain.bzl", "cc_toolchain")
load(
    "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:features.bzl",
    "cc_toolchain_import_feature",
)
load("@local_config_sycl//:nonhermetic_includes.bzl", "NONHERMETIC_INCLUDES")

load("@rules_ml_toolchain//third_party/rules_cc_toolchain:toolchain_config.bzl", "cc_toolchain_config")


# -- Tools (each alias must resolve to ONE existing file) ----------------------

# Use Intel oneAPI compilers (icx/icpx) to satisfy toolchain single-file contract.
# Pick the line that exists on your system and delete/comment the other.

alias(name = "clang",   actual = "compiler/2025.1/bin/compiler/clang")
# alias(name = "clang", actual = "compiler/latest/bin/compiler/clang")

alias(name = "clang++",   actual = "compiler/2025.1/bin/compiler/clang++")
# alias(name = "clang++", actual = "compiler/latest/bin/compiler/clang++")

# These usually exist; if not, switch to the 'latest' path.
alias(name = "clang-offload-bundler", actual = "compiler/2025.1/bin/compiler/clang-offload-bundler")
# alias(name = "clang-offload-bundler", actual = "compiler/latest/bin/compiler/clang-offload-bundler")

alias(name = "llvm-objcopy", actual = "compiler/2025.1/bin/compiler/llvm-objcopy")
# alias(name = "llvm-objcopy", actual = "compiler/latest/bin/compiler/llvm-objcopy")

alias(name = "ld", actual = "compiler/2025.1/bin/compiler/ld.lld")
# alias(name = "ld", actual = "compiler/latest/bin/compiler/ld.lld")

alias(name = "ar", actual = "compiler/2025.1/bin/compiler/llvm-ar")
# alias(name = "ar", actual = "compiler/latest/bin/compiler/llvm-ar")

alias(name = "icpx", actual = "compiler/2025.1/bin/icpx")

alias(name = "asan_ignorelist", actual = "compiler/2025.1/lib/clang/20/share/asan_ignorelist.txt")



# Provider stubs used by toolchain config (not referenced by :all to avoid cycles).
cc_toolchain_import(
    name = "includes",
    builtin_includes = NONHERMETIC_INCLUDES,
)
cc_toolchain_import(name = "core")
cc_toolchain_import(name = "libclang_rt")
cc_toolchain_import(name = "mkl")

cc_toolchain_import_feature(
    name = "binaries",
    enabled = True,
    toolchain_import = ":includes",
)
cc_toolchain_import_feature(
    name = "includes_feature",
    enabled = True,
    toolchain_import = ":includes",
)
cc_toolchain_config(
    name = "toolchain_cfg",
    target_system_name = "local",
    target_cpu = "x86_64",  # or "k8"
    # Feature that *carries* the builtin include dirs:
    includes_feature = ":includes_feature",   # <<— REQUIRED

    # Other features you want enabled by default:
    compiler_features = [
        ":binaries",
        ":includes_feature",  # fine to keep here as a FeatureInfo too
    ],

    # Map tools to your aliases:
    c_compiler = ":clang",
    cc_compiler = ":clang++",
    linker     = ":ld",
    archiver   = ":ar",
)


# -- Headers for normal code: NO GLOBS; just add include dirs (gives -I flags).
cc_library(
    name = "headers",
    hdrs = [],
    includes = [
        "compiler/2025.1/include",  # adjust to your installed version or use 'latest'
        "mkl/2025.1/include",
    ],
)

# -- Libs for normal code: NO GLOBS; provide -L/-rpath and link by soname.
cc_library(
    name = "libs",
    srcs = [],
    linkopts = [
        "-Lmkl/2025.1/lib/intel64",            # adjust if your libdir differs
        "-Wl,-rpath,mkl/2025.1/lib/intel64",
        "-lmkl_intel_ilp64",
        "-lmkl_core",
        "-lmkl_sequential",
    ],
)

filegroup(
    name = "all",
    srcs = [
        ":clang",
        ":clang++",
        ":icpx",
        ":clang-offload-bundler",
        ":llvm-objcopy",
        ":ld",
        ":ar",
    ],
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
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    visibility = ["//visibility:public"],
)
