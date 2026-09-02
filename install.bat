@echo off
setlocal enabledelayedexpansion
title Instalador OmniRoute Gateway

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

echo ===================================================
echo         INSTALADOR OMNIROUTE GATEWAY
echo ===================================================
echo.

where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Node.js nao foi encontrado no sistema.
    echo Por favor, instale o Node.js em https://nodejs.org/ para continuar.
    echo.
    pause
    exit /b 1
)

echo [1/4] Instalando dependencias do OmniRoute (npm install)...
call npm install
if %errorlevel% neq 0 (
    echo [ERRO] Falha ao instalar dependencias do npm.
    pause
    exit /b 1
)

echo.
echo [2/4] Verificando instalacao do OpenCode CLI...
where opencode >nul 2>&1
if %errorlevel% neq 0 (
    echo [AVISO] O comando "opencode" nao foi encontrado no sistema.
    echo Deseja instalar o OpenCode globalmente agora via npm (npm i -g opencode-ai)? (S/N)
    set /p "INST_OC=> "
    if /i "!INST_OC!"=="S" (
        echo [INFO] Instalando opencode-ai globalmente...
        call npm install -g opencode-ai
    ) else (
        echo [INFO] Pulando instalacao do opencode-ai.
    )
) else (
    echo [OK] OpenCode CLI ja esta instalado no sistema.
)

echo.
echo [3/4] Configurando arquivo de ambiente local (.env)...
if not exist "%SCRIPT_DIR%.env" (
    copy "%SCRIPT_DIR%.env.example" "%SCRIPT_DIR%.env" >nul
    echo [OK] Arquivo .env criado a partir de .env.example
) else (
    echo [OK] Arquivo .env ja existente.
)

echo.
echo [4/4] Configurando plugin, credenciais e patches exclusivos do OpenCode...
node "%SCRIPT_DIR%scripts\setup-opencode.mjs"

echo.
echo ===================================================
echo   INSTALACAO CONCLUIDA COM SUCESSO!
echo ===================================================
echo.
echo Tudo pronto! Para iniciar o servidor e abrir o dashboard:
echo   Execute: start.bat
echo.
pause