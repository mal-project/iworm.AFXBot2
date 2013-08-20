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
hello   proc    lpszline
    local   szmsgbuffer[1024]:byte, szbuffer1[64]:byte, szbuffer2[64]:byte

    invoke  get_token, addr szbuffer1, lpszline, ' ', 0, FALSE
    invoke  get_token, addr szbuffer1, addr szbuffer1, ':', 1, FALSE
    invoke  get_token, addr szbuffer1, addr szbuffer1, '!', 0, FALSE
    
    ; its for
    invoke  get_token, addr szbuffer2, lpszline, ' ', 2, FALSE
    
    .if     byte ptr szbuffer2 == '#'
        invoke  wsprintf, addr szmsgbuffer, SADD('PRIVMSG %s :%s', EOL), addr szbuffer2, SADD("Hello everyone!")
    .else
        invoke  wsprintf, addr szmsgbuffer, SADD('PRIVMSG %s :%s', EOL), addr szbuffer1, SADD("Hello sir")
    .endif
    
    mov     eax, lpbot_info
    mov     ebx, (sbot_data ptr [eax]).dwsocket
    invoke  send, ebx, addr szmsgbuffer, FUNC(lstrlen, addr szmsgbuffer), 0
   
    ret
hello   endp

;-----------------------------------------------------------------------
ibm_init    proc    lpsbot_data
    
    m2m     lpbot_info, lpsbot_data
    mov     eax, offset mdt
    
    ret
ibm_init    endp

end
;-----------------------------------------------------------------------
