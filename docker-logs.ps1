# ===============================================
# SCRIPT: Ver Logs de Servicios en Docker
# ===============================================
# Uso: .\docker-logs.ps1 [-Service nombre] [-Follow]
# Ubicacion: Raiz del proyecto (ddsoft/)

param(
    [string]$Service = "",
    [switch]$Follow = $true,
    [switch]$All = $false
)

# Asegurar que estamos en el directorio correcto
$projectRoot = $PSScriptRoot
Set-Location $projectRoot

if ($All -or $Service -eq "") {
    Write-Host "Mostrando logs de TODOS los servicios..." -ForegroundColor Cyan
    Write-Host ""
    
    if ($Follow) {
        docker-compose logs -f
    } else {
        docker-compose logs
    }
} else {
    Write-Host "Mostrando logs de: $Service" -ForegroundColor Cyan
    Write-Host ""
    
    # Ver logs
    if ($Follow) {
        docker-compose logs -f $Service
    } else {
        docker-compose logs $Service
    }
}
