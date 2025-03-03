param (
    [Parameter(Mandatory = $true)]
    [string]$IMAGE_VERSION
)

# Define the base registry and image name
$registry = "opusregistryuk.azurecr.io"
$image_name = "ib-gateway-docker-stable"

# Construct the docker build command
$dockerCommand = "docker build -t $registry/$image_name`:latest -t $registry/$image_name`:$IMAGE_VERSION ."

# Output the command for verification
Write-Host "Running: $dockerCommand" -ForegroundColor Cyan

# Execute the command
Invoke-Expression $dockerCommand