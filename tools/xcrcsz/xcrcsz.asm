;21:17:11.00 - Thu 04/02/2009 ------------------------------------------
; this test program perform a custom crc32 over strings
;-----------------------------------------------------------------------
.386
.model flat, stdcall
option casemap: none
;-----------------------------------------------------------------------
include     project.inc

;-----------------------------------------------------------------------
include     ..\..\common\xcrcsz.inc

;-----------------------------------------------------------------------
.code

    start:
        
        pushad
        
        invoke  GetCurrentDirectory, sizeof szbuffer, addr szbuffer
        invoke  lstrcat, addr szbuffer, SADD("\commands.ini")
        invoke  GetPrivateProfileSection, SADD("commands"), addr szbuffer, sizeof szbuffer, addr szbuffer

        lea     esi, offset szbuffer
       
        .while  (1)
            
            mov     ebx, esi
            
            .break  .if !byte ptr [esi]
            invoke  xcrcsz, esi
            
            invoke  printf, SADD("String: '%s' - CRC: %0.9lXh", EOL), ebx, eax
       
        .endw

        popad
        ret
    end start
;-----------------------------------------------------------------------
