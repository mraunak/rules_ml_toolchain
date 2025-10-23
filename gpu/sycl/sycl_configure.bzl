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

"""Repository rule for SYCL autoconfiguration.

`sycl_configure` depends on:
  * TF_NEED_SYCL: enable building with SYCL
"""

def enable_sycl(ctx):
    return bool(ctx.getenv("TF_NEED_SYCL", "").strip())

_DUMMY_CROSSTOOL_BZL_FILE = """
def error_gpu_disabled():
  fail("ERROR: Building with --config=sycl but TensorFlow is not configured " +
       "to build with GPU support. Please re-run ./configure and enter 'Y' " +
       "at the prompt to build with GPU support.")

  native.genrule(
      name = "error_gen_crosstool",
      outs = ["CROSSTOOL"],
      cmd = "echo 'Should not be run.' && exit 1",
  )

  native.filegroup(
      name = "crosstool",
      srcs = [":CROSSTOOL"],
      output_licenses = ["unencumbered"],
  )
"""

_DUMMY_CROSSTOOL_BUILD_FILE = """
load(":error_gpu_disabled.bzl", "error_gpu_disabled")
error_gpu_disabled()
"""

def _create_dummy_repository(ctx):
    # Intercept --config=sycl when TF_NEED_SYCL is not enabled.
    ctx.file("error_gpu_disabled.bzl", _DUMMY_CROSSTOOL_BZL_FILE)
    ctx.file("BUILD", _DUMMY_CROSSTOOL_BUILD_FILE)

    # Emit templated defs with False/False so loads work but nothing is active.
    ctx.template(
        "sycl/build_defs.bzl",
        ctx.attr.build_defs_tpl,
        {
            "%{sycl_is_configured}": "False",
            "%{sycl_build_is_configured}": "False",
        },
    )
    ctx.file("sycl/BUILD", "")

def _sycl_configure_impl(ctx):
    if not enable_sycl(ctx):
        _create_dummy_repository(ctx)
        return

    # SYCL is enabled: bake True/True in defs
    ctx.template(
        "sycl/build_defs.bzl",
        ctx.attr.build_defs_tpl,
        {
            "%{sycl_is_configured}": "True",
            "%{sycl_build_is_configured}": "True",
        },
    )

    # Use the SAME façade in both hermetic and non-hermetic.
    # Your sycl.BUILD should route to @oneapi (system-mounted) targets.
    ctx.file("sycl/BUILD", ctx.read(ctx.attr.build_file))

    # Make repo root a Bazel package
    ctx.file("BUILD", "")

sycl_configure = repository_rule(
    implementation = _sycl_configure_impl,
    local = True,
    # No need for SYCL_BUILD_HERMETIC anymore.
    environ = ["TF_NEED_SYCL", "TF_ICPX_CLANG"],
    attrs = {
        "build_defs_tpl": attr.label(default = Label("//gpu/sycl:build_defs.bzl.tpl")),
        "build_file":     attr.label(default = Label("//gpu/sycl:sycl.BUILD")),
    },
)
