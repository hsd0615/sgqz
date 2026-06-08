param([string]$ImagePath)
Add-Type -AssemblyName System.Runtime.WindowsRuntime
Add-Type -AssemblyName System.Drawing

# Helper: invoke WinRT IAsyncOperation<T> and get result
function Invoke-WinRTAsync($asyncObj) {
    $type = $asyncObj.GetType()
    try {
        return $type.InvokeMember('GetResults', [System.Reflection.BindingFlags]::InvokeMethod, $null, $asyncObj, @())
    } catch {
        Write-Host "GetResults error: $_"
        return $null
    }
}

if (-not $ImagePath -or -not (Test-Path $ImagePath)) {
    Write-Host "Usage: .\ocr.ps1 <image_path>"
    exit 1
}

$fullPath = (Resolve-Path $ImagePath).Path
Write-Host "Image: $fullPath"

# Load as PNG bytes
$bmp = New-Object System.Drawing.Bitmap($fullPath)
$w = $bmp.Width; $h = $bmp.Height
$ms = New-Object System.IO.MemoryStream
$bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
$bytes = $ms.ToArray()
$ms.Dispose()
Write-Host "Size: ${w}x${h}, PNG: $($bytes.Length) bytes"

# Create IRandomAccessStream
$memStream = New-Object System.IO.MemoryStream
$memStream.Write($bytes, 0, $bytes.Length)
$memStream.Seek(0, [System.IO.SeekOrigin]::Begin) | Out-Null
$randStream = [System.IO.WindowsRuntimeStreamExtensions]::AsRandomAccessStream($memStream)

# BitmapDecoder.CreateAsync
$decoderType = [System.Type]::GetType('Windows.Graphics.Imaging.BitmapDecoder, Windows.Graphics, ContentType=WindowsRuntime')
$createMethod = $decoderType.GetMethods() | Where-Object { $_.Name -eq 'CreateAsync' -and $_.GetParameters().Count -eq 1 }
$asyncOp = $createMethod.Invoke($null, @($randStream))
$decoder = Invoke-WinRTAsync $asyncOp

if (-not $decoder) {
    Write-Host "ERROR: Failed to decode image"
    exit 1
}
Write-Host "BitmapDecoder: OK"

# Get SoftwareBitmap
$swAsync = $decoder.GetSoftwareBitmapAsync()
$swBitmap = Invoke-WinRTAsync $swAsync
if (-not $swBitmap) {
    Write-Host "ERROR: Failed to get SoftwareBitmap"
    exit 1
}
Write-Host "SoftwareBitmap: OK"

# Create OCR engine
$ocrType = [System.Type]::GetType('Windows.Media.Ocr.OcrEngine, Windows.Media, ContentType=WindowsRuntime')
$engine = $ocrType.GetMethod('TryCreateFromUserProfileLanguages').Invoke($null, @())
if (-not $engine) {
    Write-Host "ERROR: No OCR engine available"
    exit 1
}
Write-Host "OCR Engine: OK"

# Recognize
$recogAsync = $engine.RecognizeAsync($swBitmap)
$result = Invoke-WinRTAsync $recogAsync
if (-not $result) {
    Write-Host "ERROR: OCR recognition failed"
    exit 1
}

Write-Host ""
Write-Host "=== OCR RESULT ==="
foreach ($line in $result.Lines) {
    Write-Host $line.Text
}
Write-Host "=== END ==="
