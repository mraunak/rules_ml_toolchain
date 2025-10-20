package(default_visibility = ["//visibility:public"])

cc_library(
    name = "sycl_headers",
    hdrs = [],
    includes = [
        "%{dpcpp_include_dir}",
        "%{mkl_include_dir}",
    ],
)

cc_library(
    name = "level_zero_headers",
    hdrs = [],
    includes = ["%{l0_include_dir}"],
)

cc_library(
    name = "oneapi_libs",
    srcs = [],
    linkopts = [
        "-L%{mkl_library_dir}",
        "-Wl,-rpath,%{mkl_library_dir}",
        "-lmkl_intel_ilp64",
        "-lmkl_core",
        "-lmkl_sequential",
    ],
)

cc_library(
    name = "ze_loader",
    srcs = [],
    linkopts = [
        "-L%{l0_library_dir}",
        "-Wl,-rpath,%{l0_library_dir}",
        "-lze_loader",
    ],
)
