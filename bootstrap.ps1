#requires -Version 5.1
<#
.SYNOPSIS
    Replace template placeholders with the new app's name and bundle id.
.DESCRIPTION
    Run ONCE after `gh repo create --template mi-j/ios-app-template`.
    Walks every text file under the repo, replaces __APP_NAME__ /
    __BUNDLE_ID__ / __BUNDLE_ID_PREFIX__ in-place, renames the
    Sources/__APP_NAME__/ folder, then deletes itself.

    Idempotent only on first run. Subsequent runs are no-ops because the
    placeholders have been replaced.
.PARAMETER AppName
    Pascal-case Xcode-friendly name (target / scheme / Swift module).
    Example: "MyApp", "ProDraftAI", "TaskTracker"
.PARAMETER BundleId
    Reverse-DNS bundle identifier. Example: "com.mi-j.myapp"
.EXAMPLE
    ./bootstrap.ps1 -AppName MyApp -BundleId com.mi-j.myapp
#>
param(
    [Parameter(Mandatory)][string]$AppName,
    [Parameter(Mandatory)][string]$BundleId
)
$ErrorActionPreference = "Stop"

if ($AppName -notmatch "^[A-Za-z][A-Za-z0-9]*$") {
    throw "AppName must start with a letter and contain only letters/digits. Got: $AppName"
}
if ($BundleId -notmatch "^[a-z0-9-]+(\.[a-z0-9-]+)+$") {
    throw "BundleId must look like 'com.example.myapp'. Got: $BundleId"
}
$bundlePrefix = ($BundleId -split '\.' | Select-Object -SkipLast 1) -join '.'

$root = Split-Path -Parent $PSCommandPath
Set-Location $root

$textExtensions = @('.swift','.yml','.yaml','.json','.md','.rb','.sh','.ps1','.toml','.plist','.entitlements','.xcconfig','.gitignore','.example','.txt','Gemfile','Podfile','Fastfile','Appfile','Matchfile')
$skipDirs = @('.git','build','Pods','vendor','node_modules','DerivedData','*.xcodeproj')

function Should-Process($file) {
    foreach ($skip in $skipDirs) { if ($file.FullName -like "*\$skip\*") { return $false } }
    if ($textExtensions -contains $file.Extension) { return $true }
    if ($textExtensions -contains $file.Name) { return $true }
    return $false
}

$files = Get-ChildItem -Path $root -Recurse -File | Where-Object { Should-Process $_ }
$changed = 0
foreach ($f in $files) {
    $content = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $content) { continue }
    $new = $content `
        -replace '__APP_NAME__',         $AppName `
        -replace '__BUNDLE_ID_PREFIX__', $bundlePrefix `
        -replace '__BUNDLE_ID__',        $BundleId
    if ($new -ne $content) {
        $new | Out-File $f.FullName -Encoding utf8 -NoNewline
        $changed++
    }
}
Write-Output "Updated $changed file(s)."

# Rename Sources/__APP_NAME__ and the App.swift inside
$srcDir = Join-Path $root "Sources\__APP_NAME__"
if (Test-Path $srcDir) {
    Rename-Item -Path $srcDir -NewName $AppName
    Write-Output "Renamed Sources\__APP_NAME__ -> Sources\$AppName"
    $appSwift = Join-Path $root "Sources\$AppName\__APP_NAME__App.swift"
    if (Test-Path $appSwift) {
        Rename-Item -Path $appSwift -NewName "${AppName}App.swift"
        Write-Output "Renamed __APP_NAME__App.swift -> ${AppName}App.swift"
    }
}

# Self-delete
$self = $PSCommandPath
Write-Output "Bootstrap complete. Removing $self..."
Remove-Item $self -Force

Write-Output ""
Write-Output "Next steps:"
Write-Output "  1. Run 'xcodegen generate' to produce $AppName.xcodeproj"
Write-Output "  2. Open $AppName.xcodeproj in Xcode"
Write-Output "  3. git add -A && git commit -m 'chore: initial bootstrap' && git push"
