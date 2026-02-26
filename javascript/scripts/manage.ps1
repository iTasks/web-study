#Requires -Version 5.1
<#
.SYNOPSIS
    Full-stack project management tool (PowerShell).

.DESCRIPTION
    Manage setup, development, build, test, lint, deploy, and Docker operations
    for the full-stack JavaScript + Python project.

.EXAMPLE
    .\scripts\manage.ps1 setup
    .\scripts\manage.ps1 dev all
    .\scripts\manage.ps1 build
    .\scripts\manage.ps1 test
    .\scripts\manage.ps1 lint
    .\scripts\manage.ps1 deploy production
    .\scripts\manage.ps1 docker up
    .\scripts\manage.ps1 clean
    .\scripts\manage.ps1 status
    .\scripts\manage.ps1 logs backend
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('setup','dev','build','test','lint','deploy','docker','clean','status','logs','help')]
    [string]$Command = 'help',

    [Parameter(Position = 1)]
    [string]$Arg1 = '',

    [Parameter(Position = 2)]
    [string]$Arg2 = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'  # allow individual steps to fail without aborting all

# ─── Paths ────────────────────────────────────────────────────────────────────
$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root        = Split-Path -Parent $ScriptDir
$FrontendDir = Join-Path $Root 'roadmap'            # adjust to your frontend
$BackendDir  = Join-Path (Split-Path -Parent $Root) 'python\samples'  # adjust
$ComposeFile = Join-Path $Root 'docker-compose.yml'

# ─── Helpers ──────────────────────────────────────────────────────────────────
function Write-Header([string]$Text) {
    $line = '─' * 60
    Write-Host "`n$line" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan -BackgroundColor Black
    Write-Host "$line`n" -ForegroundColor Cyan
}

function Write-Success([string]$Msg) {
    Write-Host "✔  $Msg" -ForegroundColor Green
}

function Write-Warn([string]$Msg) {
    Write-Host "⚠  $Msg" -ForegroundColor Yellow
}

function Write-Err([string]$Msg) {
    Write-Host "✖  $Msg" -ForegroundColor Red
}

function Test-Tool([string]$Name) {
    $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Invoke-Compose {
    param([string[]]$Args)
    if (Test-Path $ComposeFile) {
        & docker compose -f $ComposeFile @Args
    } else {
        & docker compose @Args
    }
}

function Invoke-Cmd {
    param([string[]]$CmdArgs, [string]$WorkDir = $null)
    $old = $PWD
    if ($WorkDir) { Set-Location $WorkDir }
    try {
        & $CmdArgs[0] $CmdArgs[1..$CmdArgs.Length]
        return $LASTEXITCODE
    } finally {
        Set-Location $old
    }
}

# ─── Commands ─────────────────────────────────────────────────────────────────
function Invoke-Setup {
    Write-Header 'Setup — Installing Dependencies'
    $errors = 0

    if (Test-Path $FrontendDir) {
        Write-Header 'Frontend — npm install'
        Invoke-Cmd @('npm', 'install') $FrontendDir
        if ($LASTEXITCODE -eq 0) { Write-Success 'Frontend deps installed' }
        else { Write-Err 'npm install failed'; $errors++ }
    } else {
        Write-Warn "Frontend dir not found: $FrontendDir"
    }

    if (Test-Path $BackendDir) {
        Get-ChildItem -Path $BackendDir -Recurse -Filter 'requirements*.txt' | ForEach-Object {
            Write-Header "Backend — pip install -r $($_.Name)"
            Invoke-Cmd @('python', '-m', 'pip', 'install', '-r', $_.FullName)
            if ($LASTEXITCODE -eq 0) { Write-Success "Installed $($_.Name)" }
            else { Write-Err "pip install failed for $($_.Name)"; $errors++ }
        }
    } else {
        Write-Warn "Backend dir not found: $BackendDir"
    }

    return $errors
}

function Invoke-Dev {
    param([string]$Service = 'all')
    Write-Header "Dev Servers — $Service"
    $jobs = @()

    if ($Service -ne 'backend' -and (Test-Path $FrontendDir)) {
        Write-Host '  Starting frontend on port 5173 …'
        $jobs += Start-Process -FilePath 'cmd' -ArgumentList "/k npm --prefix `"$FrontendDir`" run dev" -PassThru
    } elseif ($Service -ne 'backend') {
        Write-Warn "Frontend dir not found: $FrontendDir"
    }

    if ($Service -ne 'frontend' -and (Test-Path $BackendDir)) {
        Write-Host '  Starting backend on port 8000 …'
        $jobs += Start-Process -FilePath 'cmd' -ArgumentList "/k cd /d `"$BackendDir`" && python -m uvicorn app.main:app --reload --port 8000" -PassThru
    } elseif ($Service -ne 'frontend') {
        Write-Warn "Backend dir not found: $BackendDir"
    }

    if ($jobs.Count -eq 0) { Write-Err 'No services started.'; return 1 }
    Write-Host "`n  Servers launched in separate windows. Close them to stop.`n"
}

function Invoke-Build {
    Write-Header 'Build — Frontend Production Build'
    if (-not (Test-Path $FrontendDir)) { Write-Err "Frontend dir not found: $FrontendDir"; return 1 }
    Invoke-Cmd @('npm', 'run', 'build') $FrontendDir
    if ($LASTEXITCODE -eq 0) { Write-Success 'Build complete → dist/' }
    else { Write-Err 'Build failed' }
    return $LASTEXITCODE
}

function Invoke-Test {
    Write-Header 'Test Suites'
    $errors = 0

    if (Test-Path $FrontendDir) {
        Write-Header 'Frontend — npm test'
        Invoke-Cmd @('npm', 'test', '--', '--run') $FrontendDir
        if ($LASTEXITCODE -eq 0) { Write-Success 'Frontend tests passed' }
        else { Write-Err 'Frontend tests failed'; $errors++ }
    }

    if (Test-Path $BackendDir) {
        Write-Header 'Backend — pytest'
        Invoke-Cmd @('python', '-m', 'pytest', '-v') $BackendDir
        if ($LASTEXITCODE -eq 0) { Write-Success 'Backend tests passed' }
        else { Write-Err 'Backend tests failed'; $errors++ }
    }

    if ($errors -eq 0) { Write-Success 'All tests passed' }
    else { Write-Err "$errors suite(s) failed" }
    return $errors
}

function Invoke-Lint {
    Write-Header 'Lint & Type-check'
    $errors = 0

    if (Test-Path $FrontendDir) {
        Invoke-Cmd @('npm', 'run', 'lint')       $FrontendDir; if ($LASTEXITCODE -ne 0) { $errors++ }
        Invoke-Cmd @('npm', 'run', 'type-check') $FrontendDir; if ($LASTEXITCODE -ne 0) { $errors++ }
    }

    if (Test-Path $BackendDir) {
        if (Test-Tool 'ruff') {
            Invoke-Cmd @('ruff', 'check', '.') $BackendDir; if ($LASTEXITCODE -ne 0) { $errors++ }
        } else { Write-Warn 'ruff not found — skipping' }

        if (Test-Tool 'mypy') {
            Invoke-Cmd @('mypy', '.') $BackendDir; if ($LASTEXITCODE -ne 0) { $errors++ }
        } else { Write-Warn 'mypy not found — skipping' }
    }

    if ($errors -eq 0) { Write-Success 'All lint checks passed' }
    else { Write-Err "$errors check(s) failed" }
    return $errors
}

function Invoke-Deploy {
    param([string]$Env = 'production')
    Write-Header "Deploy — $Env"
    Invoke-Compose @('pull')
    Invoke-Compose @('up', '-d', '--build', '--remove-orphans')
    Write-Success 'Deployment complete'
}

function Invoke-Docker {
    param([string]$Action = 'ps')
    Write-Header "Docker — $Action"
    switch ($Action) {
        'up'    { Invoke-Compose @('up', '-d') }
        'down'  { Invoke-Compose @('down') }
        'ps'    { Invoke-Compose @('ps') }
        'logs'  { Invoke-Compose @('logs', '--tail=50', '-f') }
        'pull'  { Invoke-Compose @('pull') }
        'build' { Invoke-Compose @('build') }
        default {
            Write-Err "Unknown docker action: $Action. Choose: up, down, ps, logs, pull, build"
            return 1
        }
    }
}

function Invoke-Clean {
    Write-Header 'Clean — Removing Build Artefacts'
    $targets = @(
        (Join-Path $FrontendDir 'dist'),
        (Join-Path $FrontendDir '.vite'),
        (Join-Path $FrontendDir 'coverage'),
        (Join-Path $BackendDir  '.pytest_cache'),
        (Join-Path $BackendDir  '.mypy_cache'),
        (Join-Path $BackendDir  '.ruff_cache')
    )
    foreach ($t in $targets) {
        if (Test-Path $t) { Remove-Item -Recurse -Force $t; Write-Host "  Removed: $t" }
    }
    if (Test-Path $BackendDir) {
        Get-ChildItem -Path $BackendDir -Recurse -Directory -Filter '__pycache__' | ForEach-Object {
            Remove-Item -Recurse -Force $_.FullName
            Write-Host "  Removed: $($_.FullName)"
        }
    }
    Write-Success 'Clean complete'
}

function Invoke-Status {
    Write-Header 'Service Status'

    Write-Host 'Docker Compose services:'
    Invoke-Compose @('ps') 2>$null

    Write-Host "`nLocal ports:"
    $ports = @{ frontend = 5173; backend = 8000 }
    foreach ($svc in $ports.GetEnumerator()) {
        $conn = Get-NetTCPConnection -LocalPort $svc.Value -State Listen -ErrorAction SilentlyContinue
        if ($conn) {
            Write-Host ("  {0,-12} port {1}  " -f $svc.Key, $svc.Value) -NoNewline
            Write-Host "RUNNING" -ForegroundColor Green
        } else {
            Write-Host ("  {0,-12} port {1}  " -f $svc.Key, $svc.Value) -NoNewline
            Write-Host "STOPPED" -ForegroundColor DarkGray
        }
    }
}

function Invoke-Logs {
    param([string]$Service = '')
    Write-Header "Logs — $( if ($Service) { $Service } else { 'all services' } )"
    if ($Service) {
        Invoke-Compose @('logs', '--tail=100', '-f', $Service)
    } else {
        Invoke-Compose @('logs', '--tail=100', '-f')
    }
}

function Show-Help {
    Get-Help $MyInvocation.PSCommandPath -Detailed
}

# ─── Entry Point ──────────────────────────────────────────────────────────────
switch ($Command) {
    'setup'  { exit (Invoke-Setup) }
    'dev'    { exit (Invoke-Dev   ($Arg1 ? $Arg1 : 'all')) }
    'build'  { exit (Invoke-Build) }
    'test'   { exit (Invoke-Test) }
    'lint'   { exit (Invoke-Lint) }
    'deploy' { Invoke-Deploy ($Arg1 ? $Arg1 : 'production') }
    'docker' { Invoke-Docker ($Arg1 ? $Arg1 : 'ps') }
    'clean'  { Invoke-Clean }
    'status' { Invoke-Status }
    'logs'   { Invoke-Logs $Arg1 }
    'help'   { Show-Help }
    default  { Write-Err "Unknown command: $Command"; Show-Help; exit 1 }
}
