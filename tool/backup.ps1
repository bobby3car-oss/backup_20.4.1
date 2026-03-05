# ─────────────────────────────────────────────────────────────
#  backup.ps1 – Commit, Push & optionales ZIP-Backup (Windows)
#  Nutzung:  .\tool\backup.ps1 [-z] [-f] [-m "Nachricht"]
#
#  Status: STUB – noch nicht vollständig implementiert.
#          Siehe tool/backup.sh für die fertige macOS/Linux-Version.
# ─────────────────────────────────────────────────────────────
param(
    [string]$m = "",
    [switch]$z,
    [switch]$f,
    [switch]$h
)

$ErrorActionPreference = "Stop"

if ($h) {
    Write-Host ""
    Write-Host "Backup-Tool fuer Flutter-Repo (Windows)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Nutzung:  .\tool\backup.ps1 [Optionen]"
    Write-Host ""
    Write-Host "Optionen:"
    Write-Host "  -m `"msg`"   Eigene Nachricht (wird an Timestamp angehaengt)"
    Write-Host "  -z         Zusaetzlich ZIP-Snapshot erstellen"
    Write-Host "  -f         Vorher dart format . ausfuehren"
    Write-Host "  -h         Diese Hilfe anzeigen"
    Write-Host ""
    exit 0
}

# Repo-Root pruefen
try {
    $repoRoot = git rev-parse --show-toplevel 2>$null
} catch {
    Write-Host "✗ Nicht in einem Git-Repository." -ForegroundColor Red
    exit 1
}
if (-not $repoRoot) {
    Write-Host "✗ Nicht in einem Git-Repository." -ForegroundColor Red
    exit 1
}
Set-Location $repoRoot
Write-Host "▸ Repo-Root: $repoRoot" -ForegroundColor Cyan

# Optional: Format
if ($f) {
    Write-Host "▸ Fuehre dart format . aus …" -ForegroundColor Yellow
    dart format .
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ dart format fehlgeschlagen." -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ Formatierung abgeschlossen." -ForegroundColor Green
}

# Uncommitted Changes pruefen
$status = git status --porcelain
if (-not $status) {
    Write-Host "✓ Keine Aenderungen vorhanden – nichts zu tun." -ForegroundColor Yellow
    exit 0
}

# Timestamp & Commit-Message
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$timestampFile = Get-Date -Format "yyyyMMdd_HHmm"

if ($m) {
    $commitMsg = "backup: $timestamp - $m"
} else {
    $commitMsg = "backup: $timestamp"
}

# Git Add + Commit
Write-Host "▸ Stage all changes …" -ForegroundColor Yellow
git add -A

Write-Host "▸ Commit: $commitMsg" -ForegroundColor Yellow
git commit -m $commitMsg
Write-Host "✓ Commit erstellt." -ForegroundColor Green

# Git Push
$branch = git rev-parse --abbrev-ref HEAD
Write-Host "▸ Push nach origin/$branch …" -ForegroundColor Yellow
git push origin $branch
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Push fehlgeschlagen." -ForegroundColor Red
    exit 1
}
Write-Host "✓ Push erfolgreich." -ForegroundColor Green

# Optional: ZIP Snapshot
if ($z) {
    $backupDir = Join-Path $repoRoot "backups"
    $zipName = "backup_$timestampFile.zip"
    $zipPath = Join-Path $backupDir $zipName

    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir | Out-Null
    }

    Write-Host "▸ Erstelle ZIP-Snapshot: $zipName …" -ForegroundColor Yellow

    $excludeDirs = @("build", ".dart_tool", ".idea", "ios\Pods", "DerivedData", "node_modules", ".git", "backups", ".build", ".pub-cache")
    $tempDir = Join-Path $env:TEMP "flutter_backup_$(Get-Random)"
    
    # Einfacher Ansatz: git archive nutzen
    git archive --format=zip HEAD -o $zipPath
    
    $zipSize = (Get-Item $zipPath).Length / 1MB
    $zipSizeFmt = "{0:N1} MB" -f $zipSize
    Write-Host "✓ ZIP erstellt: $zipPath ($zipSizeFmt)" -ForegroundColor Green
}

# Fertig
Write-Host ""
Write-Host "══════════════════════════════════════" -ForegroundColor Green
Write-Host "  ✓ Backup abgeschlossen!" -ForegroundColor Green
Write-Host "══════════════════════════════════════" -ForegroundColor Green
Write-Host ""
