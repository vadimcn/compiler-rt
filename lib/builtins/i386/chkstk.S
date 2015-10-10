
#if defined(__WIN32__)

#define PAGE_SIZE 0x1000

.global __alloca
.global ___chkstk

// Probes memory pages from %esp down to (%esp-%eax), then adjusts %esp down by %eax bytes
// Preserves all registers, except for %eax and %esp.
// x86 __alloca and ___chkstk use %eax as the argument.
___chkstk:
        push    %ecx                    // save working register

        lea     4(%esp), %ecx           // put old TOS in %ecx
        sub     %eax, %ecx              // compute new TOS in %ecx

        sbb     %eax, %eax              // %eax = FF...F if CF==1, else 0
        not     %eax                    // invert
        and     %eax, %ecx              // reset new TOS to 0 if we underflowed; this will cause probing
                                        // to run into the stack limit and trigger a "stack overflow" exception

        lea     4(%esp), %eax           // put probe pointer in %eax
        and     $~(PAGE_SIZE-1), %eax   // round down to page boundary
        sub     $PAGE_SIZE, %eax        // skip to the next page (old TOS page doesn't need probing)
1:
        cmp     %ecx, %eax              // is new TOS in the current page yet?
        ja      2f
                                        // yes
        mov     4(%esp), %eax           // copy return address...
        mov     %eax, (%ecx)            // into the new TOS (this also probes the last page)

        mov     (%esp), %eax            // fetch saved value of %ecx
        mov     %ecx, %esp              // install new TOS into %esp
        mov     %eax, %ecx              // restore %ecx
        ret
2:
        test    %eax, (%eax)            // probe
        sub     $PAGE_SIZE, %eax        // skip to the next page
        jmp     1b


// Probes memory pages from %esp down to (%esp-%eax).
// Preserves all registers, including %eax.
// Unlike linux __chkstk above, %esp is left unadjusted.
.global ___chkstk_ms
___chkstk_ms:
        push    %eax                    // save working registers
        push    %ecx

        lea     8(%esp), %ecx           // put old TOS in %ecx (before pushing registers)
        sub     %eax, %ecx              // compute new TOS in %ecx

        sbb     %eax, %eax              // %eax = FF...F if CF==1, else 0
        not     %eax                    // invert
        and     %eax, %ecx              // reset new TOS to 0 if we underflowed; this will cause probing
                                        // to run into the stack limit and trigger a "stack overflow" exception

        lea     8(%esp), %eax           // put probe pointer in %eax
        and     $~(PAGE_SIZE-1), %eax   // round down to page boundary
        sub     $PAGE_SIZE, %eax        // skip to the next page (old TOS page doesn't need probing)
1:
        cmp     %ecx, %eax              // is new TOS in the current page yet?
        ja      2f
                                        // yes
        test    %ecx, (%ecx)            // probe the last page

        pop     %ecx                    // restore registers
        pop     %eax
        ret
2:
        test    %eax, (%eax)            // probe
        sub     $PAGE_SIZE, %eax        // skip to the next page
        jmp     1b

#endif
