package(default_visibility = ["//visibility:public"])

# Expose Level Zero headers for includes like <level_zero/ze_api.h>.
# When you call:
#   new_local_repository(name = "level_zero", path = "/usr", build_file = "..."),
# this adds -I/usr/include so <level_zero/...> resolves without enumerating files.
cc_library(
    name = "headers",
    hdrs = glob([
        "include/level_zero/**",   # will be empty if the dir doesn't exist; that's OK
    ]),
    includes = [
        "include",                 # adds -I<repo_root>/include (e.g. -I/usr/include)
    ],
)

# Some toolchains aggregate :all; forward it to the headers target.
filegroup(
    name = "all",
    srcs = [":headers"],
)
