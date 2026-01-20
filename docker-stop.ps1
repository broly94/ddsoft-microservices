# ===============================================
# SCRIPT: Detener Stack de Desarrollo con Docker
# ===============================================
# Uso: .\docker-stop.ps1
# Ubicacion: Raiz del proyecto (ddsoft/)

Write-Host "Deteniendo stack completo de DDSoft..." -ForegroundColor Cyan
Write-Host ""

# Asegurar que estamos en el directorio correcto
$projectRoot = $PSScriptRoot
Set-Location $projectRoot

# Detener los servicios
docker-compose down

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Stack detenido correctamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Todos los servicios han sido detenidos:" -ForegroundColor Cyan
    Write-Host "  - Dashboard (Next.js)" -ForegroundColor Gray
    Write-Host "  - Gateway (NestJS)" -ForegroundColor Gray
    Write-Host "  - Auth Service" -ForegroundColor Gray
    Write-Host "  - Price Comparator Backend" -ForegroundColor Gray
    Write-Host "  - ETL Indexer" -ForegroundColor Gray
    Write-Host "  - Gescom Data Access" -ForegroundColor Gray
    Write-Host "  - Redis" -ForegroundColor Gray
    Write-Host "  - PostgreSQL (Auth y Comparador)" -ForegroundColor Gray
    Write-Host "  - Qdrant" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Para reiniciar: .\docker-start.ps1" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "Error al detener el stack" -ForegroundColor Red
    Write-Host ""
}
