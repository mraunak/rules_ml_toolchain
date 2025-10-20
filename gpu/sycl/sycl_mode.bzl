def _impl(ctx):
    hermetic = ctx.getenv("SYCL_BUILD_HERMETIC") == "1"
    oneapi_root      = ctx.getenv("ONEAPI_ROOT", "/opt/intel/oneapi")
    level_zero_root  = ctx.getenv("LEVEL_ZERO_ROOT", "/usr")
    zero_loader_root = ctx.getenv("ZERO_LOADER_ROOT", "/usr")
    ctx.file("defs.bzl", f"""
SYCL_HERMETIC = {str(hermetic)}
ONEAPI_ROOT = {oneapi_root!r}
LEVEL_ZERO_ROOT = {level_zero_root!r}
ZERO_LOADER_ROOT = {zero_loader_root!r}
""")
    ctx.file("BUILD.bazel", 'exports_files(["defs.bzl"])')

sycl_mode_repo = repository_rule(
    implementation = _impl,
    environ = ["SYCL_BUILD_HERMETIC", "ONEAPI_ROOT", "LEVEL_ZERO_ROOT", "ZERO_LOADER_ROOT"],
)
