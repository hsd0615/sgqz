<#
.SYNOPSIS
  OCR tool - reads text from image file or Windows clipboard
.DESCRIPTION
  Uses Windows 10 built-in OCR (Windows.Media.Ocr) to extract text.
  Works with both file paths and clipboard images.
.EXAMPLE
  .\read_image.ps1 screenshot.png      # Read from file
  .\read_image.ps1                     # Read from clipboard
#>
param([string]$ImagePath)

Add-Type -AssemblyName System.Runtime.WindowsRuntime
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

function Invoke-WinRTAsync($asyncObj) {
    $type = $asyncObj.GetType()
    return $type.InvokeMember('GetResults',
        [System.Reflection.BindingFlags]::InvokeMethod,
        $null, $asyncObj, @())
}

function Ocr-FromBitmap($bitmap) {
    $w = $bitmap.Width; $h = $bitmap.Height
    $ms = New-Object System.IO.MemoryStream
    $bitmap.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
    $bytes = $ms.ToArray(); $ms.Dispose()

    $memStream = New-Object System.IO.MemoryStream
    $memStream.Write($bytes, 0, $bytes.Length)
    $memStream.Seek(0, [System.IO.SeekOrigin]::Begin) | Out-Null
    $randStream = [System.IO.WindowsRuntimeStreamExtensions]::AsRandomAccessStream($memStream)

    # Decode image - need the CreateAsync(IRandomAccessStream) overload
    $decoderType = [System.Type]::GetType('Windows.Graphics.Imaging.BitmapDecoder, Windows.Graphics, ContentType=WindowsRuntime')
    $createMethod = $decoderType.GetMethods() | Where-Object {
        $_.Name -eq 'CreateAsync' -and $_.GetParameters().Count -eq 1
    }
    if (-not $createMethod) {
        Write-Error "Cannot find CreateAsync method"
        return $null
    }
    $asyncOp = $createMethod.Invoke($null, @($randStream))

    $sysExtType = [System.WindowsRuntimeSystemExtensions]
    $asTaskMethod = $null
    foreach ($m in $sysExtType.GetMethods()) {
        if ($m.Name -eq 'AsTask' -and $m.IsGenericMethod -and
            $m.GetGenericArguments().Count -eq 1 -and
            $m.GetParameters().Count -eq 1 -and
            $m.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1') {
            $asTaskMethod = $m
            break
        }
    }
    if (-not $asTaskMethod) {
        Write-Error "Cannot find AsTask method"
        return $null
    }
    $task = $asTaskMethod.MakeGenericMethod(@([Windows.Graphics.Imaging.BitmapDecoder])).Invoke($null, @($asyncOp))
    $task.Wait(5000)
    $decoder = $task.Result

    # Get SoftwareBitmap
    $swAsync = $decoder.GetSoftwareBitmapAsync()
    $task2 = $asTaskMethod.MakeGenericMethod(@([Windows.Graphics.Imaging.SoftwareBitmap])).Invoke($null, @($swAsync))
    $task2.Wait(5000)
    $swBitmap = $task2.Result

    # OCR
    $ocrType = [System.Type]::GetType('Windows.Media.Ocr.OcrEngine, Windows.Media, ContentType=WindowsRuntime')
    $engine = $ocrType.GetMethod('TryCreateFromUserProfileLanguages').Invoke($null, @())
    if (-not $engine) {
        Write-Error "No OCR engine. Install Chinese language pack in Windows Settings."
        return $null
    }

    $recogAsync = $engine.RecognizeAsync($swBitmap)
    $task3 = $asTaskMethod.MakeGenericMethod(@([Windows.Media.Ocr.OcrResult])).Invoke($null, @($recogAsync))
    $task3.Wait(10000)
    $result = $task3.Result

    Write-Host "Image: ${w}x${h}"
    Write-Host "--- OCR Result ---"
    $text = ""
    foreach ($line in $result.Lines) {
        Write-Host $line.Text
        $text += $line.Text + "`n"
    }
    Write-Host "--- End ---"
    return $text.TrimEnd()
}

# Main
$bitmap = $null
$fromClipboard = $false

if ($ImagePath -and (Test-Path $ImagePath)) {
    $fullPath = (Resolve-Path $ImagePath).Path
    Write-Host "[File: $fullPath]"
    $bitmap = New-Object System.Drawing.Bitmap($fullPath)
} else {
    # Try multiple clipboard methods
    $gotImage = $false

    # Method 1: Standard clipboard image check
    try {
        if ([System.Windows.Forms.Clipboard]::ContainsImage()) {
            $bitmap = [System.Windows.Forms.Clipboard]::GetImage()
            $gotImage = $true
            Write-Host "[From Clipboard: standard image]"
        }
    } catch {}

    # Method 2: Try clipboard file drop (screenshots saved as files)
    if (-not $gotImage) {
        try {
            $fileList = [System.Windows.Forms.Clipboard]::GetFileDropList()
            if ($fileList -and $fileList.Count -gt 0) {
                $firstFile = $fileList[0]
                if (Test-Path $firstFile) {
                    $ext = [System.IO.Path]::GetExtension($firstFile).ToLower()
                    if (@('.png','.jpg','.jpeg','.bmp','.gif','.tiff') -contains $ext) {
                        $bitmap = New-Object System.Drawing.Bitmap($firstFile)
                        $gotImage = $true
                        Write-Host "[From Clipboard: file drop - $firstFile]"
                    }
                }
            }
        } catch {}
    }

    # Method 3: Try clipboard PNG/DIB format
    if (-not $gotImage) {
        try {
            $dataObj = [System.Windows.Forms.Clipboard]::GetDataObject()
            if ($dataObj) {
                $formats = $dataObj.GetFormats()
                foreach ($fmt in $formats) {
                    if ($fmt -match 'PNG|Bitmap|DIB|DeviceIndependentBitmap|JPG|GIF|TIFF') {
                        $imgData = $dataObj.GetData($fmt)
                        if ($imgData -is [System.IO.MemoryStream]) {
                            $bitmap = New-Object System.Drawing.Bitmap($imgData)
                            $gotImage = $true
                            Write-Host "[From Clipboard: $fmt format]"
                            break
                        } elseif ($imgData -is [System.Drawing.Image]) {
                            $bitmap = $imgData
                            $gotImage = $true
                            Write-Host "[From Clipboard: $fmt image]"
                            break
                        } elseif ($imgData -is [byte[]]) {
                            $ms = New-Object System.IO.MemoryStream(@(,$imgData))
                            $bitmap = New-Object System.Drawing.Bitmap($ms)
                            $gotImage = $true
                            Write-Host "[From Clipboard: $fmt bytes]"
                            break
                        }
                    }
                }
            }
        } catch {}
    }

    if (-not $gotImage) {
        # Show what formats ARE available
        try {
            $dataObj = [System.Windows.Forms.Clipboard]::GetDataObject()
            if ($dataObj) {
                $avail = ($dataObj.GetFormats() | ForEach-Object { $_ }) -join ', '
                Write-Error "No image found in clipboard. Available formats: $avail"
            } else {
                Write-Error "Clipboard is empty or inaccessible."
            }
        } catch {
            Write-Error "Cannot access clipboard. Try running PowerShell as STA mode: powershell -sta -File tools/read_image.ps1"
        }
        Write-Host "Usage: .\read_image.ps1 [image_path]"
        Write-Host "       If no path given, reads from clipboard."
        exit 1
    }
}

if ($bitmap) {
    $result = Ocr-FromBitmap $bitmap
    $bitmap.Dispose()

    # Copy result to clipboard (only works in interactive session)
    if ($result) {
        try {
            [System.Windows.Forms.Clipboard]::SetText($result)
            Write-Host "[OCR text copied to clipboard]"
        } catch {
            Write-Host "[Clipboard write failed - run from GUI terminal if needed]"
        }
    }

    if (-not $result) {
        exit 1
    }
}
