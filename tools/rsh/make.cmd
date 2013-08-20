@echo off

set filename=serv

set masm_path=Z:\Programs\Development\RCE\Assemblers\MASM\
set masm_inc=%masm_path%\include
set masm_lib=%masm_path%\lib

set path=%path%%masm_path%\bin

%masm_path%\bin\ml /c /coff /nologo /I%masm_inc% /I%masm_path%\macros /I%cd% %filename%.asm
%masm_path%\bin\link /libpath:%masm_lib% /nologo /SUBSYSTEM:CONSOLE %filename%.obj

echo STFU already!!
pause>nul
