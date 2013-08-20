;-----------------------------------------------------------------------
include     includes.inc
include     ..\..\common\project.inc
includelib  ..\..\afxbot\bin\afxbot.lib

;-----------------------------------------------------------------------
.data
    mdt MODULE_DESCRYPTION_TABLE <'hello mod', '0.1', <'.hello', _MODULE_TYPE_PRVMSG, offset hello>>
    
;-----------------------------------------------------------------------
.data?
    lpbot_info    dword   ?

;-----------------------------------------------------------------------

