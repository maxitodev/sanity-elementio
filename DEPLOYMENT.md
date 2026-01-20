# Guía de Despliegue - Sanity Studio en Cloud Run

Esta guía detalla el proceso completo de despliegue del Sanity Studio en Google Cloud Run.

## 📋 Índice

1. [Arquitectura de Despliegue](#arquitectura-de-despliegue)
2. [Requisitos Previos](#requisitos-previos)
3. [Flujo de Despliegue](#flujo-de-despliegue)
4. [Configuración Inicial (Primera vez)](#configuración-inicial-primera-vez)
5. [Despliegue Automático](#despliegue-automático)
6. [Despliegue Manual Paso a Paso](#despliegue-manual-paso-a-paso)
7. [Configuración de CORS](#configuración-de-cors)
8. [Troubleshooting](#troubleshooting)

---

## 🏗️ Arquitectura de Despliegue

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FLUJO DE DESPLIEGUE                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   LOCAL                    GOOGLE CLOUD                    PRODUCCIÓN      │
│                                                                             │
│   ┌──────────┐            ┌──────────────────┐           ┌──────────────┐  │
│   │  Source  │──build───▶│ Artifact Registry │──deploy──▶│  Cloud Run   │  │
│   │   Code   │  (Docker)  │   (Docker Image)  │           │   (nginx)    │  │
│   └──────────┘            └──────────────────┘           └──────────────┘  │
│                                                                             │
│   pnpm build              docker push                     Serving on       │
│   docker build                                            port 8080        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Componentes:

| Componente | Descripción |
|------------|-------------|
| **Dockerfile** | Multi-stage build: Node.js para compilar, nginx para servir |
| **Artifact Registry** | Almacena las imágenes Docker en `us-central1-docker.pkg.dev` |
| **Cloud Run** | Ejecuta el contenedor nginx sirviendo archivos estáticos |
| **nginx** | Servidor web que sirve el Sanity Studio en puerto 8080 |

---

## ✅ Requisitos Previos

### Software necesario:

```bash
# Verificar instalaciones
node --version      # v20+
pnpm --version      # 10.23.0+
docker --version    # 20+
gcloud --version    # Google Cloud CLI
```

### Autenticación:

```bash
# Iniciar sesión en Google Cloud
gcloud auth login

# Configurar proyecto
gcloud config set project webpage-elementio

# Autenticar Docker con Artifact Registry
gcloud auth configure-docker us-central1-docker.pkg.dev
```

---

## 🔄 Flujo de Despliegue

### Resumen del proceso:

1. **Build local** → `pnpm build` genera `/dist` con archivos estáticos
2. **Docker build** → Crea imagen con nginx + archivos estáticos
3. **Push a Artifact Registry** → Sube imagen a Google Cloud
4. **Deploy a Cloud Run** → Despliega contenedor desde la imagen

### Datos del proyecto:

| Variable | Valor |
|----------|-------|
| Project ID | `webpage-elementio` |
| Region | `us-central1` |
| Service Name | `sanity-elementio` |
| Repository | `sanity-repo` |
| Image | `us-central1-docker.pkg.dev/webpage-elementio/sanity-repo/sanity-elementio` |
| URL Producción | `https://sanity-elementio-830119773865.us-central1.run.app` |

---

## 🔧 Configuración Inicial (Primera vez)

Solo necesitas hacer esto una vez:

### 1. Habilitar APIs necesarias

```bash
gcloud services enable \
  cloudbuild.googleapis.com \
  containerregistry.googleapis.com \
  artifactregistry.googleapis.com \
  run.googleapis.com \
  --project=webpage-elementio
```

### 2. Crear repositorio en Artifact Registry

```bash
gcloud artifacts repositories create sanity-repo \
  --repository-format=docker \
  --location=us-central1 \
  --project=webpage-elementio
```

### 3. Configurar Docker para Artifact Registry

```bash
gcloud auth configure-docker us-central1-docker.pkg.dev --quiet
```

---

## 🚀 Despliegue Automático

### Windows (PowerShell):

```powershell
.\deploy.ps1
```

### Unix/Mac:

```bash
chmod +x deploy.sh
./deploy.sh
```

---

## 📝 Despliegue Manual Paso a Paso

### Paso 1: Build de Sanity Studio

```bash
pnpm install
pnpm build
```

Esto genera la carpeta `/dist` con:
- `index.html` - Punto de entrada
- `/static` - Assets de Sanity
- `/vendor` - Dependencias (React, styled-components)

### Paso 2: Construir imagen Docker

```bash
docker build -t us-central1-docker.pkg.dev/webpage-elementio/sanity-repo/sanity-elementio .
```

**¿Qué hace el Dockerfile?**
1. **Stage 1 (builder)**: Usa `node:20-alpine`, instala dependencias con pnpm, ejecuta `pnpm build`
2. **Stage 2 (runner)**: Usa `nginx:alpine`, copia `/dist` a nginx, configura para puerto 8080

### Paso 3: Subir imagen a Artifact Registry

```bash
docker push us-central1-docker.pkg.dev/webpage-elementio/sanity-repo/sanity-elementio
```

**Verificar imagen subida:**
```bash
gcloud artifacts docker images list us-central1-docker.pkg.dev/webpage-elementio/sanity-repo
```

### Paso 4: Desplegar a Cloud Run

```bash
gcloud run deploy sanity-elementio \
  --image us-central1-docker.pkg.dev/webpage-elementio/sanity-repo/sanity-elementio \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --project webpage-elementio
```

---

## 🔐 Configuración de CORS

**Importante:** Debes agregar la URL de Cloud Run a los CORS de Sanity.

1. Ve a [Sanity Manage > API](https://www.sanity.io/manage/project/l055irz8/api)
2. En **CORS origins**, agrega:
   ```
   https://sanity-elementio-830119773865.us-central1.run.app
   ```
3. ✅ Marca **Allow credentials**
4. Guarda los cambios

---

## 🔍 Troubleshooting

### Error: Página en blanco

**Causa:** MIME type incorrecto para archivos `.mjs`

**Solución:** Verificar que `nginx.conf` tenga:
```nginx
types {
    application/javascript mjs;
}
```

### Error: Container failed to start

**Causa:** El contenedor no escucha en puerto 8080

**Solución:** Verificar que nginx escuche en 8080:
```nginx
server {
    listen 8080;
    ...
}
```

### Error: CORS blocked

**Causa:** URL de Cloud Run no está en CORS origins de Sanity

**Solución:** Agregar URL en [Sanity Manage > API](https://www.sanity.io/manage/project/l055irz8/api)

### Error: Permission denied al push

**Causa:** Docker no está autenticado con Artifact Registry

**Solución:**
```bash
gcloud auth configure-docker us-central1-docker.pkg.dev
```

### Ver logs de Cloud Run

```bash
gcloud run services logs read sanity-elementio --region us-central1 --limit 50
```

### Ver logs en consola

[Cloud Run Logs](https://console.cloud.google.com/run/detail/us-central1/sanity-elementio/logs?project=webpage-elementio)

---

## 📊 Comandos Útiles

```bash
# Ver servicios desplegados
gcloud run services list --region us-central1

# Ver revisiones del servicio
gcloud run revisions list --service sanity-elementio --region us-central1

# Ver detalles del servicio
gcloud run services describe sanity-elementio --region us-central1

# Eliminar servicio (cuidado!)
gcloud run services delete sanity-elementio --region us-central1
```

---

## 📁 Archivos de Configuración

### Dockerfile

```dockerfile
# Build stage - compila Sanity Studio
FROM node:20-alpine AS builder
RUN corepack enable && corepack prepare pnpm@10.23.0 --activate
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

# Production stage - sirve con nginx
FROM nginx:alpine AS runner
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
ENV PORT=8080
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
```

### nginx.conf (puntos clave)

```nginx
# MIME type para ES modules
types {
    application/javascript mjs;
}

# Servidor en puerto 8080 (requerido por Cloud Run)
server {
    listen 8080;
    root /usr/share/nginx/html;
    
    # SPA routing
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```
