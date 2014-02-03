//===-- asan_win.cc -------------------------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file is a part of AddressSanitizer, an address sanity checker.
//
// Windows-specific details.
//===----------------------------------------------------------------------===//

#include "sanitizer_common/sanitizer_platform.h"
#if SANITIZER_WINDOWS
#include <windows.h>

#include <stdlib.h>

#include "asan_interceptors.h"
#include "asan_internal.h"
#include "asan_thread.h"
#include "sanitizer_common/sanitizer_libc.h"
#include "sanitizer_common/sanitizer_mutex.h"

extern "C" {
  SANITIZER_INTERFACE_ATTRIBUTE
  int __asan_should_detect_stack_use_after_return() {
    __asan_init();
    return __asan_option_detect_stack_use_after_return;
  }
}

namespace __asan {

// ---------------------- TSD ---------------- {{{1
static DWORD tsd_key = 0;
static bool tsd_key_inited = false;

void AsanTSDInit(void (*destructor)(void *tsd)) {
  // FIXME: we're ignoring the destructor for now.
  tsd_key = TlsAlloc();
  tsd_key_inited = true;
}

void *AsanTSDGet() {
  CHECK(tsd_key_inited);
  return TlsGetValue(tsd_key);
}

void AsanTSDSet(void *tsd) {
  CHECK(tsd_key_inited);
  TlsSetValue(tsd_key, tsd);
}

void PlatformTSDDtor(void *tsd) {
  AsanThread::TSDDtor(tsd);
}
// ---------------------- Various stuff ---------------- {{{1
void MaybeReexec() {
  // No need to re-exec on Windows.
}

void *AsanDoesNotSupportStaticLinkage() {
#if defined(_DEBUG)
#error Please build the runtime with a non-debug CRT: /MD or /MT
#endif
  return 0;
}

void AsanPlatformThreadInit() {
  // Nothing here for now.
}

void ReadContextStack(void *context, uptr *stack, uptr *ssize) {
  UNIMPLEMENTED();
}

void AsanOnSIGSEGV(int, void *siginfo, void *context) {
  UNIMPLEMENTED();
}

}  // namespace __asan

#endif  // _WIN32
