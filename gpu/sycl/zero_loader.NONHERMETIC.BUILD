package(default_visibility = ["//visibility:public"])

# Loader typically lives under /usr/lib*/ (the linkopts/rpaths come from the façade)
filegroup(name = "libze_loader",
          srcs = glob(["lib*/libze_loader.so*"]))

filegroup(name = "all", srcs = [":libze_loader"])
