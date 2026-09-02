# OmniRoute Gateway - PowerShell Launcher
$Host.UI.RawUI.WindowTitle = "OmniRoute Gateway"

$SCRIPT_DIR = $PSScriptRoot
if (-not $SCRIPT_DIR) { $SCRIPT_DIR = (Get-Location).Path }

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "[ERRO] Node.js não foi encontrado no sistema." -ForegroundColor Red
    Write-Host "Por favor, instale o Node.js em https://nodejs.org/ para continuar." -ForegroundColor Yellow
    Read-Host "Pressione Enter para sair..."
    exit 1
}

function Show-Menu {
    Clear-Host
    Write-Host "===================================================" -ForegroundColor Cyan
    Write-Host "              OMNIROUTE GATEWAY                    " -ForegroundColor Cyan
    Write-Host "===================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] Iniciar Servidor + Web (Abre Dashboard no Navegador)" -ForegroundColor Green
    Write-Host "  [2] Iniciar Somente Servidor (Headless / API em :20128)" -ForegroundColor Green
    Write-Host "  [3] Abrir Dashboard Web no Navegador" -ForegroundColor Yellow
    Write-Host "  [4] Definir / Redefinir Senha do Dashboard" -ForegroundColor Yellow
    Write-Host "  [5] App Desktop Oficial (Baixar / Executar .exe)" -ForegroundColor Magenta
    Write-Host "  [6] Verificar Status do Sistema" -ForegroundColor Gray
    Write-Host "  [7] Iniciar OpenCode conectado ao OmniRoute" -ForegroundColor Cyan
    Write-Host "  [8] Configurar / Sincronizar OpenCode (Patches + Plugins)" -ForegroundColor Cyan
    Write-Host "  [9] Parar Servidor OmniRoute" -ForegroundColor Red
    Write-Host "  [0] Sair" -ForegroundColor White
    Write-Host ""
    Write-Host "===================================================" -ForegroundColor Cyan
    $choice = Read-Host "Escolha uma opção (0-9)"
    return $choice
}

$cliPath = Join-Path $SCRIPT_DIR "node_modules\omniroute\bin\omniroute.mjs"
$resetPath = Join-Path $SCRIPT_DIR "node_modules\omniroute\bin\reset-password.mjs"
$setupOcPath = Join-Path $SCRIPT_DIR "scripts\setup-opencode.mjs"

do {
    $opt = Show-Menu
    switch ($opt) {
        "1" {
            Clear-Host
            Write-Host "===================================================" -ForegroundColor Cyan
            Write-Host "  Iniciando OmniRoute (Servidor + Dashboard Web)   " -ForegroundColor Cyan
            Write-Host "===================================================" -ForegroundColor Cyan
            Write-Host "[INFO] API Endpoint: http://localhost:20128/v1" -ForegroundColor Gray
            Write-Host "[INFO] Dashboard:    http://localhost:20128/dashboard" -ForegroundColor Gray
            Write-Host "[INFO] O navegador será aberto automaticamente assim que o servidor responder..." -ForegroundColor Yellow
            Write-Host ""
            Start-Job -ScriptBlock {
                for ($i=0; $i -lt 90; $i++) {
                    try {
                        $r = Invoke-WebRequest -Uri 'http://localhost:20128/api/monitoring/health' -UseBasicParsing -TimeoutSec 2
                        if ($r.StatusCode -eq 200) {
                            Start-Process 'http://localhost:20128/dashboard'
                            break
                        }
                    } catch {}
                    Start-Sleep -Seconds 2
                }
            } | Out-Null
            node $cliPath serve
            Read-Host "`nPressione Enter para voltar ao menu..."
        }
        "2" {
            Clear-Host
            Write-Host "===================================================" -ForegroundColor Cyan
            Write-Host "  Iniciando Somente Servidor (Modo Headless / API)  " -ForegroundColor Cyan
            Write-Host "===================================================" -ForegroundColor Cyan
            Write-Host "[INFO] API Endpoint: http://localhost:20128/v1" -ForegroundColor Gray
            Write-Host "[INFO] Navegador automático desativado (--no-open)." -ForegroundColor Gray
            Write-Host ""
            node $cliPath serve --no-open
            Read-Host "`nPressione Enter para voltar ao menu..."
        }
        "3" {
            Write-Host "[INFO] Abrindo Dashboard no navegador..." -ForegroundColor Green
            Start-Process "http://localhost:20128/dashboard"
            Start-Sleep -Seconds 1
        }
        "4" {
            Clear-Host
            Write-Host "===================================================" -ForegroundColor Cyan
            Write-Host "      Definir / Redefinir Senha do Dashboard       " -ForegroundColor Cyan
            Write-Host "===================================================" -ForegroundColor Cyan
            Write-Host ""
            node $resetPath
            Read-Host "`nPressione Enter para voltar ao menu..."
        }
        "5" {
            Clear-Host
            Write-Host "===================================================" -ForegroundColor Cyan
            Write-Host "          OmniRoute Desktop App (Windows)          " -ForegroundColor Cyan
            Write-Host "===================================================" -ForegroundColor Cyan
            Write-Host ""
            $setupExe = Join-Path $SCRIPT_DIR "OmniRoute.Setup.exe"
            $appExe = Join-Path $SCRIPT_DIR "OmniRoute.exe"
            if (Test-Path $setupExe) {
                Write-Host "[INFO] Executando instalador existente..." -ForegroundColor Green
                Start-Process $setupExe
            } elseif (Test-Path $appExe) {
                Write-Host "[INFO] Executando aplicativo existente..." -ForegroundColor Green
                Start-Process $appExe
            } else {
                Write-Host "O app desktop oficial é empacotado em Electron com instalador .exe (~526MB)."
                $confirm = Read-Host "Deseja baixar o OmniRoute.Setup.exe oficial do GitHub agora? (S/N)"
                if ($confirm -eq "S" -or $confirm -eq "s") {
                    Write-Host "[INFO] Baixando instalador do GitHub..." -ForegroundColor Yellow
                    Invoke-WebRequest -Uri "https://github.com/diegosouzapw/OmniRoute/releases/download/v3.8.50/OmniRoute.Setup.3.8.50.exe" -OutFile $setupExe
                    if (Test-Path $setupExe) {
                        Write-Host "[SUCESSO] Download concluído! Executando instalador..." -ForegroundColor Green
                        Start-Process $setupExe
                    } else {
                        Write-Host "[ERRO] Falha ao baixar o instalador." -ForegroundColor Red
                    }
                }
            }
            Read-Host "`nPressione Enter para voltar ao menu..."
        }
        "6" {
            Clear-Host
            Write-Host "===================================================" -ForegroundColor Cyan
            Write-Host "            Status do OmniRoute                    " -ForegroundColor Cyan
            Write-Host "===================================================" -ForegroundColor Cyan
            Write-Host ""
            node $cliPath status
            Read-Host "`nPressione Enter para voltar ao menu..."
        }
        "7" {
            Clear-Host
            Write-Host "===================================================" -ForegroundColor Cyan
            Write-Host "        Iniciando OpenCode com OmniRoute           " -ForegroundColor Cyan
            Write-Host "===================================================" -ForegroundColor Cyan
            Write-Host "[INFO] Modelo padrao: opencode-omniroute/auto" -ForegroundColor Green
            Write-Host ""
            opencode -m opencode-omniroute/auto
            Read-Host "`nPressione Enter para voltar ao menu..."
        }
        "8" {
            Clear-Host
            Write-Host "===================================================" -ForegroundColor Cyan
            Write-Host "      Configurando Integracao com OpenCode         " -ForegroundColor Cyan
            Write-Host "===================================================" -ForegroundColor Cyan
            Write-Host ""
            node $setupOcPath
            Read-Host "`nPressione Enter para voltar ao menu..."
        }
        "9" {
            Clear-Host
            Write-Host "===================================================" -ForegroundColor Cyan
            Write-Host "            Parando Servidor OmniRoute             " -ForegroundColor Cyan
            Write-Host "===================================================" -ForegroundColor Cyan
            Write-Host ""
            node $cliPath stop
            Read-Host "`nPressione Enter para voltar ao menu..."
        }
        "0" {
            exit 0
        }
    }
} while ($opt -ne "0")