;-----------------------------------------------------------------------
; fileio v2.2 by Asphyxia's motherfucker
; 11:26 PM 6/2/2009
sfileio  struct
    hfile    HANDLE ?  
    usize    UINT   ?
    hmap     HANDLE ?
    hview    HANDLE ?
sfileio  ends

;-----------------------------------------------------------------------
_FILEIO_ERR_CREATEFILE  equ -1
_FILEIO_ERR_FILEMAPPING equ -2
_FILEIO_ERR_MAPVIEW     equ -3

_FILEIO_READ            equ GENERIC_READ
_FILEIO_READWRITE       equ GENERIC_READ + GENERIC_WRITE
_FILEIO_MODIFYCOPY      equ FILE_MAP_COPY
_FILEIO_MODIFY          equ FILE_MAP_ALL_ACCESS

;-----------------------------------------------------------------------
; dwaccess MUST be _FILEIO_READWRITE
_createfile     proto   lpszfile:dword, dwaccess:dword, dwcreation:dword, dwmodification:dword, dwlength:dword, lpsfileio:dword

_writefile      proto   lpszfile:dword, lpdata:dword, dwlength:dword, dwcreation:dword, lpsfileio:dword

_closefile      proto   lpsfileio:dword

   
;-----------------------------------------------------------------------
