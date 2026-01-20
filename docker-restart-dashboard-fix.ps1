# ===============================================
# SCRIPT: Reiniciar Dashboard con Fixes
# ===============================================
# Uso: .\docker-restart-dashboard-fix.ps1
# Ubicacion: Raiz del proyecto (ddsoft/)

Write-Host "Aplicando fixes y reiniciando dashboard..." -ForegroundColor Cyan
Write-Host ""

# Asegurar que estamos en el directorio correcto
$projectRoot = $PSScriptRoot
Set-Location $projectRoot

Write-Host "FIXES QUE SE APLICARAN:" -ForegroundColor Yellow
Write-Host "  1. Variables de entorno (localhost en lugar de nombres Docker)" -ForegroundColor White
Write-Host "  2. Next.js escucha en 0.0.0.0 (permite conexiones desde red)" -ForegroundColor White
Write-Host "  3. TypeScript actualizado a 5.7.2" -ForegroundColor White
Write-Host "  4. allowedDevOrigins configurado" -ForegroundColor White
Write-Host ""

# Copiar .env.docker actualizado a .env.local
Write-Host "1/4 Actualizando variables de entorno..." -ForegroundColor Yellow
$dashboardPath = Join-Path $projectRoot "rag_ia_dashboard"
Copy-Item -Path "$dashboardPath\.env.docker" -Destination "$dashboardPath\.env.local" -Force
Write-Host "    Variables de entorno actualizadas" -ForegroundColor Green
Write-Host ""

# Detener el dashboard
Write-Host "2/4 Deteniendo dashboard..." -ForegroundColor Yellow
docker-compose stop rag-ia-dashboard
Write-Host "    Dashboard detenido" -ForegroundColor Green
Write-Host ""

# Rebuild completo del dashboard
Write-Host "3/4 Reconstruyendo dashboard (esto puede tardar unos minutos)..." -ForegroundColor Yellow
docker-compose build --no-cache rag-ia-dashboard
Write-Host "    Dashboard reconstruido" -ForegroundColor Green
Write-Host ""

# Reiniciar dashboard
Write-Host "4/4 Reiniciando dashboard..." -ForegroundColor Yellow
docker-compose up -d rag-ia-dashboard

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "====================================" -ForegroundColor Green
    Write-Host "DASHBOARD REINICIADO CORRECTAMENTE" -ForegroundColor Green
    Write-Host "====================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "FIXES APLICADOS:" -ForegroundColor Cyan
    Write-Host "  [OK] Variables de entorno usando localhost" -ForegroundColor Green
    Write-Host "  [OK] Next.js escuchando en 0.0.0.0" -ForegroundColor Green
    Write-Host "  [OK] TypeScript 5.7.2" -ForegroundColor Green
    Write-Host "  [OK] allowedDevOrigins configurado" -ForegroundColor Green
    Write-Host ""
    Write-Host "ACCESO:" -ForegroundColor Cyan
    Write-Host "  Local:    http://localhost:3001" -ForegroundColor White
    Write-Host "  Red:      http://192.168.100.185:3001" -ForegroundColor White
    Write-Host ""
    Write-Host "COMANDOS UTILES:" -ForegroundColor Cyan
    Write-Host "  Ver logs:     .\docker-logs.ps1 -Service rag-ia-dashboard" -ForegroundColor Gray
    Write-Host "  Detener todo: .\docker-stop.ps1" -ForegroundColor Gray
    Write-Host ""
    Write-Host "VERIFICACION:" -ForegroundColor Yellow
    Write-Host "  1. Abre http://localhost:3001 en tu navegador" -ForegroundColor White
    Write-Host "  2. Presiona F12 para abrir la consola" -ForegroundColor White
    Write-Host "  3. Verifica que NO haya errores:" -ForegroundColor White
    Write-Host "     - ERR_NAME_NOT_RESOLVED" -ForegroundColor Gray
    Write-Host "     - WebSocket errors" -ForegroundColor Gray
    Write-Host "     - CORS warnings" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "ERROR al reiniciar el dashboard" -ForegroundColor Red
    Write-Host ""
    Write-Host "Ver logs con: .\docker-logs.ps1 -Service rag-ia-dashboard" -ForegroundColor Yellow
    Write-Host ""
}
