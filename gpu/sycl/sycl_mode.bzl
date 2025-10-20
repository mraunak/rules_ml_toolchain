def _sycl_mode_impl(ctx):
    # Read env (with sensible defaults for non-hermetic)
    hermetic = ctx.getenv("SYCL_BUILD_HERMETIC") == "1"
    oneapi_root = ctx.getenv("ONEAPI_ROOT", "/opt/intel/oneapi")
    level_zero_root = ctx.getenv("LEVEL_ZERO_ROOT", "/usr")
    zero_loader_root = ctx.getenv("ZERO_LOADER_ROOT", "/usr")

    # Build defs.bzl content (no f-strings in Starlark)
    lines = [
        "SYCL_HERMETIC = {}".format("True" if hermetic else "False"),
        "ONEAPI_ROOT = {!r}".format(oneapi_root),
        "LEVEL_ZERO_ROOT = {!r}".format(level_zero_root),
        "ZERO_LOADER_ROOT = {!r}".format(zero_loader_root),
        "",
    ]
    ctx.file("defs.bzl", "\n".join(lines))

    # Export the file so WORKSPACE can load it
    ctx.file("BUILD.bazel", 'exports_files(["defs.bzl"])\n')

sycl_mode_repo = repository_rule(
    implementation = _sycl_mode_impl,
    # When any of these change, Bazel will re-run the rule
    environ = [
        "SYCL_BUILD_HERMETIC",
        "ONEAPI_ROOT",
        "LEVEL_ZERO_ROOT",
        "ZERO_LOADER_ROOT",
    ],
)
