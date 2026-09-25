param([string]$AirSdk = 'D:\tools\AIRSDK-50.2.4.1')
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$config = Get-Content (Join-Path $root 'game\Config.as') -Raw
$version = [regex]::Match($config, 'CLIENT_VER:String\s*=\s*"([^"]+)"').Groups[1].Value
if (!$version) { throw 'CLIENT_VER missing' }
$descriptor = Get-Content (Join-Path $root 'mobile\application-android.xml') -Raw
if ($descriptor -notmatch "<versionNumber>$([regex]::Escape($version))</versionNumber>") { throw 'Android descriptor version mismatch' }
$builder = Get-Content (Join-Path $root 'tools\build-android.ps1') -Raw
if ($builder -notmatch [regex]::Escape($version + '-android')) { throw 'Android build source version mismatch' }
$apk = Join-Path $root 'output\android\sanguoqz-android-arm64.apk'
$desktop = Join-Path $root 'main.swf'
$web = Join-Path $root 'client\sanguo_web.swf'
foreach ($file in @($apk,$desktop,$web)) { if (!(Test-Path $file) -or (Get-Item $file).Length -lt 1000000) { throw "Release artifact missing or too small: $file" } }
$aapt = Join-Path $AirSdk 'lib\android\bin\aapt.exe'
$badging = & $aapt dump badging $apk | Select-Object -First 1
if ($badging -notmatch "versionName='$([regex]::Escape($version))'") { throw "APK manifest mismatch: $badging" }
$signer = Join-Path $AirSdk 'lib\android\lib\apksigner.jar'
& java -jar $signer verify $apk
if ($LASTEXITCODE -ne 0) { throw 'APK signature verification failed' }
$actual = (Get-FileHash $apk -Algorithm SHA256).Hash.ToLowerInvariant()
$recorded = (Get-Content "$apk.sha256" -Raw).Split(' ')[0].Trim().ToLowerInvariant()
if ($actual -ne $recorded) { throw 'APK SHA256 mismatch' }
if ((Get-FileHash $desktop -Algorithm SHA256).Hash -ne (Get-FileHash $web -Algorithm SHA256).Hash) { throw 'Desktop and web SWF mismatch' }
Write-Output "Three-platform release artifacts OK: $version / APK SHA256 $actual"
