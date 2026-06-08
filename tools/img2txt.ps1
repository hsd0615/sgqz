param([string]$ImagePath)
Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile((Resolve-Path $ImagePath).Path)
$w = $img.Width; $h = $img.Height

# Create bitmap for pixel access
$bmp = New-Object System.Drawing.Bitmap($img)
$img.Dispose()

# Downsample: each output char represents a block
$stepX = [Math]::Max(1, [int]($w / 80))
$stepY = [Math]::Max(1, [int]($h / 25))

foreach ($y in (0..($h-1) | Where-Object { $_ % $stepY -eq 0 } | Select-Object -First 25)) {
    $line = ""
    foreach ($x in (0..($w-1) | Where-Object { $_ % $stepX -eq 0 } | Select-Object -First 80)) {
        $px = $bmp.GetPixel([Math]::Min($x, $w-1), [Math]::Min($y, $h-1))
        $brightness = ($px.R + $px.G + $px.B) / 3
        if ($brightness -lt 60) { $line += "#" }
        elseif ($brightness -lt 100) { $line += ":" }
        elseif ($brightness -lt 150) { $line += "." }
        elseif ($brightness -lt 200) { $line += "-" }
        else { $line += " " }
    }
    Write-Host $line
}
$bmp.Dispose()
