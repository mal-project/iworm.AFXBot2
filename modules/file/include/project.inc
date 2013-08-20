;-----------------------------------------------------------------------
include     includes.inc
include     ..\..\common\project.inc
includelib  ..\..\afxbot\bin\afxbot.lib
includes     fileio, b64

;-----------------------------------------------------------------------
.data
    mdt MODULE_DESCRYPTION_TABLE <'file mod', '0.1', <'.file', _MODULE_TYPE_PRVMSG, offset file>>
    
;-----------------------------------------------------------------------
.data?
    lpbot_info    dword   ?

;-----------------------------------------------------------------------

