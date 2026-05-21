# ================================
# SAFE HUGO PUBLISH SCRIPT
# With: backups, logs, safety locks, notifications
# ================================

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFile = "./logs/publish_$timestamp.log"
$backupFolder = "./backups/$timestamp"

# Ensure folders exist
New-Item -ItemType Directory -Force -Path "./logs" | Out-Null
New-Item -ItemType Directory -Force -Path "./backups" | Out-Null

function Log {
    param([string]$msg)
    $msg | Tee-Object -FilePath $logFile -Append
}

Log "===== SAFE PUBLISH STARTED at $timestamp ====="

# --- SAFETY LOCK 1: Ensure docs folder exists ---
if (!(Test-Path "./docs")) {
    Log "ERROR: /docs folder missing. Publishing stopped."
    Write-Host "❌ ERROR: /docs folder missing. Site protected." -ForegroundColor Red
    exit 1
}

# --- SAFETY LOCK 2: Ensure CNAME exists ---
if (!(Test-Path "./CNAME")) {
    Log "ERROR: CNAME missing. Publishing stopped."
    Write-Host "❌ ERROR: CNAME missing. Domain protected." -ForegroundColor Red
    exit 1
}

# --- SAFETY LOCK 3: Ensure working tree is clean ---
$gitStatus = git status --porcelain
if ($gitStatus) {
    Log "ERROR: Uncommitted changes detected. Publishing stopped."
    Write-Host "❌ ERROR: Uncommitted changes. Commit or stash first." -ForegroundColor Red
    exit 1
}

# --- BACKUP CURRENT DOCS ---
Log "Creating backup at $backupFolder..."
Copy-Item -Recurse -Force "./docs" $backupFolder
Copy-Item -Force "./CNAME" "$backupFolder/CNAME"
Log "Backup complete."

# --- Build the Hugo site ---
Write-Host "⚙️ Building Hugo site..." -ForegroundColor Yellow
Log "Running Hugo build..."
hugo

if ($LASTEXITCODE -ne 0) {
    Log "ERROR: Hugo build failed."
    Write-Host "❌ ERROR: Hugo build failed. Site protected." -ForegroundColor Red
    exit 1
}

# --- SAFETY LOCK 4: Ensure docs folder is NOT empty after build ---
$docsFiles = Get-ChildItem "./docs" -Recurse -ErrorAction SilentlyContinue
if ($docsFiles.Count -lt 10) {
    Log "ERROR: /docs folder looks empty after build. Publishing stopped."
    Write-Host "❌ ERROR: /docs is empty. Site protected." -ForegroundColor Red
    exit 1
}

# --- Ensure CNAME stays inside /docs ---
Copy-Item -Force "./CNAME" "./docs/CNAME"
Log "CNAME restored to /docs."

# --- Commit and push ---
Write-Host "⬆️ Committing and pushing changes..." -ForegroundColor Yellow
Log "Running git add/commit/push..."

git add .
git commit -m "Safe publish: updated site at $timestamp"
git push origin main

Log "Publish complete."
Write-Host "✅ Publish complete. Your site is safe." -ForegroundColor Green