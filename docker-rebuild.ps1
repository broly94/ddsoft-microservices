# ===============================================
# SCRIPT: Rebuild de Contenedores
# ===============================================
# Uso: .\docker-rebuild.ps1 [-Service nombre]
# Ubicacion: Raiz del proyecto (ddsoft/)

param(
    [string]$Service = "",
    [switch]$All = $false
)

# Asegurar que estamos en el directorio correcto
$projectRoot = $PSScriptRoot
Set-Location $projectRoot

if ($All -or $Service -eq "") {
    Write-Host "Reconstruyendo TODOS los servicios..." -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Deteniendo servicios..." -ForegroundColor Yellow
    docker-compose down
    
    Write-Host "Reconstruyendo imagenes..." -ForegroundColor Yellow
    docker-compose build --no-cache
    
    Write-Host "Reiniciando servicios..." -ForegroundColor Yellow
    docker-compose up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "Todos los servicios reconstruidos y reiniciados!" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "Error al reconstruir los servicios" -ForegroundColor Red
        Write-Host ""
    }
} else {
    Write-Host "Reconstruyendo servicio: $Service" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Deteniendo servicio..." -ForegroundColor Yellow
    docker-compose stop $Service
    
    Write-Host "Reconstruyendo imagen..." -ForegroundColor Yellow
    docker-compose build --no-cache $Service
    
    Write-Host "Reiniciando servicio..." -ForegroundColor Yellow
    docker-compose up -d $Service
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "Servicio reconstruido y reiniciado!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Ver logs: .\docker-logs.ps1 -Service $Service" -ForegroundColor Cyan
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "Error al reconstruir el servicio" -ForegroundColor Red
        Write-Host ""
    }
}
