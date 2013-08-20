;-----------------------------------------------------------------------
    include     includes.inc

;-----------------------------------------------------------------------
    MAX_CONNECTIONS equ 16
    CRLF            equ 13, 10
    HELP			equ 1
    CONNECT			equ 2
    
	PARAMS	struct
		szaddr	db 128 dup(?)
		szport	db 128 dup(?)
	PARAMS	ends
	
;-----------------------------------------------------------------------
.data?
    buffer  dword   256 dup(?)
    dwRet   dword   ?
    nRet    dword   ?

    sa_in   sockaddr_in <?>
    sa_rem  sockaddr_in <?>
    wd      WSADATA     <?>
    rso     SOCKET      <>
    so      SOCKET      <>
    
    sparams	PARAMS	<>
    
;-----------------------------------------------------------------------
