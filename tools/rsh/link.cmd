@echo off
set name=pewrsec
set lcc=Z:\programs\development\apps\lcc
set bin=%lcc%\bin
set lib=%lcc%\lib
%bin%\lcclnk.exe -s -subsystem windows -o bin\%name%.exe bin\%name%.obj

echo done :)
pause>nul