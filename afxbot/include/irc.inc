;-----------------------------------------------------------------------
irc_connect     proto :dword,:dword,:dword,:dword,:dword
irc_thread      proto :dword
irc_parse       proto :dword,:dword,:dword,:dword,:dword
irc_command     proto :dword,:dword,:dword,:dword,:dword

;-----------------------------------------------------------------------
IRC_CONNECT struct
  dwsocket                dword ?
  dwserver                dword ?
  dwport                  dword ?
  sznick                  byte MAX_NAME_LENGTH dup(?)
  szchannel               byte MAX_CHANNEL_LENGTH dup(?)
  szchannelpass           byte MAX_PASS_LENGTH dup(?)
IRC_CONNECT ends

;-----------------------------------------------------------------------
SERVER_MSG_PING equ 01340D049h
SERVER_MSG_001  equ 055B20A4Bh
SERVER_MSG_005  equ 052DFCE52h
SERVER_MSG_433  equ 097989078h
SERVER_MSG_PRIVMSG  equ 045163144h

;-----------------------------------------------------------------------
