param(
    [string]$GamePath = $env:W3_GAME_PATH,
    [switch]$Dev,
    [switch]$Remove
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

if (-not $GamePath -or -not (Test-Path (Join-Path $GamePath 'bin'))) {
    throw 'game folder not found, pass -GamePath or set W3_GAME_PATH'
}
if (Get-Process witcher3 -ErrorAction SilentlyContinue) {
    throw 'close the game before deploying'
}

$targets = @(
    "mods\modSkillTreeReforged",
    "mods\modSkillTreeReforgedDev",
    "bin\config\r4game\user_config_matrix\pc\modSkillTreeReforged.xml"
)
foreach ($target in $targets) {
    Remove-Item (Join-Path $GamePath $target) -Recurse -Force -ErrorAction SilentlyContinue
}

if ($Remove) {
    Write-Host "removed from $GamePath" -ForegroundColor Green
    exit 0
}

$stage = Join-Path $root 'build\stage'
if (-not (Test-Path $stage)) { throw 'nothing built yet, run tools\build.ps1' }

Copy-Item (Join-Path $stage '*') $GamePath -Recurse -Force
if ($Dev) {
    Copy-Item (Join-Path $root 'build\stage-dev\*') $GamePath -Recurse -Force
}

Write-Host "deployed to $GamePath$(if ($Dev) { ' with dev commands' })" -ForegroundColor Green
