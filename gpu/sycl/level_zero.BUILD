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

# Level Zero system path example:
# l0_include_dir: /usr/include/level_zero
# l0_library_dir: /usr/lib/x86_64-linux-gnu

load(
    "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl",
    "cc_toolchain_import",
)

package(
    default_visibility = [
        "//cc/impls/linux_x86_64_linux_x86_64_sycl:__pkg__",
    ],
)

filegroup(
    name = "all",
    srcs = glob([
        "include/**",
        "level_zero/**",  # also match when a symlink exists
    ]),
    visibility = ["//visibility:public"],
)

# Headers for <level_zero/ze_api.h>.
# Supports both layouts:
#  - hermetic: symlink 'level_zero' -> 'include'
#  - system:   real 'include/level_zero/...'
cc_library(
    name = "headers",
    hdrs = glob([
        "level_zero/**",         # hermetic (via symlink)
        "include/level_zero/**", # system
    ]),
    includes = [
        ".",         # makes <level_zero/...> work when symlink exists
        "include",   # makes <level_zero/...> work when tree is under include/
    ],
    visibility = ["//visibility:public"],
)
