# pack_starter_kit.ps1
# Builds a clean, sellable Starter Kit ZIP of this repository.
# Usage:  powershell -ExecutionPolicy Bypass -File pack_starter_kit.ps1 [-Version 1.0.0]
param(
  [string]$Version = ""
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
if (-not $root) { $root = (Get-Location).Path }

if ([string]::IsNullOrWhiteSpace($Version)) {
  $pub = Join-Path $root "pubspec.yaml"
  if (Test-Path -LiteralPath $pub) {
    $txt = Get-Content -LiteralPath $pub -Raw
    if ($txt -match '(?m)^version:\s*([0-9]+\.[0-9]+\.[0-9]+)') { $Version = $Matches[1] }
  }
  if ([string]::IsNullOrWhiteSpace($Version)) { $Version = "0.0.0" }
}

$name    = "electronic-vault-starter-kit-v$Version"
$dist    = Join-Path $root "dist"
$stage   = Join-Path $env:TEMP ("ev-skit-" + [guid]::NewGuid().ToString("N"))
$zip     = Join-Path $dist "$name.zip"

New-Item -ItemType Directory -Force -Path $dist  | Out-Null
New-Item -ItemType Directory -Force -Path $stage | Out-Null

# Directories to exclude anywhere in the tree (by name)
$xd = @(".git", ".dart_tool", "build", ".idea", "dist", "node_modules", "ephemeral", ".gradle", "Podfile.lock", ".vscode")
# Files to exclude (glob) — junk + secrets
$xf = @("*.iml", ".flutter-plugins-dependencies", "*.env", ".env", "*.key", "*.pem", "*.log",
        "*.jks", "*.keystore", "*.log.*", "Thumbs.db", ".DS_Store", "*.zip",
        "local.properties", ".packages")

Write-Host "[pack] source : $root"
Write-Host "[pack] version: $Version"

robocopy $root $stage /E /XD $xd /XF $xf /NFL /NDL /NJH /NJS /NP /R:1 /W:1 | Out-Null
$rc = $LASTEXITCODE
if ($rc -ge 8) { throw "robocopy failed with code $rc" }

# Strip any accidental secret-looking files that slipped through
$secretPatterns = @("*.env", ".env*", "*.key", "*.pem", "*.jks", "*.keystore", "id_rsa*", "*credential*", "*secret*")
foreach ($sp in $secretPatterns) {
  Get-ChildItem -Path $stage -Recurse -Force -File -Filter $sp -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
}

# Scan staged content for obvious secrets (best-effort gate)
$suspicious = Get-ChildItem -Path $stage -Recurse -Force -File -ErrorAction SilentlyContinue |
  Where-Object { $_.Extension -in @(".dart",".yaml",".yml",".json",".md",".html",".js",".ps1",".sh",".bat") } |
  Select-String -Pattern 'AKIA[0-9A-Z]{16}','-----BEGIN [A-Z ]*PRIVATE KEY-----','ghp_[A-Za-z0-9]{36}','xox[baprs]-' -ErrorAction SilentlyContinue
if ($suspicious) {
  Write-Warning "Potential secret patterns found:"
  $suspicious | ForEach-Object { Write-Warning ("  {0}:{1}" -f $_.Path, $_.LineNumber) }
  throw "Aborting: potential secrets detected in package."
}

if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }
Compress-Archive -Path (Join-Path $stage "*") -DestinationPath $zip -CompressionLevel Optimal
Remove-Item -LiteralPath $stage -Recurse -Force

$hash = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLower()
$size = (Get-Item -LiteralPath $zip).Length
$sums = Join-Path $dist "SHA256SUMS.txt"
"$hash  $name.zip" | Set-Content -LiteralPath $sums -Encoding ASCII

Write-Host ""
Write-Host "[pack] OK -> $zip"
Write-Host ("[pack] size : {0:N2} MB" -f ($size / 1MB))
Write-Host "[pack] sha256: $hash"
Write-Host "[pack] sums : $sums"
