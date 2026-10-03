param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
$problems = [System.Collections.Generic.List[string]]::new()
$utf8 = [System.Text.UTF8Encoding]::new($false, $true)

function Add-Problem([string]$file, [string]$message) {
    $problems.Add("$($file.Substring($Root.Length + 1)): $message")
}

$sourceDirs = @('mod', 'dev', 'localization', 'tools') | ForEach-Object { Join-Path $Root $_ } | Where-Object { Test-Path $_ }
$files = Get-ChildItem $sourceDirs -Recurse -File -Include *.ws, *.xml, *.csv, *.ps1

foreach ($file in $files) {
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        Add-Problem $file.FullName 'UTF-8 BOM'
    }
    try {
        $text = $utf8.GetString($bytes)
    }
    catch {
        Add-Problem $file.FullName 'not valid UTF-8'
        continue
    }

    switch ($file.Extension) {
        '.ws' {
            $code = [regex]::Replace($text, '"(\\.|[^"\\])*"', '""')
            $code = [regex]::Replace($code, "'[^'\r\n]*'", "''")
            if ($code -match '//|/\*') { Add-Problem $file.FullName 'comment in script' }
            $open = ([regex]::Matches($code, '\{')).Count
            $close = ([regex]::Matches($code, '\}')).Count
            if ($open -ne $close) { Add-Problem $file.FullName "unbalanced braces ($open/$close)" }
            $openParen = ([regex]::Matches($code, '\(')).Count
            $closeParen = ([regex]::Matches($code, '\)')).Count
            if ($openParen -ne $closeParen) { Add-Problem $file.FullName "unbalanced parentheses ($openParen/$closeParen)" }
        }
        '.xml' {
            if ($text -match '<!--') { Add-Problem $file.FullName 'comment in xml' }
            try { [xml]$text | Out-Null } catch { Add-Problem $file.FullName "invalid xml: $($_.Exception.Message)" }
        }
        '.ps1' {
            foreach ($line in $text -split "`n") {
                if ($line -match '^\s*#' -or $line.Contains('<' + '#')) { Add-Problem $file.FullName 'comment in script'; break }
            }
        }
    }
}

$stringsFile = Join-Path $Root 'localization\strings.csv'
$keys = @{}
if (Test-Path $stringsFile) {
    $rows = Import-Csv $stringsFile -Delimiter ';' -Encoding UTF8
    $languages = ($rows | Select-Object -First 1).PSObject.Properties.Name | Where-Object { $_ -ne 'key' }
    foreach ($row in $rows) {
        if ($keys.ContainsKey($row.key)) { Add-Problem $stringsFile "duplicate key $($row.key)" }
        $keys[$row.key] = $true
        foreach ($language in $languages) {
            if ([string]::IsNullOrWhiteSpace($row.$language)) { Add-Problem $stringsFile "missing $language text for $($row.key)" }
        }
    }
}

foreach ($menu in Get-ChildItem (Join-Path $Root 'mod') -Recurse -Filter *.xml) {
    [xml]$doc = Get-Content $menu.FullName -Raw -Encoding UTF8
    $names = @($doc.SelectNodes('//*[@displayName]') | ForEach-Object { $_.displayName })
    foreach ($name in $names) {
        foreach ($part in ($name -replace '^Mods\.', '') -split '\.') {
            if (-not $keys.ContainsKey($part)) { Add-Problem $menu.FullName "unknown string key $part" }
        }
    }
}

$version = (Get-Content (Join-Path $Root 'VERSION') -Raw).Trim()
if ($version -notmatch '^\d+\.\d+\.\d+$') { Add-Problem (Join-Path $Root 'VERSION') "not a semantic version: $version" }
$changelog = Get-Content (Join-Path $Root 'CHANGELOG.md') -Raw
if ($changelog -notmatch "## \[$([regex]::Escape($version))\]") { Add-Problem (Join-Path $Root 'CHANGELOG.md') "no entry for $version" }

if ($problems.Count -gt 0) {
    $problems | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    Write-Host "check failed: $($problems.Count) problem(s)" -ForegroundColor Red
    exit 1
}

Write-Host "check passed ($($files.Count) files, $($keys.Count) strings, version $version)" -ForegroundColor Green
exit 0
