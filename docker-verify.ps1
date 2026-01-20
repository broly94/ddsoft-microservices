# ===============================================
# SCRIPT: Verificar Configuracion de Docker
# ===============================================
# Uso: .\docker-verify.ps1
# Ubicacion: Raiz del proyecto (ddsoft/)

Write-Host "Verificando configuracion completa del proyecto DDSoft..." -ForegroundColor Cyan
Write-Host ""

$errors = 0
$warnings = 0

# Asegurar que estamos en el directorio correcto
$projectRoot = $PSScriptRoot
Set-Location $projectRoot

# Verificar Docker Desktop
Write-Host "Verificando Docker Desktop..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "  OK - Docker instalado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "  ERROR - Docker no esta instalado o no esta en PATH" -ForegroundColor Red
    $errors++
}

# Verificar Docker Compose
Write-Host ""
Write-Host "Verificando Docker Compose..." -ForegroundColor Yellow
try {
    $composeVersion = docker-compose --version
    Write-Host "  OK - Docker Compose instalado: $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "  ERROR - Docker Compose no esta instalado" -ForegroundColor Red
    $errors++
}

# Verificar archivos principales
Write-Host ""
Write-Host "Verificando archivos del proyecto..." -ForegroundColor Yellow

$requiredFiles = @(
    "docker-compose.yml",
    ".env",
    "README.md",
    ".gitignore",
    "microservices",
    "rag_ia_dashboard"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  OK - $file" -ForegroundColor Green
    } else {
        Write-Host "  ERROR - $file falta" -ForegroundColor Red
        $errors++
    }
}

# Verificar docker-compose.yml
Write-Host ""
Write-Host "Verificando docker-compose.yml..." -ForegroundColor Yellow
if (Test-Path "docker-compose.yml") {
    $composeContent = Get-Content "docker-compose.yml" -Raw
    
    $services = @("redis", "db_auth", "db_price-comparator", "qdrant_db", "gateway", "rag-ia-dashboard", "auth", "price-comparator-backend", "rag-etl-indexer", "gescom-data-access")
    
    foreach ($service in $services) {
        if ($composeContent -match "$service\:") {
            Write-Host "  OK - Servicio '$service' configurado" -ForegroundColor Green
        } else {
            Write-Host "  WARN - Servicio '$service' no encontrado" -ForegroundColor Yellow
            $warnings++
        }
    }
}

# Verificar .env
Write-Host ""
Write-Host "Verificando archivo .env..." -ForegroundColor Yellow
if (Test-Path ".env") {
    $envContent = Get-Content ".env" -Raw
    
    $envVars = @("NODE_ENV", "GATEWAY_PORT", "DASHBOARD_PORT", "PRICE_COMPARATOR_BACKEND_PORT", "REDIS_HOST", "AUTH_DB_USER", "QDRANT_URL")
    
    foreach ($envVar in $envVars) {
        if ($envContent -match $envVar) {
            Write-Host "  OK - $envVar configurada" -ForegroundColor Green
        } else {
            Write-Host "  WARN - $envVar no encontrada" -ForegroundColor Yellow
            $warnings++
        }
    }
}

# Verificar dashboard
Write-Host ""
Write-Host "Verificando rag_ia_dashboard..." -ForegroundColor Yellow
$dashboardFiles = @(
    "rag_ia_dashboard\Dockerfile.dev",
    "rag_ia_dashboard\.dockerignore",
    "rag_ia_dashboard\.env.docker",
    "rag_ia_dashboard\next.config.mjs",
    "rag_ia_dashboard\package.json"
)

foreach ($file in $dashboardFiles) {
    if (Test-Path $file) {
        Write-Host "  OK - $file" -ForegroundColor Green
    } else {
        Write-Host "  ERROR - $file falta" -ForegroundColor Red
        $errors++
    }
}

# Verificar puertos disponibles
Write-Host ""
Write-Host "Verificando puertos..." -ForegroundColor Yellow
$ports = @(3000, 3001, 3002, 5432, 5433, 6333, 6379)

foreach ($port in $ports) {
    $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($connection) {
        Write-Host "  WARN - Puerto $port esta en uso" -ForegroundColor Yellow
        $warnings++
    } else {
        Write-Host "  OK - Puerto $port disponible" -ForegroundColor Green
    }
}

# Resumen
Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "RESUMEN" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

if ($errors -eq 0 -and $warnings -eq 0) {
    Write-Host ""
    Write-Host "Todo esta configurado correctamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Siguiente paso:" -ForegroundColor Cyan
    Write-Host "   Ejecuta: .\docker-start.ps1" -ForegroundColor White
    Write-Host ""
} elseif ($errors -eq 0) {
    Write-Host ""
    Write-Host "Hay $warnings advertencias, pero puedes continuar" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Siguiente paso:" -ForegroundColor Cyan
    Write-Host "   Ejecuta: .\docker-start.ps1" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "Hay $errors errores que deben corregirse" -ForegroundColor Red
    Write-Host "Hay $warnings advertencias" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Revisa los errores anteriores y corrigelos antes de continuar" -ForegroundColor Yellow
    Write-Host ""
}
