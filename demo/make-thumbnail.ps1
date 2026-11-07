# Builds the YouTube thumbnail (1280x720) from a real frame of the recording.
param(
  [string]$Raw = (Join-Path $PSScriptRoot 'raw\Recording 2026-11-07 135112.mp4'),
  [double]$At = 141.5,
  [string]$Ffmpeg = "ffmpeg",
  [string]$Out = (Join-Path $PSScriptRoot 'thumbnail.png')
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$frame = Join-Path $PSScriptRoot 'build\thumb-frame.png'
& $Ffmpeg -hide_banner -loglevel error -y -ss $At -i $Raw -frames:v 1 $frame

$W = 1280; $H = 720
$bmp = New-Object System.Drawing.Bitmap $W, $H
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'; $g.TextRenderingHint = 'AntiAliasGridFit'; $g.InterpolationMode = 'HighQualityBicubic'

$accent = [System.Drawing.Color]::FromArgb(52, 211, 153)
$white = [System.Drawing.Color]::White
$muted = [System.Drawing.Color]::FromArgb(190, 198, 210)
$grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.Point(0, 0)), (New-Object System.Drawing.Point($W, $H)), [System.Drawing.Color]::FromArgb(8, 13, 25), [System.Drawing.Color]::FromArgb(20, 44, 52))
$g.FillRectangle($grad, 0, 0, $W, $H)

function Font($size, $style = 'Bold') { New-Object System.Drawing.Font('Segoe UI', $size, [System.Drawing.FontStyle]::$style, [System.Drawing.GraphicsUnit]::Pixel) }
function Say($text, $size, $color, $x, $y, $style = 'Bold') { $g.DrawString($text, (Font $size $style), (New-Object System.Drawing.SolidBrush $color), [single]$x, [single]$y) }

# real screenshot: the Switch "Permission needed" request with Allow once
$src = [System.Drawing.Image]::FromFile($frame)
$crop = New-Object System.Drawing.Rectangle(1400, 380, 518, 520)
$sx = 700; $sy = 40; $scale = 1.08
$dw = [int]($crop.Width * $scale); $dh = [int]($crop.Height * $scale)
$g.FillRectangle((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(120, 0, 0, 0))), $sx + 14, $sy + 14, $dw, $dh)
$g.DrawImage($src, (New-Object System.Drawing.Rectangle($sx, $sy, $dw, $dh)), $crop, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawRectangle((New-Object System.Drawing.Pen $accent, 6), $sx, $sy, $dw, $dh)
$src.Dispose()

# highlight the "Allow once" button (raw 1519-1654 x 735-774)
$bx = $sx + [int]((1519 - 1400) * $scale) - 10; $by = $sy + [int]((735 - 380) * $scale) - 10
$bw = [int](135 * $scale) + 20; $bh = [int](39 * $scale) + 20
$g.DrawEllipse((New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(250, 204, 21)), 7), $bx - 18, $by - 12, $bw + 36, $bh + 24)

# left: pill + headline
$g.FillRectangle((New-Object System.Drawing.SolidBrush $accent), 48, 52, 300, 50)
Say 'BUILT ON SWITCH' 30 ([System.Drawing.Color]::FromArgb(8, 13, 25)) 64 58
$arrow = [string][char]0x2192
Say 'Customer bug' 86 $white 40 130
Say "$arrow merged fix" 86 $accent 40 236
Say "$arrow refund" 86 $white 40 342
Say ('3 AI agents  ' + [char]0x00B7 + '  2 human approvals') 36 $muted 48 470 'Regular'

# bottom strip
$g.FillRectangle((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(200, 8, 13, 25))), 0, 630, $W, 90)
Say 'Claude Code  +  Switch  +  Mattermost' 34 $white 48 652
Say 'You click: Allow once' 34 ([System.Drawing.Color]::FromArgb(250, 204, 21)) 860 652

$bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose()
"THUMB: $Out  " + [math]::Round((Get-Item $Out).Length / 1KB) + ' KB'
