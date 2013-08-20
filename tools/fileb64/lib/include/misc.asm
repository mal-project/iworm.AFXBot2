.code
;-----------------------------------------------------------------------
; This procedure determines throught ddFlag if use lpBuffer as buffer or
; allocates ddSize bytes of virtual memory as buffer.
; Then return in eax a pointer to that buffer
_get_buffer  proc    dwflag, dwsize, lpbuffer
    pushad

    and     dwflag, VIRTUAL_ALLOC
    .if     !ZERO?
        invoke  VirtualAlloc, 0, dwsize, MEM_COMMIT, PAGE_READWRITE
    .else
        mov     eax, lpbuffer
    .endif  
    
    mov     dword ptr [esp+28], eax

    popad
    ret
_get_buffer  endp

IF INCLUDE_ENCODE
;-----------------------------------------------------------------------
; This procedure writes the common header ("begin ooo [filename]")
; where ooo is the unix access rights octet, and cuz we are'nt at unix box
; just put 666 (rw-rw-rw-) and the file name
_write_header proc    lpbuffer, lpfilename
   
    ; this code looks pretty ugly
    option epilogue: none
    pushad

    mov     edi, lpbuffer

    ; --------------------------------
    push    LINE1_LENGHT-1
    pop     ecx
    mov     esi, offset mime_header_line1
    rep     movsb

    ; --------------------------------
    mov     esi, lpfilename
    call    @copysz

    ; --------------------------------
    push    LINE2_LENGHT-1
    pop     ecx        
    mov     esi, offset mime_header_line2
    rep     movsb

    ; --------------------------------
    mov     esi, lpfilename
    call    @copysz

    ; --------------------------------
    push    LINE3_LENGHT-1
    pop     ecx
    mov     esi, offset mime_header_line3
    rep     movsb

    mov     dword ptr [esp], edi
    jmp     @ret

@copysz:
    .repeat
        lodsb
        stosb
    .until  !byte ptr [esi]
    ret

@ret:
    popad
    
    option epilogue: EpilogueDef
    ret

_write_header endp
ENDIF

;-----------------------------------------------------------------------
