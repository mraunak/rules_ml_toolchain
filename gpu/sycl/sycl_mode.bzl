def _quote(s):
    # Return a Starlark-escaped double-quoted string literal
    # (escape backslashes and double quotes; newlines to \n).
    return "\"" + s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n") + "\""

def _sycl_mode_impl(ctx):
    # Read env (with sensible defaults for non-hermetic)
    hermetic = ctx.getenv("SYCL_BUILD_HERMETIC") == "1"
    oneapi_root = ctx.getenv("ONEAPI_ROOT", "/opt/intel/oneapi")
    level_zero_root = ctx.getenv("LEVEL_ZERO_ROOT", "/usr")
    zero_loader_root = ctx.getenv("ZERO_LOADER_ROOT", "/usr")

    # Build defs.bzl content (no f-strings, no {!r})
    lines = [
        "SYCL_HERMETIC = {}".format("True" if hermetic else "False"),
        "ONEAPI_ROOT = {}".format(_quote(oneapi_root)),
        "LEVEL_ZERO_ROOT = {}".format(_quote(level_zero_root)),
        "ZERO_LOADER_ROOT = {}".format(_quote(zero_loader_root)),
        "",
    ]
    ctx.file("defs.bzl", "\n".join(lines))
    ctx.file("BUILD.bazel", 'exports_files(["defs.bzl"])\n')

sycl_mode_repo = repository_rule(
    implementation = _sycl_mode_impl,
    environ = [
        "SYCL_BUILD_HERMETIC",
        "ONEAPI_ROOT",
        "LEVEL_ZERO_ROOT",
        "ZERO_LOADER_ROOT",
    ],
)
