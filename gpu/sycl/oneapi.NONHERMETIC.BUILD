package(default_visibility = ["//visibility:public"])

load(
    "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl",
    "cc_toolchain_import",
)
load(
    "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:features.bzl",
    "cc_toolchain_import_feature",
)

# -- Tools (must be single files; adjust one of the two paths to match your install) --
# Choose the line that exists on your machine and delete the other.

alias(name = "clang",
      actual = "compiler/2025.1/bin/clang")                 # common layout
# alias(name = "clang", actual = "compiler/2025.1/bin/compiler/clang")  # alternate

alias(name = "clang++",
      actual = "compiler/2025.1/bin/clang++")
# alias(name = "clang++", actual = "compiler/2025.1/bin/compiler/clang++")

alias(name = "icpx",
      actual = "compiler/2025.1/bin/icpx")

alias(name = "clang-offload-bundler",
      actual = "compiler/2025.1/bin/clang-offload-bundler")

alias(name = "llvm-objcopy",
      actual = "compiler/2025.1/bin/llvm-objcopy")

alias(name = "ld",
      actual = "compiler/2025.1/bin/ld.lld")

alias(name = "ar",
      actual = "compiler/2025.1/bin/llvm-ar")


# Provider stubs used by toolchain config (not referenced by :all to avoid cycles).
cc_toolchain_import(name = "includes")
cc_toolchain_import(name = "core")
cc_toolchain_import(name = "libclang_rt")
cc_toolchain_import(name = "mkl")

cc_toolchain_import_feature(
    name = "binaries",
    enabled = True,
    toolchain_import = ":includes",
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

# -- Toolchain aggregator: FILES ONLY (no cc_library / no cc_toolchain_import) --
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
        # Intentionally NOT including :headers, :libs, :includes, :core, :libclang_rt, :mkl, :binaries
        # to avoid introducing CcInfo/providers into the toolchain dependency graph.
    ],
)
