@echo off
REM Set paths
set SRC_DIR=%~dp0src
set LOVE_EXE=C:\Program Files\LOVE\love.exe
set OUT_EXE=%SRC_DIR%\TileMapper.exe
set GAME_LOVE=%SRC_DIR%\game.love

REM Zip src contents into game.love (excluding .exe if present)
cd /d "%SRC_DIR%"
if exist game.love del game.love
REM Adjust 7z path if needed
7z a -tzip game.love * -xr!*.exe

REM Concatenate love.exe and game.love into TileMapper.exe
powershell -Command "[System.IO.File]::WriteAllBytes('%OUT_EXE%', [System.IO.File]::ReadAllBytes('%LOVE_EXE%') + [System.IO.File]::ReadAllBytes('%GAME_LOVE%'))"

echo Done! TileMapper.exe created in %SRC_DIR%
pause