# 截图 OCR 识别工具 - 用于 Claude 读取终端截图
param(
    [Parameter(Mandatory=$true)]
    [string]$ImagePath
)

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Runtime.WindowsRuntime
$null = [Windows.Media.Ocr.OcrEngine, Windows.Foundation, ContentType = WindowsRuntime]
$null = [Windows.Graphics.Imaging.BitmapDecoder, Windows.Graphics.Imaging, ContentType = WindowsRuntime]
$null = [Windows.Storage.Streams.RandomAccessStreamReference, Windows.Storage.Streams, ContentType = WindowsRuntime]

# 加载图片
$imagePathAbs = (Resolve-Path $ImagePath).Path
$bitmap = [System.Drawing.Image]::FromFile($imagePathAbs)
$width = $bitmap.Width
$height = $bitmap.Height
Write-Host "图片尺寸: ${width}x${height}"

# 转为内存流
$ms = New-Object System.IO.MemoryStream
$bitmap.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
$bitmap.Dispose()

# 创建 Windows Runtime 流
$ms.Seek(0, 'Begin') | Out-Null
$randomAccessStream = New-Object System.IO.MemoryStream -ArgumentList @()
$ms.CopyTo($randomAccessStream)
$ms.Dispose()
$randomAccessStream.Seek(0, 'Begin') | Out-Null

# 使用 Windows OCR
try {
    $decoder = [Windows.Graphics.Imaging.BitmapDecoder]::CreateAsync([Windows.Graphics.Imaging.BitmapDecoder+PngDecoderId], $randomAccessStream).GetAwaiter().GetResult()
    $softwareBitmap = $decoder.GetSoftwareBitmapAsync().GetAwaiter().GetResult()

    # Try Chinese first, then fallback
    $engine = $null
    $chinese = [Windows.Media.Ocr.OcrEngine]::AvailableRecognizerLanguages | Where-Object { $_.LanguageTag -like "zh*" } | Select-Object -First 1
    if ($chinese) {
        $engine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromLanguage($chinese)
        Write-Host "OCR语言: $($chinese.LanguageTag)"
    }
    if (-not $engine) {
        $engine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromUserProfileLanguages()
        Write-Host "OCR语言: 系统默认"
    }

    if ($engine) {
        $result = $engine.RecognizeAsync($softwareBitmap).GetAwaiter().GetResult()
        Write-Host "`n========== OCR识别结果 =========="
        foreach ($line in $result.Lines) {
            Write-Host $line.Text
        }
        Write-Host "================================`n"
    } else {
        Write-Host "ERROR: 无可用的OCR引擎，请安装中文语言包"
    }
} catch {
    Write-Host "OCR错误: $_"
    Write-Host "尝试备用方案: 将图片转为 base64 供 AI 分析..."

    # 备用方案: 输出 base64
    $bytes = [System.IO.File]::ReadAllBytes($imagePathAbs)
    $base64 = [Convert]::ToBase64String($bytes)
    Write-Host "base64 (前200字符): $($base64.Substring(0, [Math]::Min(200, $base64.Length)))"
} finally {
    if ($randomAccessStream) { $randomAccessStream.Dispose() }
}
