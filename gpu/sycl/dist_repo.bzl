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

def _get_file_name(url):
    last = url.rfind("/")
    return url[last + 1:] if last >= 0 else url

def _download_distribution(ctx, dist):
    """Download and extract a redistribution tuple [url, sha256, strip_prefix]."""
    url, sha256, strip_prefix = dist[0], dist[1], dist[2]

    file_name = _get_file_name(url)
    print("Downloading {}".format(url))  # buildifier: disable=print
    ctx.download(
        url = url,
        output = file_name,
        sha256 = sha256,
    )

    print("Extracting {} with strip prefix '{}'".format(file_name, strip_prefix))  # buildifier: disable=print
    ctx.extract(
        archive = file_name,
        stripPrefix = strip_prefix,
    )
    ctx.delete(file_name)

def _is_hermetic(ctx):
    return ctx.getenv("SYCL_BUILD_HERMETIC") == "1"

def _get_oneapi_version(ctx):
    return ctx.getenv("ONEAPI_VERSION", "")

def _get_os(ctx):
    return ctx.getenv("OS", "")

def _require_env(env_val, name):
    if not env_val:
        fail("{} must be set via --repo_env for hermetic build".format(name))

def _get_dist_key(ctx):
    """Return '<os>_<version>' after validating required envs for hermetic."""
    oneapi_version = _get_oneapi_version(ctx)
    os_id = _get_os(ctx)
    _require_env(oneapi_version, "ONEAPI_VERSION")
    _require_env(os_id, "OS")
    return "{}_{}".format(os_id, oneapi_version)

def _build_file(ctx, build_file_label):
    """Write BUILD.bazel from a template label."""
    ctx.file("BUILD.bazel", ctx.read(build_file_label))

def _handle_level_zero(ctx):
    # Provide include/level_zero/… for code that uses <level_zero/ze_api.h>
    ctx.symlink("include", "level_zero")

def _write_minimal_build(ctx):
    # A dummy repo that keeps labels addressable if invoked in non-hermetic.
    ctx.file(
        "BUILD.bazel",
        'package(default_visibility = ["//visibility:public"])\n',
    )

def _use_downloaded_archive(ctx):
    """Hermetic path: download, extract, and write the versioned BUILD."""
    dist_key = _get_dist_key(ctx)

    if dist_key not in ctx.attr.distrs:
        fail("No redistribution defined for key '{}'. (ONEAPI_VERSION='{}', OS='{}')"
             .format(dist_key, _get_oneapi_version(ctx), _get_os(ctx)))

    dist = ctx.attr.distrs[dist_key]
    if not dist or len(dist) < 3:
        fail("Invalid redistribution tuple for key '{}': expected [url, sha256, strip_prefix]".format(dist_key))

    _download_distribution(ctx, dist)

    if ctx.name == "level_zero":
        _handle_level_zero(ctx)

    if dist_key not in ctx.attr.build_templates:
        fail("No build template provided for key '{}'".format(dist_key))
    _build_file(ctx, Label(ctx.attr.build_templates[dist_key]))

def _dist_repo_impl(ctx):
    if not _is_hermetic(ctx):
        _write_minimal_build(ctx)
        return

    # Hermetic: download and materialize from the versioned tables
    _use_downloaded_archive(ctx)

dist_repo = repository_rule(
    implementation = _dist_repo_impl,
    attrs = {
        # distrs maps '<os>_<version>' -> [url, sha256, strip_prefix]
        "distrs": attr.string_list_dict(mandatory = True),
        # build_templates maps '<os>_<version>' -> "//path:BUILD.tpl"
        "build_templates": attr.string_dict(mandatory = True),
    },
)
