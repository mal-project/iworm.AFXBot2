; reference: The Base16, Base32, and Base64 Data Encodings [http://tools.ietf.org/html/rfc4648]
;-----------------------------------------------------------------------
; Base64 encode/decode implentation by Asphyxia's motherfucker
; Asphx // FOFF - astalavista.ms
; version 0.2.1
; coded for clarity, and a little bit of performance (compared with previous version)
;-----------------------------------------------------------------------

;4.  Base 64 Encoding
;
;   The following description of base 64 is derived from [3], [4], [5],
;   and [6].  This encoding may be referred to as "base64".
;
;   The Base 64 encoding is designed to represent arbitrary sequences of
;   octets in a form that allows the use of both upper- and lowercase
;   letters but that need not be human readable.
;
;   A 65-character subset of US-ASCII is used, enabling 6 bits to be
;   represented per printable character.  (The extra 65th character, "=",
;   is used to signify a special processing function.)
;
;   The encoding process represents 24-bit groups of input bits as output
;   strings of 4 encoded characters.  Proceeding from left to right, a
;   24-bit input group is formed by concatenating 3 8-bit input groups.
;   These 24 bits are then treated as 4 concatenated 6-bit groups, each
;   of which is translated into a single character in the base 64
;   alphabet.
;
;   Each 6-bit group is used as an index into an array of 64 printable
;   characters.  The character referenced by the index is placed in the
;   output string.
;
;                      Table 1: The Base 64 Alphabet
;
;     Value Encoding  Value Encoding  Value Encoding  Value Encoding
;         0 A            17 R            34 i            51 z
;         1 B            18 S            35 j            52 0
;         2 C            19 T            36 k            53 1
;         3 D            20 U            37 l            54 2
;         4 E            21 V            38 m            55 3
;         5 F            22 W            39 n            56 4
;         6 G            23 X            40 o            57 5
;         7 H            24 Y            41 p            58 6
;         8 I            25 Z            42 q            59 7
;         9 J            26 a            43 r            60 8
;        10 K            27 b            44 s            61 9
;        11 L            28 c            45 t            62 +
;        12 M            29 d            46 u            63 /
;        13 N            30 e            47 v
;        14 O            31 f            48 w         (pad) =
;        15 P            32 g            49 x
;        16 Q            33 h            50 y
;
;   Special processing is performed if fewer than 24 bits are available
;   at the end of the data being encoded.  A full encoding quantum is
;   always completed at the end of a quantity.  When fewer than 24 input
;   bits are available in an input group, bits with value zero are added
;   (on the right) to form an integral number of 6-bit groups.  Padding
;   at the end of the data is performed using the '=' character.  Since
;   all base 64 input is an integral number of octets, only the following
;   cases can arise:
;
;   (1) The final quantum of encoding input is an integral multiple of 24
;       bits; here, the final unit of encoded output will be an integral
;       multiple of 4 characters with no "=" padding.
;
;   (2) The final quantum of encoding input is exactly 8 bits; here, the
;       final unit of encoded output will be two characters followed by
;       two "=" padding characters.
;
;   (3) The final quantum of encoding input is exactly 16 bits; here, the
;       final unit of encoded output will be three characters followed by
;       one "=" padding character.
;
;-----------------------------------------------------------------------
.486
.model flat, stdcall
option casemap: none

;-----------------------------------------------------------------------
include project.inc
include misc.asm

;-----------------------------------------------------------------------
.code
;-----------------------------------------------------------------------
    align   4
    IF INCLUDE_DECODE
    ;-------------------------------------------------------------------
    ; This procedure is the core of B64 decode algorithm.
    B64_decode_core  proc    lpsource, lpdest, dwbytes

        pushad
        mov     esi, lpsource
        mov     edi, lpdest
        mov     edx, dwbytes

        mov     eax, dword ptr [esi]            ; four bytes (dword)

        mov     edx, 3
        mov     ecx, 4
        
        .repeat
            mov     ebx, eax
            and     ebx, 0FFh
            .if     bl == '='
                xor     bl, bl
                dec     edx 

            .elseif     bl >= 'A'
                sub     ebx, 41h

            .elseif bl >= '0'
                add     ebx, 0Ah 

            .else
                add     ebx, 019h

            .endif
            mov     al, byte ptr [b64_charset_rev+ebx]   ; get its index

            rol     eax, 8
            dec     ecx
        .until      !ecx

        bswap   eax
        
        xor     ebx, ebx
        xor     ecx, ecx

        or      bl, al       
        mov     ecx, 3
        .repeat
            ror     ebx, 6
            sar     eax, 8
            or      bl, al
            
            dec     ecx
        .until  !ecx
        
        ror     ebx, 6
        bswap   ebx

        mov     dword ptr [esp+28], edx
        mov     dword ptr [edi], ebx

        popad

        ret
    B64_decode_core  endp    

    ;-------------------------------------------------------------------    
    ; This procedure decode an arbitrary lenght given stream of data from B64 format
    ; 
    ; lpdata    -> offset to data for decode
    ; dwlen     -> Data size. Its only necesary if VIRTUAL_ALLOC
    ; dwflag    -> VIRTUAL_ALLOC | IGNORE_HEADER
    ; lpfilename-> where to store filename
    ; lpbuffer  -> buffer offset where to put decoded data. Ignored if VIRTUAL_ALLOC
    ;
    ; return in eax offset to buffer; in ecx size of data
    B64_Decode   proc    lpdata, dwlen, dwflag, lpfilename, lpbuffer
        local   hbuffer
        pushad
        ;---------------------------------------------------------------
        invoke  _get_buffer, dwflag, dwlen, lpbuffer
        mov     hbuffer, eax
       
        mov     esi, lpdata
        
        .if     dword ptr [esi] == MIME_HEADER    ; its have a header?

            and     dwflag, IGNORE_HEADER
            .if     ZERO?
                add     esi, LINE1_LENGHT-1
                mov     edi, lpfilename
                .repeat
                    lodsb
                    stosb
                .until  byte ptr [esi] == '"'
                
                mov     byte ptr [edi], 0
            .endif

            .repeat
                inc     esi
            .until dword ptr [esi] == 0D0A0D22h ;" 13 10 13
            add     esi, 5
        .endif

        mov     edi, hbuffer
        
        xor     eax, eax
        .repeat
            
            .if byte ptr [esi] != 0Dh                
            
                invoke  B64_decode_core, esi, edi, eax
                
                ;add     eax, 3
                
                add     edi, INPUT_BLOCK_SIZE
                add     esi, OUTPUT_BLOCK_SIZE

            .else
                add     esi, 2
            .endif

        .until  !byte ptr [esi]

        m2m     dword ptr [esp+28], hbuffer
        mov     dword ptr [esp+24], eax

        popad
        ret
    B64_Decode   endp
    ENDIF
    
    IF INCLUDE_ENCODE
    ;-------------------------------------------------------------------
    ; This procedure is the core of b64 encode algorithm.
    ; Transform tree bytes (octects) into four sixtects and using it
    ; as an index for a look up table of chars, witch will be the output 
    B64_encode_core  proc    lpsource, lpdest
        pushad
        mov     esi, lpsource
        mov     edi, lpdest
        mov     edx, offset base64_charset
        
        ; 00 00 00 00|00 00 00 00|00 00 00 00   <- octects (AKA bytes)
        ; 00 00 00|00 00 00|00 00 00|00 00 00   <- sixtects
        
        ; 01 10 11 11|01 01 00 00|00 10 00 00|01 00 00 01
        ;             01 00 00 01|00 10 00 00|01 01 00 00
        ;             \      / \      / \       /\      /

        xor     eax, eax
        xor     ebx, ebx
        push    4
        pop     ecx
        
        lodsd
        and     eax, 0FFFFFFh
        bswap   eax
        shr     eax, 8
        ror     eax, 10h
    
        xchg    eax, ebx

        .repeat
            mov     al, bl
            shr     al, 2     ; [>>??????b] [00??????b]
            
            mov     al, byte ptr [base64_charset+eax]
            ;mov     byte ptr [edi], bl
            ;inc     edi
            stosb

            rol     ebx, 6
            and     ebx, 0FFFF00FFh
            
            dec     cl
        .until  ZERO?

        popad        
        ret

    B64_encode_core  endp

    ;-------------------------------------------------------------------    
    ; This procedure code an arbitrary lenght given stream of data to B64 format
    ; 
    ; lpdata    -> offset to data for code
    ; dwlen     -> lenght (bytes) of data
    ; dwflag    -> WRITE_HEADER | VIRTUAL_ALLOC
    ; lpfilename-> If WRITE_HEADER this is needed
    ; lpbuffer  -> buffer offset where to put coded data. Ignored if VIRTUAL_ALLOC
    ;
    ; return in eax offset to buffer; in ecx size of data
    B64_Encode  proc    lpdata, dwlen, dwflag, lpfilename, lpbuffer
        local   dwsize, hbuffer
        pushad
        
        ;---------------------------------------------------------------
        ; this is not optimal, in fact, its pure lazyness..
        mov     eax, dwlen
        imul    eax, OUTPUT_BLOCK_SIZE
        imul    eax, 2
        mov     dwsize, eax

        ;---------------------------------------------------------------
        ; get buffer
        invoke  _get_buffer, dwflag, dwsize, lpbuffer
        mov     hbuffer, eax

        ;---------------------------------------------------------------
        ; set some pointers
        mov     esi, lpdata
        mov     edi, hbuffer

        ;---------------------------------------------------------------
        ; write mime crap header
        and     dwflag, WRITE_HEADER
        .if     !ZERO?
            invoke  _write_header, edi, lpfilename
        .endif

        ;---------------------------------------------------------------
        xor     eax, eax

        .while  eax < dwlen

            xor     ecx, ecx            

            .while  ecx < LINE_SIZE

                ; encode three bytes each loop
                invoke  B64_encode_core, esi, edi
    
                add     esi, INPUT_BLOCK_SIZE
                add     edi, OUTPUT_BLOCK_SIZE
                add     eax, INPUT_BLOCK_SIZE
                
                .break .if eax >= dwlen
                
                inc     ecx
            .endw
            mov     word ptr [edi], CRLF
            add     edi, 2
        .endw
        
        ; 'sup. dont blame me for this i havent a better idea! ok?
        mov     ebx, dwlen
        sub     eax, ebx
        .if !ZERO?
            lea     ebx, [edi-4]
            mov     byte ptr [ebx+1], PADDING_CHARACTER
            dec     eax
            .if !ZERO?
                mov     byte ptr [ebx], PADDING_CHARACTER
            .endif
        .endif 
        ;---------------------------------------------------------------

        ;---------------------------------------------------------------
        ; we ending        
        m2m     dword ptr [esp+28], hbuffer
        sub     edi, dword ptr [hbuffer]
        mov     dword ptr [esp+24], edi
        
        popad
        ret
    B64_Encode endp
    ENDIF
    
    ;-------------------------------------------------------------------
    B64_Clear   proc    lpbuffer, dwflag
        
        and      dwflag, VIRTUAL_ALLOC
        .if     !ZERO?
            invoke  VirtualFree, lpbuffer
        .else
            
            mov     esi, lpbuffer
            .while  byte ptr [esi]
                and byte ptr [esi], 0
                
                inc esi
            .endw

        .endif
        ret
    B64_Clear   endp

;-----------------------------------------------------------------------
    B64_start:
    end B64_start
;-----------------------------------------------------------------------
