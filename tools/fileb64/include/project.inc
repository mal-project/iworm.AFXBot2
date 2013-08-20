;-----------------------------------------------------------------------
include includes.inc

CRLF    equ 0A0Dh

;-----------------------------------------------------------------------
.const
    szError         db  "Error!",0
    szErrCreating   db  "Cannot create file!",0
   
    
    CMD_ENCODE  equ 101
    CMD_DECODE  equ 102
;-----------------------------------------------------------------------
.data?
    hFile   dd  ?
    hMapFile    dd  ?
    hMapView    dd  ?
    hFileSize   dd  ?
        
    hCommand    dd  ?
    hCommandLine   db   128 dup(?)
;-----------------------------------------------------------------------
