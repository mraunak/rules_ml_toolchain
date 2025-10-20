package(default_visibility = ["//visibility:public"])

# Most distros install headers in /usr/include/level_zero
cc_library(
    name = "headers",
    hdrs = glob(["include/level_zero/**"]),
    includes = ["include/level_zero/.."],  # adds /usr/include
)

# Export an :all target since some toolchains aggregate it
filegroup(name = "all", srcs = ["include/level_zero"])
