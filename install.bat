@echo off
REM Cola Lark Skills Installer for Windows

echo Cola Lark Skills Installer
echo ==========================
echo.

set "SKILLS_DIR=%USERPROFILE%\.cola\mods\default\skills"
set "SOURCE_DIR=%~dp0skills"

if not exist "%SOURCE_DIR%" (
    echo Error: skills\ directory not found.
    exit /b 1
)

if not exist "%SKILLS_DIR%" mkdir "%SKILLS_DIR%"

for %%s in (lark-setup lark-messages lark-tasks lark-calendar lark-docs lark-base) do (
    if exist "%SOURCE_DIR%\%%s" (
        xcopy /E /I /Y "%SOURCE_DIR%\%%s" "%SKILLS_DIR%\%%s" >nul
        echo   Installed: %%s
    )
)

echo.
echo Done! %SKILLS_DIR%
echo.
echo Now tell Cola: "帮我连接飞书"
pause
