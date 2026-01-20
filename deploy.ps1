# deploy.ps1 - Script de despliegue para Sanity Studio en Cloud Run
# Uso: .\deploy.ps1

$ErrorActionPreference = "Stop"

# Configuración
$PROJECT_ID = "webpage-elementio"
$REGION = "us-central1"
$SERVICE_NAME = "sanity-elementio"
$REPO_NAME = "sanity-repo"
$IMAGE_NAME = "$REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$SERVICE_NAME"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Desplegando Sanity Studio a Cloud Run" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Paso 1: Construir imagen Docker
Write-Host "[1/3] Construyendo imagen Docker..." -ForegroundColor Yellow
docker build -t $IMAGE_NAME .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Fallo al construir la imagen Docker" -ForegroundColor Red
    exit 1
}
Write-Host "OK Imagen construida" -ForegroundColor Green
Write-Host ""

# Paso 2: Subir imagen a Artifact Registry
Write-Host "[2/3] Subiendo imagen a Artifact Registry..." -ForegroundColor Yellow
docker push $IMAGE_NAME
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Fallo al subir la imagen" -ForegroundColor Red
    exit 1
}
Write-Host "OK Imagen subida" -ForegroundColor Green
Write-Host ""

# Paso 3: Desplegar a Cloud Run
Write-Host "[3/3] Desplegando a Cloud Run..." -ForegroundColor Yellow
gcloud run deploy $SERVICE_NAME `
    --image $IMAGE_NAME `
    --platform managed `
    --region $REGION `
    --allow-unauthenticated `
    --project $PROJECT_ID

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Fallo al desplegar a Cloud Run" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Despliegue completado!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "URL: https://$SERVICE_NAME-830119773865.$REGION.run.app" -ForegroundColor Cyan
