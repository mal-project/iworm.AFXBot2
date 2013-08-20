;-----------------------------------------------------------------------
include     includes.inc
include     ..\..\common\project.inc
includelib  ..\..\afxbot\bin\afxbot.lib

;-----------------------------------------------------------------------
.data
    mdt MODULE_DESCRYPTION_TABLE <'pkill mod', '0.1', <'.pkill', _MODULE_TYPE_PRVMSG, offset pkill>>
    
;-----------------------------------------------------------------------
.data?
    lpbot_info      dword   ?
    dwinitialized   dword   ?
;-----------------------------------------------------------------------

