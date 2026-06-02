$ErrorActionPreference = "Stop"

# ====================================================================
# [Configuration Path] Please modify the path below to match your system!
# ====================================================================
$TargetDir = "D:\MyProject\llama"  # UPDATE THIS to your actual llama.cpp installation directory!

$TempDir = Join-Path $env:TEMP "llama-cpp-update"

$Repo = "ggml-org/llama.cpp"
$ApiUrl = "https://api.github.com/repos/$Repo/releases/latest"
$Headers = @{
    "User-Agent" = "llama-cpp-windows-updater"
}

function Download-WithRetry {
    param (
        [string]$Uri,
        [string]$OutFile,
        [hashtable]$Headers,
        [int]$MaxRetries = 3,
        [int]$DelaySeconds = 5
    )
    
    $oldProgress = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    
    $attempt = 0
    $success = $false
    
    while (-not $success -and $attempt -lt $MaxRetries) {
        $attempt++
        try {
            Write-Host " (Attempt $attempt of $MaxRetries)..."
            Invoke-WebRequest -Uri $Uri -OutFile $OutFile -Headers $Headers -TimeoutSec 120
            $success = $true
        }
        catch {
            Write-Host "    Download failed: $_" -ForegroundColor Yellow
            if ($attempt -lt $MaxRetries) {
                Write-Host "    Waiting $DelaySeconds seconds before retrying..."
                Start-Sleep -Seconds $DelaySeconds
            }
        }
    }
    
    $ProgressPreference = $oldProgress
    if (-not $success) {
        throw "Failed to download after $MaxRetries attempts: $Uri"
    }
}

Write-Host "========================================"
Write-Host "       llama.cpp Auto-Updater"
Write-Host "========================================"
Write-Host ""

Write-Host "[1/5] Checking llama-server.exe process..."

$running = Get-Process "llama-server" -ErrorAction SilentlyContinue
if ($running) {
    throw "llama-server.exe is still running. Please close it first."
}

Write-Host "[2/5] Fetching latest release info and selecting assets..."

$release = Invoke-RestMethod -Uri $ApiUrl -Headers $Headers
$tag = $release.tag_name

if ([string]::IsNullOrWhiteSpace($tag)) {
    throw "Could not get latest release tag."
}

Write-Host "Latest release tag: $tag"

# Detect local CUDA capability
$localCuda = $null
if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) {
    $smi = nvidia-smi 2>&1 | Out-String
    if ($smi -match "CUDA Version:\s+([\d\.]+)") {
        $localCuda = [version]$Matches[1]
    }
}
if (-not $localCuda -and (Get-Command nvcc -ErrorAction SilentlyContinue)) {
    $nvcc = nvcc --version 2>&1 | Out-String
    if ($nvcc -match "release\s+([\d\.]+)") {
        $localCuda = [version]$Matches[1]
    }
}
if (-not $localCuda -and $env:CUDA_PATH) {
    if ($env:CUDA_PATH -match "v([\d\.]+)") {
        $localCuda = [version]$Matches[1]
    }
}

if ($localCuda) {
    Write-Host "Detected local CUDA capability: $localCuda"
} else {
    Write-Host "Could not detect local CUDA version. Defaulting to standard compatibility mode."
}

# Extract available CUDA versions from release assets
$availableCudaVersions = @()
foreach ($asset in $release.assets) {
    if ($asset.name -match "^llama-.*-bin-win-cuda-([\d\.]+)-x64\.zip$") {
        $v = [version]$Matches[1]
        if ($availableCudaVersions -notcontains $v) {
            $availableCudaVersions += $v
        }
    }
}

if ($availableCudaVersions.Count -eq 0) {
    throw "No Windows CUDA assets found in the latest release."
}

# Sort available versions descending to prefer the highest compatible version
$availableCudaVersions = $availableCudaVersions | Sort-Object -Descending

$selectedCuda = $null
if ($localCuda) {
    # Find the highest version <= localCuda
    foreach ($v in $availableCudaVersions) {
        if ($v -le $localCuda) {
            $selectedCuda = $v
            break
        }
    }
}

# If no matching version is found or local detection failed, pick the lowest available CUDA version for maximum compatibility
if (-not $selectedCuda) {
    $selectedCuda = $availableCudaVersions[-1]
    if ($localCuda) {
        Write-Host "No release asset is fully compatible with your CUDA version ($localCuda)."
        Write-Host "Falling back to the most compatible older version: $selectedCuda"
    } else {
        Write-Host "Using default CUDA version: $selectedCuda"
    }
} else {
    Write-Host "Selected CUDA version: $selectedCuda"
}

$cudaStr = "$($selectedCuda.Major).$($selectedCuda.Minor)"
$LlamaZipName = "llama-$tag-bin-win-cuda-$cudaStr-x64.zip"
$CudartZipName = "cudart-llama-bin-win-cuda-$cudaStr-x64.zip"

$llamaAsset = $release.assets | Where-Object { $_.name -eq $LlamaZipName } | Select-Object -First 1
$cudartAsset = $release.assets | Where-Object { $_.name -eq $CudartZipName } | Select-Object -First 1

if (-not $llamaAsset) {
    Write-Host ""
    Write-Host "Available assets:"
    $release.assets | ForEach-Object { Write-Host " - $($_.name)" }
    throw "Cannot find asset: $LlamaZipName"
}

if (-not $cudartAsset) {
    Write-Host ""
    Write-Host "Available assets:"
    $release.assets | ForEach-Object { Write-Host " - $($_.name)" }
    throw "Cannot find asset: $CudartZipName"
}

if (Test-Path $TempDir) {
    Remove-Item $TempDir -Recurse -Force
}

New-Item -ItemType Directory -Path $TempDir | Out-Null

if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir | Out-Null
}

$LlamaZipPath = Join-Path $TempDir $LlamaZipName
$CudartZipPath = Join-Path $TempDir $CudartZipName

Write-Host "[3/5] Downloading $LlamaZipName..."
Download-WithRetry -Uri $llamaAsset.browser_download_url -OutFile $LlamaZipPath -Headers $Headers

Write-Host "[4/5] Downloading $CudartZipName..."
Download-WithRetry -Uri $cudartAsset.browser_download_url -OutFile $CudartZipPath -Headers $Headers

Write-Host "[5/5] Extracting files..."

Expand-Archive -Path $LlamaZipPath -DestinationPath $TargetDir -Force
Expand-Archive -Path $CudartZipPath -DestinationPath $TargetDir -Force

Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================"
Write-Host "Done! Updated llama.cpp to $tag"
Write-Host "Target directory: $TargetDir"
Write-Host "========================================"