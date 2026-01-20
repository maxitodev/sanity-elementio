#!/bin/bash
# deploy.sh - Script de despliegue para Sanity Studio en Cloud Run
# Uso: ./deploy.sh

set -e

# Configuración
PROJECT_ID="webpage-elementio"
REGION="us-central1"
SERVICE_NAME="sanity-elementio"
REPO_NAME="sanity-repo"
IMAGE_NAME="$REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$SERVICE_NAME"

echo "========================================"
echo "  Desplegando Sanity Studio a Cloud Run"
echo "========================================"
echo ""

# Paso 1: Construir imagen Docker
echo "[1/3] Construyendo imagen Docker..."
docker build -t $IMAGE_NAME .
echo "✓ Imagen construida"
echo ""

# Paso 2: Subir imagen a Artifact Registry
echo "[2/3] Subiendo imagen a Artifact Registry..."
docker push $IMAGE_NAME
echo "✓ Imagen subida"
echo ""

# Paso 3: Desplegar a Cloud Run
echo "[3/3] Desplegando a Cloud Run..."
gcloud run deploy $SERVICE_NAME \
    --image $IMAGE_NAME \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated \
    --project $PROJECT_ID

echo ""
echo "========================================"
echo "  ✓ Despliegue completado!"
echo "========================================"
echo ""
echo "URL: https://$SERVICE_NAME-830119773865.$REGION.run.app"
