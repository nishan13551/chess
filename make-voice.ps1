<#
  make-voice.ps1 — turns voice-script.json into one mp3 per line for Magnus.

  1. Open chess.html, go to the Learn tab, press "Export script".
     Move the downloaded voice-script.json next to this file.
  2. Pick the voice you want on elevenlabs.io and copy its Voice ID
     (Voices -> your voice -> ID). Use a voice you own or a stock/designed
     voice — not a clone of a real person.
  3. Run:
       .\make-voice.ps1 -ApiKey "sk_..." -VoiceId "abcdef123456"

  Files land in .\voice\<id>.mp3, which is exactly where chess.html looks.
  Re-running skips lines that already exist, so it is safe to stop and resume,
  and after editing one lesson you can delete that clip and rerun.
#>

param(
  [Parameter(Mandatory = $true)][string] $ApiKey,
  [Parameter(Mandatory = $true)][string] $VoiceId,
  [string] $ScriptPath = ".\voice-script.json",
  [string] $OutDir     = ".\voice",
  [string] $ModelId    = "eleven_multilingual_v2",
  [double] $Stability        = 0.45,
  [double] $SimilarityBoost  = 0.80,
  [double] $Style            = 0.15,
  [int]    $DelayMs          = 350,
  [switch] $Force
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ScriptPath)) {
  Write-Host "Cannot find $ScriptPath." -ForegroundColor Red
  Write-Host 'Open chess.html -> Learn tab -> "Export script", then move the file here.'
  exit 1
}

$lines = Get-Content $ScriptPath -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

$total   = $lines.Count
$done    = 0
$skipped = 0
$copied  = 0
$failed  = @()
$chars   = 0
$i       = 0

Write-Host "$total lines to generate with voice $VoiceId" -ForegroundColor Cyan

foreach ($line in $lines) {
  $i++
  $id   = $line.id
  $text = $line.text
  $out  = Join-Path $OutDir "$id.mp3"

  if ((Test-Path $out) -and (-not $Force)) {
    $skipped++
    continue
  }
  if ([string]::IsNullOrWhiteSpace($text)) { continue }

  # identical wording to an earlier line: copy that clip instead of paying again
  if ($line.PSObject.Properties.Name -contains 'dupOf' -and $line.dupOf) {
    $src = Join-Path $OutDir "$($line.dupOf).mp3"
    if (Test-Path $src) {
      Copy-Item $src $out -Force
      $copied++
      continue
    }
  }

  $pct = [int](($i / $total) * 100)
  Write-Progress -Activity "Generating Magnus" -Status "$i/$total  $id" -PercentComplete $pct

  $body = @{
    text     = $text
    model_id = $ModelId
    voice_settings = @{
      stability         = $Stability
      similarity_boost  = $SimilarityBoost
      style             = $Style
      use_speaker_boost = $true
    }
  } | ConvertTo-Json -Depth 5

  # send as UTF-8 bytes so apostrophes and dashes survive the trip
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($body)

  try {
    Invoke-RestMethod -Method Post `
      -Uri "https://api.elevenlabs.io/v1/text-to-speech/$VoiceId" `
      -Headers @{ "xi-api-key" = $ApiKey; "Accept" = "audio/mpeg" } `
      -ContentType "application/json" `
      -Body $bytes `
      -OutFile $out
    $done++
    $chars += $text.Length
  } catch {
    $failed += $id
    Write-Host "  failed: $id  -  $($_.Exception.Message)" -ForegroundColor Yellow
    if (Test-Path $out) { Remove-Item $out -Force }   # never leave a truncated clip behind
  }

  Start-Sleep -Milliseconds $DelayMs
}

Write-Progress -Activity "Generating Magnus" -Completed
Write-Host ""
Write-Host "generated : $done"   -ForegroundColor Green
Write-Host "copied    : $copied (identical wording, no API call)"
Write-Host "skipped   : $skipped (already existed)"
Write-Host "characters: $chars (this is what you are billed for)"
if ($failed.Count -gt 0) {
  Write-Host "failed    : $($failed.Count)" -ForegroundColor Yellow
  Write-Host ($failed -join ", ")
  Write-Host "Re-run the same command to retry just those."
} else {
  Write-Host "Done. Reload chess.html and Magnus will speak with the clips." -ForegroundColor Green
}
