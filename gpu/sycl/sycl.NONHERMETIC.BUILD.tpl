package(default_visibility = ["//visibility:public"])

load(
    "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl",
    "cc_toolchain_import",
)
load(
    "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:features.bzl",
    "cc_toolchain_import_feature",
)

# Tools from the system install (prefer 'latest' symlinks if present)
filegroup(name = "clang",                 srcs = ["compiler/latest/bin/clang"])
filegroup(name = "clang++",               srcs = ["compiler/latest/bin/clang++"])
filegroup(name = "icpx",                  srcs = ["compiler/latest/bin/icpx"])
filegroup(name = "clang-offload-bundler", srcs = ["compiler/latest/bin/clang-offload-bundler"])
filegroup(name = "llvm-objcopy",          srcs = ["compiler/latest/bin/llvm-objcopy"])
filegroup(name = "ld",                    srcs = ["compiler/latest/bin/ld.lld"])
filegroup(name = "ar",                    srcs = ["compiler/latest/bin/llvm-ar"])

# Provider-bearing imports expected by the toolchain (can be empty in non-hermetic).
cc_toolchain_import(name = "includes")
cc_toolchain_import(name = "core")
cc_toolchain_import(name = "libclang_rt")
cc_toolchain_import(name = "mkl")

# Feature provider some toolchains expect in compiler_features.
cc_toolchain_import_feature(
    name = "binaries",
    enabled = True,
    toolchain_import = ":includes",
)

# HEADERS: do not glob recursively (avoids symlink loops).
# Just expose the include dirs so dependents get -I flags.
cc_library(
    name = "headers",
    hdrs = [],  # no recursive globs
    includes = [
        "compiler/latest/include",   # e.g. /opt/intel/oneapi/compiler/latest/include
        "mkl/latest/include",        # e.g. /opt/intel/oneapi/mkl/latest/include
    ],
)

# LIBS: avoid recursive globs; provide link search & rpath and link by soname.
cc_library(
    name = "libs",
    srcs = [],
    linkopts = [
        # Prefer 'latest'; if your install lacks it, replace with 'mkl/2025.2/lib/intel64'
        "-Lmkl/latest/lib/intel64",
        "-Wl,-rpath,mkl/latest/lib/intel64",

        # Minimal sequential threading set; tweak if you use TBB/OpenMP
        "-lmkl_intel_ilp64",
        "-lmkl_core",
        "-lmkl_sequential",
    ],
)
