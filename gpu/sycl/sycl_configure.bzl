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
`sycl_configure` depends on the following environment variables:
  * `TF_NEED_SYCL`: Whether to enable building with SYCL.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(
    "//gpu/sycl:sycl_redist_versions.bzl",
    "BUILD_TEMPLATES",
    "REDIST_DICT",
)

def enable_sycl(ctx):
    """Returns whether to build with SYCL support."""
    return bool(ctx.getenv("TF_NEED_SYCL", "").strip())

# TODO: Add support of TF_ICPX_CLANG environment variable
def _use_icpx_and_clang(ctx):
    """Returns whether to use ICPX for SYCL and Clang for C++."""
    return ctx.getenv("TF_ICPX_CLANG", "").strip()

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

# Load from the current package (file is written at repo root).
_DUMMY_CROSSTOOL_BUILD_FILE = """
load(":error_gpu_disabled.bzl", "error_gpu_disabled")
error_gpu_disabled()
"""

def _create_dummy_repository(ctx):
    """
    Create a minimal SYCL layout that intercepts --config=sycl when SYCL
    isn't configured, emitting a clear, actionable error.
    """
    ctx.file("error_gpu_disabled.bzl", _DUMMY_CROSSTOOL_BZL_FILE)
    ctx.file("BUILD", _DUMMY_CROSSTOOL_BUILD_FILE)

    # Materialize templated files under sycl/
    ctx.template(
        "sycl/build_defs.bzl",
        ctx.attr.build_defs_tpl,
        {
            "%{sycl_is_configured}": "False",
            "%{sycl_build_is_configured}": "False",
        },
    )
    ctx.file("sycl/BUILD", "")

# --- minimal helpers for non-hermetic detection ---

def _parse_keyvals(stdout):
    # expects lines like:  key: value
    d = {}
    for line in stdout.splitlines():
        line = line.strip()
        if not line or line.startswith("#") or (": " not in line):
            continue
        k, v = line.split(": ", 1)
        d[k.strip()] = v.strip()
    return d

def _run_find_sycl_config(ctx):
    py = ctx.which("python3") or ctx.which("python")
    if not py:
        fail("Could not find python3/python on PATH to run find_sycl_config.py")

    script = ctx.path(Label("//third_party/gpus:find_sycl_config.py"))
    res = ctx.execute([py, script], timeout = 120, quiet = True)
    if res.return_code != 0:
        fail("find_sycl_config.py failed ({}):\nSTDOUT:\n{}\nSTDERR:\n{}".format(
            res.return_code, res.stdout, res.stderr))
    return _parse_keyvals(res.stdout)

def _sycl_configure_impl(ctx):
    """Implementation of the sycl_configure rule"""
    if not enable_sycl(ctx):
        _create_dummy_repository(ctx)
        return

    # Always emit build_defs with True/True in configured mode
    ctx.template(
        "sycl/build_defs.bzl",
        ctx.attr.build_defs_tpl,
        {
            "%{sycl_is_configured}": "True",
            "%{sycl_build_is_configured}": "True",
        },
    )

    hermetic = ctx.getenv("SYCL_BUILD_HERMETIC") == "1"
    if hermetic:
        # Hermetic: façade aliases to vendor repos
        ctx.file("sycl/BUILD", ctx.read(ctx.attr.build_file))
    else:
        # Non-hermetic: discover system paths and generate façade shims
        cfg = _run_find_sycl_config(ctx)

        # Minimal required keys (extend as needed)
        required = [
            "mkl_include_dir",
            "mkl_library_dir",
            "l0_include_dir",
            "l0_library_dir",
            "sycl_toolkit_path",
        ]
        missing = [k for k in required if not cfg.get(k)]
        if missing:
            fail("find_sycl_config.py missing keys: {}".format(", ".join(missing)))

        # Heuristic for DPC++ headers if script didn't print dpcpp_include_dir
        dpcpp_inc = cfg.get("dpcpp_include_dir", cfg["sycl_toolkit_path"] + "/include")

        ctx.template(
            "sycl/BUILD",
            ctx.attr.nonhermetic_build_tpl,
            {
                "%{mkl_include_dir}": cfg["mkl_include_dir"],
                "%{mkl_library_dir}": cfg["mkl_library_dir"],
                "%{l0_include_dir}": cfg["l0_include_dir"],
                "%{l0_library_dir}": cfg["l0_library_dir"],
                "%{dpcpp_include_dir}": dpcpp_inc,
            },
        )

    ctx.file("BUILD", "")

sycl_configure = repository_rule(
    implementation = _sycl_configure_impl,
    local = True,
    environ = ["TF_NEED_SYCL", "SYCL_BUILD_HERMETIC"],
    attrs = {
        "build_defs_tpl": attr.label(default = Label("//gpu/sycl:build_defs.bzl.tpl")),
        "build_file": attr.label(default = Label("//gpu/sycl:sycl.BUILD")),
        "nonhermetic_build_tpl": attr.label(default = Label("//gpu/sycl:sycl.NONHERMETIC.BUILD.tpl")),
    },
)
