# OpportunityAlert - Installer
# Version 1.0

$ErrorActionPreference = "Continue"

function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

Clear-Host
Write-Info "=============================================="
Write-Info "   OPPORTUNITYALERT"
Write-Info "   Interactive Installer v1.0"
Write-Info "=============================================="
Write-Host ""

# Step 1: Check Python
Write-Info "Step 1: Checking Python Installation"
Write-Info "--------------------------------------"

try {
    $pythonVersion = python --version 2>&1
    if ($pythonVersion -match "Python (\d+)\.(\d+)") {
        $major = [int]$matches[1]
        $minor = [int]$matches[2]
        
        if ($major -ge 3 -and $minor -ge 8) {
            Write-Success "Python $pythonVersion found"
        } else {
            Write-Error "Python version too old: $pythonVersion"
            Write-Error "Please install Python 3.8 or newer"
            pause
            exit 1
        }
    }
} catch {
    Write-Error "Python not found or not in PATH"
    Write-Error "Please install Python first and make sure to check 'Add Python to PATH'"
    pause
    exit 1
}

Write-Host ""

# Step 2: Email Configuration
Write-Info "Step 2: Email Configuration"
Write-Info "----------------------------"
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
    Write-Warning "Please enter a valid Gmail address"
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

Write-Success "Email configured: $email"
Write-Host ""

# Step 3: Job Search Keywords
Write-Info "Step 3: Job Search Settings"
Write-Info "----------------------------"
Write-Host "Enter keywords (comma-separated)"
Write-Host "Example: Epic Analyst, Clinical Informatics"
Write-Host ""

$keywordsInput = Read-Host "Job search keywords"
$keywords = $keywordsInput -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }

Write-Host ""
Write-Host "Enter negative keywords to EXCLUDE (or press Enter to skip)"
$negativeInput = Read-Host "Negative keywords (optional)"
if ($negativeInput) {
    $negativeKeywords = $negativeInput -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
} else {
    $negativeKeywords = @()
}

Write-Success "Keywords configured"
Write-Host ""

# Step 4: Career Sites
Write-Info "Step 4: Career Sites to Monitor"
Write-Info "--------------------------------"
Write-Host "Enter career site URLs (one per line, blank to finish)"
Write-Host ""

$careerSites = @()
$siteCount = 1

while ($true) {
    $siteName = Read-Host "Site #$siteCount name (or press Enter to finish)"
    if ([string]::IsNullOrWhiteSpace($siteName)) { break }
    
    $siteUrl = Read-Host "Site #$siteCount URL"
    if ([string]::IsNullOrWhiteSpace($siteUrl)) {
        Write-Warning "URL cannot be empty"
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

Write-Success "$($careerSites.Count) career sites added"
Write-Host ""

# Step 5: Installation Paths
Write-Info "Step 5: Installation Location"
Write-Info "------------------------------"

$defaultInstallPath = "C:\OpportunityAlert"
Write-Host "Installation path [default: $defaultInstallPath]:"
$installPath = Read-Host
if ([string]::IsNullOrWhiteSpace($installPath)) {
    $installPath = $defaultInstallPath
}

$scriptsPath = Join-Path $installPath "Scripts"
$batchPath = Join-Path $installPath "Batch"
$resultsPath = Join-Path $installPath "Scanned_Results"

Write-Success "Installation path: $installPath"
Write-Host ""

# Step 6: Schedule Configuration
Write-Info "Step 6: Daily Schedule"
Write-Info "----------------------"
Write-Host "Daily scan time (24-hour format) [default: 08:00]:"
$scheduleTime = Read-Host
if ([string]::IsNullOrWhiteSpace($scheduleTime)) {
    $scheduleTime = "08:00"
}

Write-Success "Scheduled for daily scan at $scheduleTime"
Write-Host ""

# Step 7: Installation
Write-Info "Step 7: Installing..."
Write-Info "---------------------"

try {
    # Create directories
    Write-Host "Creating directories..."
    New-Item -ItemType Directory -Force -Path $installPath | Out-Null
    New-Item -ItemType Directory -Force -Path $scriptsPath | Out-Null
    New-Item -ItemType Directory -Force -Path $batchPath | Out-Null
    New-Item -ItemType Directory -Force -Path $resultsPath | Out-Null
    Write-Success "Directories created"
    
    # Install packages
    Write-Host "Installing Python packages..."
    python -m pip install --quiet --upgrade pip requests 2>&1 | Out-Null
    Write-Success "Python packages installed"
    
    # Create config
    Write-Host "Creating configuration..."
    $config = @{
        email = $email
        email_password = $emailPasswordPlain
        keywords = $keywords
        negative_keywords = $negativeKeywords
        career_sites = $careerSites
        schedule_time = $scheduleTime
        install_path = $installPath
        scripts_path = $scriptsPath
        batch_path = $batchPath
        results_path = $resultsPath
    }
    
    $configPath = Join-Path $installPath "config.json"
    $config | ConvertTo-Json -Depth 10 | Set-Content $configPath
    Write-Success "Configuration saved"
    
    # Copy templates to Scripts folder
    Write-Host "Copying scripts..."
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $templatesDir = Join-Path $scriptDir "templates"
    
    Copy-Item (Join-Path $templatesDir "opportunity_alert_template.py") (Join-Path $scriptsPath "opportunity_alert.py")
    Copy-Item (Join-Path $templatesDir "health_check_template.py") (Join-Path $scriptsPath "health_check.py")
    Copy-Item (Join-Path $templatesDir "update_settings_template.py") (Join-Path $scriptsPath "update_settings.py")
    
    Write-Success "Scripts created"
    
    # Create batch files in Batch folder
    Write-Host "Creating batch files..."
    
    # scan_jobs.bat
    $scanJobsBat = @"
@echo off
REM OpportunityAlert - Manual Job Scan
cd "$scriptsPath"
python opportunity_alert.py
pause
"@
    Set-Content (Join-Path $batchPath "scan_jobs.bat") $scanJobsBat
    
    # scan_all.bat
    $scanAllBat = @"
@echo off
REM OpportunityAlert - Show All Jobs
cd "$scriptsPath"
python opportunity_alert.py --all
pause
"@
    Set-Content (Join-Path $batchPath "scan_all.bat") $scanAllBat
    
    # scan_reset.bat
    $scanResetBat = @"
@echo off
REM OpportunityAlert - Reset History
cd "$scriptsPath"
python opportunity_alert.py --reset
pause
"@
    Set-Content (Join-Path $batchPath "scan_reset.bat") $scanResetBat
    
    # health_check.bat
    $healthCheckBat = @"
@echo off
REM OpportunityAlert - Site Health Check
cd "$scriptsPath"
python health_check.py
pause
"@
    Set-Content (Join-Path $batchPath "health_check.bat") $healthCheckBat
    
    # run_scheduled.bat (for Task Scheduler - no pause)
    $runScheduledBat = @"
@echo off
REM OpportunityAlert - Scheduled Task Runner
cd "$scriptsPath"
python opportunity_alert.py
"@
    Set-Content (Join-Path $batchPath "run_scheduled.bat") $runScheduledBat
    
    # update_settings.bat
    $updateSettingsBat = @"
@echo off
REM OpportunityAlert - Settings Manager
cd "$scriptsPath"
python update_settings.py
pause
"@
    Set-Content (Join-Path $batchPath "update_settings.bat") $updateSettingsBat
    
    # open_failed_sites.bat
    $openFailedBat = @"
@echo off
echo No failed sites from last scan.
pause
"@
    Set-Content (Join-Path $batchPath "open_failed_sites.bat") $openFailedBat
    
    Write-Success "Batch files created"
    
    # Task Scheduler
    Write-Host "Setting up Task Scheduler..."
    
    $taskName = "OpportunityAlert"
    $taskPath = Join-Path $batchPath "run_scheduled.bat"
    
    try {
        schtasks /Delete /TN "$taskName" /F 2>&1 | Out-Null
    } catch {}
    
    $taskXml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <Triggers>
    <CalendarTrigger>
      <StartBoundary>2026-01-01T$scheduleTime:00</StartBoundary>
      <ScheduleByDay><DaysInterval>1</DaysInterval></ScheduleByDay>
    </CalendarTrigger>
  </Triggers>
  <Settings>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <StartWhenAvailable>true</StartWhenAvailable>
    <Enabled>true</Enabled>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>$taskPath</Command>
      <WorkingDirectory>$scriptsPath</WorkingDirectory>
    </Exec>
  </Actions>
</Task>
"@
    
    $tempXml = Join-Path $env:TEMP "task_temp.xml"
    $taskXml | Set-Content -Path $tempXml -Encoding Unicode
    
    $output = schtasks /Create /TN "$taskName" /XML "$tempXml" /F 2>&1
    
    if (Test-Path $tempXml) {
        Remove-Item $tempXml -Force -ErrorAction SilentlyContinue
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Task Scheduler configured"
    } else {
        Write-Warning "Could not create Task Scheduler task"
        Write-Host "You can create it manually later"
    }
    
    # Run test
    Write-Host ""
    Write-Info "Running initial test..."
    Set-Location $scriptsPath
    python opportunity_alert.py --reset 2>&1 | Out-Null
    Write-Success "Test completed"
    
} catch {
    Write-Error "Installation failed: $_"
    pause
    exit 1
}

# Done
Write-Host ""
Write-Success "=============================================="
Write-Success "   INSTALLATION COMPLETE!"
Write-Success "=============================================="
Write-Host ""
Write-Host "OpportunityAlert is now running automatically!"
Write-Host ""
Write-Host "Installation folder: $installPath"
Write-Host "Next scheduled scan: Tomorrow at $scheduleTime"
Write-Host ""
Write-Host "Available commands (in Batch folder):"
Write-Host "  scan_jobs.bat       - Manual scan"
Write-Host "  scan_all.bat        - Show all jobs"
Write-Host "  scan_reset.bat      - Clear history"
Write-Host "  health_check.bat    - Test sites"
Write-Host "  update_settings.bat - Change settings"
Write-Host ""
pause
Invoke-Item $installPath
