param(
    [Parameter(Mandatory = $true)]
    [string]$Registry
)

$ErrorActionPreference = "Stop"

az acr login --name $Registry

Write-Host "Building Docker images..."

docker build -t "$Registry/aca-metrics-api:1.0.0" ../sample-apps/metrics-api
docker build -t "$Registry/aca-servicebus-worker:1.0.0" ../sample-apps/servicebus-worker
docker build -t "$Registry/aca-storagequeue-worker:1.0.0" ../sample-apps/storagequeue-worker

Write-Host "Pushing Docker images to ACR..."

docker push "$Registry/aca-metrics-api:1.0.0"
docker push "$Registry/aca-servicebus-worker:1.0.0"
docker push "$Registry/aca-storagequeue-worker:1.0.0"

Write-Host "Build and push completed successfully."