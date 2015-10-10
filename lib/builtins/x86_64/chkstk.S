
#if defined(__WIN32__)

#define PAGE_SIZE 0x1000

.global __alloca
.global ___chkstk

// Probes memory pages from %rsp down to (%rsp-%rcx), then adjusts %rsp down by %rcx bytes
__alloca:
        mov     %rcx, %rax              // x64 alloca is a normal function, so the argument is in %rcx
        // fallthrough

// Probes memory pages from %rsp down to (%rsp-%rax), then adjusts %rsp down by %rax bytes
// Preserves integer argument registers %rcx, %rdx, %r8 and %r9
// ___chkstk uses %rax as the argument.
___chkstk:
        mov     %rsp, %r10              // put old TOS in %r10
        sub     %rax, %r10              // compute new TOS in %r10

        sbb     %rax, %rax              // %rax = FF...F if CF==1, else 0
        not     %rax                    // invert
        and     %rax, %r10              // reset new TOS to 0 if we underflowed; this will cause probing
                                        // to run into the stack limit and trigger a "stack overflow" exception

        mov     %rsp, %rax              // put probe pointer in %rax
        and     $~(PAGE_SIZE-1), %rax   // round down to page boundary
        sub     $PAGE_SIZE, %rax        // skip to the next page (old TOS page doesn't need probing)
1:
        cmp     %r10, %rax              // is new TOS in the current page yet?
        ja      2f
                                        // yes
        mov     (%rsp), %rax            // copy return address...
        mov     %rax, (%r10)            // into the new TOS (this also probes the last page)

        mov     %r10, %rsp              // install new TOS into %rsp
        ret
2:
        test    %rax, (%rax)            // probe
        sub     $PAGE_SIZE, %rax        // skip to the next page
        jmp     1b


// Probes memory pages from %rsp down to (%rsp-%rax).
// Preserves all registers, including %rax.
// Unlike linux __chkstk above, %rsp is left unadjusted.
.global ___chkstk_ms
___chkstk_ms:
        push    %rax                    // save working registers
        push    %r10

        lea     16(%rsp), %r10          // put old TOS in %r10 (before pushing registers)
        sub     %rax, %r10              // compute new TOS in %r10

        sbb     %rax, %rax              // %rax = FF...F if CF==1, else 0
        not     %rax                    // invert
        and     %rax, %r10              // reset new TOS to 0 if we underflowed; this will cause probing
                                        // to run into the stack limit and trigger a "stack overflow" exception

        mov     16(%rsp), %rax          // put probe pointer in %rax
        and     $~(PAGE_SIZE-1), %rax   // round down to page boundary
        sub     $PAGE_SIZE, %rax        // skip to the next page (old TOS page doesn't need probing)
1:
        cmp     %r10, %rax              // is new TOS in the current page yet?
        ja      2f
                                        // yes
        test    %r10, (%r10)            // probe the last page

        pop     %r10                    // restore registers
        pop     %rax
        ret
2:
        test    %rax, (%rax)            // probe
        sub     $PAGE_SIZE, %rax        // skip to the next page
        jmp     1b

#endif
