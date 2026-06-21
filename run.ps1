# Portable ShopEasy Deployment and Startup Script

$workDir = Get-Location
$toolsDir = Join-Path $workDir "tools"
$mvnZip = Join-Path $toolsDir "maven.zip"
$mvnHome = Join-Path $toolsDir "apache-maven-3.8.6"
$mvnBin = Join-Path $mvnHome "bin\mvn.cmd"
$tcZip = Join-Path $toolsDir "tomcat.zip"
$tcHome = Join-Path $toolsDir "apache-tomcat-9.0.75"
$tcBin = Join-Path $tcHome "bin\startup.bat"

# 1. Create tools directory
if (!(Test-Path $toolsDir)) {
    Write-Host ">>> Creating tools workspace directory..." -ForegroundColor Green
    New-Item -ItemType Directory -Path $toolsDir | Out-Null
}

# 2. Download portable Maven if not present
if (!(Test-Path $mvnBin)) {
    Write-Host ">>> Downloading portable Apache Maven 3.8.6..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.zip" -OutFile $mvnZip
    Write-Host ">>> Extracting Maven..." -ForegroundColor Green
    Expand-Archive -Path $mvnZip -DestinationPath $toolsDir -Force
    Remove-Item $mvnZip
}

# 3. Download portable Tomcat if not present
if (!(Test-Path $tcBin)) {
    Write-Host ">>> Downloading portable Apache Tomcat 9.0.75..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75-windows-x64.zip" -OutFile $tcZip
    Write-Host ">>> Extracting Tomcat..." -ForegroundColor Green
    Expand-Archive -Path $tcZip -DestinationPath $toolsDir -Force
    Remove-Item $tcZip
}

# 4. Build application using the local Maven instance
Write-Host ">>> Compiling Java project and packaging WAR..." -ForegroundColor Cyan
& $mvnBin clean package

if ($LASTEXITCODE -ne 0) {
    Write-Host ">>> Error: Project compilation failed! Check compiler logs." -ForegroundColor Red
    exit 1
}

# 5. Clean and deploy ROOT.war to Tomcat webapps folder
Write-Host ">>> Deploying application on Tomcat ROOT context..." -ForegroundColor Cyan
$warFile = Join-Path $workDir "target\ECommerceApp.war"
$webappsDir = Join-Path $tcHome "webapps"

# Clear default Tomcat ROOT folder to mount ours instead
$rootFolder = Join-Path $webappsDir "ROOT"
if (Test-Path $rootFolder) {
    Remove-Item -Recurse -Force $rootFolder
}
$rootWar = Join-Path $webappsDir "ROOT.war"
if (Test-Path $rootWar) {
    Remove-Item -Force $rootWar
}

# Copy compiled WAR
Copy-Item $warFile $rootWar

# 6. Launch Tomcat Web Server
Write-Host ">>> Launching Tomcat Web Server on http://localhost:8080/..." -ForegroundColor Green
Write-Host ">>> (A background cmd window will launch and display Tomcat logs)" -ForegroundColor DarkGray
Start-Process -FilePath cmd.exe -ArgumentList "/c `"$tcBin`"" -WorkingDirectory (Join-Path $tcHome "bin")

# 7. Wait and open default browser
Write-Host ">>> Waiting 5 seconds for web container initialization and database bootstrap..." -ForegroundColor Cyan
Start-Sleep -Seconds 5

Write-Host ">>> Launching browser..." -ForegroundColor Green
Start-Process "http://localhost:8080/"

Write-Host ">>> Setup Completed successfully! ShopEasy is running on your browser." -ForegroundColor Green
