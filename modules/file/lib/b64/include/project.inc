;-----------------------------------------------------------------------
include includes.inc

;-----------------------------------------------------------------------
CRLF        equ 0A0Dh

;-----------------------------------------------------------------------
; PRIVATE
INCLUDE_ENCODE  equ     TRUE
INCLUDE_DECODE  equ     TRUE

OUTPUT_BLOCK_SIZE   equ     4
INPUT_BLOCK_SIZE    equ     3
LINE_SIZE           equ     13h

VIRTUAL_ALLOC       equ     00000010b
WRITE_HEADER        equ     00000100b
IGNORE_HEADER       equ     00001000b

MIME_HEADER         equ     454D494Dh ; "EMIM"
PADDING_CHARACTER   equ     '='

;-----------------------------------------------------------------------
.const
    IF INCLUDE_ENCODE   
    mime_header_line1   db  'MIME-Version: 1.0', 13, 10, 'Content-Type: application/octet-stream; name="',0
    mime_header_line2   db  '"', 13, 10, 'Content-Transfer-Encoding: base64', 13, 10, 'Content-Disposition: attachment; filename="',0
    mime_header_line3   db  '"', 13, 10, 13, 10, 0
    LINE1_LENGHT        equ sizeof mime_header_line1
    LINE2_LENGHT        equ sizeof mime_header_line2
    LINE3_LENGHT        equ sizeof mime_header_line3
    
    base64_charset      db  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",0
    ENDIF
    
    IF INCLUDE_DECODE
    b64_charset_rev     db  00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h, 08h, 09h, 0Ah, 0Bh, 0Ch, 0Dh, 0Eh, 0Fh, 10h, 11h, 12h, 13h, 14h, 15h, 16h, 17h, 18h, 19h, -1, -1, -1, -1, -1, -1
                        db  1Ah, 1Bh, 1Ch, 1Dh, 1Eh, 1Fh, 20h, 21h, 22h, 23h, 24h, 25h, 26h, 27h, 28h, 29h, 2Ah, 2Bh, 2Ch, 2Dh, 2Eh, 2Fh, 30h, 31h, 32h, 33h
                        db  34h, 35h, 36h, 37h, 38h, 39h, 3Ah, 3Bh, 3Ch, 3Dh, 3Eh, -1, -1, -1, 3Fh, 0
    ENDIF
;-----------------------------------------------------------------------
