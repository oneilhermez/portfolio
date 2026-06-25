<#
Publish Oneil's portfolio site to GitHub Pages.

Requirements on Windows:
1) Install Git: https://git-scm.com/downloads
2) Install GitHub CLI: https://cli.github.com/
3) Run this script from inside the extracted portfolio folder.

What it does:
- Signs you into GitHub CLI if needed.
- Creates a public GitHub repository named <your-username>.github.io if it does not exist.
- Pushes this portfolio website to the repository.
- Attempts to enable GitHub Pages from the main branch.
#>

$ErrorActionPreference = "Stop"

function Require-Command($Name, $InstallNote) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Write-Host "Missing required command: $Name" -ForegroundColor Red
        Write-Host $InstallNote -ForegroundColor Yellow
        exit 1
    }
}

Require-Command "git" "Install Git from https://git-scm.com/downloads, then re-open PowerShell."
Require-Command "gh" "Install GitHub CLI from https://cli.github.com/, then re-open PowerShell."

if (-not (Test-Path "index.html")) {
    Write-Host "Run this script from inside the extracted portfolio folder, where index.html is located." -ForegroundColor Red
    exit 1
}

Write-Host "Checking GitHub login..." -ForegroundColor Cyan
gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "GitHub login required. A browser sign-in will open." -ForegroundColor Yellow
    gh auth login --hostname github.com --web
}

$detectedUser = (gh api user --jq ".login").Trim()
Write-Host "Detected GitHub username: $detectedUser" -ForegroundColor Green

$defaultRepo = "$detectedUser.github.io"
$repoNameInput = Read-Host "Repository name for your portfolio site [$defaultRepo]"
if ([string]::IsNullOrWhiteSpace($repoNameInput)) {
    $repoName = $defaultRepo
} else {
    $repoName = $repoNameInput.Trim()
}

$ownerRepo = "$detectedUser/$repoName"

if (-not (Test-Path ".git")) {
    git init
}

git branch -M main

git add .
$commitMessage = "Publish portfolio website"
$hasStagedChanges = git diff --cached --quiet; $stagedExit = $LASTEXITCODE
if ($stagedExit -ne 0) {
    git commit -m $commitMessage
} else {
    Write-Host "No file changes to commit." -ForegroundColor Yellow
}

Write-Host "Checking repository $ownerRepo..." -ForegroundColor Cyan
gh repo view $ownerRepo *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Creating repository $ownerRepo..." -ForegroundColor Cyan
    gh repo create $repoName --public --source . --remote origin --push
} else {
    Write-Host "Repository already exists. Pushing latest files..." -ForegroundColor Cyan
    git remote get-url origin *> $null
    if ($LASTEXITCODE -ne 0) {
        git remote add origin "https://github.com/$ownerRepo.git"
    } else {
        git remote set-url origin "https://github.com/$ownerRepo.git"
    }
    git push -u origin main
}

Write-Host "Attempting to enable GitHub Pages..." -ForegroundColor Cyan
# This may say Pages already exists, which is fine.
gh api "repos/$ownerRepo/pages" *> $null
if ($LASTEXITCODE -ne 0) {
    gh api --method POST "repos/$ownerRepo/pages" -f "source[branch]=main" -f "source[path]=/" *> $null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Automatic Pages enabling did not complete. Open repository Settings > Pages and set branch to main / root." -ForegroundColor Yellow
    }
} else {
    gh api --method PUT "repos/$ownerRepo/pages" -f "source[branch]=main" -f "source[path]=/" *> $null
}

Write-Host "Done." -ForegroundColor Green
Write-Host "Your site should appear soon at:" -ForegroundColor Green
Write-Host "https://$repoName" -ForegroundColor White
Write-Host "If it does not appear after a few minutes, open GitHub > your repo > Settings > Pages and confirm source is main / root." -ForegroundColor Yellow
