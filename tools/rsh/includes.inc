;-----------------------------------------------------------------------
include     windows.inc
include     macros.asm
include     xmacros.mac

includes    kernel32, user32, ws2_32, wsock32, msvcrt, masm32

;-----------------------------------------------------------------------
externdef _imp__printf:PTR c_msvcrt
printf equ <_imp__printf>

externdef _imp__strcpy:PTR c_msvcrt
strcpy equ <_imp__strcpy>

externdef _imp__strlen:PTR c_msvcrt
strlen equ <_imp__strlen>

;-----------------------------------------------------------------------
