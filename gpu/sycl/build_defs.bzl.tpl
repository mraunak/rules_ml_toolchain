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

def if_sycl(if_true, if_false = []):
    """Select on --config=sycl."""
    return select({
        "@rules_ml_toolchain//common:is_sycl_enabled": if_true,
        "//conditions:default": if_false,
    })

def sycl_default_copts():
    """Default options for all SYCL compilations."""
    return if_sycl([
        "-sycl_compile",
        "-DTENSORFLOW_USE_SYCL=1",
        "-DMKL_ILP64",
        "-fPIC",
    ])

def sycl_default_linkopts():
    """Default link options for all SYCL compilations."""
    return if_sycl(["-link_stage", "-lirc"])

def sycl_build_is_configured():
    """True iff SYCL was enabled during configure (templated)."""
    return %{sycl_build_is_configured}

def if_sycl_is_configured(x):
    """True at *configure* time (independent of --config=sycl)."""
    if %{sycl_is_configured}:
        return select({"//conditions:default": x})
    return select({"//conditions:default": []})

def if_sycl_build_is_configured(x, y):
    return x if sycl_build_is_configured() else y

def sycl_library(copts = [], linkopts = [], tags = [], deps = [], **kwargs):
    """cc_library wrapper that injects SYCL defaults and façade deps."""
    native.cc_library(
        copts    = sycl_default_copts()    + copts,
        linkopts = sycl_default_linkopts() + linkopts,
        tags     = tags + ["gpu"],
        deps     = deps + if_sycl_is_configured([
            "@local_config_sycl//sycl:sycl_headers",
            "@local_config_sycl//sycl:level_zero_headers",
            "@local_config_sycl//sycl:oneapi_libs",
            "@local_config_sycl//sycl:ze_loader",
        ]),
        **kwargs
    )
