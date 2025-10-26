@echo off
set SRC_DIR=%~dp0src

REM -- ADJUST THIS -- Set path to where LOVE2D is installed on your system and love.exe is located
set LOVE_EXE=C:\Program Files\LOVE\love.exe
REM ----------------------------------------------------------------------------------------------

set OUT_EXE=%SRC_DIR%\TileMapper.exe
set GAME_LOVE=%SRC_DIR%\game.love
cd /d "%SRC_DIR%"
if exist game.love del game.love
7z a -tzip game.love * -xr!*.exe
powershell -Command "[System.IO.File]::WriteAllBytes('%OUT_EXE%', [System.IO.File]::ReadAllBytes('%LOVE_EXE%') + [System.IO.File]::ReadAllBytes('%GAME_LOVE%'))"

echo Done! TileMapper.exe created in %SRC_DIR%
pause