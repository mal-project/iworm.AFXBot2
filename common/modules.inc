;-----------------------------------------------------------------------
handle_module   proto   :dword, :dword, :dword
module_load     proto   :dword, :dword
module_unload   proto   :dword

;-----------------------------------------------------------------------  
ibm_init        proto   :dword

;-----------------------------------------------------------------------  
_MODULE_TYPE_PRVMSG equ 1
_MODULE_TYPE_IRC    equ 2
_MODULE_TYPE_DOTCOMMAND equ 3

;-----------------------------------------------------------------------  
MODULE_COMMANDS struct
    szcommand   db 10 dup(?) ; nombre del comando (".dcc", ".shelld", ".proc")
    dwtype      dd  ?       ; commando (.comando), manejar mensajes del IRC (PING, 433, etc) o comandos del PRVMSG (DCC)
    dwfunction  dd ?        ; offset a la rutina correspondiente
MODULE_COMMANDS ends

MODULE_DESCRYPTION_TABLE    struct
    szmodule        db 16 dup(?); nombre del modulo (para mostrar cuando se usa el comando .modules)
    szversion       db 4  dup(?); "1.0",0 
    scommands       MODULE_COMMANDS <>
MODULE_DESCRYPTION_TABLE    ends

;-----------------------------------------------------------------------
