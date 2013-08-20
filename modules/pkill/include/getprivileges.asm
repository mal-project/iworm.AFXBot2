;-----------------------------------------------------------------------
getprivileges   proc
    local   hToken, tp:TOKEN_PRIVILEGES
    pushad
    invoke  GetCurrentProcess
    mov     ebx, eax
    invoke  OpenProcessToken, ebx, TOKEN_ADJUST_PRIVILEGES OR TOKEN_QUERY, addr hToken
    .if     eax
        invoke  LookupPrivilegeValue, NULL, SADD("SeDebugPrivilege"), addr tp.Privileges[0].Luid
        mov     tp.PrivilegeCount, 1
        mov     tp.Privileges[0].Attributes, SE_PRIVILEGE_ENABLED
        invoke  AdjustTokenPrivileges, hToken, FALSE, addr tp, sizeof TOKEN_PRIVILEGES, NULL, NULL
        .if     eax
            return  1
        .else
            return  -1
        .endif       
    .else
        return  -1
    .endif

    popad
    ret
getprivileges   endp

;-----------------------------------------------------------------------
