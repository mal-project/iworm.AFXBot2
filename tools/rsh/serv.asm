;-----------------------------------------------------------------------
.386
.model flat, stdcall
option casemap:none

;-----------------------------------------------------------------------
include     project.inc

;-----------------------------------------------------------------------
.code
;-----------------------------------------------------------------------
	parse_params	proc lpparams
		local	szcmd[128]:byte

		invoke	GetCL, 1, addr szcmd
		.if		!byte ptr [szcmd] || word ptr [szcmd] == '?-' || word ptr [szcmd] == '-h'
			mov		eax, HELP
		.else
			; shelldconsole 127.0.0.1 1337
			mov		ebx, lpparams
			invoke	GetCL, 1, addr (PARAMS ptr [ebx]).szaddr
			invoke	GetCL, 2, addr (PARAMS ptr [ebx]).szport
			
			mov		eax, CONNECT
			
		.endif
		
		ret
	parse_params	endp

;-----------------------------------------------------------------------
	init_network	proc lpparams

		invoke	WSAStartup, 202h, addr wd
		.if		!eax
			invoke	socket, AF_INET, SOCK_STREAM, IPPROTO_TCP
			.if		eax != INVALID_SOCKET
				mov     so, eax

				mov     sa_in.sin_family, AF_INET;
				mov		ebx, lpparams
				invoke  inet_addr, addr (PARAMS ptr [ebx]).szaddr
				mov     sa_in.sin_addr.S_un.S_addr, eax

				invoke	atodw, addr (PARAMS ptr [ebx]).szport
				invoke  htons, eax
				mov     sa_in.sin_port, ax
			
				invoke  connect, so, addr sa_in, sizeof sa_in
				
			.else
				xor		eax, eax
			.endif
			
		.else
			xor		eax, eax
		.endif
		ret
	init_network	endp

;-----------------------------------------------------------------------
start:
	invoke	printf, SADD("AFXBot rsh client console v0.1", CRLF, "Written by the Asphyxia's motherfucker", CRLF)
    
    invoke	parse_params, addr sparams
    switch	eax
		case	HELP
			invoke	printf, SADD("usage:", CRLF, "rsh [-h | -?] | [IP address Port]", CRLF)
		
		case	CONNECT
			invoke	init_network, addr sparams
			.if		!eax
				invoke  send, so, SADD("Hi dude!"), 8, 0
				
				.while (1)
					invoke  recv, so, addr buffer, sizeof buffer, 0
					.break  .if !eax || eax == SOCKET_ERROR
					
					invoke	printf, addr buffer
					invoke	printf, SADD(CRLF)

				.endw
				
				.if		!eax || eax == SOCKET_ERROR
					invoke	printf, SADD("Socket error!", CRLF)
				
				.else
					invoke	printf, SADD("Connection closed.", CRLF)
				.endif
				
				invoke  WSACleanup

			.else
				invoke	printf, SADD("Error connecting!", CRLF)
				
			.endif
		
	endsw
    
    invoke	ExitProcess, 0
    ret
end start

;-----------------------------------------------------------------------
