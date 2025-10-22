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

# Hermetic SYCL repositories initialization. Consult the WORKSPACE on how to use it.

load("//gpu/sycl:dist_repo.bzl", "dist_repo")
load("//gpu/sycl:sycl_redist_versions.bzl", "BUILD_TEMPLATES", "REDIST_DICT")

def sycl_init_repository(
        hermetic = True,
        oneapi_root = "/opt/intel/oneapi",
        level_zero_root = "/usr",
        zero_loader_root = "/usr",
        redist_dict = REDIST_DICT,
        build_templates = BUILD_TEMPLATES):
    """Initializes SYCL repos. hermetic=True uses dist_repo; else new_local_repository."""

    if hermetic:
        # Download & materialize each redist using the versioned tables.
        for dist_name, _ in redist_dict.items()[::-1]:
            bt = build_templates[dist_name]
            dist_repo(
                name = dist_name,
                distrs = redist_dict[dist_name],
                build_templates = bt["version_to_template"],
            )
        return

    if not native.existing_rule("oneapi"):
     native.new_local_repository(
        name = "oneapi",
        path = oneapi_root,  # MUST be /opt/intel/oneapi (no version)
        build_file = "@rules_ml_toolchain//gpu/sycl:oneapi.NONHERMETIC.BUILD",
    )

   if not native.existing_rule("level_zero"):
    native.new_local_repository(
        name = "level_zero",
        path = level_zero_root,  # /usr
        build_file = "@rules_ml_toolchain//gpu/sycl:level_zero.NONHERMETIC.BUILD",
    )

  if not native.existing_rule("zero_loader"):
    native.new_local_repository(
        name = "zero_loader",
        path = zero_loader_root,  # /usr
        build_file = "@rules_ml_toolchain//gpu/sycl:zero_loader.NONHERMETIC.BUILD",
    )
