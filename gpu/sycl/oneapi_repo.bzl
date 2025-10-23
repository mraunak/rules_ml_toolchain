def _oneapi_system_impl(ctx):
    # 1) Write BUILD file from template shipped in rules_ml_toolchain
    tpl = ctx.read(Label("//gpu/sycl:oneapi.nonhermetic.BUILD.tpl"))
    tpl = tpl.replace("{{ONEAPI_VERSION}}", ctx.attr.oneapi_version)
    tpl = tpl.replace("{{CLANG_VERSION}}", ctx.attr.clang_version)
    ctx.file("BUILD.bazel", tpl)

    # 2) Expose the system oneAPI tree by symlinking top-level dirs we reference
    root = ctx.attr.path
    def link_if_exists(sub):
        p = ctx.path(root + "/" + sub)
        if p.exists:
            ctx.symlink(p, sub)

    for d in [
        "advisor", "ccl", "common", "compiler", "dal", "dev-utilities", "dnnl",
        "dpcpp-ct", "dpl", "installer", "ipp", "ippcp", "mkl", "mpi",
        "pti", "tbb", "tcm", "umf", "vtune"
    ]:
        link_if_exists(d)

oneapi_system_repository = repository_rule(
    implementation = _oneapi_system_impl,
    attrs = {
        "path": attr.string(mandatory=True, doc="System oneAPI root, e.g. /opt/intel/oneapi"),
        "oneapi_version": attr.string(default="2025.1"),
        "clang_version": attr.string(default="20"),
    },
    doc = "Mounts a system oneAPI install as @oneapi with a hermetic-like BUILD.",
)
