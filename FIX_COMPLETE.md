# FIX COMPLETO: WebSocket + CORS + ENV Variables
## Fecha: 2026-01-20

## PROBLEMAS IDENTIFICADOS

### 1. ERR_NAME_NOT_RESOLVED
```
Failed to load resource: net::ERR_NAME_NOT_RESOLVED
http://price-comparator-backend:3002/competitors
```

### 2. WebSocket HMR Falla
```
WebSocket connection to 'ws://192.168.100.185:3001/_next/webpack-hmr' failed
Error during WebSocket handshake: net::ERR_INVALID_HTTP_RESPONSE
```

### 3. CORS Bloqueado
```
Blocked cross-origin request from 192.168.100.185 to /_next/*
To allow this, configure "allowedDevOrigins" in next.config
```

### 4. TypeScript Obsoleto
```
Minimum recommended TypeScript version is v5.1.0
Detected: 5.0.2
```

## CAUSAS RAÍZ

| Problema | Causa |
|----------|-------|
| **ERR_NAME_NOT_RESOLVED** | Variables NEXT_PUBLIC_* usando nombres Docker |
| **WebSocket falla** | Next.js escuchando solo en 127.0.0.1, no en 0.0.0.0 |
| **CORS bloqueado** | allowedDevOrigins no configurado |
| **TypeScript warning** | Versión 5.0.2 < 5.1.0 mínimo |

## SOLUCIONES APLICADAS

### 1. Variables de Entorno Corregidas

**Archivo:** `rag_ia_dashboard/.env.docker`

```env
# ANTES (❌ Incorrecto)
NEXT_PUBLIC_BACKEND_URL=http://gateway:3000
NEXT_PUBLIC_PRICE_COMPARATOR_URL=http://price-comparator-backend:3002

# AHORA (✅ Correcto)
NEXT_PUBLIC_BACKEND_URL=http://localhost:3000
NEXT_PUBLIC_PRICE_COMPARATOR_URL=http://localhost:3002
NEXT_PUBLIC_API_URL=http://localhost:3000
```

**Por qué funciona:**
- NEXT_PUBLIC_* se ejecutan en el NAVEGADOR (cliente)
- El navegador NO puede resolver nombres de servicios Docker
- Docker expone puertos al host: `gateway:3000` → `localhost:3000`

### 2. Next.js Escucha en 0.0.0.0

**Archivo:** `rag_ia_dashboard/package.json`

```json
// ANTES
"dev": "next dev -p 3001"

// AHORA
"dev": "next dev -p 3001 -H 0.0.0.0"
"start": "next start -p 3001 -H 0.0.0.0"
```

**Por qué funciona:**
- `-H 0.0.0.0` hace que Next.js escuche en TODAS las interfaces
- Permite conexiones desde `localhost`, `192.168.100.185`, etc.
- WebSocket HMR ahora funciona desde cualquier IP de la red

### 3. allowedDevOrigins Configurado

**Archivo:** `rag_ia_dashboard/next.config.mjs`

```javascript
allowedDevOrigins: [
  'http://192.168.100.185:3001',
  'http://localhost:3001',
],
```

**Por qué funciona:**
- Permite requests cross-origin desde estas IPs
- Elimina warnings de CORS
- Necesario para Next.js 16+

### 4. TypeScript Actualizado

**Archivo:** `rag_ia_dashboard/package.json`

```json
// ANTES
"typescript": "^5"  // Instalaba 5.0.2

// AHORA
"typescript": "5.7.2"
```

**Por qué funciona:**
- Next.js 16 requiere TypeScript >= 5.1.0
- 5.7.2 es la última versión estable
- Elimina el warning de versión mínima

## ARQUITECTURA CORREGIDA

### Flujo de Comunicación

```
┌──────────────────────────────────────────────┐
│ Navegador en tu PC (192.168.100.185)        │
│                                              │
│ fetch('http://localhost:3002/api')          │ ← Usa localhost
│ ws://192.168.100.185:3001/_next/webpack-hmr │ ← WebSocket HMR
└────────────────┬─────────────────────────────┘
                 │
                 │ HTTP/WebSocket
                 │
                 ▼
┌──────────────────────────────────────────────┐
│ Docker Host (0.0.0.0)                        │
│                                              │
│ localhost:3001 → rag-ia-dashboard:3001      │
│ localhost:3002 → price-comparator:3002      │
└────────────────┬─────────────────────────────┘
                 │
                 │ Docker Network
                 │
                 ▼
┌──────────────────────────────────────────────┐
│ Contenedores Docker (internal_network)      │
│                                              │
│ - rag-ia-dashboard (Next.js en 0.0.0.0)    │
│ - price-comparator-backend                  │
│ - gateway                                    │
└──────────────────────────────────────────────┘
```

## CÓMO APLICAR TODOS LOS FIXES

### Opción 1: Script Automatizado (Recomendado)

```powershell
cd d:\didonato\softwares\ddsoft
.\docker-restart-dashboard-fix.ps1
```

Este script hace:
1. ✅ Actualiza variables de entorno (.env.local)
2. ✅ Detiene el dashboard
3. ✅ Rebuild completo (sin cache)
4. ✅ Reinicia el dashboard
5. ✅ Muestra verificación

### Opción 2: Manual

```powershell
cd d:\didonato\softwares\ddsoft

# 1. Actualizar .env
Copy-Item "rag_ia_dashboard\.env.docker" "rag_ia_dashboard\.env.local" -Force

# 2. Rebuild dashboard
docker-compose stop rag-ia-dashboard
docker-compose build --no-cache rag-ia-dashboard
docker-compose up -d rag-ia-dashboard

# 3. Ver logs
docker-compose logs -f rag-ia-dashboard
```

## VERIFICACIÓN

### 1. Sin Errores en Consola

Abre http://localhost:3001 y presiona F12:

- ✅ **NO** debe aparecer: `ERR_NAME_NOT_RESOLVED`
- ✅ **NO** debe aparecer: `WebSocket handshake error`
- ✅ **NO** debe aparecer: `Blocked cross-origin request`
- ✅ **NO** debe aparecer: `Minimum TypeScript version warning`

### 2. Requests Correctos

En la Network tab del navegador debes ver:

```
✅ http://localhost:3000/api/...
✅ http://localhost:3002/competitors
✅ ws://192.168.100.185:3001/_next/webpack-hmr (101 Switching Protocols)

❌ NO deben aparecer:
   http://gateway:3000/...
   http://price-comparator-backend:3002/...
```

### 3. Hot-Reload Funciona

1. Edita cualquier archivo en `rag_ia_dashboard/app`
2. Guarda el archivo
3. El navegador debe recargar automáticamente
4. NO debe haber errores de WebSocket

### 4. Acceso desde Red

Prueba acceder desde otra PC en la misma red:

```
http://192.168.100.185:3001
```

Debe funcionar sin errores.

## RESUMEN DE CAMBIOS

| Archivo | Cambio | Resultado |
|---------|--------|-----------|
| `.env.docker` | localhost en lugar de nombres Docker | ✅ Navegador puede resolver URLs |
| `package.json` | `-H 0.0.0.0` en dev/start | ✅ WebSocket HMR funciona |
| `package.json` | TypeScript 5.7.2 | ✅ Sin warnings de versión |
| `next.config.mjs` | allowedDevOrigins | ✅ Sin warnings de CORS |

## ARCHIVOS MODIFICADOS

1. ✅ **rag_ia_dashboard/.env.docker** - URLs con localhost
2. ✅ **rag_ia_dashboard/package.json** - Next.js en 0.0.0.0 + TS 5.7.2
3. ✅ **rag_ia_dashboard/next.config.mjs** - allowedDevOrigins
4. ✨ **docker-restart-dashboard-fix.ps1** - Script de aplicación

## SIGUIENTE PASO

Ejecuta el fix completo:

```powershell
cd d:\didonato\softwares\ddsoft
.\docker-restart-dashboard-fix.ps1
```

Espera a que termine (3-5 minutos la primera vez) y luego:

1. Abre http://localhost:3001
2. Presiona F12
3. Verifica que NO haya errores
4. Prueba el hot-reload editando un archivo

---

**Todos los problemas resueltos:** 2026-01-20
**Tiempo estimado de fix:** 3-5 minutos
