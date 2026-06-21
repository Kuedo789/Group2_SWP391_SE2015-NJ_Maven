# Synchronization Script for Webapp files
$sourceDir = "src/main/webapp"
$targetDir = "target/Bakery_SWP-1.0-SNAPSHOT"

if (-not (Test-Path $targetDir)) {
    Write-Error "Target directory $targetDir does not exist. Ensure build has run first."
    exit 1
}

# Copy files keeping directory structures
$filesToCopy = @(
    "admin/productDetail.jsp",
    "admin/ingredientList.jsp",
    "admin/ingredientDetail.jsp",
    "admin/unitList.jsp",
    "admin/unitDetail.jsp",
    "common/sidebar.jsp"
)

foreach ($file in $filesToCopy) {
    $srcFile = Join-Path $sourceDir $file
    $dstFile = Join-Path $targetDir $file
    
    if (Test-Path $srcFile) {
        # Ensure parent directory of destination exists
        $dstParent = Split-Path $dstFile -Parent
        if (-not (Test-Path $dstParent)) {
            New-Item -ItemType Directory -Force -Path $dstParent | Out-Null
        }
        Copy-Item -Path $srcFile -Destination $dstFile -Force
        Write-Host "Synchronized $file successfully."
    } else {
        Write-Warning "Source file $srcFile does not exist."
    }
}

Write-Host "Synchronization completed!"
