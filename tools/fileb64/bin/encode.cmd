@ECHO OFF
REM FUCK SHIT
SET FILENAME=data.dat
SET BINARY=b64.main.exe

IF NOT EXIST %FILENAME%. GOTO ERROR
%BINARY% -e %FILENAME%

GOTO END

:ERROR
    ECHO Put some file named '%FILENAME%' to encode
    PAUSE>nul
:END
EXIT