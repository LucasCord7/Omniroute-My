@echo off
setlocal enabledelayedexpansion
title OmniRoute Gateway

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Node.js nao foi encontrado no sistema.
    echo Por favor, instale o Node.js em https://nodejs.org/ para continuar.
    pause
    exit /b 1
)

:menu
cls
echo ===================================================
echo               OMNIROUTE GATEWAY
echo ===================================================
echo.
echo   [1] Iniciar Servidor + Web (Abre Dashboard no Navegador)
echo   [2] Iniciar Somente Servidor (Headless / API em :20128)
echo   [3] Abrir Dashboard Web no Navegador
echo   [4] Definir / Redefinir Senha do Dashboard
echo   [5] App Desktop Oficial (Baixar / Executar .exe)
echo   [6] Verificar Status do Sistema
echo   [7] Iniciar OpenCode conectado ao OmniRoute
echo   [8] Configurar / Sincronizar OpenCode (Patches + Plugins)
echo   [9] Parar Servidor OmniRoute
echo   [0] Sair
echo.
echo ===================================================
set /p "OPCAO=Escolha uma opcao (0-9): "

if "%OPCAO%"=="1" goto opt_server_web
if "%OPCAO%"=="2" goto opt_server_only
if "%OPCAO%"=="3" goto opt_open_web
if "%OPCAO%"=="4" goto opt_password
if "%OPCAO%"=="5" goto opt_desktop_app
if "%OPCAO%"=="6" goto opt_status
if "%OPCAO%"=="7" goto opt_opencode
if "%OPCAO%"=="8" goto opt_setup_opencode
if "%OPCAO%"=="9" goto opt_stop
if "%OPCAO%"=="0" exit /b 0

echo [AVISO] Opcao invalida. Pressione qualquer tecla...
pause >nul
goto menu

:opt_server_web
cls
echo ===================================================
echo   Iniciando OmniRoute (Servidor + Dashboard Web)
echo ===================================================
echo [INFO] API Endpoint: http://localhost:20128/v1
echo [INFO] Dashboard:    http://localhost:20128/dashboard
echo [INFO] O navegador sera aberto automaticamente assim que o servidor responder...
echo.
start "" powershell -NoProfile -WindowStyle Hidden -Command "for ($i=0; $i -lt 90; $i++) { try { $r = Invoke-WebRequest -Uri 'http://localhost:20128/api/monitoring/health' -UseBasicParsing -TimeoutSec 2; if ($r.StatusCode -eq 200) { Start-Process 'http://localhost:20128/dashboard'; break } } catch {} Start-Sleep -Seconds 2 }"
node "%SCRIPT_DIR%node_modules\omniroute\bin\omniroute.mjs" serve
echo.
pause
goto menu

:opt_server_only
cls
echo ===================================================
echo   Iniciando Somente Servidor (Modo Headless / API)
echo ===================================================
echo [INFO] API Endpoint: http://localhost:20128/v1
echo [INFO] Navegador automatico desativado (--no-open).
echo.
node "%SCRIPT_DIR%node_modules\omniroute\bin\omniroute.mjs" serve --no-open
echo.
pause
goto menu

:opt_open_web
cls
echo [INFO] Abrindo Dashboard no navegador...
start http://localhost:20128/dashboard
timeout /t 2 >nul
goto menu

:opt_password
cls
echo ===================================================
echo       Definir / Redefinir Senha do Dashboard
echo ===================================================
echo.
node "%SCRIPT_DIR%node_modules\omniroute\bin\reset-password.mjs"
echo.
pause
goto menu

:opt_desktop_app
cls
echo ===================================================
echo          OmniRoute Desktop App (Windows)
echo ===================================================
echo.
if exist "%SCRIPT_DIR%OmniRoute.Setup.exe" (
    echo [INFO] Executando instalador existente...
    start "" "%SCRIPT_DIR%OmniRoute.Setup.exe"
    pause
    goto menu
)
if exist "%SCRIPT_DIR%OmniRoute.exe" (
    echo [INFO] Executando aplicativo existente...
    start "" "%SCRIPT_DIR%OmniRoute.exe"
    pause
    goto menu
)
echo O app desktop oficial e empacotado em Electron com instalador .exe (~526MB).
echo Deseja baixar o OmniRoute.Setup.exe oficial do GitHub agora? (S/N)
set /p "DL_CONFIRM=> "
if /i "%DL_CONFIRM%"=="S" (
    echo.
    echo [INFO] Baixando instalador do GitHub...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference = 'Continue'; Invoke-WebRequest -Uri 'https://github.com/diegosouzapw/OmniRoute/releases/download/v3.8.50/OmniRoute.Setup.3.8.50.exe' -OutFile '%SCRIPT_DIR%OmniRoute.Setup.exe'"
    if exist "%SCRIPT_DIR%OmniRoute.Setup.exe" (
        echo.
        echo [SUCESSO] Download concluido! Executando instalador...
        start "" "%SCRIPT_DIR%OmniRoute.Setup.exe"
    ) else (
        echo [ERRO] Falha ao baixar o instalador.
    )
)
pause
goto menu

:opt_status
cls
echo ===================================================
echo             Status do OmniRoute
echo ===================================================
echo.
node "%SCRIPT_DIR%node_modules\omniroute\bin\omniroute.mjs" status
echo.
pause
goto menu

:opt_opencode
cls
echo ===================================================
echo        Iniciando OpenCode com OmniRoute
echo ===================================================
echo [INFO] Modelo padrao: opencode-omniroute/auto
echo.
opencode -m opencode-omniroute/auto
pause
goto menu

:opt_setup_opencode
cls
echo ===================================================
echo      Configurando Integracao com OpenCode
echo ===================================================
echo.
node "%SCRIPT_DIR%scripts\setup-opencode.mjs"
echo.
pause
goto menu

:opt_stop
cls
echo ===================================================
echo             Parando Servidor OmniRoute
echo ===================================================
echo.
node "%SCRIPT_DIR%node_modules\omniroute\bin\omniroute.mjs" stop
echo.
pause
goto menu