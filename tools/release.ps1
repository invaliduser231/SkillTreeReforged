param(
    [switch]$Tag
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root

try {
    $version = (Get-Content 'VERSION' -Raw).Trim()

    if (git status --porcelain) { throw 'working tree is not clean' }
    if ((git rev-parse --abbrev-ref HEAD) -ne 'main') { throw 'releases are cut from main' }
    if (git tag --list "v$version") { throw "v$version is already tagged" }

    $changelog = Get-Content 'CHANGELOG.md' -Raw
    if ($changelog -match "## \[$([regex]::Escape($version))\] - unreleased") { throw "set a date for $version in CHANGELOG.md" }

    & (Join-Path $PSScriptRoot 'build.ps1') -Release
    if ($LASTEXITCODE -ne 0) { throw 'build failed' }

    if ($Tag) {
        git tag -a "v$version" -m "Skill Tree Reforged $version"
        Write-Host "tagged v$version, push with: git push origin main v$version" -ForegroundColor Green
    }
    else {
        Write-Host "release build for $version is ready, run again with -Tag to tag it" -ForegroundColor Green
    }
}
finally {
    Pop-Location
}
