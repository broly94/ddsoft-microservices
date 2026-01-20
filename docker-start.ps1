# ===============================================
# SCRIPT: Levantar Stack de Desarrollo con Docker
# ===============================================
# Uso: .\docker-start.ps1
# Ubicacion: Raiz del proyecto (ddsoft/)

Write-Host "Iniciando stack completo de DDSoft..." -ForegroundColor Cyan
Write-Host ""

# Asegurar que estamos en el directorio correcto
$projectRoot = $PSScriptRoot
Set-Location $projectRoot

# Copiar .env.docker a .env.local para el dashboard
Write-Host "Configurando variables de entorno para Docker..." -ForegroundColor Yellow
$dashboardPath = Join-Path $projectRoot "rag_ia_dashboard"
Copy-Item -Path "$dashboardPath\.env.docker" -Destination "$dashboardPath\.env.local" -Force
Write-Host "Variables de entorno configuradas" -ForegroundColor Green
Write-Host ""

# Levantar los servicios
Write-Host "Levantando contenedores..." -ForegroundColor Yellow
docker-compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Stack iniciado correctamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "SERVICIOS DISPONIBLES" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Frontend:" -ForegroundColor Yellow
    Write-Host "  Dashboard:       http://localhost:3001" -ForegroundColor White
    Write-Host ""
    Write-Host "Backend:" -ForegroundColor Yellow
    Write-Host "  Gateway:         http://localhost:3000" -ForegroundColor White
    Write-Host "  Comparador:      http://localhost:3002" -ForegroundColor White
    Write-Host ""
    Write-Host "Infraestructura:" -ForegroundColor Yellow
    Write-Host "  Redis:           localhost:6379" -ForegroundColor White
    Write-Host "  PostgreSQL Auth: localhost:5432" -ForegroundColor White
    Write-Host "  PostgreSQL Comp: localhost:5433" -ForegroundColor White
    Write-Host "  Qdrant:          http://localhost:6333" -ForegroundColor White
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Comandos utiles:" -ForegroundColor Cyan
    Write-Host "  Ver logs de todo:        docker-compose logs -f" -ForegroundColor Gray
    Write-Host "  Ver logs del dashboard:  docker-compose logs -f rag-ia-dashboard" -ForegroundColor Gray
    Write-Host "  Detener todo:            .\docker-stop.ps1" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "Error al iniciar el stack" -ForegroundColor Red
    Write-Host "Ver logs con: docker-compose logs" -ForegroundColor Yellow
    Write-Host ""
}
