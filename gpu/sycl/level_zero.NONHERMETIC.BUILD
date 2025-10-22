package(default_visibility = ["//visibility:public"])

# 1) Plain files (NO CcInfo)
filegroup(
    name = "headers_files",
    srcs = glob(["include/level_zero/**"]),
)

# 2) For normal code (facade points here)
cc_library(
    name = "headers",
    hdrs = glob(["include/level_zero/**"]),
    includes = ["include"],   # adds -I/usr/include → <level_zero/...> works
)

# 3) Toolchain aggregation (files ONLY)
filegroup(
    name = "all",
    srcs = [":headers_files"],
)
