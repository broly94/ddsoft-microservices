# ===============================================
# SCRIPT: Fix Completo WebSocket + Rebuild
# ===============================================
# Uso: .\docker-fix-websocket.ps1
# Ubicacion: Raiz del proyecto (ddsoft/)

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "FIX COMPLETO: WebSocket HMR + Variables de Entorno" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# Asegurar que estamos en el directorio correcto
$projectRoot = $PSScriptRoot
Set-Location $projectRoot

Write-Host "PROBLEMAS QUE SE VAN A CORREGIR:" -ForegroundColor Yellow
Write-Host "  [X] WebSocket HMR falla desde IPs externas" -ForegroundColor Red
Write-Host "  [X] ERR_NAME_NOT_RESOLVED en navegador" -ForegroundColor Red
Write-Host "  [X] Variables de entorno incorrectas" -ForegroundColor Red
Write-Host ""

Write-Host "ACCIONES QUE SE EJECUTARAN:" -ForegroundColor Yellow
Write-Host "  1. Actualizar .env.local con localhost" -ForegroundColor White
Write-Host "  2. Detener dashboard" -ForegroundColor White
Write-Host "  3. Rebuild COMPLETO (sin cache)" -ForegroundColor White
Write-Host "  4. Reiniciar dashboard" -ForegroundColor White
Write-Host ""

# Paso 1: Actualizar .env.local
Write-Host "[1/4] Actualizando variables de entorno..." -ForegroundColor Yellow
$dashboardPath = Join-Path $projectRoot "rag_ia_dashboard"
Copy-Item -Path "$dashboardPath\.env.docker" -Destination "$dashboardPath\.env.local" -Force
Write-Host "      Variables de entorno actualizadas" -ForegroundColor Green
Write-Host ""

# Paso 2: Detener dashboard
Write-Host "[2/4] Deteniendo dashboard..." -ForegroundColor Yellow
docker-compose stop rag-ia-dashboard
if ($LASTEXITCODE -eq 0) {
    Write-Host "      Dashboard detenido" -ForegroundColor Green
} else {
    Write-Host "      ERROR al detener dashboard" -ForegroundColor Red
}
Write-Host ""

# Paso 3: Rebuild completo
Write-Host "[3/4] Reconstruyendo dashboard..." -ForegroundColor Yellow
Write-Host "      Esto puede tardar 3-5 minutos..." -ForegroundColor Gray
docker-compose build --no-cache rag-ia-dashboard

if ($LASTEXITCODE -eq 0) {
    Write-Host "      Dashboard reconstruido correctamente" -ForegroundColor Green
} else {
    Write-Host "      ERROR al reconstruir dashboard" -ForegroundColor Red
    Write-Host ""
    Write-Host "Ver logs: docker-compose logs rag-ia-dashboard" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Paso 4: Reiniciar dashboard
Write-Host "[4/4] Reiniciando dashboard..." -ForegroundColor Yellow
docker-compose up -d rag-ia-dashboard

if ($LASTEXITCODE -eq 0) {
    Write-Host "      Dashboard reiniciado" -ForegroundColor Green
} else {
    Write-Host "      ERROR al reiniciar dashboard" -ForegroundColor Red
    exit 1
}

# Esperar un poco para que inicie
Write-Host ""
Write-Host "Esperando a que el dashboard inicie..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Mostrar logs en tiempo real por 10 segundos
Write-Host ""
Write-Host "Mostrando logs (presiona Ctrl+C para salir)..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Ver logs
docker-compose logs --tail=50 -f rag-ia-dashboard

