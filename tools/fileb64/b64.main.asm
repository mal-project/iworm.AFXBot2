.586
.model flat, stdcall
option casemap:none
;-----------------------------------------------------------------------
include     project.inc

;-----------------------------------------------------------------------
.code
    Start:
    pushad
    
    ;-----------------------------------------------------------
    ; checking for command line
    invoke  GetCL, 0, addr hCommandLine
    .if     eax != 1
        jmp     Death
    .endif
    
    ;-----------------------------------------------------------
    ; getting switcher (-d or -e)
    invoke  GetCL, 1, addr hCommandLine
    .if     eax != 1
        jmp     Death
    .endif
    
    .if     word ptr [hCommandLine] == 652Dh ; encode
        mov     hCommand, CMD_ENCODE
    .else
        mov     hCommand, CMD_DECODE
    .endif

    ;-----------------------------------------------------------
    ; getting file name
    invoke  GetCL, 2, addr hCommandLine
    .if     eax != 1
        jmp     Death
    .endif
    
    ;-----------------------------------------------------------
    ; Open file    
    invoke  CreateFile, addr hCommandLine, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, 0, 0
    mov     hFile, eax
    
    .if     hFile == INVALID_HANDLE_VALUE
        jmp     Death
    .else
        
        invoke  GetFileSize, hFile, 0
        mov     hFileSize, eax
        
        invoke  CreateFileMapping, hFile, 0, PAGE_READONLY, 0, 0, 0
        mov     hMapFile, eax
        
        invoke  MapViewOfFile, eax, FILE_MAP_READ, 0, 0, 0 
        mov     hMapView, eax
        
        .if     hCommand == CMD_ENCODE
            invoke  B64_Encode, dword ptr [hMapView], dword ptr [hFileSize], VIRTUAL_ALLOC OR WRITE_HEADER, addr hCommandLine, 0
        .else
            invoke  B64_Decode, dword ptr [hMapView], dword ptr [hFileSize], VIRTUAL_ALLOC, addr hCommandLine, 0
        .endif

        push    eax
        push    ecx

        .if     hCommand == CMD_ENCODE                
            invoke  szCatStr, addr hCommandLine, SADD(".b64")
        .endif

        invoke  CreateFile, addr hCommandLine, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, 0, 0
        .if eax != INVALID_HANDLE_VALUE
            pop     ecx
            pop     ebx
            invoke  WriteFile, eax, ebx, ecx, esp, 0

        .endif
    .endif

Death:

    popad
    ret
    
    end Start
;-----------------------------------------------------------------------