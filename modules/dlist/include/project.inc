;-----------------------------------------------------------------------
include     includes.inc
include     ..\..\common\project.inc
includelib  ..\..\afxbot\bin\afxbot.lib

;-----------------------------------------------------------------------
.data
    mdt MODULE_DESCRYPTION_TABLE <'dlist mod', '0.1', <'.dlist', _MODULE_TYPE_PRVMSG, offset dlist>>
    
;-----------------------------------------------------------------------
.const
    szdrive_removable   db "DRIVE_REMOVABLE",0
    szdrive_fixed       db "DRIVE_FIXED",0
    szdrive_remote      db "DRIVE_REMOTE",0

;-----------------------------------------------------------------------
.data?
    lpbot_info    dword   ?

;-----------------------------------------------------------------------

