;-----------------------------------------------------------------------
; B64.inc
B64_Encode   PROTO   :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
B64_Decode   PROTO   :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

VIRTUAL_ALLOC   equ     00000010b
WRITE_HEADER    equ     00000100b
IGNORE_HEADER   equ     00001000b

;-----------------------------------------------------------------------
