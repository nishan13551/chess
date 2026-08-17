<#
  save-to-github.ps1 — put the latest changes on GitHub WITHOUT spending a
  Netlify build.

  Pushing to GitHub is free. What costs Netlify credits is the build it runs
  afterwards, so the commit message below carries [skip netlify], which tells
  Netlify to ignore this push and not build at all.

  Run it from this folder:

      .\save-to-github.ps1

  or with your own message:

      .\save-to-github.ps1 -Message "board trays and rule fixes"

  When your credits are back and you want it live, see DEPLOY-LATER.md.
#>

param(
  [string] $Message = "Unlocked puzzles, green board, captured-piece trays, rule fixes"
)

$ErrorAction = "Stop"
Set-Location -Path $PSScriptRoot

# nothing to do?
$dirty = git status --porcelain
if ([string]::IsNullOrWhiteSpace($dirty)) {
  Write-Host "Nothing has changed since the last commit." -ForegroundColor Yellow
  git log --oneline -1
  exit 0
}

Write-Host "About to commit:" -ForegroundColor Cyan
git status --short
Write-Host ""

git add -A
if (-not $?) { Write-Host "git add failed." -ForegroundColor Red; exit 1 }

# [skip netlify] is the important part: GitHub stores it, Netlify ignores it
$full = "$Message`n`n[skip netlify]"
git commit -m $full
if (-not $?) { Write-Host "git commit failed." -ForegroundColor Red; exit 1 }

git push origin main
if (-not $?) {
  Write-Host ""
  Write-Host "Push failed. If it is asking for credentials, sign in to GitHub" -ForegroundColor Yellow
  Write-Host "in the popup, or run:  git push origin main" -ForegroundColor Yellow
  exit 1
}

Write-Host ""
Write-Host "Saved to GitHub. Netlify was told to skip this build, so no credits used." -ForegroundColor Green
git log --oneline -3
