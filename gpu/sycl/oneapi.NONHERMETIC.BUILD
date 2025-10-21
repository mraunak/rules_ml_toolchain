package(default_visibility = ["//visibility:public"])

load(
    "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl",
    "cc_toolchain_import",
)
load(
    "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:features.bzl",
    "cc_toolchain_import_feature",
)

# Tools from the system install (choose 'latest' symlinks if present)
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

# Convenience headers (SYCL + MKL). Keep permissive globs; includes prefer 'latest'.
cc_library(
    name = "headers",
    hdrs = glob([
        "compiler/**/include/**",
        "mkl/**/include/**",
    ]),
    includes = [
        "compiler/latest/include",   # use 'latest' if present; otherwise facade/targets can add specific dirs
        "mkl/latest/include",
    ],
)

# IMPORTANT: Avoid recursive globs (they can hit symlink loops under mkl/**).
# Inject canonical libdir via -L/-rpath and link by soname.
cc_library(
    name = "libs",
    srcs = [],   # no globs; let linker find via -L and -l
    linkopts = [
        # Prefer 'latest'; replace with 'mkl/2025.1/lib/intel64' if your layout lacks 'latest'.
        "-Lmkl/latest/lib/intel64",
        "-Wl,-rpath,mkl/latest/lib/intel64",

        # Minimal sequential threading set; adjust if you use TBB/OpenMP threading.
        "-lmkl_intel_ilp64",
        "-lmkl_core",
        "-lmkl_sequential",
    ],
)
