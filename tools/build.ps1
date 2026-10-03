param(
    [switch]$Release,
    [string]$Encoder = $env:W3STRINGS_ENCODER
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

& (Join-Path $PSScriptRoot 'check.ps1') -Root $root
if ($LASTEXITCODE -ne 0) { exit 1 }

$version = (Get-Content (Join-Path $root 'VERSION') -Raw).Trim()
$modName = 'modSkillTreeReforged'
$idSpace = 4731
$gameLanguages = 'ar', 'br', 'cn', 'cz', 'de', 'en', 'es', 'esmx', 'fr', 'hu', 'it', 'jp', 'kr', 'pl', 'ru', 'tr', 'ua', 'zh'

$buildDir = Join-Path $root 'build'
$stage = Join-Path $buildDir 'stage'
$devStage = Join-Path $buildDir 'stage-dev'
$distDir = Join-Path $root 'dist'

Remove-Item $buildDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $stage, $devStage, $distDir | Out-Null

Copy-Item (Join-Path $root 'mod\*') $stage -Recurse
Copy-Item (Join-Path $root 'dev\*') $devStage -Recurse

$rows = Import-Csv (Join-Path $root 'localization\strings.csv') -Delimiter ';' -Encoding UTF8
$contentDir = Join-Path $stage "mods\$modName\content"
$encoderFound = $Encoder -and (Test-Path $Encoder)

if (-not $encoderFound) {
    if ($Release) { throw 'w3strings encoder not found, set W3STRINGS_ENCODER' }
    Write-Host 'w3strings encoder not found, menu texts will show their keys' -ForegroundColor Yellow
}
else {
    $csvDir = Join-Path $buildDir 'strings'
    New-Item -ItemType Directory -Force $csvDir | Out-Null
    foreach ($language in $gameLanguages) {
        $column = if ($rows[0].PSObject.Properties.Name -contains $language) { $language } else { 'en' }
        $lines = [System.Collections.Generic.List[string]]::new()
        $lines.Add(";meta[language=$language]")
        $lines.Add('; id      |key(hex)|key(str)| text')
        $index = 0
        foreach ($row in $rows) {
            $id = 2110000000 + $idSpace * 1000 + $index
            $lines.Add("$id||$($row.key)|$($row.$column)")
            $index++
        }
        $csv = Join-Path $csvDir "$language.csv"
        [System.IO.File]::WriteAllLines($csv, $lines, [System.Text.UTF8Encoding]::new($false))
        & $Encoder --id-space $idSpace $csv | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "encoder failed for $language" }
        Move-Item "$csv.w3strings" (Join-Path $contentDir "$language.w3strings") -Force
    }
}

$zip = Join-Path $distDir "SkillTreeReforged-$version.zip"
Remove-Item $zip -Force -ErrorAction SilentlyContinue
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip

Write-Host "built $zip" -ForegroundColor Green
