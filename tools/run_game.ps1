param(
    [string]$GodotPath = 'D:\Godot\Godot_v4.7.1-stable_win64.exe',
    [switch]$SkipLaunch
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$consolePath = [System.IO.Path]::Combine(
    [System.IO.Path]::GetDirectoryName($GodotPath),
    ([System.IO.Path]::GetFileNameWithoutExtension($GodotPath) + '_console.exe')
)
$testExecutable = if (Test-Path -LiteralPath $consolePath) { $consolePath } else { $GodotPath }

& $testExecutable --headless --path $projectRoot --import
if ($LASTEXITCODE -ne 0) {
    throw 'Godot asset import failed.'
}

& $testExecutable --headless --path $projectRoot --script res://tests/fog_valley_baseline_test.gd
if ($LASTEXITCODE -ne 0) {
    throw 'Fog Valley baseline failed.'
}

if (-not $SkipLaunch) {
    Start-Process -FilePath $GodotPath -ArgumentList @('--path', $projectRoot) -WorkingDirectory $projectRoot
}
