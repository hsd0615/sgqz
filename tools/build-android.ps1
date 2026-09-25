param(
  [string]$AirSdk = 'D:\tools\AIRSDK-50.2.4.1',
  [string]$FlexSdk = 'D:\BaiduNetdiskDownload\flex_home',
  [ValidateSet('armv8','armv7')][string]$Architecture = 'armv8'
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$adt = Join-Path $AirSdk 'lib\adt.jar'
$airglobal = Join-Path $AirSdk 'frameworks\libs\air\airglobal.swc'
$compiler = Join-Path $FlexSdk 'lib\mxmlc.jar'
foreach ($file in @($adt,$airglobal,$compiler)) {
  if (!(Test-Path -LiteralPath $file)) { throw "Missing build dependency: $file" }
}
$signFile = Join-Path $env:LOCALAPPDATA 'SGQZAndroid\signing.json'
if (!(Test-Path $signFile)) { throw "Missing signing configuration: $signFile" }
$sign = Get-Content -LiteralPath $signFile -Raw | ConvertFrom-Json
$build = Join-Path $root 'output\android'
$source = Join-Path $build 'source'
$package = Join-Path $build 'package'
New-Item $source,$package -ItemType Directory -Force | Out-Null
# Android uses a source snapshot and never overwrites desktop release files.
foreach ($dir in @('game','com','fl','unit4399','utils','assets')) {
  Copy-Item (Join-Path $root $dir) $source -Recurse -Force
}
Copy-Item (Join-Path $root 'BarMC.as') $source -Force
Get-ChildItem $source -Recurse -Filter '*.as' | ForEach-Object {
  $code = [IO.File]::ReadAllText($_.FullName)
  $updated = $code.Replace('47.96.41.243','47.114.59.65')
  if ($updated -ne $code) { [IO.File]::WriteAllText($_.FullName,$updated,[Text.UTF8Encoding]::new($false)) }
}
$config = Join-Path $source 'game\Config.as'
$code = [IO.File]::ReadAllText($config)
$code = $code -replace 'CLIENT_VER:String = "[^"]+"','CLIENT_VER:String = "4.9.19-android.1"'
[IO.File]::WriteAllText($config,$code,[Text.UTF8Encoding]::new($false))
Push-Location $source
try {
  & java -jar $compiler "+flexlib=$FlexSdk\frameworks" '-compiler.source-path=.' '-default-size=770,500' '-target-player=32.0' '-static-link-runtime-shared-libraries=true' "-external-library-path=$airglobal" "-output=$package\main.swf" '--' 'game/Sanguo4399.as'
  if ($LASTEXITCODE -ne 0) { throw "SWF compilation failed: $LASTEXITCODE" }
} finally { Pop-Location }
$assets = @('ui.swf','general.swf','superGeneral.swf','face.swf','fubenui.swf','sound.swf','game_mobile.xml')
foreach ($asset in $assets) { Copy-Item (Join-Path $root $asset) $package -Force }
Copy-Item (Join-Path $root 'mobile\application-android.xml') (Join-Path $package 'application.xml') -Force
$suffix = if ($Architecture -eq 'armv8') { 'arm64' } else { 'arm32' }
$apk = Join-Path $build "sanguoqz-android-$suffix.apk"
$env:JAVA_HOME = 'D:\jdk'
Push-Location $package
try {
  & java -Xmx2048m -jar $adt -package -target apk-captive-runtime -arch $Architecture -storetype pkcs12 -keystore $sign.certificate -storepass $sign.password $apk application.xml main.swf @assets
  if ($LASTEXITCODE -ne 0) { throw "APK packaging failed: $LASTEXITCODE" }
} finally { Pop-Location }
$hash = (Get-FileHash $apk -Algorithm SHA256).Hash.ToLowerInvariant()
"$hash  $([IO.Path]::GetFileName($apk))" | Set-Content "$apk.sha256" -Encoding ascii
Write-Output "APK: $apk"
Write-Output "SHA256: $hash"
