;-----------------------------------------------------------------------
.code
;-----------------------------------------------------------------------
xcopy   proc    uses esi edi ecx lpdest, lpsource, dwlen
    mov     esi, lpsource
    mov     edi, lpdest
    mov     ecx, dwlen
    rep     movsb
    ret
    
xcopy endp

;-----------------------------------------------------------------------
xfill   proc    uses esi ecx eax dwbyte:byte, lpdest, dwlen
    movzx   eax, dwbyte
    mov     edi, lpdest
    mov     ecx, dwlen
    rep     stosb
    ret
    
xfill   endp

;-----------------------------------------------------------------------
