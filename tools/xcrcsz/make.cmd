@echo off
set filename=xcrcsz

set masm=z:\programs\development\rce\assemblers\masm
set path=%path%%masm%\bin

set masm_inc=%masm%\include
set masm_lib=%masm%\lib


ml  /c /coff /nologo /I%masm_inc% /I%masm%\macros /I%cd%\include /I%cd%\..\common %filename%.asm
link /libpath:%masm_lib% /nologo /SUBSYSTEM:CONSOLE %filename%.obj /out:bin\%filename%.exe

echo Asphyxia//MAL
pause>nul