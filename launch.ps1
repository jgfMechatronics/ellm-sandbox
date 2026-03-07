# Launch existing ellm-sandbox container
# Errors if container doesn't exist (use build.ps1 first)

$containerName = "ellm-dev"

$exists = docker ps -a --format "{{.Names}}" | Where-Object { $_ -eq $containerName }

if (-not $exists) {
    Write-Host "Container '$containerName' doesn't exist. Run build.ps1 first." -ForegroundColor Red
    exit 1
}

docker start -ai $containerName
