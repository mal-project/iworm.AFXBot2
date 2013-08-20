@echo off
set filename=b64
set fileout=b64

set masm=z:\programs\development\rce\assemblers\masm
set path=%path%%masm%\bin

set masm_bin=%masm%\bin
set masm_inc=%masm%\include
set masm_lib=%masm%\lib

ml.exe /nologo /I"%masm_inc%" /Fo"%cd%\bin\%fileout%.obj" /I"%cd%\include" /c /coff %filename%.asm

polib.exe /out:%cd%\bin\%fileout%.lib "bin\%fileout%.obj"

if  EXIST "bin\%fileout%.obj". del "bin\%fileout%.obj"

echo done :)
pause>nul