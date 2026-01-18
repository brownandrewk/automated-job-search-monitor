# Automated Job Search Monitor - Installer
# Version 1.0

$ErrorActionPreference = "Continue"

# Colors for output
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

Clear-Host
Write-Info "=============================================="
Write-Info "   AUTOMATED JOB SEARCH MONITOR"
Write-Info "   Interactive Installer v1.0"
Write-Info "=============================================="
Write-Host ""

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "Note: Not running as administrator. Task Scheduler may require elevation."
    Write-Warning "If installation fails, right-click and 'Run as Administrator'"
    Write-Host ""
}

# Step 1: Check Python Installation
Write-Info "Step 1: Checking Python Installation"
Write-Info "--------------------------------------"

try {
    $pythonVersion = python --version 2>&1
    if ($pythonVersion -match "Python (\d+)\.(\d+)") {
        $major = [int]$matches[1]
        $minor = [int]$matches[2]
        
        if ($major -ge 3 -and $minor -ge 8) {
            Write-Success "âœ" Python $pythonVersion found"
        } else {
            Write-Error "âœ— Python version too old: $pythonVersion"
            Write-Error "Please install Python 3.8 or newer"
            Write-Host "Visit: https://www.python.org/downloads/"
            pause
            exit 1
        }
    }
} catch {
    Write-Error "âœ— Python not found or not in PATH"
    Write-Error ""
    Write-Error "Please install Python first:"
    Write-Error "1. Go to https://www.python.org/downloads/"
    Write-Error "2. Scroll down past the big yellow button"
    Write-Error "3. Download 'Windows installer (64-bit)' from Files section"
    Write-Error "4. During install, CHECK 'Add Python to PATH'"
    Write-Error ""
    pause
    exit 1
}

Write-Host ""

# Step 2: Email Configuration
Write-Info "Step 2: Email Configuration"
Write-Info "----------------------------"
Write-Host ""
Write-Warning "IMPORTANT: We need a Gmail APP PASSWORD, NOT your regular Gmail password!"
Write-Host ""
Write-Host "A Gmail App Password is a special 16-character password just for apps."
Write-Host "It is NOT the password you use to log into Gmail."
Write-Host ""
Write-Host "To create one:"
Write-Host "  1. Go to: https://myaccount.google.com/apppasswords"
Write-Host "  2. You may need to enable 2-Step Verification first"
Write-Host "  3. Select 'Mail' and click 'Generate'"
Write-Host "  4. Copy the 16-character password it shows you"
Write-Host "  5. Paste it below when prompted"
Write-Host ""
Write-Warning "DO NOT enter your regular Gmail login password - it won't work!"
Write-Host ""

$email = Read-Host "Enter your Gmail address"
while ($email -notmatch "^[^@]+@gmail\.com$") {
    Write-Warning "Please enter a valid Gmail address (must end with @gmail.com)"
    $email = Read-Host "Enter your Gmail address"
}

Write-Host ""
Write-Host "Now enter your Gmail APP PASSWORD (the 16-character one from the link above):"
$emailPassword = Read-Host "Gmail App Password" -AsSecureString
$emailPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($emailPassword))

if ($emailPasswordPlain.Length -ne 16) {
    Write-Warning "Gmail App Passwords are usually 16 characters (with no spaces)."
    Write-Warning "Make sure you're using an App Password, not your regular password!"
    Write-Host ""
    $continue = Read-Host "Continue anyway? (Y/N)"
    if ($continue -ne "Y" -and $continue -ne "y") {
        Write-Error "Installation cancelled. Please get a Gmail App Password and try again."
        pause
        exit 1
    }
}

Write-Success "âœ" Email configured: $email"
Write-Host ""

# Step 3: Job Search Keywords
Write-Info "Step 3: Job Search Settings"
Write-Info "----------------------------"
Write-Host "Enter keywords to search for (comma-separated)"
Write-Host "Example: Epic Analyst, Clinical Informatics, EHR Analyst"
Write-Host ""

$keywordsInput = Read-Host "Job search keywords"
$keywords = $keywordsInput -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }

Write-Host ""
Write-Host "Enter negative keywords to EXCLUDE (comma-separated, or press Enter to skip)"
Write-Host "Example: nurse, physician, medical assistant"
Write-Host ""

$negativeInput = Read-Host "Negative keywords (optional)"
if ($negativeInput) {
    $negativeKeywords = $negativeInput -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
} else {
    $negativeKeywords = @()
}

Write-Success "âœ" Keywords configured"
Write-Host ""

# Step 4: Career Sites
Write-Info "Step 4: Career Sites to Monitor"
Write-Info "--------------------------------"
Write-Host "Enter career site URLs to monitor (one per line)"
Write-Host "Press Enter on blank line when done"
Write-Host ""
Write-Host "Example URLs:"
Write-Host "  https://careers.ohsu.edu/jobs"
Write-Host "  https://providence.jobs/locations/oregon/jobs/"
Write-Host ""

$careerSites = @()
$siteCount = 1

while ($true) {
    $siteName = Read-Host "Site #$siteCount name (or press Enter to finish)"
    if ([string]::IsNullOrWhiteSpace($siteName)) { break }
    
    $siteUrl = Read-Host "Site #$siteCount URL"
    if ([string]::IsNullOrWhiteSpace($siteUrl)) {
        Write-Warning "URL cannot be empty. Try again."
        continue
    }
    
    $careerSites += @{
        name = $siteName
        url = $siteUrl
    }
    
    $siteCount++
    Write-Host ""
}

if ($careerSites.Count -eq 0) {
    Write-Error "You must add at least one career site!"
    pause
    exit 1
}

Write-Success "âœ" $($careerSites.Count) career sites added"
Write-Host ""

# Step 5: Installation Paths
Write-Info "Step 5: Installation Location"
Write-Info "------------------------------"

$defaultInstallPath = "C:\JobSearchMonitor"
Write-Host "Where should we install the job monitor?"
$installPath = Read-Host "Installation path [default: $defaultInstallPath]"
if ([string]::IsNullOrWhiteSpace($installPath)) {
    $installPath = $defaultInstallPath
}

$resultsPath = Join-Path $installPath "Results"

Write-Success "âœ" Installation path: $installPath"
Write-Success "âœ" Results path: $resultsPath"
Write-Host ""

# Step 6: Schedule Configuration
Write-Info "Step 6: Daily Schedule"
Write-Info "----------------------"
Write-Host "What time should the job monitor run each day?"
Write-Host "Use 24-hour format (e.g., 08:00 for 8 AM, 17:00 for 5 PM)"
Write-Host ""

$scheduleTime = Read-Host "Daily run time [default: 08:00]"
if ([string]::IsNullOrWhiteSpace($scheduleTime)) {
    $scheduleTime = "08:00"
}

# Validate time format
while ($scheduleTime -notmatch "^\d{2}:\d{2}$") {
    Write-Warning "Please use format HH:MM (e.g., 08:00)"
    $scheduleTime = Read-Host "Daily run time"
}

Write-Success "âœ" Scheduled for daily run at $scheduleTime"
Write-Host ""

# Step 7: Installation
Write-Info "Step 7: Installing..."
Write-Info "---------------------"

try {
    # Create directories
    Write-Host "Creating directories..."
    New-Item -ItemType Directory -Force -Path $installPath | Out-Null
    New-Item -ItemType Directory -Force -Path $resultsPath | Out-Null
    Write-Success "âœ" Directories created"
    
    # Install Python packages
    Write-Host "Installing Python packages..."
    $pipOutput = python -m pip install --quiet --upgrade pip requests 2>&1
    Write-Success "âœ" Python packages installed"
    
    # Create config.json
    Write-Host "Creating configuration file..."
    $config = @{
        email = $email
        email_password = $emailPasswordPlain
        keywords = $keywords
        negative_keywords = $negativeKeywords
        career_sites = $careerSites
        schedule_time = $scheduleTime
        install_path = $installPath
        results_path = $resultsPath
    }
    
    $configPath = Join-Path $installPath "config.json"
    $config | ConvertTo-Json -Depth 10 | Set-Content $configPath
    Write-Success "âœ" Configuration saved"
    
    # Copy template files and generate scripts
    Write-Host "Generating monitoring scripts..."
    
    # Get script directory
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $templatesDir = Join-Path $scriptDir "templates"
    
    # Copy template files
    if (Test-Path (Join-Path $templatesDir "job_monitor_template.py")) {
        Copy-Item (Join-Path $templatesDir "job_monitor_template.py") (Join-Path $installPath "job_monitor.py")
        Copy-Item (Join-Path $templatesDir "job_test_template.py") (Join-Path $installPath "job_test.py")
        Write-Success "âœ" Python scripts created"
    } else {
        Write-Error "Template files not found! Make sure templates folder exists."
        throw
    }
    
    # Create batch files
    Write-Host "Creating batch files..."
    
    # monitor.bat
    @"
@echo off
cd "$installPath"
python job_monitor.py
pause
"@ | Set-Content (Join-Path $installPath "monitor.bat")
    
    # monitor_all.bat
    @"
@echo off
cd "$installPath"
python job_monitor.py --all
pause
"@ | Set-Content (Join-Path $installPath "monitor_all.bat")
    
    # monitor_reset.bat
    @"
@echo off
cd "$installPath"
python job_monitor.py --reset
pause
"@ | Set-Content (Join-Path $installPath "monitor_reset.bat")
    
    # monitor_test.bat
    @"
@echo off
cd "$installPath"
python job_test.py
pause
"@ | Set-Content (Join-Path $installPath "monitor_test.bat")
    
    # run_job_monitor.bat (for Task Scheduler - no pause)
    @"
@echo off
cd "$installPath"
python job_monitor.py
"@ | Set-Content (Join-Path $installPath "run_job_monitor.bat")
    
    # open_failed_sites.bat (will be updated by scripts)
    @"
@echo off
echo No failed sites from last run.
pause
"@ | Set-Content (Join-Path $installPath "open_failed_sites.bat")
    
    Write-Success "âœ" Batch files created"
    
    # Create update_settings.bat (launches PowerShell script)
    @"
@echo off
REM Settings Update Launcher for Job Search Monitor

echo Starting settings manager...
PowerShell.exe -ExecutionPolicy Bypass -File "%~dp0UPDATE_SETTINGS.ps1"
"@ | Set-Content (Join-Path $installPath "update_settings.bat")
    
    # Copy UPDATE_SETTINGS.ps1
    if (Test-Path (Join-Path $templatesDir "UPDATE_SETTINGS.ps1")) {
        Copy-Item (Join-Path $templatesDir "UPDATE_SETTINGS.ps1") (Join-Path $installPath "UPDATE_SETTINGS.ps1")
    } else {
        # Embedded version if template doesn't exist
        $updateSettingsScript | Set-Content (Join-Path $installPath "UPDATE_SETTINGS.ps1")
    }
    
    # Copy UNINSTALL.ps1
    if (Test-Path (Join-Path $templatesDir "UNINSTALL.ps1")) {
        Copy-Item (Join-Path $templatesDir "UNINSTALL.ps1") (Join-Path $installPath "UNINSTALL.ps1")
    }
    
    # Create uninstall.bat launcher
    @"
@echo off
echo.
echo WARNING: This will completely remove Job Search Monitor!
echo.
pause
PowerShell.exe -ExecutionPolicy Bypass -File "%~dp0UNINSTALL.ps1"
"@ | Set-Content (Join-Path $installPath "uninstall.bat")
    
    Write-Success "✓ Uninstaller created"
    
    # Create Task Scheduler task
    Write-Host "Setting up Windows Task Scheduler..."
    
    $timeParts = $scheduleTime -split ":"
    $hour = $timeParts[0]
    $minute = $timeParts[1]
    
    $taskName = "Automated Job Monitor"
    $taskPath = Join-Path $installPath "run_job_monitor.bat"
    
    # Remove existing task if it exists
    schtasks /Query /TN $taskName 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        schtasks /Delete /TN $taskName /F | Out-Null
    }
    
    # Create new task
    $action = New-ScheduledTaskAction -Execute $taskPath
    $trigger = New-ScheduledTaskTrigger -Daily -At $scheduleTime
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Description "Automated job search monitoring" | Out-Null
    
    Write-Success "âœ" Task Scheduler configured"
    
    # Run initial test
    Write-Host ""
    Write-Info "Running initial test..."
    Set-Location $installPath
    $testOutput = python job_monitor.py --reset 2>&1
    
    Write-Success "âœ" Test completed"
    
} catch {
    Write-Error ""
    Write-Error "Installation failed: $_"
    Write-Error ""
    pause
    exit 1
}

# Installation Complete
Write-Host ""
Write-Success "=============================================="
Write-Success "   INSTALLATION COMPLETE!"
Write-Success "=============================================="
Write-Host ""
Write-Host "Your job monitor is now running automatically!"
Write-Host ""
Write-Host "Installation folder: $installPath"
Write-Host "Next scheduled run: Tomorrow at $scheduleTime"
Write-Host ""
Write-Host "Test email sent - check your inbox!"
Write-Host ""
Write-Host "Available commands:"
Write-Host "  monitor.bat         - Manual run (shows new jobs)"
Write-Host "  monitor_all.bat     - Show all matching jobs"
Write-Host "  monitor_reset.bat   - Clear history, start fresh"
Write-Host "  monitor_test.bat    - Test site health"
Write-Host "  update_settings.bat - Change settings"
Write-Host ""
Write-Host "Press any key to open installation folder..."
pause
Invoke-Item $installPath
