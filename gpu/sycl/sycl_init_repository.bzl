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

"""Hermetic SYCL repositories initialization. Consult the WORKSPACE on how to use it."""

load("//gpu/sycl:dist_repo.bzl", "dist_repo")
load(
    "//gpu/sycl:sycl_redist_versions.bzl",
    "BUILD_TEMPLATES",
    "REDIST_DICT",
)

def sycl_init_repository(
        redist_dict = REDIST_DICT,
        build_templates = BUILD_TEMPLATES):
    """Initializes SYCL repositories.

    Hermetic:
      - Uses dist_repo() with versioned redist tables (download+extract).
    Non-hermetic:
      - Uses new_local_repository() pointing to system install roots with
        small BUILD files in //gpu/sycl:*.NONHERMETIC.BUILD.
    """
    hermetic = native.getenv("SYCL_BUILD_HERMETIC") == "1"

    if hermetic:
        # Keep existing behavior: instantiate dist_repo for each distribution
        # described in the redist tables.
        # Preserve prior order if you relied on it.
        for dist_name, _ in redist_dict.items()[::-1]:
            build_template = build_templates[dist_name]
            dist_repo(
                name = dist_name,
                distrs = redist_dict[dist_name],
                build_templates = build_template["version_to_template"],
            )
        return

    # -------------------------
    # Non-hermetic (system) path
    # -------------------------
    # Roots can be overridden via --repo_env. Provide sensible defaults.
    oneapi_root      = native.getenv("ONEAPI_ROOT") or "/opt/intel/oneapi"
    level_zero_root  = native.getenv("LEVEL_ZERO_ROOT") or "/usr"
    zero_loader_root = native.getenv("ZERO_LOADER_ROOT") or "/usr"

    # Only create repos that exist in the redist dict (names typically:
    # "oneapi", "level_zero", "zero_loader"). This keeps behavior aligned
    # with what the hermetic path would have instantiated.
    names = [k for k, _ in redist_dict.items()]

    if "oneapi" in names:
        native.new_local_repository(
            name = "oneapi",
            path = oneapi_root,
            build_file = "//gpu/sycl:oneapi.NONHERMETIC.BUILD",
        )

    if "level_zero" in names:
        native.new_local_repository(
            name = "level_zero",
            path = level_zero_root,
            build_file = "//gpu/sycl:level_zero.NONHERMETIC.BUILD",
        )

    if "zero_loader" in names:
        native.new_local_repository(
            name = "zero_loader",
            path = zero_loader_root,
            build_file = "//gpu/sycl:zero_loader.NONHERMETIC.BUILD",
        )
