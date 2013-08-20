;-----------------------------------------------------------------------
include     includes.inc
include     ..\..\common\project.inc
includelib  ..\..\afxbot\bin\afxbot.lib

;-----------------------------------------------------------------------
.data
    mdt MODULE_DESCRYPTION_TABLE <'plist mod', '0.1', <'.plist', _MODULE_TYPE_PRVMSG, offset plist>>
    
;-----------------------------------------------------------------------
.data?
    lpbot_info    dword   ?

;-----------------------------------------------------------------------

