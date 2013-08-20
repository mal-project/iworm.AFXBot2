@echo off
set filename=file

set masm=z:\programs\development\rce\assemblers\masm
set path=%path%%masm%\bin

set masm_inc=%masm%\include
set masm_lib=%masm%\lib


ml  /c /coff /nologo /I%masm_inc% /I%masm%\macros /I%cd%\include %filename%.asm
link /def:include\%filename%.def /dll /noentry /libpath:%masm_lib% /libpath:%cd%\lib /nologo /SUBSYSTEM:WINDOWS %filename%.obj /out:bin\%filename%.dll

echo Asphyxia//MAL
pause>nul