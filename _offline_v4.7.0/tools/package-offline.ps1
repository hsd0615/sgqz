$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$version = [regex]::Match((Get-Content (Join-Path $root 'game/Config.as') -Raw), 'CLIENT_VER:String = "([^"]+)"').Groups[1].Value
if (!$version) { throw 'Missing version' }
$files = @('main.exe','main.swf','game.xml','battle_bg.png','staticequip.xml','start.bat','mimetype','PACKAGE_MANIFEST.txt','CHANGELOG.md','OFFLINE_BUILD_README.md')
[xml]$config = Get-Content (Join-Path $root 'game.xml') -Raw
foreach ($loader in $config.data.ChildNodes) {
    if ($loader.LocalName -in @('SWFLoader','DataLoader')) {
        $path = $loader.GetAttribute('url')
        if ($path -match '(^/|:|\.\.)') { throw "Nonlocal resource: $path" }
        $files += $path
    }
}
$chapters = @('黄巾之乱','洛阳兵变','群雄逐鹿','赤壁之战','鏖战三国','奇袭蜀中','进军东吴','马踏中原','试炼之地','外敌入侵','邪魔入侵','时空漩涡')
foreach ($chapter in $chapters) { $files += "bg/$chapter.png" }
$files += 'assets/ac-parts/邪魔入侵.png','assets/ac-parts/时空漩涡.png'
$files += Get-ChildItem (Join-Path $root 'META-INF') -File -Recurse | ForEach-Object { $_.FullName.Substring($root.Length+1).Replace('\','/') }
$files = @($files | Sort-Object -Unique)
foreach ($required in @('ui.swf','general.swf','sound.swf','stage.xml','shop.xml','staticgeneral.xml')) {
    if ($required -notin $files) { throw "Loader manifest missing: $required" }
}
foreach ($file in $files) {
    if (!(Test-Path -LiteralPath (Join-Path $root $file) -PathType Leaf)) { throw "Missing release resource: $file" }
}
Add-Type -AssemblyName System.IO.Compression.FileSystem
$output = Join-Path (Split-Path $root) ("sgqz-offline-v$version-full-" + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.zip')
$zip = [IO.Compression.ZipFile]::Open($output, [IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($file in $files) {
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, (Join-Path $root $file), $file, [IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
} finally { $zip.Dispose() }
$zip = [IO.Compression.ZipFile]::OpenRead($output)
try {
    if ($zip.Entries.Count -ne $files.Count) { throw 'ZIP entry count mismatch' }
    foreach ($file in $files) {
        $stream = $zip.GetEntry($file).Open()
        $sha = [Security.Cryptography.SHA256]::Create()
        try { $hash = [BitConverter]::ToString($sha.ComputeHash($stream)).Replace('-','') }
        finally { $stream.Dispose(); $sha.Dispose() }
        if ($hash -ne (Get-FileHash -LiteralPath (Join-Path $root $file) -Algorithm SHA256).Hash) { throw "ZIP content mismatch: $file" }
    }
} finally { $zip.Dispose() }
Write-Output "Verified $($files.Count) files: $output"
Get-FileHash -LiteralPath $output -Algorithm SHA256
