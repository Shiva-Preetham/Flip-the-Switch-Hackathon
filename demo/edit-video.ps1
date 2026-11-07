# Edits the raw screen recording into the final demo video:
# cuts the segments in edit-plan.json, speeds each one to fit its narration, zooms the
# approval moments, burns in captions, adds title/outro cards and the Kokoro narration.
param(
  [string]$Raw = (Join-Path $PSScriptRoot 'raw\Recording 2026-11-07 135112.mp4'),
  [string]$Plan = (Join-Path $PSScriptRoot 'edit-plan.json'),
  [string]$Voice = (Join-Path $PSScriptRoot 'build\voice'),
  [string]$Ffmpeg = "ffmpeg",
  [string]$Out = (Join-Path $PSScriptRoot 'support-to-ship-demo.mp4')
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$work = Join-Path $PSScriptRoot 'build\edit'
if (Test-Path $work) { Remove-Item -Recurse -Force $work }
New-Item -ItemType Directory $work | Out-Null

$W = 1920; $H = 1080; $BAR = 150
$bg     = [System.Drawing.Color]::FromArgb(17, 24, 39)
$accent = [System.Drawing.Color]::FromArgb(52, 211, 153)
$white  = [System.Drawing.Color]::White
$muted  = [System.Drawing.Color]::FromArgb(170, 178, 192)

function Text($g, $s, $size, $color, $x, $y, $w, $h, $style = 'Regular') {
  $f = New-Object System.Drawing.Font('Segoe UI', $size, [System.Drawing.FontStyle]::$style, [System.Drawing.GraphicsUnit]::Pixel)
  $g.DrawString($s, $f, (New-Object System.Drawing.SolidBrush $color), (New-Object System.Drawing.RectangleF($x, $y, $w, $h)))
}
function Canvas($transparent) {
  $b = New-Object System.Drawing.Bitmap $W, $H, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($b); $g.SmoothingMode = 'AntiAlias'; $g.TextRenderingHint = 'AntiAliasGridFit'
  if ($transparent) { $g.Clear([System.Drawing.Color]::Transparent) } else { $g.Clear($bg) }
  return @($b, $g)
}
function Card($path, $seg) {
  $b, $g = Canvas $false
  $g.FillRectangle((New-Object System.Drawing.SolidBrush $accent), 160, 250, 12, 300)
  Text $g $seg.kicker 32 $accent 210 240 1600 60 'Bold'
  Text $g $seg.title 88 $white 210 292 1600 250 'Bold'
  Text $g ($seg.body -replace '\\n', "`n") 38 $muted 210 590 1600 420
  $b.Save($path, [System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $b.Dispose()
}
function Box($g, $x, $y, $w, $h, $num, $title, $sub, $human) {
  $fill = if ($human) { [System.Drawing.Color]::FromArgb(22, 52, 44) } else { [System.Drawing.Color]::FromArgb(31, 41, 55) }
  $g.FillRectangle((New-Object System.Drawing.SolidBrush $fill), $x, $y, $w, $h)
  $pen = New-Object System.Drawing.Pen ($(if ($human) { $accent } else { [System.Drawing.Color]::FromArgb(75, 85, 99) })), 3
  $g.DrawRectangle($pen, $x, $y, $w, $h)
  $g.FillEllipse((New-Object System.Drawing.SolidBrush $accent), $x + 18, $y + ($h - 52) / 2, 52, 52)
  Text $g $num 30 $bg ($x + 35) ($y + ($h - 52) / 2 + 6) 52 44 'Bold'
  Text $g $title 30 $white ($x + 88) ($y + 14) ($w - 100) 44 'Bold'
  Text $g $sub 24 $muted ($x + 88) ($y + 54) ($w - 100) 40
}
function Arrow($g, $x1, $y1, $x2, $y2, $label, $lx, $ly) {
  $pen = New-Object System.Drawing.Pen $accent, 5
  $pen.CustomEndCap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap 5, 5
  $g.DrawLine($pen, $x1, $y1, $x2, $y2)
  if ($label) { Text $g $label 24 $accent $lx $ly 300 36 'Bold' }
}
function Diagram($path, $seg) {
  $b, $g = Canvas $false
  Text $g $seg.kicker 30 $accent 140 50 1600 50 'Bold'
  Text $g $seg.title 52 $white 140 92 1700 80 'Bold'
  $panel = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(23, 31, 46))
  $g.FillRectangle($panel, 120, 200, 760, 840); $g.FillRectangle($panel, 1040, 200, 760, 840)
  Text $g '#shoplite-support room' 30 $accent 150 215 700 44 'Bold'
  Text $g '#shoplite-engineering room' 30 $accent 1070 215 700 44 'Bold'
  # support column
  Box $g 150 280 700 110 '1' 'Ticket pasted' 'Support person, in team chat' $true
  Box $g 150 440 700 110 '2' 'Support agent' 'Reproduces vs. pricing policy, escalates' $false
  Box $g 150 760 700 110 '6' 'Support agent' 'Drafts the reply with the exact refund' $false
  Box $g 150 910 700 110 '7' 'Person: Allow once' 'Switch approval to send the reply' $true
  # engineering column
  Box $g 1070 440 700 110 '3' 'Fixer agent' 'Branch, failing test, fix, tests pass' $false
  Box $g 1070 600 700 110 '4' 'Reviewer agent' 'Checks diff vs. policy: APPROVED' $false
  Box $g 1070 760 700 110 '5' 'Person: Allow once' 'Switch approval to merge to main' $true
  # flow
  Arrow $g 500 392 500 436 $null 0 0
  Arrow $g 852 495 1066 495 'escalate' 895 455
  Arrow $g 1420 552 1420 596 $null 0 0
  Arrow $g 1420 712 1420 756 $null 0 0
  Arrow $g 1068 815 854 815 'fixed + merged' 870 775
  Arrow $g 500 872 500 906 $null 0 0
  $b.Save($path, [System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $b.Dispose()
}
function Caption($path, $seg, $speed) {
  $b, $g = Canvas $true
  $g.FillRectangle((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(230, 10, 14, 26))), 0, $H - $BAR, $W, $BAR)
  $g.FillRectangle((New-Object System.Drawing.SolidBrush $accent), 0, $H - $BAR, 12, $BAR)
  Text $g $seg.step 30 $accent 50 ($H - $BAR + 16) 1500 44 'Bold'
  Text $g $seg.caption 32 $white 50 ($H - $BAR + 60) 1830 84
  if ($speed -ge 1.25) {
    $badge = ('{0:0.#}x speed' -f $speed)
    $g.FillRectangle((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(200, 10, 14, 26))), $W - 230, 24, 200, 52)
    Text $g $badge 28 $accent ($W - 215) 32 190 44 'Bold'
  }
  $b.Save($path, [System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $b.Dispose()
}

$segments = Get-Content -Raw -Encoding UTF8 $Plan | ConvertFrom-Json
$durations = Get-Content -Raw (Join-Path $Voice 'durations.json') | ConvertFrom-Json
$inv = [Globalization.CultureInfo]::InvariantCulture
$list = @()

foreach ($seg in $segments) {
  $id = $seg.id
  $narr = [double]$durations.$id
  $target = $narr + 0.7
  $wav = Join-Path $Voice "$id.wav"
  $mp4 = Join-Path $work "$id.mp4"

  if ($seg.kind -eq 'scroll') {
    $img = Join-Path $PSScriptRoot $seg.image
    $cap = Join-Path $work "$id-cap.png"; Caption $cap $seg 1
    $len = [Math]::Max($target, 6.0)
    $L = $len.ToString('0.###', $inv); $fo = ($len - 0.4).ToString('0.###', $inv)
    $run = ($len - 2.0).ToString('0.###', $inv); $toY = [int]$seg.toY
    $cw = [int]$seg.cropW; $ch = [int]($cw * 9 / 16); $cx = [int]$seg.cropX
    $vf = "[0:v]crop=${cw}:${ch}:${cx}:'if(lt(t,1),0,min((t-1)/$run,1)*$toY)',scale=1920:1080:flags=lanczos,setsar=1,fps=30[base];" +
          "[base][1:v]overlay=0:0,fade=t=in:st=0:d=0.4,fade=t=out:st=${fo}:d=0.4,format=yuv420p[v];[2:a]apad,atrim=0:${L}[a]"
    & $Ffmpeg -hide_banner -loglevel error -y -loop 1 -framerate 30 -t $L -i $img -loop 1 -i $cap -i $wav `
      -filter_complex $vf -map "[v]" -map "[a]" -c:v libx264 -preset medium -crf 20 -r 30 -c:a aac -b:a 192k -ar 48000 -t $L $mp4
  } elseif ($seg.kind -eq 'card' -or $seg.kind -eq 'diagram') {
    $png = Join-Path $work "$id-card.png"
    if ($seg.kind -eq 'diagram') { Diagram $png $seg } else { Card $png $seg }
    $len = [Math]::Max($target, 5.0)
    $fo = ($len - 0.4).ToString('0.###', $inv); $L = $len.ToString('0.###', $inv)
    & $Ffmpeg -hide_banner -loglevel error -y -loop 1 -framerate 30 -t $L -i $png -i $wav `
      -filter_complex "[0:v]fade=t=in:st=0:d=0.4,fade=t=out:st=${fo}:d=0.4,format=yuv420p[v];[1:a]apad,atrim=0:${L}[a]" `
      -map "[v]" -map "[a]" -c:v libx264 -preset medium -crf 20 -r 30 -c:a aac -b:a 192k -ar 48000 -t $L $mp4
  } else {
    $D = [double]$seg.end - [double]$seg.start
    $speed = [Math]::Min([Math]::Max($D / $target, 1.0), 4.0)
    $vidLen = $D / $speed
    $len = [Math]::Max($vidLen, $target)
    $freeze = [Math]::Max($len - $vidLen, 0)
    $cap = Join-Path $work "$id-cap.png"; Caption $cap $seg $speed
    $zoom = if ($seg.zoom) { 'crop=1152:648:766:330,' } else { '' }
    $S = $speed.ToString('0.####', $inv); $L = $len.ToString('0.###', $inv); $F = $freeze.ToString('0.###', $inv)
    $fo = ($len - 0.25).ToString('0.###', $inv)
    $ss = ([double]$seg.start).ToString('0.###', $inv); $dd = $D.ToString('0.###', $inv)
    $vf = "[0:v]setpts=(PTS-STARTPTS)/${S},${zoom}scale=1920:1080:flags=lanczos,setsar=1,fps=30,tpad=stop_mode=clone:stop_duration=${F}[base];" +
          "[base][1:v]overlay=0:0,fade=t=in:st=0:d=0.25,fade=t=out:st=${fo}:d=0.25,format=yuv420p[v];[2:a]apad,atrim=0:${L}[a]"
    & $Ffmpeg -hide_banner -loglevel error -y -ss $ss -t $dd -i $Raw -loop 1 -i $cap -i $wav `
      -filter_complex $vf -map "[v]" -map "[a]" -c:v libx264 -preset medium -crf 20 -r 30 -c:a aac -b:a 192k -ar 48000 -t $L $mp4
    Write-Host ("{0}: src {1}s -> {2:0.0}s at {3:0.00}x, narration {4:0.0}s" -f $id, $D, $len, $speed, $narr)
  }
  if ($LASTEXITCODE -ne 0) { throw "ffmpeg failed on segment $id" }
  $list += "file '$($mp4 -replace '\\','/')'"
}

$listFile = Join-Path $work 'list.txt'
[IO.File]::WriteAllLines($listFile, $list)
& $Ffmpeg -hide_banner -loglevel error -y -f concat -safe 0 -i $listFile -c copy -movflags +faststart $Out
if ($LASTEXITCODE -ne 0) { throw 'concat failed' }
Write-Host "VIDEO: $Out"
