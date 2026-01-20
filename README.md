# Sanity Studio - Elementio

CMS headless para gestionar el contenido de Elementio usando [Sanity.io](https://www.sanity.io/).

## 🚀 URLs

| Entorno | URL |
|---------|-----|
| **Producción** | https://sanity-elementio-830119773865.us-central1.run.app |
| **Sanity Manage** | https://www.sanity.io/manage/project/l055irz8 |

## 📋 Requisitos

- Node.js 20+
- pnpm 10.23.0+
- Docker (para despliegue)
- Google Cloud CLI (para despliegue)

## 🛠️ Desarrollo Local

```bash
# Instalar dependencias
pnpm install

# Iniciar servidor de desarrollo
pnpm dev
```

El studio estará disponible en `http://localhost:3333`

## 📦 Build

```bash
# Crear build de producción
pnpm build
```

## 🚢 Despliegue a Cloud Run

### Despliegue rápido

```powershell
# Windows (PowerShell)
.\deploy.ps1
```

```bash
# Unix/Mac
./deploy.sh
```

### Despliegue manual

```bash
# 1. Construir imagen Docker
docker build -t us-central1-docker.pkg.dev/webpage-elementio/sanity-repo/sanity-elementio .

# 2. Subir imagen a Artifact Registry
docker push us-central1-docker.pkg.dev/webpage-elementio/sanity-repo/sanity-elementio

# 3. Desplegar a Cloud Run
gcloud run deploy sanity-elementio \
  --image us-central1-docker.pkg.dev/webpage-elementio/sanity-repo/sanity-elementio \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

## 🏗️ Arquitectura

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Cloud Run     │────▶│  Sanity API     │────▶│   Sanity CDN    │
│  (nginx:alpine) │     │  (Backend)      │     │   (Assets)      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

- **Cloud Run**: Sirve el Sanity Studio (archivos estáticos con nginx)
- **Sanity API**: Backend gestionado por Sanity.io
- **Sanity CDN**: Almacenamiento de imágenes y archivos

## 📁 Estructura del Proyecto

```
studio-elementio/
├── schemaTypes/        # Definiciones de esquemas
│   ├── index.ts
│   └── postType.ts
├── static/             # Archivos estáticos
├── sanity.config.ts    # Configuración del studio
├── sanity.cli.ts       # Configuración del CLI
├── Dockerfile          # Imagen Docker para Cloud Run
├── nginx.conf          # Configuración de nginx
├── deploy.ps1          # Script de despliegue (Windows)
└── deploy.sh           # Script de despliegue (Unix/Mac)
```

## ⚙️ Configuración

### Variables de entorno

| Variable | Descripción |
|----------|-------------|
| `SANITY_PROJECT_ID` | ID del proyecto: `l055irz8` |
| `SANITY_DATASET` | Dataset: `production` |

### CORS

Asegúrate de que la URL de Cloud Run esté configurada en los CORS origins:
1. Ve a [Sanity Manage > API](https://www.sanity.io/manage/project/l055irz8/api)
2. Agrega: `https://sanity-elementio-830119773865.us-central1.run.app`
3. Marca "Allow credentials"

## 📝 Scripts disponibles

| Script | Descripción |
|--------|-------------|
| `pnpm dev` | Inicia servidor de desarrollo |
| `pnpm build` | Crea build de producción |
| `pnpm start` | Inicia servidor de producción |
| `pnpm deploy` | Despliega a Sanity hosting |

## 🔧 Tecnologías

- [Sanity v4](https://www.sanity.io/)
- [React 19](https://react.dev/)
- [TypeScript](https://www.typescriptlang.org/)
- [Docker](https://www.docker.com/)
- [Google Cloud Run](https://cloud.google.com/run)
- [nginx](https://nginx.org/)
