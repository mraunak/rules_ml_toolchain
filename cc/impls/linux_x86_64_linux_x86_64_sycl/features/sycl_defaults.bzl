load("@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
     "feature", "flag_set", "flag_group")

# Export a list so your config rule can extend it.
def sycl_default_features():
    return [
        feature(
            name = "sycl_define",            # adds global SYCL macros/flags
            enabled = True,                  # always on for this toolchain
            flag_sets = [
                flag_set(
                    actions = [
                        "c-compile",
                        "c++-compile",
                        "assemble",
                        "preprocess-assemble",
                        "c++-module-compile",
                        "c++-module-codegen",
                    ],
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-DTENSORFLOW_USE_SYCL=1",
                                "-DMKL_ILP64",
                                "-fPIC",
                            ],
                        ),
                    ],
                ),
            ],
        ),
        feature(
            name = "sycl_frontend",          # front-end switch for DPC++/Clang
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = [
                        "c++-compile",
                        "c++-module-compile",
                        "c++-module-codegen",
                    ],
                    flag_groups = [flag_group(flags = ["-fsycl"])],
                ),
            ],
        ),
    ]
