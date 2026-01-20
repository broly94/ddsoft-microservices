# ===============================================
# SCRIPT: Reiniciar Dashboard con Nueva Config
# ===============================================
# Uso: .\docker-restart-dashboard.ps1
# Ubicacion: Raiz del proyecto (ddsoft/)

Write-Host "Reiniciando dashboard con nueva configuracion..." -ForegroundColor Cyan
Write-Host ""

# Asegurar que estamos en el directorio correcto
$projectRoot = $PSScriptRoot
Set-Location $projectRoot

# Copiar .env.docker actualizado a .env.local
Write-Host "Actualizando variables de entorno..." -ForegroundColor Yellow
$dashboardPath = Join-Path $projectRoot "rag_ia_dashboard"
Copy-Item -Path "$dashboardPath\.env.docker" -Destination "$dashboardPath\.env.local" -Force
Write-Host "Variables de entorno actualizadas" -ForegroundColor Green
Write-Host ""

# Detener solo el dashboard
Write-Host "Deteniendo dashboard..." -ForegroundColor Yellow
docker-compose stop rag-ia-dashboard

# Rebuild del dashboard
Write-Host "Reconstruyendo dashboard..." -ForegroundColor Yellow
docker-compose build --no-cache rag-ia-dashboard

# Reiniciar dashboard
Write-Host "Reiniciando dashboard..." -ForegroundColor Yellow
docker-compose up -d rag-ia-dashboard

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Dashboard reiniciado correctamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Dashboard disponible en: http://localhost:3001" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Ver logs: .\docker-logs.ps1 -Service rag-ia-dashboard" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "Error al reiniciar el dashboard" -ForegroundColor Red
    Write-Host ""
}
