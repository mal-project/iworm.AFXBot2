@echo off
set filename=afxbot

set masm=z:\programs\development\rce\assemblers\masm
set path=%path%%masm%\bin

set masm_inc=%masm%\include
set masm_lib=%masm%\lib


%masm%\bin\ml  /c /coff /nologo /I%masm_inc% /I%masm%\macros /I%cd%\include /I%cd%\..\common %filename%.asm
%masm%\bin\link /EXPORT:get_token /libpath:%masm_lib% /nologo /SUBSYSTEM:CONSOLE %filename%.obj /out:bin\%filename%.exe

echo Asphyxia//MAL
pause>nul