;-----------------------------------------------------------------------
; B64.inc
; PUBLIC
B64_Encode  proto  :dword, :dword, :dword, :dword, :dword
B64_Decode  proto  :dword, :dword, :dword, :dword, :dword
B64_Clear   proto  :dword, :dword

;-----------------------------------------------------------------------
VIRTUAL_ALLOC       equ     00000010b
WRITE_HEADER        equ     00000100b
IGNORE_HEADER       equ     00001000b

;-----------------------------------------------------------------------