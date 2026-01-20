# FIX: ERR_NAME_NOT_RESOLVED - Variables de Entorno
## Fecha: 2026-01-20

## PROBLEMA

El navegador no puede resolver nombres de servicios Docker.

### Error en Consola:
```
Error fetching competitors: AxiosError
price-comparator-backend:3002/competitors:1 
Failed to load resource: net::ERR_NAME_NOT_RESOLVED
```

### Warning de CORS:
```
Cross origin request detected from 192.168.100.185 to /_next/*
```

## CAUSA

Las variables `NEXT_PUBLIC_*` estaban configuradas con nombres de servicios Docker:

```env
# INCORRECTO - El navegador no puede resolver esto
NEXT_PUBLIC_BACKEND_URL=http://gateway:3000
NEXT_PUBLIC_PRICE_COMPARATOR_URL=http://price-comparator-backend:3002
```

### ¿Por qué falla?

1. **NEXT_PUBLIC_*** variables se ejecutan en el **NAVEGADOR** (cliente)
2. El navegador corre en tu **máquina host** (Windows)
3. El navegador **NO** puede resolver nombres de servicios Docker
4. Solo los contenedores pueden resolver nombres entre sí

## SOLUCIÓN

### 1. Actualizado `.env.docker`

```env
# CORRECTO - El navegador usa localhost
NEXT_PUBLIC_BACKEND_URL=http://localhost:3000
NEXT_PUBLIC_PRICE_COMPARATOR_URL=http://localhost:3002
NEXT_PUBLIC_API_URL=http://localhost:3000
```

**Por qué funciona:**
- `localhost:3000` → Docker expone `gateway:3000` en el host como `localhost:3000`
- `localhost:3002` → Docker expone `price-comparator-backend:3002` en el host como `localhost:3002`
- El navegador puede acceder a estos puertos expuestos

### 2. Agregado `allowedDevOrigins` en `next.config.mjs`

```javascript
allowedDevOrigins: [
  'http://192.168.100.185:3001',
  'http://localhost:3001',
],
```

Esto elimina el warning de CORS cuando accedes desde otras IPs de la red local.

## ARQUITECTURA DE NEXT.JS

### Código del Cliente (Navegador)
```javascript
// ✅ CORRECTO - Usa NEXT_PUBLIC_* con localhost
const API_URL = process.env.NEXT_PUBLIC_BACKEND_URL; // http://localhost:3000
fetch(`${API_URL}/api/users`)
```

### Código del Servidor (Next.js Server)
```javascript
// Si necesitas llamadas servidor-lado, puedes usar nombres de Docker
// Pero generalmente usamos las mismas NEXT_PUBLIC_* que redirigen
const API_URL = process.env.NEXT_PUBLIC_BACKEND_URL; // http://localhost:3000
```

## FLUJO DE COMUNICACIÓN

```
┌─────────────────────────────────────────────────┐
│ Navegador (Windows Host)                        │
│  - JavaScript React ejecutando                  │
│  - Usa: NEXT_PUBLIC_BACKEND_URL                 │
│  - Valor: http://localhost:3000                 │
└────────────────┬────────────────────────────────┘
                 │
                 │ HTTP Request a localhost:3000
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ Puerto Expuesto del Host                        │
│  localhost:3000 → gateway:3000                  │
│  localhost:3002 → price-comparator-backend:3002 │
└────────────────┬────────────────────────────────┘
                 │
                 │ Docker Network
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ Contenedores Docker                             │
│  - gateway (container)                          │
│  - price-comparator-backend (container)         │
│  - Usan nombres internos entre sí               │
└─────────────────────────────────────────────────┘
```

## CÓMO APLICAR EL FIX

### Opción 1: Script Automático (Recomendado)

```powershell
cd d:\didonato\softwares\ddsoft
.\docker-restart-dashboard.ps1
```

Este script:
1. Copia `.env.docker` actualizado a `.env.local`
2. Detiene el dashboard
3. Rebuild del dashboard
4. Reinicia el dashboard

### Opción 2: Manual

```powershell
cd d:\didonato\softwares\ddsoft

# 1. Copiar .env actualizado
Copy-Item -Path "rag_ia_dashboard\.env.docker" -Destination "rag_ia_dashboard\.env.local" -Force

# 2. Rebuild del dashboard
docker-compose stop rag-ia-dashboard
docker-compose build --no-cache rag-ia-dashboard
docker-compose up -d rag-ia-dashboard

# 3. Ver logs
docker-compose logs -f rag-ia-dashboard
```

## VERIFICACIÓN

Después de aplicar el fix, verifica:

1. **No más errores ERR_NAME_NOT_RESOLVED**
   - Abre http://localhost:3001
   - Abre la consola del navegador (F12)
   - No deberías ver errores de "name not resolved"

2. **Requests correctos**
   ```
   ✅ http://localhost:3000/api/...
   ✅ http://localhost:3002/competitors
   ❌ http://gateway:3000/... (esto NO debe aparecer)
   ❌ http://price-comparator-backend:3002/... (esto NO debe aparecer)
   ```

3. **No más warnings de CORS**
   - El warning de `allowedDevOrigins` debe desaparecer

## RESUMEN

| Elemento | Antes | Ahora | Resultado |
|----------|-------|-------|-----------|
| NEXT_PUBLIC_BACKEND_URL | `http://gateway:3000` | `http://localhost:3000` | ✅ Funciona |
| NEXT_PUBLIC_PRICE_COMPARATOR_URL | `http://price-comparator-backend:3002` | `http://localhost:3002` | ✅ Funciona |
| allowedDevOrigins | No configurado | Agregado | ✅ Sin warnings |

## ARCHIVOS MODIFICADOS

1. ✅ `rag_ia_dashboard/.env.docker` - URLs corregidas
2. ✅ `rag_ia_dashboard/next.config.mjs` - allowedDevOrigins agregado
3. ✨ `docker-restart-dashboard.ps1` - Script helper

## SIGUIENTE PASO

```powershell
cd d:\didonato\softwares\ddsoft
.\docker-restart-dashboard.ps1
```

Luego recarga http://localhost:3001 y verifica que no haya errores en la consola.

---

**Problema resuelto:** 2026-01-20
**Causa raíz:** NEXT_PUBLIC_* usando nombres de Docker en lugar de localhost
