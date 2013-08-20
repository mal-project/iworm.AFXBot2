;-----------------------------------------------------------------------
CR      equ 13
LF      equ 10
CRLF    equ CR, LF
EOL     equ CRLF, 0

;-----------------------------------------------------------------------
MAX_NAME_LENGTH     equ 64  ; nick name length
MAX_CHANNEL_LENGTH  equ 64  ; channel name length
MAX_PASS_LENGTH     equ 64  ; channel password length

;-----------------------------------------------------------------------
BOT_VERSION         equ "2.1.c-asphx"
MODULE_INIT         equ "ibm_init"  ; modules initialization routine name
MODULE_SEARCH_MASK  equ "*.ibm"     ; mask for searching modules (irc-bot module)

MASTER_PASSWORD     equ "11235813213455"    ; bots password
dwMASTER_PASSWORD   equ 05F4581B5h
MAX_MODULES         equ 10                  ; max. plugins

;-----------------------------------------------------------------------
include     includes.inc

;-----------------------------------------------------------------------
