# Build/rebuild ellm-sandbox image and create container
# Use this after Dockerfile changes

$containerName = "ellm-admin"
$imageName = "ellm-admin"
$gitMount = "C:\Git:/workspace/git"

# Stop and remove existing container if present
$exists = docker ps -a --format "{{.Names}}" | Where-Object { $_ -eq $containerName }
if ($exists) {
    Write-Host "Removing existing container..." -ForegroundColor Yellow
    docker stop $containerName 2>$null
    docker rm $containerName
}

# Build image
Write-Host "Building image..." -ForegroundColor Cyan
docker build -t $imageName .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

# Create and start container
Write-Host "Creating container with C:\Git mounted..." -ForegroundColor Cyan
docker run -it --name $containerName -v $gitMount $imageName
