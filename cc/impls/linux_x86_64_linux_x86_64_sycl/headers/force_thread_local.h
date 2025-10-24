/* forces LLVM_THREAD_LOCAL to be C++ thread_local everywhere */
#undef LLVM_THREAD_LOCAL
#define LLVM_THREAD_LOCAL thread_local
