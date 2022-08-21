::credits sebastien.kirche@gmail.com
@echo off
%~d0
cd "%~dp0"
del /Q /F *.pbl
cd src

set target=json_test_app
set pbver=220

echo Rebuild the pbl from sources
echo.
orcascr%pbver% /D targetname="%target%" ..\bootstrap-pbl.orca
echo.

if errorlevel 1 goto failed
goto ok

:failed
echo Process failed ?
goto end:

:ok
echo Done. 
copy /Y *.pbl .. 1>nul
copy /Y *.pbt .. 1>nul
cd ..
echo *.pbl files should have been copied in the project directory.

:end
pause