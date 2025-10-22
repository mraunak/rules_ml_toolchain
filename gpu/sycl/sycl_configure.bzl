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

def _emit_nonhermetic_includes(ctx):
    """Detect host builtin include dirs and write NONHERMETIC_INCLUDES."""
    incs = []

    def _add_if_dir(p):
        if not p:
            return
        rp = ctx.path(p)
        if rp.exists:
            incs.append(str(rp.realpath))

    # 1) Clang verbose search list (most robust)
    clang = ctx.which("clang") or ctx.which("icpx")
    if clang:
        r = ctx.execute([clang, "-E", "-v", "-x", "c", "/dev/null", "-o", "/dev/null"])
        if r.return_code == 0:
            lines = r.stderr.splitlines()
            in_block = False
            for ln in lines:
                if "search starts here:" in ln:
                    in_block = True
                    continue
                if in_block and "End of search list." in ln:
                    in_block = False
                    break
                if in_block:
                    s = ln.strip()
                    if s.startswith("/") and " (framework directory)" not in s:
                        _add_if_dir(s)

    # 2) Clang resource dir(s) (explicit)
    for prog in ("clang", "icpx"):
        p = ctx.which(prog)
        if not p:
            continue
        r = ctx.execute([p, "-print-resource-dir"])
        if r.return_code == 0:
            rd = r.stdout.strip()
            _add_if_dir(rd + "/include")
            # Debian/Ubuntu alias path: /usr/lib/clang/<ver>/include
            parts = rd.strip("/").split("/")
            if len(parts) >= 2 and parts[-2] == "clang":
                # already /.../clang/<ver>
                _add_if_dir(rd + "/include")
            elif "lib/clang" in rd:
                try:
                    ver = parts[-1]
                    _add_if_dir("/usr/lib/clang/{}/include".format(ver))
                except Exception:
                    pass

    # 3) System headers
    _add_if_dir("/usr/include")

    # 4) GCC include + include-fixed (compiler’s limits.h)
    gcc = ctx.which("gcc")
    if gcc:
        r = ctx.execute([gcc, "-print-libgcc-file-name"])
        if r.return_code == 0:
            verdir = ctx.path(r.stdout.strip()).dirname  # .../lib/gcc/<triple>/<ver>
            _add_if_dir(str(verdir) + "/include")
            _add_if_dir(str(verdir) + "/include-fixed")

    # De-dup while preserving order
    seen = {}
    incs_dedup = []
    for p in incs:
        if p not in seen:
            seen[p] = True
            incs_dedup.append(p)

    ctx.file("nonhermetic_includes.bzl",
             "NONHERMETIC_INCLUDES = " + repr(incs_dedup) + "\n")


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
    ctx.file("sycl/BUILD", ctx.read(ctx.attr.build_file))

    # Make repo root a Bazel package
    ctx.file("BUILD", "")

    # NEW: Emit host include roots for non-hermetic builds so the toolchain
    # treats them as "builtin" (prevents absolute-path include errors).
    if ctx.getenv("SYCL_BUILD_HERMETIC", "1") == "0":
        _emit_nonhermetic_includes(ctx)
    else:
        ctx.file("nonhermetic_includes.bzl", "NONHERMETIC_INCLUDES = []\n")


sycl_configure = repository_rule(
    implementation = _sycl_configure_impl,
    local = True,
    environ = ["TF_NEED_SYCL", "SYCL_BUILD_HERMETIC", "TF_ICPX_CLANG"],
    attrs = {
        "build_defs_tpl": attr.label(default = Label("//gpu/sycl:build_defs.bzl.tpl")),
        "build_file":     attr.label(default = Label("//gpu/sycl:sycl.BUILD")),
    },
)
