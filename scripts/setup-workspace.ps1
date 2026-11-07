# Creates (or resets) the ShopLite workspace the Switch agents work in.
# It copies demo-app/shoplite into a standalone git repo, so agents can branch,
# commit and merge without touching this project repo.
#
# Usage:  powershell -ExecutionPolicy Bypass -File scripts/setup-workspace.ps1 [-Path <dir>]
# Default path: $HOME\switch-demo\shoplite

param(
  [string]$Path = (Join-Path $HOME 'switch-demo\shoplite')
)

$ErrorActionPreference = 'Stop'
$source = Join-Path $PSScriptRoot '..\demo-app\shoplite' | Resolve-Path

if (Test-Path $Path) {
  Write-Host "Resetting existing workspace at $Path"
  Remove-Item -Recurse -Force $Path
}
New-Item -ItemType Directory -Force $Path | Out-Null
Copy-Item -Recurse -Force (Join-Path $source '*') $Path

Push-Location $Path
try {
  git init -q -b main
  git add -A
  git -c user.name='ShopLite Bot' -c user.email='shoplite@example.com' commit -q -m 'ShopLite 1.4.0'
  Write-Host ''
  Write-Host "Workspace ready: $Path"
  Write-Host 'Paste this path into the "Workspace" field when you create the Support-to-Ship template.'
} finally {
  Pop-Location
}
