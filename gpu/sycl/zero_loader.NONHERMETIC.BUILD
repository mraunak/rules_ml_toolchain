package(default_visibility = ["//visibility:public"])

# Provide ze_loader as a cc_library so it can be used in cc_library deps.
# We don't enumerate .so files; just add search paths (+ rpaths) and link by soname.
cc_library(
    name = "libze_loader",
    srcs = [],
    linkopts = [
        # Common lib dirs on Linux distros; keep them relative to repo root (/usr).
        "-Llib/x86_64-linux-gnu",
        "-Llib64",
        "-Llib",
        "-Wl,-rpath,lib/x86_64-linux-gnu",
        "-Wl,-rpath,lib64",
        "-Wl,-rpath,lib",
        "-lze_loader",
    ],
)
