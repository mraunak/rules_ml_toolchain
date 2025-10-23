# MIT License
#
# Copyright (c) 2021 silvergasp
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

load(
    "@rules_cc//cc:action_names.bzl",
    "ACTION_NAMES",
    "ACTION_NAME_GROUPS",
    "ALL_CC_COMPILE_ACTION_NAMES",
    "ALL_CPP_COMPILE_ACTION_NAMES",
    "CC_LINK_EXECUTABLE_ACTION_NAMES",
    "DYNAMIC_LIBRARY_LINK_ACTION_NAMES",
)
load(
    "@rules_cc//cc:cc_toolchain_config_lib.bzl",
    "FeatureInfo",
    "env_entry",
    "env_set",
    "feature",
    "flag_group",
    "flag_set",
    _feature = "feature",
)
load(
    "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl",
    "CcToolchainImportInfo",
)
BuiltinIncludesInfo = provider(
    fields = {
        "dirs": "List of toolchain builtin include directories " +
                "(to be set as cxx_builtin_include_directories).",
    },
)

ALL_ACTIONS = [
    ACTION_NAMES.c_compile,
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.cc_flags_make_variable,
    ACTION_NAMES.cpp_module_codegen,
    ACTION_NAMES.cpp_header_parsing,
    ACTION_NAMES.cpp_module_compile,
    ACTION_NAMES.assemble,
    ACTION_NAMES.preprocess_assemble,
    ACTION_NAMES.lto_indexing,
    ACTION_NAMES.lto_backend,
    ACTION_NAMES.lto_index_for_executable,
    ACTION_NAMES.lto_index_for_dynamic_library,
    ACTION_NAMES.lto_index_for_nodeps_dynamic_library,
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
    ACTION_NAMES.cpp_link_static_library,
    ACTION_NAMES.clif_match,
]

def _cc_feature_impl(ctx):
    flag_sets = []
    env_sets = []

    if ctx.attr.cc_flags:
        flag_sets.append(flag_set(
            actions = ALL_CPP_COMPILE_ACTION_NAMES,
            flag_groups = [
                flag_group(
                    flags = ctx.attr.cc_flags,
                    expand_if_available = ctx.attr.expand_if_available if ctx.attr.expand_if_available else None,
                    expand_if_not_available = ctx.attr.expand_if_not_available if ctx.attr.expand_if_not_available else None,
                ),
            ],
        ))
    if ctx.attr.c_flags:
        flag_sets.append(flag_set(
            actions = [
                ACTION_NAMES.c_compile,
            ],
            flag_groups = [
                flag_group(
                    flags = ctx.attr.c_flags,
                    expand_if_available = ctx.attr.expand_if_available if ctx.attr.expand_if_available else None,
                    expand_if_not_available = ctx.attr.expand_if_not_available if ctx.attr.expand_if_not_available else None,
                ),
            ],
        ))
    if ctx.attr.compiler_flags:
        flag_sets.append(flag_set(
            actions = ALL_CC_COMPILE_ACTION_NAMES,
            flag_groups = [
                flag_group(
                    flags = ctx.attr.compiler_flags,
                    expand_if_available = ctx.attr.expand_if_available if ctx.attr.expand_if_available else None,
                    expand_if_not_available = ctx.attr.expand_if_not_available if ctx.attr.expand_if_not_available else None,
                ),
            ],
        ))
    if ctx.attr.linker_flags:
        flag_sets.append(flag_set(
            actions = ACTION_NAME_GROUPS.all_cc_link_actions,
            flag_groups = [
                flag_group(
                    flags = ctx.attr.linker_flags,
                    expand_if_available = ctx.attr.expand_if_available if ctx.attr.expand_if_available else None,
                    expand_if_not_available = ctx.attr.expand_if_not_available if ctx.attr.expand_if_not_available else None,
                ),
            ],
        ))

    if len(ctx.attr.env_sets.items()) > 0:
        env_sets.append(env_set(
            actions = ALL_ACTIONS,
            env_entries = [
                env_entry(e[0], e[1])
                for e in ctx.attr.env_sets.items()
            ],
        ))

    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            provides = ctx.attr.provides,
            implies = [target.label.name for target in ctx.attr.implies],
            flag_sets = flag_sets,
            env_sets = env_sets,
        ),
    ]

cc_feature = rule(
    _cc_feature_impl,
    attrs = {
        "enabled": attr.bool(
            default = False,
            doc = "This feature should be enabled by default.",
        ),
        "provides": attr.string_list(
            default = [],
            doc = "Unique key for which only one provider of a functionality \
can be enabled any given time.",
        ),
        "implies": attr.label_list(
            default = [],
            doc = "Other features that are automatically enabled with this \
feature.",
        ),
        "cc_flags": attr.string_list(
            default = [],
            doc = "The list of flags to apply when compiling c++ files.",
        ),
        "c_flags": attr.string_list(
            default = [],
            doc = "The list of flags to apply when compiling c files.",
        ),
        "compiler_flags": attr.string_list(
            default = [],
            doc = "The list of flags to pass to the compiler regardless of if \
the target is a C or C++ library.",
        ),
        "linker_flags": attr.string_list(
            default = [],
            doc = "The list of flags to apply when linking.",
        ),
        "env_sets": attr.string_dict(
            default = {},
            doc = "The list of env variables to apply.",
        ),
        "expand_if_available": attr.string(
            doc = "A build variable that needs to be available \
                               in order to expand the flag_group.",
        ),
        "expand_if_not_available": attr.string(
            doc = "A build variable that needs to be not available \
                            in order to expand the flag_group.",
        ),
    },
    provides = [FeatureInfo],
)

def _file_to_library_flag(file):
    lib_prefix = "lib"
    if file.basename.startswith(lib_prefix):
        library_name = file.basename.replace("." + file.extension, "")
        library_flag = "-l" + library_name[len(lib_prefix):]
    else:
        library_flag = file.path

    return library_flag

LIB_EXCLUDE_CRT_OBJS = ["crt1.o", "Scrt1.o", "gcrt1.o", "Mcrt1.o"]

def _filter_for_shared_obj(flags):
    libFlags = []
    for flag in flags:
        needed = True
        for crtObj in LIB_EXCLUDE_CRT_OBJS:
            if crtObj in flag:
                needed = False
                break

        if needed:
            libFlags.append(flag)

    return libFlags

def _import_feature_impl(ctx):
    toolchain_import_info = ctx.attr.toolchain_import[CcToolchainImportInfo]

    include_flags = [
        "-isystem " + inc
        for inc in toolchain_import_info
            .compilation_context.includes.to_list()
    ]
    builtin_dirs = toolchain_import_info.compilation_context.builtin_includes.to_list()

    injected_include_flags = [
        "-include " + hdr.path
        for hdr in toolchain_import_info
            .compilation_context
            .injected_headers
            .to_list()
    ]

    framework_flags = [
        "-F " + fw
        for fw in toolchain_import_info
            .compilation_context.frameworks.to_list()
    ]

    linker_runtime_path_flags = depset([
        "-Wl,-rpath," + path
        for path in toolchain_import_info
            .linking_context.runtime_paths.to_list()
    ]).to_list()

    linker_dir_flags = depset([
        "-L" + file.dirname
        for file in toolchain_import_info
            .linking_context.static_libraries.to_list()
    ] + [
        "-L" + file.dirname
        for file in toolchain_import_info
            .linking_context.dynamic_libraries.to_list()
    ] + [
        "-L" + file.dirname
        for file in toolchain_import_info
            .linking_context.additional_libs.to_list()
    ]).to_list()

    linker_flags = depset([
        _file_to_library_flag(file)
        for file in toolchain_import_info
            .linking_context.static_libraries.to_list()
    ] + [
        _file_to_library_flag(file)
        for file in toolchain_import_info
            .linking_context.dynamic_libraries.to_list()
    ]).to_list()

    flag_sets = []

    # Project-level includes (NOT the builtin dirs)
    if include_flags:
        flag_sets.append(flag_set(
            actions = ALL_CC_COMPILE_ACTION_NAMES,
            flag_groups = [flag_group(flags = include_flags)],
        ))

    if framework_flags:
        flag_sets.append(flag_set(
            actions = ALL_CC_COMPILE_ACTION_NAMES,
            flag_groups = [flag_group(flags = framework_flags)],
        ))

    if injected_include_flags:
        flag_sets.append(flag_set(
            actions = ALL_CC_COMPILE_ACTION_NAMES,
            flag_groups = [flag_group(flags = injected_include_flags)],
        ))

    # Generic link flags (search paths, libraries, rpaths)
    if linker_dir_flags or linker_flags or linker_runtime_path_flags:
        flag_sets.append(flag_set(
            actions = CC_LINK_EXECUTABLE_ACTION_NAMES,
            flag_groups = [flag_group(
                flags = linker_dir_flags + linker_flags + linker_runtime_path_flags
            )],
        ))

    # For shared objects: avoid startup CRT objects
    linker_flags_for_shared_obj = depset(_filter_for_shared_obj([
        _file_to_library_flag(file)
        for file in toolchain_import_info
            .linking_context.static_libraries.to_list()
    ]) + [
        _file_to_library_flag(file)
        for file in toolchain_import_info
            .linking_context.dynamic_libraries.to_list()
    ]).to_list()

    if linker_dir_flags or linker_flags_for_shared_obj:
        flag_sets.append(flag_set(
            actions = [ACTION_NAMES.cpp_link_dynamic_library, ACTION_NAMES.cpp_link_nodeps_dynamic_library],
            flag_groups = [flag_group(flags = linker_dir_flags + linker_flags_for_shared_obj)],
        ))

    # --- NEW: always drive lld via the driver (keeps C++ runtime/crt wired) ---
    if ctx.attr.use_lld:
        flag_sets.append(flag_set(
            actions = ACTION_NAME_GROUPS.all_cc_link_actions,
            flag_groups = [flag_group(flags = ["-fuse-ld=lld"])],
        ))

    # --- NEW: if you insist on using a pure ld.lld as 'ld', inject C++ runtime ---
    if ctx.attr.inject_cxx_runtime:
        # Restrict to C++ link actions so we don't pollute C-only links
        cxx_link_actions = [
            ACTION_NAMES.cpp_link_executable,
            ACTION_NAMES.cpp_link_dynamic_library,
            ACTION_NAMES.cpp_link_nodeps_dynamic_library,
            ACTION_NAMES.cpp_link_static_library,
        ]
        cxx_runtime_flags = [
            "-stdlib=libstdc++",  # harmless if default; ensures libstdc++ with Clang
            "-lstdc++",
            "-lm",
            "-lgcc_s",
            "-lgcc",
            "-lc",
            "-lpthread",
            "-ldl",
        ]
        # Optional extra search path if you want to pass a GCC lib dir string here:
        if ctx.attr.gcc_lib_dir:
            cxx_runtime_flags = [
                "-L" + ctx.attr.gcc_lib_dir,
                "-Wl,-rpath," + ctx.attr.gcc_lib_dir,
            ] + cxx_runtime_flags

        flag_sets.append(flag_set(
            actions = cxx_link_actions,
            flag_groups = [flag_group(flags = cxx_runtime_flags)],
        ))

    library_feature = _feature(
        name = ctx.label.name,
        enabled = ctx.attr.enabled,
        flag_sets = flag_sets,
        implies = ctx.attr.implies,
        provides = ctx.attr.provides,
    )
    # NOTE: builtin include dirs are carried via BuiltinIncludesInfo; do NOT emit them as -isystem
    return [library_feature, ctx.attr.toolchain_import[DefaultInfo], BuiltinIncludesInfo(dirs = builtin_dirs)]

cc_toolchain_import_feature = rule(
    _import_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
        "provides": attr.string_list(),
        "requires": attr.string_list(),
        "implies": attr.string_list(),
        "toolchain_import": attr.label(providers = [CcToolchainImportInfo]),
        # NEW: keep lld but drive it via the driver (clang++), default True
        "use_lld": attr.bool(
            default = True,
            doc = "Appends -fuse-ld=lld to all C/C++ link actions.",
        ),
        # NEW: if your ld tool is a pure ld.lld, inject C++ runtime libs for C++ links
        "inject_cxx_runtime": attr.bool(
            default = False,
            doc = "Append -stdlib=libstdc++ and C++ runtime libs on C++ link actions.",
        ),
        # Optional: pass a GCC lib dir if you want to add -L/-rpath explicitly
        "gcc_lib_dir": attr.string(
            default = "",
            doc = "Optional GCC runtime lib directory to add as -L and rpath.",
        ),
    },
    provides = [FeatureInfo, DefaultInfo, BuiltinIncludesInfo],
)


def _sysroot_feature(ctx):
    return _feature(
        name = ctx.label.name,
        enabled = ctx.attr.enabled,
        provides = ctx.attr.provides,
        implies = ["sysroot"] + [label.name for label in ctx.attr.implies],
        flag_sets = [
            flag_set(
                actions = CC_LINK_EXECUTABLE_ACTION_NAMES +
                          DYNAMIC_LIBRARY_LINK_ACTION_NAMES +
                          ALL_CC_COMPILE_ACTION_NAMES,
                flag_groups = [
                    flag_group(
                        flags = [
                            "--sysroot",
                            ctx.attr.sysroot.label.workspace_root,
                        ],
                    ),
                    flag_group(
                        flags = [
                            "--target=" + ctx.attr.target,
                        ],
                    ),
                ],
            ),
        ],
    )

cc_toolchain_sysroot_feature = rule(
    _sysroot_feature,
    attrs = {
        "enabled": attr.bool(default = False),
        "provides": attr.string_list(),
        "requires": attr.string_list(),
        "implies": attr.string_list(),
        "sysroot": attr.label(mandatory = True),
        "target": attr.string(mandatory = True),
    },
    provides = [FeatureInfo],
)
