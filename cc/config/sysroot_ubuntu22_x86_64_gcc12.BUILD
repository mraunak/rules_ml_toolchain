# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================

load(
    "@rules_ml_toolchain//third_party/rules_cc_toolchain:sysroot.bzl",
    "sysroot_package",
)
load(
    "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl",
    "cc_toolchain_import",
)

sysroot_package(
    name = "sysroot",
    visibility = ["//visibility:public"],
)

GCC_VERSION = 12
GLIBC_VERSION = "2.35"

# Details about C RunTime (CRT) objects:
# https://docs.oracle.com/cd/E88353_01/html/E37853/crt1.o-7.html
# https://dev.gentoo.org/~vapier/crt.txt
CRT_OBJECTS = [
    "crti",
    "crtn",
    # Use PIC Scrt1.o instead of crt1.o to keep PIC code from segfaulting.
    "Scrt1",
]

[
    cc_toolchain_import(
        name = obj,
        static_library = "usr/lib/x86_64-linux-gnu/%s.o" % obj,
    )
    for obj in CRT_OBJECTS
]

cc_toolchain_import(
    name = "startup_libs",
    visibility = ["//visibility:public"],
    deps = [":" + obj for obj in CRT_OBJECTS],
)

cc_toolchain_import(
    name = "includes_c",
    hdrs = glob([
        "usr/include/c++/{gcc_version}/**".format(gcc_version = GCC_VERSION),
        "usr/include/x86_64-linux-gnu/c++/{gcc_version}/*/**".format(gcc_version = GCC_VERSION),
        "usr/include/c++/{gcc_version}/experimental/**".format(gcc_version = GCC_VERSION),
    ]),
    includes = [
        "usr/include/c++/{gcc_version}".format(gcc_version = GCC_VERSION),
        "usr/include/x86_64-linux-gnu/c++/{gcc_version}".format(gcc_version = GCC_VERSION),
        "usr/include/c++/{gcc_version}/backward".format(gcc_version = GCC_VERSION),
        "usr/include/c++/{gcc_version}/experimental".format(gcc_version = GCC_VERSION),
    ],
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "includes_system",
    hdrs = glob([
        "usr/local/include/**",
        "usr/include/x86_64-linux-gnu/**",
        "usr/include/**",
    ]),
    includes = [
        "usr/local/include",
        "usr/include/x86_64-linux-gnu",
        "usr/include",
    ],
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "gcc",
    additional_libs = [
        "lib/x86_64-linux-gnu/libgcc_s.so.1",
        "usr/lib/gcc/x86_64-linux-gnu/{gcc_version}/libgcc_eh.a".format(gcc_version = GCC_VERSION),
    ],
    shared_library = "usr/lib/gcc/x86_64-linux-gnu/{gcc_version}/libgcc_s.so".format(gcc_version = GCC_VERSION),
    static_library = "usr/lib/gcc/x86_64-linux-gnu/{gcc_version}/libgcc.a".format(gcc_version = GCC_VERSION),
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "stdc++",
    additional_libs = [
        "usr/lib/x86_64-linux-gnu/libstdc++.so.6",
        "usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.30",
    ],
    shared_library = "usr/lib/gcc/x86_64-linux-gnu/{gcc_version}/libstdc++.so".format(gcc_version = GCC_VERSION),
    static_library = "usr/lib/gcc/x86_64-linux-gnu/{gcc_version}/libstdc++.a".format(gcc_version = GCC_VERSION),
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "dynamic_linker",
    additional_libs = [
        "lib64/ld-linux-x86-64.so.2",
        "lib/x86_64-linux-gnu/ld-linux-x86-64.so.2",
        "usr/lib/x86_64-linux-gnu/libdl.so.2",
    ],
    shared_library = "usr/lib/x86_64-linux-gnu/libdl.so",
    static_library = "usr/lib/x86_64-linux-gnu/libdl.a",
    deps = [":libc"],
)

cc_toolchain_import(
    name = "math",
    additional_libs = [
        "lib/x86_64-linux-gnu/libm.so.6",
        "lib/x86_64-linux-gnu/libmvec.so.1",
        "usr/lib/x86_64-linux-gnu/libm-{glibc_version}.a".format(glibc_version = GLIBC_VERSION),
        "usr/lib/x86_64-linux-gnu/libmvec.so",
        "usr/lib/x86_64-linux-gnu/libmvec.a",
    ],
    shared_library = "usr/lib/x86_64-linux-gnu/libm.so",
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "pthread",
    additional_libs = [
        "usr/lib/x86_64-linux-gnu/libpthread.so.0",
    ],
    shared_library = "usr/lib/x86_64-linux-gnu/libpthread.so",
    static_library = "usr/lib/x86_64-linux-gnu/libpthread.a",
    visibility = ["//visibility:public"],
    deps = [
        ":libc",
    ],
)

cc_toolchain_import(
    name = "rt",
    additional_libs = [
        "usr/lib/x86_64-linux-gnu/librt.so.1",
        "usr/lib/x86_64-linux-gnu/librt.a",
    ],
    visibility = ["//visibility:private"],
)

cc_toolchain_import(
    name = "libc",
    additional_libs = [
        "lib/x86_64-linux-gnu/libc.so.6",
        "usr/lib/x86_64-linux-gnu/libc_nonshared.a",
    ],
    shared_library = "usr/lib/x86_64-linux-gnu/libc.so",
    static_library = "usr/lib/x86_64-linux-gnu/libc.a",
    visibility = ["//visibility:public"],
    deps = [
        ":gcc",
        ":math",
        ":stdc++",
        ":rt",
    ],
)

# This is a group of all the system libraries we need. The actual glibc library is split
# out to fix link ordering problems that cause false undefined symbol positives.
cc_toolchain_import(
    name = "glibc",
    visibility = ["//visibility:public"],
    deps = [
        ":dynamic_linker",
        ":libc",
    ],
)
