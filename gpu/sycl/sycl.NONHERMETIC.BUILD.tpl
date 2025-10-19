package(default_visibility = ["//visibility:public"])

# Headers: use Bazel's 'includes' so dependents can #include<> from system dirs.
cc_library(
    name = "sycl_headers",
    hdrs = [],
    textual_hdrs = [],
    # 'includes' adds -I (actually -isystem) to dependent compile lines.
    includes = [
        "%{dpcpp_include_dir}",    # e.g. /opt/intel/oneapi/compiler/2025.2/include
        "%{mkl_include_dir}",      # e.g. /opt/intel/oneapi/mkl/2025.2/include
        # add more if you need (tbb, dpl, etc.)
    ],
)

cc_library(
    name = "level_zero_headers",
    hdrs = [],
    includes = ["%{l0_include_dir}"],   # e.g. /usr/include/level_zero
)

# Linker shim for oneAPI libs (MKL, toolchain runtimes, etc.)
cc_library(
    name = "oneapi_libs",
    srcs = [],
    linkopts = [
        "-L%{mkl_library_dir}",
        "-Wl,-rpath,%{mkl_library_dir}",
        # Minimal set; extend as needed:
        "-lmkl_intel_ilp64",
        "-lmkl_core",
        "-lmkl_sequential",
    ],
)

# Level Zero loader
cc_library(
    name = "ze_loader",
    srcs = [],
    linkopts = [
        "-L%{l0_library_dir}",
        "-Wl,-rpath,%{l0_library_dir}",
        "-lze_loader",
    ],
)
