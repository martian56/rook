# Install or update rook on Windows. Run with:
#
#   irm https://raw.githubusercontent.com/martian56/rook/main/scripts/install.ps1 | iex
#
# Downloads the latest release, finds rook.exe inside it, and places it
# where rook already lives (or ~\.rook\bin for a first install, added to the
# user PATH). A running rook.exe cannot be overwritten but can be renamed,
# so the old binary moves aside and the new one takes its place; restart
# rook to run it.

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$release = Invoke-RestMethod -Uri "https://api.github.com/repos/martian56/rook/releases/latest" -Headers @{ "User-Agent" = "rook-install" }
$asset = $release.assets | Where-Object { $_.name -like "*x86_64.zip" } | Select-Object -First 1
if (-not $asset) {
    Write-Host "error: the latest release has no Windows zip asset" -ForegroundColor Red
    exit 1
}
Write-Host "Installing rook $($release.tag_name) ..."

$work = Join-Path $env:TEMP ("rook-install-" + [IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Path $work | Out-Null
$zip = Join-Path $work $asset.name
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zip -Headers @{ "User-Agent" = "rook-install" }
Expand-Archive -Path $zip -DestinationPath (Join-Path $work "unpacked") -Force
$exe = Get-ChildItem -Path (Join-Path $work "unpacked") -Recurse -Filter "rook.exe" | Select-Object -First 1
if (-not $exe) {
    Write-Host "error: rook.exe not found inside the release zip" -ForegroundColor Red
    exit 1
}

# Prefer the directory of an existing install; fall back to ~\.rook\bin.
$target = $null
$existing = Get-Command rook.exe -ErrorAction SilentlyContinue
if ($existing) {
    $target = Split-Path $existing.Source
} else {
    $target = Join-Path $env:USERPROFILE ".rook\bin"
    New-Item -ItemType Directory -Path $target -Force | Out-Null
}
$dest = Join-Path $target "rook.exe"

# A previous update may have left the renamed old binary; clear it, then
# move any running binary aside (renaming a running exe is allowed).
$aside = Join-Path $target "rook-old.exe"
if (Test-Path $aside) {
    Remove-Item -Path $aside -Force -ErrorAction SilentlyContinue
}
if (Test-Path $dest) {
    Move-Item -Path $dest -Destination $aside -Force
}
Copy-Item -Path $exe.FullName -Destination $dest -Force
Remove-Item -Path $work -Recurse -Force -ErrorAction SilentlyContinue

# First installs get the target onto the user PATH.
if (-not $existing) {
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -notlike "*$target*") {
        [Environment]::SetEnvironmentVariable("Path", "$userPath;$target", "User")
        Write-Host "Added $target to your user PATH; open a new terminal to pick it up."
    }
}

Write-Host "rook $($release.tag_name) installed to $dest" -ForegroundColor Green
Write-Host "If rook is running, restart it to use the new version."
