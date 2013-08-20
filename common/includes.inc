;-----------------------------------------------------------------------
include     windows.inc
include     macros.asm
include     xmacros.mac

includes    kernel32, user32, advapi32, urlmon, ws2_32, wsock32, masm32, msvcrt
includes    modules.inc, afxbot.inc

externdef _imp__printf:PTR c_msvcrt
printf equ <_imp__printf>

;-----------------------------------------------------------------------
