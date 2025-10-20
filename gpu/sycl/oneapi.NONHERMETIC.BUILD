package(default_visibility = ["//visibility:public"])

load("@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl",
     "cc_toolchain_import")
load("@rules_ml_toolchain//third_party/rules_cc_toolchain/features:features.bzl",
     "cc_toolchain_import_feature")

# Tools from the system install (choose 'latest' symlinks if present)
filegroup(name = "clang",                srcs = ["compiler/latest/bin/clang"])
filegroup(name = "clang++",              srcs = ["compiler/latest/bin/clang++"])
filegroup(name = "icpx",                 srcs = ["compiler/latest/bin/icpx"])
filegroup(name = "clang-offload-bundler",srcs = ["compiler/latest/bin/clang-offload-bundler"])
filegroup(name = "llvm-objcopy",         srcs = ["compiler/latest/bin/llvm-objcopy"])
filegroup(name = "ld",                   srcs = ["compiler/latest/bin/ld.lld"])
filegroup(name = "ar",                   srcs = ["compiler/latest/bin/llvm-ar"])

# Provider-bearing imports expected by the toolchain.  They can be empty here;
# the wrapper supplies builtin headers via -resource-dir; façade supplies -L/-rpath for MKL.
cc_toolchain_import(name = "includes")
cc_toolchain_import(name = "core")
cc_toolchain_import(name = "libclang_rt")
cc_toolchain_import(name = "mkl")

# Feature provider some toolchains expect in compiler_features (ok to point at any import)
cc_toolchain_import_feature(
    name = "binaries",
    enabled = True,
    toolchain_import = ":includes",
)

# Convenience headers/libs (optional; your façade can point straight to system dirs too)
cc_library(
    name = "headers",
    hdrs = glob([
        # Pick the common SYCL + MKL headers (allow both versioned and 'latest')
        "compiler/**/include/**",
        "mkl/**/include/**",
    ]),
    includes = [
        "compiler/latest/include",  # ok if 'latest' exists
        "mkl/latest/include",       # if not present, consumers can use façade includes instead
    ],
)

cc_library(
    name = "libs",
    srcs = glob([
        "mkl/**/lib/libmkl_intel_ilp64.so",
        "mkl/**/lib/libmkl_sequential.so",
        "mkl/**/lib/libmkl_core.so",
        # add more MKL libs if you want to expose them directly
    ]),
)
