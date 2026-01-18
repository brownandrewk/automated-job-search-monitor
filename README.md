# Automated Job Search Monitor

An automated system that monitors career websites daily and emails you when new jobs matching your criteria are found.

## Features

- 🔍 Monitors multiple career sites automatically
- 📧 Email notifications for new job postings only
- 🎯 Customizable keywords and filters
- 🛠️ Easy setup with interactive installer
- 📊 Health check script to verify sites are working
- ⚙️ Simple settings management (no code editing required)

---

## Installation

### Step 1: Install Python (IMPORTANT - Read Carefully!)

**⚠️ DO NOT CLICK THE BIG YELLOW BUTTON ON PYTHON.ORG ⚠️**

That downloads the Microsoft Store launcher, which won't work correctly.

**Correct installation process:**

1. Go to https://www.python.org/downloads/
2. **Scroll down** past the big yellow button
3. Find the section "Looking for a specific release?"
4. Click on the latest **Python 3.12.x** (or 3.11.x) link
5. Scroll to "Files" section at the bottom
6. Download: **Windows installer (64-bit)** (the one that says "Recommended")
7. Run the installer

**During installation:**
- ✅ **CHECK the box "Add Python to PATH"** (bottom of first screen - CRITICAL!)
- ✅ Click "Install Now"
- Wait for completion

**Verify Python is installed:**
1. Open Command Prompt (Win + R, type `cmd`, press Enter)
2. Type: `python --version`
3. Should show something like `Python 3.12.1`
4. If you get an error, Python isn't installed correctly - try again

### Step 2: Download This Repository

**Option A: Download ZIP**
1. Click the green "Code" button above
2. Click "Download ZIP"
3. Extract the ZIP to any folder (e.g., `C:\Downloads\job-monitor`)

**Option B: Clone with Git** (if you have Git installed)
```bash
git clone https://github.com/yourusername/job-search-monitor.git
cd job-search-monitor
```

### Step 3: Run the Installer

**EASIEST METHOD (Recommended):**
1. Navigate to the folder where you extracted the files
2. **Double-click `SETUP.bat`**
3. If you see a security warning, click "More info" → "Run anyway"
4. Follow the prompts

**ALTERNATIVE METHOD (If SETUP.bat doesn't work):**
1. Right-click `INSTALL.ps1` → Properties
2. Check "Unblock" at the bottom → Click OK
3. Right-click `INSTALL.ps1` → "Run with PowerShell"

**If you see errors about execution policy:**
1. Open PowerShell as Administrator (Win + X → "Windows PowerShell (Admin)")
2. Run: `Set-ExecutionPolicy RemoteSigned`
3. Type `Y` and press Enter
4. Run `SETUP.bat` again

**Follow the prompts:**
- Enter your Gmail address
- Enter your Gmail App Password (see below)
- Enter job search keywords
- Enter career site URLs
- Choose installation location
- Choose daily run time

The installer will:
- ✅ Install required Python packages
- ✅ Create your monitoring scripts
- ✅ Set up Windows Task Scheduler
- ✅ Create configuration files
- ✅ Run a test to verify everything works

---

## Gmail App Password Setup

**You need a Gmail App Password for email notifications:**

1. Go to https://myaccount.google.com/apppasswords
2. You may need to enable 2-Step Verification first
3. Select "Mail" from the dropdown
4. Click "Generate"
5. Copy the 16-character password
6. Paste it when the installer asks for your Gmail password

**⚠️ Do NOT use your regular Gmail password - it won't work!**

---

## Usage

### Automated Daily Runs

After installation, the script runs automatically every day at your chosen time. No action needed!

### Manual Runs

Use these batch files (found in your installation folder):

- **`monitor.bat`** - Standard run (check for new jobs, send email if found)
- **`monitor_all.bat`** - Show ALL matching jobs (not just new ones)
- **`monitor_reset.bat`** - Clear history and treat all jobs as new
- **`monitor_test.bat`** - Run health check on all sites

### Update Your Settings

Double-click **`update_settings.bat`** to:
- Add/remove career sites
- Change keywords
- Update email settings
- Modify schedule time

---

## Understanding Your Results

### Email Notifications

You'll receive emails when:
- New jobs matching your keywords are found
- Sites fail to load (for manual checking)

**Email includes:**
- Job titles and direct links
- Which company posted each job
- Failed sites with URLs for manual review

### Failed Sites Section

Some sites may fail due to:
- Bot protection (403 errors)
- Site maintenance
- Changed URLs

**What to do:**
- Click the provided links to check manually
- These sites often have good opportunities!
- Consider updating the URL if permanently broken

### Opening Failed Sites Quickly

**From your computer:**
- Double-click `open_failed_sites.bat`
- All failed sites open in browser tabs at once

**From your phone/anywhere:**
- Click individual links in the email

---

## Customization

### Adding New Career Sites

1. Run `update_settings.bat`
2. Choose option 2 (Career sites)
3. Choose "Add new site"
4. Enter organization name and URL

### Changing Keywords

1. Run `update_settings.bat`
2. Choose option 1 (Keywords)
3. Add or remove search terms

### Advanced: Edit Config Directly

Open `config.json` in any text editor:

```json
{
  "email": "your-email@gmail.com",
  "keywords": ["Epic Analyst", "Clinical Informatics"],
  "negative_keywords": ["nurse", "physician"],
  "career_sites": [
    {"name": "OHSU", "url": "https://careers.ohsu.edu"}
  ]
}
```

Save and close - changes take effect on next run.

---

## Testing & Troubleshooting

### Run the Health Check

Double-click `monitor_test.bat` to verify:
- Which sites are working
- How many jobs each site has
- Which jobs match your keywords
- Which sites need manual checking

**Example output:**
```
OHSU: 47 total jobs | 3 match your keywords
  Example: "Epic Ambulatory Analyst"
  
PeaceHealth: 0 jobs found ⚠️
  Manual check: https://careers.peacehealth.org
```

### Common Issues

**"Python not found" error:**
- Python isn't installed or not in PATH
- Reinstall Python and CHECK "Add Python to PATH"

**No emails received:**
- Verify Gmail App Password is correct
- Check spam folder
- Run `monitor_reset.bat` to force an email test

**Task not running automatically:**
- Open Task Scheduler
- Find "Automated Job Monitor" task
- Right-click → Run to test
- Check History tab for errors

**Sites showing 0 results:**
- Some sites block automated scraping
- Check manually using the provided link
- Consider running health check weekly

---

## Files & Folders

After installation:

```
C:\JobSearchMonitor\
├── job_monitor.py          # Main monitoring script
├── job_test.py            # Health check script
├── config.json            # Your settings
├── monitor.bat            # Standard run
├── monitor_all.bat        # Show all jobs
├── monitor_reset.bat      # Clear history
├── monitor_test.bat       # Health check
├── update_settings.bat    # Settings menu
├── open_failed_sites.bat  # Open failed sites
├── Results\
│   ├── job_results.txt    # Latest search results
│   └── .job_history.json  # Tracking file (don't delete)
```

---

## Tips for Best Results

- ✅ Run `monitor_test.bat` weekly to verify sites are working
- ✅ Check failed sites manually - they often have great opportunities
- ✅ Run `monitor_reset.bat` monthly to see all current openings
- ✅ Adjust keywords if getting too many/too few results
- ✅ Keep your keywords specific to your field

---

## Privacy & Security

- ✅ All data stays on your computer
- ✅ No data sent anywhere except job site requests
- ✅ Gmail password stored locally in plain text config file
- ✅ No tracking, no analytics, no cloud services
- ⚠️ Keep your `config.json` secure (contains email password)

---

## Uninstallation

**Easy Method (Recommended):**

1. Go to your installation folder (default: `C:\JobSearchMonitor\`)
2. Double-click `uninstall.bat`
3. Confirm you want to uninstall
4. Optionally backup your configuration to Desktop
5. Confirm final deletion

The uninstaller will:
- ✅ Remove the Task Scheduler task
- ✅ Offer to backup your settings
- ✅ Delete all files and folders
- ✅ Clean up completely

**Manual Method:**

If you need to uninstall manually:

1. Open Task Scheduler (Win + R, type `taskschd.msc`)
2. Find "Automated Job Monitor" task
3. Right-click → Delete
4. Delete the installation folder (`C:\JobSearchMonitor\`)
5. Uninstall Python (if not using for other purposes)

---

## Support & Issues

If something isn't working:

1. Run `monitor_test.bat` to diagnose
2. Check Task Scheduler history for errors
3. Verify Python and packages are installed
4. Check `config.json` for typos
5. Review email spam folder

---

## License

This project is open source and available under the MIT License.

---

## Credits

Created to help job seekers automate the tedious parts of job searching and focus on what matters - landing great opportunities.

**Version:** 1.0  
**Last Updated:** January 2026