;-----------------------------------------------------------------------
include     includes.inc
include     ..\..\common\project.inc
includelib  ..\..\afxbot\bin\afxbot.lib

;-----------------------------------------------------------------------
dcc_handle  proto   :dword
dcc_receive proto   :dword 

;-----------------------------------------------------------------------
DCC_RECEIVE struct
  bsync                   byte ?
  szfile                  byte 64 dup (?)
  szip                    byte 64 dup (?)
  szport                  byte 64 dup (?)
  szsize                  byte 64 dup (?)
DCC_RECEIVE ends

;-----------------------------------------------------------------------
.data
    mdt MODULE_DESCRYPTION_TABLE <'dcc mod', '0.2', <'DCC', _MODULE_TYPE_PRVMSG, offset dcc_handle>>
    
;-----------------------------------------------------------------------
.data?
    lpbot_info    dword   ?

;-----------------------------------------------------------------------

