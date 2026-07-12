# Synchronization Script for Webapp files
$sourceDir = "src/main/webapp"
$targetDir = "target/Bakery_SWP-1.0-SNAPSHOT"

if (-not (Test-Path $targetDir)) {
    Write-Error "Target directory $targetDir does not exist. Ensure build has run first."
    exit 1
}

# Copy files keeping directory structures
$filesToCopy = @(
    "admin/productList.jsp",
    "admin/productDetail.jsp",
    "admin/ingredientList.jsp",
    "admin/ingredientDetail.jsp",
    "admin/unitList.jsp",
    "admin/unitDetail.jsp",
    "admin/orderList.jsp",
    "admin/orderDetail.jsp",
    "admin/setting.jsp",
    "admin/reviewList.jsp",
    "admin/reviewDetail.jsp",
    "admin/userList.jsp",
    "admin/userDetail.jsp",
    "admin/customerList.jsp",
    "admin/customerDetail.jsp",
    "admin/dashboard.jsp",
    "admin/category-management.jsp",
    "admin/category-add.jsp",
    "admin/category-edit.jsp",
    "common/sidebar.jsp",
    "common/admin-header.jsp",
    "common/header.jsp",
    "common/home.jsp",
    "common/navbar.jsp",
    "common/breadcrumb.jsp",
    "common/top-header.jsp",
    "customer/my-orders.jsp",
    "customer/order-detail.jsp",
    "customer/order-success.jsp",
    "shipper/orderList.jsp",
    "shipper/orderDetail.jsp",
    "admin/test_permission.jsp",
    "assets/css/all/order.css",
    "assets/css/all/style.css",
    "assets/css/all/admin-global.css",
    "assets/css/sidebar-submenu.css"
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
