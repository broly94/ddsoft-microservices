# DDSoft - Sistema de Gestion y Comparacion de Precios

Sistema completo con arquitectura de microservicios y frontend Next.js.

## Estructura del Proyecto

```
ddsoft/
├── docker-compose.yml          <- Orquestador principal de todo el stack
├── .env                        <- Variables de entorno globales
├── .gitignore
│
├── microservices/              <- Microservicios backend
│   ├── gateway/               <- API Gateway (NestJS)
│   ├── auth/                  <- Servicio de autenticacion (NestJS)
│   ├── gescom-data-access/    <- ACL para SQL Server Gescom
│   └── price-comparator/
│       ├── rag_ia_backend/    <- Backend del comparador
│       └── rag-etl-indexer/   <- Indexador ETL + Qdrant
│
└── rag_ia_dashboard/           <- Frontend Next.js
    ├── app/                   <- Paginas de Next.js
    ├── components/            <- Componentes React
    ├── Dockerfile.dev         <- Configuracion Docker
    ├── docker-start.ps1       <- Scripts de gestion
    └── ...
```

## Inicio Rapido

```powershell
cd d:\didonato\softwares\ddsoft

# Verificar configuracion
.\docker-verify.ps1

# Iniciar todo el stack
.\docker-start.ps1

# Ver logs de todos los servicios
.\docker-logs.ps1

# Ver logs de un servicio especifico
.\docker-logs.ps1 -Service rag-ia-dashboard

# Detener todo
.\docker-stop.ps1
```

### Opciones Avanzadas

```powershell
# Rebuild de todo el stack
.\docker-rebuild.ps1 -All

# Rebuild de un servicio especifico
.\docker-rebuild.ps1 -Service rag-ia-dashboard

# Ver logs sin seguir (snapshot)
.\docker-logs.ps1 -Service gateway -Follow:$false
```

## Servicios Disponibles

Una vez iniciado el stack:

| Servicio | URL | Puerto | Descripcion |
|----------|-----|--------|-------------|
| **Dashboard** | http://localhost:3001 | 3001 | Frontend Next.js |
| **Gateway** | http://localhost:3000 | 3000 | API Gateway |
| **Price Comparator** | http://localhost:3002 | 3002 | Backend comparador |
| **Redis** | localhost:6379 | 6379 | Message broker |
| **PostgreSQL (Auth)** | localhost:5432 | 5432 | BD Autenticacion |
| **PostgreSQL (Comparador)** | localhost:5433 | 5433 | BD Comparador |
| **Qdrant** | http://localhost:6333 | 6333 | Vector database |

## Arquitectura

```
┌─────────────────────────────────────────────────┐
│ Browser                                         │
│  http://localhost:3001                          │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ rag-ia-dashboard (Next.js)                      │
│ Puerto: 3001                                    │
└────────────────┬────────────────────────────────┘
                 │
         ┌───────┴───────┬──────────────┐
         ▼               ▼              ▼
    ┌─────────┐    ┌──────────┐   ┌──────────┐
    │ Gateway │    │  Price   │   │  Redis   │
    │ :3000   │    │Comparator│   │  :6379   │
    │         │    │  :3002   │   │          │
    └────┬────┘    └────┬─────┘   └──────────┘
         │              │
         ▼              ▼
    ┌─────────┐    ┌──────────┐
    │   Auth  │    │  Qdrant  │
    │         │    │  :6333   │
    └─────────┘    └──────────┘
         │              │
         ▼              ▼
    ┌─────────┐    ┌──────────┐
    │ db_auth │    │ Gescom   │
    │  :5432  │    │ External │
    └─────────┘    └──────────┘
```

## Configuracion

### Variables de Entorno

El archivo `.env` en la raiz contiene todas las configuraciones:

- **NODE_ENV**: Entorno de ejecucion
- **GOOGLE_GEMINI_API_KEY**: API key de Gemini
- **REDIS_HOST/PORT**: Configuracion Redis
- **AUTH_DB_***: Configuracion BD Auth
- **PRICE_COMPARATOR_DB_***: Configuracion BD Comparador
- **JWT_SECRET/EXPIRATION**: Configuracion JWT
- **QDRANT_URL**: URL de Qdrant
- **GESCOM_DB_***: Configuracion SQL Server externo
- **GATEWAY_PORT**: Puerto del gateway (3000)
- **DASHBOARD_PORT**: Puerto del dashboard (3001)
- **PRICE_COMPARATOR_BACKEND_PORT**: Puerto del comparador (3002)

## Desarrollo

### Hot Reload

Todos los servicios estan configurados con hot-reload:
- Frontend (Next.js): Los cambios se reflejan automaticamente
- Backend (NestJS): Nodemon recarga al detectar cambios

### Logs

```powershell
# Ver logs de un servicio especifico
docker-compose logs -f rag-ia-dashboard
docker-compose logs -f gateway
docker-compose logs -f price-comparator-backend

# Ver logs de todos
docker-compose logs -f
```

### Rebuild

Si cambias el Dockerfile o package.json:

```powershell
# Desde el dashboard
cd rag_ia_dashboard
.\docker-rebuild.ps1

# O manualmente
docker-compose build --no-cache [servicio]
docker-compose up -d [servicio]
```

## Comandos Utiles

```powershell
# Ver estado de servicios
docker-compose ps

# Ver recursos consumidos
docker stats

# Entrar a un contenedor
docker exec -it rag_ia_dashboard sh
docker exec -it gateway sh

# Limpiar todo (cuidado: borra volumenes)
docker-compose down -v
docker system prune -a
```

## Troubleshooting

### Puerto en uso

```powershell
netstat -ano | findstr :3001
taskkill /PID <PID> /F
```

### Docker no responde

1. Reinicia Docker Desktop
2. Espera a que inicie completamente
3. Ejecuta `docker-compose up -d`

### Hot-reload no funciona

```powershell
cd rag_ia_dashboard
.\docker-rebuild.ps1
```

## Documentacion Adicional

- **rag_ia_dashboard/QUICKSTART.md** - Guia rapida del dashboard
- **rag_ia_dashboard/DOCKER_README.md** - Documentacion completa de Docker
- **rag_ia_dashboard/CHANGELOG_DOCKER.md** - Historial de cambios

## Siguiente Paso

```powershell
cd rag_ia_dashboard
.\docker-verify.ps1
.\docker-start.ps1
```

Luego abre http://localhost:3001 en tu navegador.

---

**Ultima actualizacion:** 2026-01-20
**Version:** 1.0.0
