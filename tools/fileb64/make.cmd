@ECHO OFF
REM --------------------------------------------------------------------
REM make.cmd v 5.1.3
SET PROJECT=%CD%
SET FILENAME=b64.main
SET FILERES=rsrc

SET PROJECT_BIN=%PROJECT%\bin
SET PROJECT_INC=%PROJECT%\include
SET PROJECT_LIB=%PROJECT%\lib
SET PROJECT_RES=%PROJECT%\res
SET LOG=%PROJECT%\bak\make.log
REM --------------------------------------------------------------------
SET SYNTAX_CHECK_ONLY=0
SET COMPILE_RES=0
SET BUILD_ASM=1
SET LINK_OBJ=1

SET RC_ARGS=/l0 "%PROJECT_RES%\%FILERES%.rc"
SET CVTRES_ARGS=/nologo /machine:ix86 "%PROJECT_RES%\%FILERES%.res"
SET ML_ARGS=/c /coff /nologo "%PROJECT%\%FILENAME%.asm"
SET LINK_ARGS=/release /nologo /subsystem:windows /out:"%PROJECT_BIN%\%FILENAME%.exe" "%PROJECT%\%FILENAME%.obj"
REM --------------------------------------------------------------------

REM --------------------------------------------------------------------
REM Masm32 directories...
REM SET MASMPATH=%systemdrive%/Programs\Development\RCE\Assemblers\MASM
SET MASM=\Programs\Development\RCE\Assemblers\MASM
SET CHECK_DRIVES=C Y Z
REM --------------------------------------------------------------------

REM --------------------------------------------------------------------
REM Checking for masm32 directories
FOR %%i IN (%CHECK_DRIVES%) DO (
    IF EXIST %%i:%MASM%. SET MASM=%%i:%MASM%
)

IF NOT EXIST %MASM%. (
    ECHO NO MASM DIRECTORY FOUND! CHECK PATH IN MAKE.CMD
    ECHO MASM=%MASM%
    GOTO ERROR_CONFIG
)
REM --------------------------------------------------------------------

REM --------------------------------------------------------------------
SET MASM_BIN=%MASM%\bin
REM You may experiment problems with compiled libraries, leave it blank if so...
SET MASM_LIB=%MASM%\lib
REM SET MASMLIB=
SET MASM_INC=%MASM%\include
SET MASM_MACROS=%MASM%\macros
REM --------------------------------------------------------------------

REM --------------------------------------------------------------------
REM upx directories...
REM SET UPX=%systemdrive%\Programs\Development\Tools\UPX\upx.exe
SET UPXPATH=\Programs\Development\RCE\Tools\Packers
SET CHECK_DRIVES=C Y Z
REM --------------------------------------------------------------------

REM --------------------------------------------------------------------
REM Checking for upx directories
FOR %%j IN (%CHECK_DRIVES%) DO (
    IF EXIST %%j:%UPXPATH%. SET UPXPATH=%%j:%UPXPATH%
)

IF NOT EXIST %UPXPATH%. (
    ECHO NO UPX DIRECTORY FOUND! CHECK PATH IN MAKE.CMD
    ECHO.
)
REM --------------------------------------------------------------------
REM Logging some useful hints when problems occurs...
ECHO MASM=%MASM%> "%LOG%"
ECHO UPXPATH=%UPXPATH%>> "%LOG%"
ECHO PROJECT=%PROJECT%>> "%LOG%"
REM --------------------------------------------------------------------
ECHO Make.cmd version 5.1
ECHO Thursday, February 19, 2009

REM --------------------------------------------------------------------
IF %SYNTAX_CHECK_ONLY%==1 (
    ECHO.
    ECHO Syntax check only...
    ECHO ...................................................................
    "%MASM_BIN%\ml.exe" /I"%MASM_INC%" /I"%MASM_MACROS%" /I"%PROJECT_INC%" %ML_ARGS% /Zs >> "%LOG%"
    GOTO _EXIT
)

REM --------------------------------------------------------------------
IF %COMPILE_RES%==1 (

    ECHO.
    ECHO Compiling resources...
    ECHO ...................................................................
    "%MASM_BIN%\rc.exe" /i %MASM_INC% /i %MASM_MACROS% %RC_ARGS% >> "%LOG%"
    REM "%MASM_BIN%\cvtres.exe" %CVTRES_ARGS% >> "%LOG%"
    IF %ERRORLEVEL% NEQ 0 GOTO ERROR_BUILD
)

REM --------------------------------------------------------------------
IF %BUILD_ASM%==1 (
    ECHO.
    ECHO Building...
    ECHO ..................................................................
    "%MASM_BIN%\ml.exe" /I"%MASM_INC%" /I"%MASM_MACROS%" /I"%PROJECT_INC%" %ML_ARGS% >> "%LOG%"
    IF %ERRORLEVEL% NEQ 0 GOTO ERROR_BUILD
)

REM --------------------------------------------------------------------
IF %LINK_OBJ%==1 (
    ECHO.
    ECHO Linking...
    ECHO ..................................................................
    IF EXIST "%MASM_LIB%\kernel32.lib". (
        "%MASM_BIN%\polink.exe" /libpath:"%MASM_LIB%" /libpath:"%PROJECT_LIB%" %LINK_ARGS% >> "%LOG%"
    ) ELSE (
        "%MASM_BIN%\polink.exe" %LINK_ARGS% >> "%LOG%"
    )
    IF %ERRORLEVEL% NEQ 0 GOTO ERROR_BUILD
    IF NOT EXIST "%PROJECT_BIN%\%FILENAME%.exe". GOTO ERROR_BUILD

    IF EXIST "%PROJECT%\*.obj" DEL "%PROJECT%\*.obj"
    IF EXIST "%PROJECT_RES%\*.res" DEL "%PROJECT_RES%\*.res"
    IF EXIST "%PROJECT_RES%\*.obj" DEL "%PROJECT_RES%\*.obj"
)

REM --------------------------------------------------------------------
ECHO.
ECHO Ok. Everything seems fine. What you wanna do now?
SET /P CHOISE=Compress/Launch/Debug/Exit? (c/l/cl/d/e)

IF %CHOISE%==c (
	ECHO.
	ECHO Compressing...
	START /D"%UPXPATH%" upx.exe -9 "%PROJECT_BIN%\%FILENAME%.exe"
	GOTO FINISH
)

IF %CHOISE%==l (
	ECHO.
	ECHO Executing...
	START /D"%PROJECT_BIN%" "" "%FILENAME%.exe"
	GOTO FINISH
)

IF %CHOISE%==cl (
    ECHO.
	ECHO Compressing and launching...
	START /WAIT /D"%UPXPATH%" upx.exe -9 "%PROJECT_BIN%\%FILENAME%.exe"
	START /D"%PROJECT_BIN%" "" "%FILENAME%.exe"
)

IF %CHOISE%==d (
	ECHO.
	ECHO Launching debugger...
	START /D"%CD%" debug.cmd
)
GOTO FINISH
REM --------------------------------------------------------------------

REM --------------------------------------------------------------------
:ERROR_BUILD
    ECHO.
    ECHO AN ERROR HAS OCCURRED! CHECK LOG FOR DETAILS.
    ECHO.
    SET /P CHOISE=Open log in notepad? (y/n)
    IF %CHOISE%==y START notepad.exe "%LOG%"
    EXIT

:ERROR_CONFIG
    PAUSE>nul

:FINISH
    IF EXIST "%LOG%" DEL "%LOG%"

:_EXIT
    EXIT