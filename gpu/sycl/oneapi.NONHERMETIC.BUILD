package(default_visibility = ["//visibility:public"])

load("@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl", "cc_toolchain_import")
load("@rules_ml_toolchain//gpu/sycl:oneapi_feature.bzl", "oneapi_feature")

ONEAPI_VERSION = "2025.1"
CLANG_VERSION = "20"

filegroup(
    name = "all",
    srcs = glob([
        "advisor/2021.15/**",
        "ccl/2021.15/**",
        "common/{v}/**".format(v = ONEAPI_VERSION),
        "compiler/{v}/**".format(v = ONEAPI_VERSION),
        "dal/2025.5/env/**",
        "dal/2025.5/etc/**",
        "dal/2025.5/include/**",
        "dal/2025.5/lib/libone*",
        "dal/2025.5/lib/pkgconfig/**",
        "dal/2025.5/share/**",
        "dev-utilities/**",
        "dnnl/**",
        "dpcpp-ct/**",
        "dpl/**",
        "installer/**",
        "ipp/2022.1/env/**",
        "ipp/2022.1/etc/**",
        "ipp/2022.1/include/**",
        "ipp/2022.1/lib/lib*",
        "ipp/2022.1/lib/nonpic/**",
        "ipp/2022.1/lib/pkgconfig/**",
        "ipp/2022.1/opt/**",
        "ipp/2022.1/share/**",
        "ippcp/{v}/env/**".format(v = ONEAPI_VERSION),
        "ippcp/{v}/etc/**".format(v = ONEAPI_VERSION),
        "ippcp/{v}/include/**".format(v = ONEAPI_VERSION),
        "ippcp/{v}/lib/lib*".format(v = ONEAPI_VERSION),
        "ippcp/{v}/lib/nonpic/**".format(v = ONEAPI_VERSION),
        "ippcp/{v}/lib/pkgconfig/**".format(v = ONEAPI_VERSION),
        "ippcp/{v}/opt/**".format(v = ONEAPI_VERSION),
        "ippcp/{v}/share/**".format(v = ONEAPI_VERSION),
        "mkl/{v}/bin/**".format(v = ONEAPI_VERSION),
        "mkl/{v}/env/**".format(v = ONEAPI_VERSION),
        "mkl/{v}/etc/**".format(v = ONEAPI_VERSION),
        "mkl/{v}/include/**".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/lib*".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/pkgconfig/**".format(v = ONEAPI_VERSION),
        "mkl/{v}/share/**".format(v = ONEAPI_VERSION),
        "mpi/2021.15/bin/**",
        "mpi/2021.15/env/**",
        "mpi/2021.15/etc/**",
        "mpi/2021.15/include/**",
        "mpi/2021.15/lib/lib*",
        "mpi/2021.15/lib/mpi/**",
        "mpi/2021.15/lib/pkgconfig/**",
        "mpi/2021.15/opt/**",
        "mpi/2021.15/share/**",
        "pti/0.12/**",
        "tbb/2022.1/env/**",
        "tbb/2022.1/etc/**",
        "tbb/2022.1/include/**",
        "tbb/2022.1/lib/lib*",
        "tbb/2022.1/lib/pkgconfig/**",
        "tbb/2022.1/share/**",
        "tcm/1.3/**",
        "umf/0.10/**",
        "vtune/2025.3/**",
    ]),
)

oneapi_feature(
    name = "binaries",
    enabled = True,
    lib_paths = [
        ":compiler/{v}/lib".format(v = ONEAPI_VERSION),
        ":compiler/{v}/compiler/lib/intel64_lin".format(v = ONEAPI_VERSION),
    ],
    icpx_path  = ":compiler/{v}/bin/icpx".format(v = ONEAPI_VERSION),
    clang_path = ":compiler/{v}/bin/compiler/clang".format(v = ONEAPI_VERSION),
    version = ONEAPI_VERSION,   # <-- use the variable
    verbose = True,
)

filegroup(name = "clang",                 srcs = ["compiler/{v}/bin/compiler/clang".format(v = ONEAPI_VERSION)], visibility = ["//visibility:public"])
filegroup(name = "clang++",               srcs = ["compiler/{v}/bin/compiler/clang++".format(v = ONEAPI_VERSION)], visibility = ["//visibility:public"])
filegroup(name = "clang-offload-bundler", srcs = ["compiler/{v}/bin/compiler/clang-offload-bundler".format(v = ONEAPI_VERSION)])
filegroup(name = "llvm-objcopy",          srcs = ["compiler/{v}/bin/compiler/llvm-objcopy".format(v = ONEAPI_VERSION)])
filegroup(name = "ld",                    srcs = ["compiler/{v}/bin/compiler/ld.lld".format(v = ONEAPI_VERSION)], visibility = ["//visibility:public"])
filegroup(name = "ar",                    srcs = ["compiler/{v}/bin/compiler/llvm-ar".format(v = ONEAPI_VERSION)], visibility = ["//visibility:public"])
filegroup(name = "icpx",                  srcs = ["compiler/{v}/bin/icpx".format(v = ONEAPI_VERSION)])

filegroup(
    name = "asan_ignorelist",
    srcs = ["compiler/{v}/lib/clang/{cv}/share/asan_ignorelist.txt".format(v = ONEAPI_VERSION, cv = CLANG_VERSION)],
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "includes",
    hdrs = glob(["compiler/{v}/lib/clang/{cv}/include/**".format(v = ONEAPI_VERSION, cv = CLANG_VERSION)]),
    includes = [
        "compiler/{v}/lib/clang/{cv}".format(v = ONEAPI_VERSION, cv = CLANG_VERSION),
        "compiler/{v}/lib/clang/{cv}/include".format(v = ONEAPI_VERSION, cv = CLANG_VERSION),
    ],
    target_compatible_with = select({"@platforms//os:linux": [], "@platforms//os:macos": []}),
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "libclang_rt",
    static_library = "compiler/{v}/lib/clang/{cv}/lib/x86_64-unknown-linux-gnu/libclang_rt.builtins.a".format(v = ONEAPI_VERSION, cv = CLANG_VERSION),
    target_compatible_with = select({"@platforms//os:linux": [], "@platforms//os:macos": []}),
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "includes_sycl",
    hdrs = glob(["compiler/{v}/include/**".format(v = ONEAPI_VERSION)]),
    includes = ["compiler/{v}/include".format(v = ONEAPI_VERSION)],
)

cc_toolchain_import(
    name = "includes_mkl",
    hdrs = glob(["mkl/{v}/include/**".format(v = ONEAPI_VERSION)]),
    includes = ["mkl/{v}/include".format(v = ONEAPI_VERSION)],
)

cc_toolchain_import(
    name = "core",
    additional_libs = glob(["compiler/{v}/lib/*".format(v = ONEAPI_VERSION)]),
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "mkl",
    additional_libs = glob([
        "mkl/{v}/lib/libmkl_intel_ilp64.s*".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_sequential.s*".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_core.s*".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_sycl_*".format(v = ONEAPI_VERSION),
    ]),
    visibility = ["//visibility:public"],
)

cc_library(
    name = "headers",
    hdrs = glob([
        "mkl/{v}/include/**".format(v = ONEAPI_VERSION),
        "compiler/{v}/include/**".format(v = ONEAPI_VERSION),
        "compiler/{v}/opt/compiler/include/**".format(v = ONEAPI_VERSION),
    ]),
    includes = [
        "mkl/{v}/include".format(v = ONEAPI_VERSION),
        "compiler/{v}/include".format(v = ONEAPI_VERSION),
        # IMPORTANT: includes entries are directories, not globs
        "compiler/{v}/opt/compiler/include".format(v = ONEAPI_VERSION),
    ],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "libs",
    srcs = glob([
        "mkl/{v}/lib/libmkl_intel_ilp64.so".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_sequential.so".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_core.so".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_sycl_stats.so".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_sycl_data_fitting.so".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_sycl_vm.so".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_sycl_lapack.so".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_sycl_dft.so".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_sycl_sparse.so".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_sycl_rng.so".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_sycl_blas.so".format(v = ONEAPI_VERSION),
    ]),
    data = glob([
        "mkl/{v}/lib/libmkl_intel_ilp64.so".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_sequential.so".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_core.so".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_sycl_stats.so".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_sycl_data_fitting.so".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_sycl_vm.so".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_sycl_lapack.so".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_sycl_dft.so".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_sycl_sparse.so".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_sycl_rng.so".format(v = ONEAPI_VERSION),
        "mkl/{v}/lib/libmkl_sycl_blas.so".format(v = ONEAPI_VERSION),
    ]),
    linkopts = ["-Wl,-Bstatic,-lsvml,-lirng,-limf,-lirc,-lirc_s,-Bdynamic"],
    linkstatic = 1,
    visibility = ["//visibility:public"],
)
