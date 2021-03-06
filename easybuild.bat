::
:: Easybuild - Generate a clean ET:L build
::
:: Change MSVS version to your own
:: Install assets in fs_homepath/etmain

@echo off
@setLocal EnableDelayedExpansion

ECHO ETLegacy easybuild for Windows

:: The default VS version
set vsversion=12
set vsvarsbat=!VS%vsversion%0COMNTOOLS!\vsvars32.bat
:: Setup the NMake env or find the correct .bat
CALL:SETUPNMAKE
:: CALL "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\VsDevCmd.bat" x86

:: variables
SET homepath=%USERPROFILE%\Documents\ETLegacy
SET basepath=%USERPROFILE%\Documents\ETLegacy-Build
SET build=Debug

PAUSE

:: clean
ECHO Cleaning...
IF EXIST %basepath% RMDIR /s /q %basepath%
IF EXIST build RMDIR /s /q build
DEL /q %homepath%\legacy\*.pk3
DEL /q %homepath%\legacy\*.dll
DEL /q %homepath%\legacy\*.dat

:: build
ECHO Building...
MKDIR build
CD build

cmake -G "NMake Makefiles" -DBUNDLED_LIBS=YES ^
-DCMAKE_BUILD_TYPE=%build% ^
-DCMAKE_INSTALL_PREFIX=%basepath% ^
-DINSTALL_DEFAULT_BASEDIR=%basepath% ^
-DINSTALL_DEFAULT_BINDIR=./ ^
-DINSTALL_DEFAULT_MODDIR=./ ^
-DINSTALL_OMNIBOT=YES ^
..

nmake

:: install
ECHO Installing...
nmake install

:: FIXME: SDL2.dll isn't copied by CMake (why?)
COPY SDL2.dll %basepath%\SDL2.dll

:: done
ECHO The %build% build has been installed in %basepath%.
PAUSE
GOTO:EOF

:SETUPNMAKE
	where nmake >nul 2>&1
	if errorlevel 1 (
		IF EXIST "%vsvarsbat%" (
			CALL "%vsvarsbat%" >nul
		) ELSE (
			CALL:FINDNMAKE
		)
	)
	set errorlevel=0
GOTO:EOF

:FINDNMAKE
	ECHO Finding nmake
	FOR /F "delims==" %%G IN ('SET') DO (
		echo(%%G|findstr /r /c:"COMNTOOLS" >nul && (
			CALL:Substring vsversion %%G 2 2
			CALL "!%%G!\vsvars32.bat" >nul
			GOTO:EOF
		)
	)
GOTO:EOF

:Substring
	::Substring(retVal,string,startIndex,length)
	:: extracts the substring from string starting at startIndex for the specified length
	SET string=%2%
	SET startIndex=%3%
	SET length=%4%

	if "%4" == "0" goto :noLength
	CALL SET _substring=%%string:~%startIndex%,%length%%%
	goto :substringResult
	:noLength
	CALL SET _substring=%%string:~%startIndex%%%
	:substringResult
	set "%~1=%_substring%"
GOTO :EOF