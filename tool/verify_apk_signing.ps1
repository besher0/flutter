<#
.SYNOPSIS
  Checks that an APK shared outside Google Play is signed with the Play app
  signing key.

.DESCRIPTION
  Students sign in from one device only, identified by ANDROID_ID. Since
  Android 8 ANDROID_ID differs per signing key, so the same phone looks like
  another device when it switches between a locally built APK (upload key)
  and the Play version (Google's app signing key). Share only the "Signed,
  universal APK" from Play Console and check it with this script first.
  See RELEASING_OUTSIDE_PLAY.md.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File tool\verify_apk_signing.ps1 "C:\Downloads\coursaty-universal.apk"
#>
param(
  [Parameter(Mandatory = $true)][string]$ApkPath,
  [string]$ExpectedSha256
)

$ErrorActionPreference = 'Stop'

# Certificate of the local upload key in android/key.properties (public
# information). APKs built with `flutter build apk --release` carry it.
$uploadKeySha256 = '0b469d7b20bf8e785cbae3ebb53930b8862d7cccb01c8c0f71333c76156486c6'
$configFile = Join-Path $PSScriptRoot 'play_app_signing_sha256.txt'

function ConvertTo-Sha256Hex([string]$value) {
  return ($value -replace '[^0-9a-fA-F]', '').ToLowerInvariant()
}

if (-not $ExpectedSha256 -and (Test-Path $configFile)) {
  $ExpectedSha256 = Get-Content $configFile |
    Where-Object { $_.Trim() -and $_ -notmatch '^\s*#' } |
    Select-Object -First 1
}
$expected = ConvertTo-Sha256Hex $ExpectedSha256
if ($expected.Length -ne 64) {
  Write-Host "Missing the Play app signing certificate SHA-256." -ForegroundColor Red
  Write-Host "Copy it from Play Console > Test and release > App integrity > App signing"
  Write-Host "(App signing key certificate) into $configFile"
  exit 2
}

if (-not (Test-Path $ApkPath)) {
  Write-Host "APK not found: $ApkPath" -ForegroundColor Red
  exit 2
}

$sdk = $env:ANDROID_HOME
if (-not $sdk) { $sdk = $env:ANDROID_SDK_ROOT }
if (-not $sdk) { $sdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk' }
$apksigner = Get-ChildItem (Join-Path $sdk 'build-tools') -Directory -ErrorAction SilentlyContinue |
  Sort-Object { try { [version]$_.Name } catch { [version]'0.0' } } -Descending |
  ForEach-Object { Join-Path $_.FullName 'apksigner.bat' } |
  Where-Object { Test-Path $_ } |
  Select-Object -First 1
if (-not $apksigner) {
  Write-Host "apksigner not found under $sdk\build-tools (install Android SDK build-tools)." -ForegroundColor Red
  exit 2
}

# apksigner writes warnings to stderr; keep them as text, not errors.
$ErrorActionPreference = 'Continue'
$output = & $apksigner verify --print-certs $ApkPath 2>&1 | ForEach-Object { "$_" }
$verifyExit = $LASTEXITCODE
$ErrorActionPreference = 'Stop'
if ($verifyExit -ne 0) {
  Write-Host "The APK signature is not valid:" -ForegroundColor Red
  $output | ForEach-Object { Write-Host "  $_" }
  exit 1
}

$signers = @(
  $output |
    Select-String -Pattern 'Signer #\d+ certificate SHA-256 digest: ([0-9a-fA-F:]+)' |
    ForEach-Object { ConvertTo-Sha256Hex $_.Matches[0].Groups[1].Value }
)
if ($signers.Count -ne 1) {
  Write-Host "Expected exactly one signer, found $($signers.Count)." -ForegroundColor Red
  exit 1
}

$actual = $signers[0]
if ($actual -eq $expected) {
  Write-Host "OK: signed with the Play app signing key. Safe to share." -ForegroundColor Green
  exit 0
}

Write-Host "DO NOT SHARE: this APK is not signed with the Play app signing key." -ForegroundColor Red
Write-Host "  APK certificate SHA-256:  $actual"
Write-Host "  Play app signing SHA-256: $expected"
if ($actual -eq $uploadKeySha256) {
  Write-Host "It was built locally (upload key). Students who install it would look like"
  Write-Host "a different device than the Play version and be locked out of their account."
  Write-Host "Download the 'Signed, universal APK' from Play Console instead."
}
exit 1
