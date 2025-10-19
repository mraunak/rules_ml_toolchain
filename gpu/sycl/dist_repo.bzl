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
    last_slash_index = url.rfind("/")
    return url[last_slash_index + 1:]

def _download_distribution(ctx, dist):
    """Downloads and extracts Intel distribution."""
    url = dist[0]
    file_name = _get_file_name(url)
    print("Downloading {}".format(url))  # buildifier: disable=print
    ctx.download(
        url = url,
        output = file_name,
        sha256 = dist[1],
    )
    strip_prefix = dist[2]
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

def _get_dist_key(ctx):
    # Non-hermetic: signal caller to no-op.
    if not _is_hermetic(ctx):
        return None
    oneapi_version = _get_oneapi_version(ctx)
    os_id = _get_os(ctx)
    if not oneapi_version or not os_id:
        fail("ONEAPI_VERSION and OS must be set via --repo_env for hermetic build")
    return "{}_{}".format(os_id, oneapi_version)

def _write_minimal_build(ctx):
    # Create an empty public package so the repo resolves but provides no targets.
    ctx.file(
        "BUILD.bazel",
        'package(default_visibility = ["//visibility:public"])\n',
    )

def _build_file(ctx, build_file):
    """Write a BUILD file from a template label."""
    ctx.file("BUILD.bazel", ctx.read(build_file))

def _handle_level_zero(ctx):
    # Symlink for includes backward compatibility (e.g. #include <level_zero/ze_api.h>)
    ctx.symlink("include", "level_zero")

def _use_downloaded_archive(ctx):
    """Downloads redistribution and initializes hermetic repository."""
    dist_key = _get_dist_key(ctx)

    # Non-hermetic: produce a no-op repo and return.
    if dist_key == None:
        _write_minimal_build(ctx)
        return

    if dist_key not in ctx.attr.distrs:
        fail(
            ("Version {version} for platform {platform} is not supported.")
            .format(version = _get_oneapi_version(ctx), platform = _get_os(ctx))
        )

    dist = ctx.attr.distrs[dist_key]
    _download_distribution(ctx, dist)

    if ctx.name == "level_zero":
        _handle_level_zero(ctx)

    if dist_key not in ctx.attr.build_templates:
        fail("No build template provided for key '{}'".format(dist_key))
    build_template = ctx.attr.build_templates[dist_key]
    _build_file(ctx, Label(build_template))

def _dist_repo_impl(ctx):
    # Previously a placeholder for local_dist_path. Keep behavior minimal.
    _use_downloaded_archive(ctx)

dist_repo = repository_rule(
    implementation = _dist_repo_impl,
    attrs = {
        "distrs": attr.string_list_dict(mandatory = True),
        "build_templates": attr.string_dict(mandatory = True),
    },
)
