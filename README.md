# OpportunityAlert

An automated job search tool that monitors career websites daily and emails you when new opportunities matching your criteria are found.
### Authors Note: 
I hope this is helpful for you finding your next career! The more broadly a person expands their job search, the more time is needed to manually scrub each company site of valuable leads. This program is an effort to simply to trim that time. 
### Disclaimer: 
I've heavily leveraged AI tools in the production of this tool. 

## Features

- 🔍 Monitors multiple career sites automatically
- 📧 Email notifications for new job postings only
- 🎯 Customizable keywords and filters
- 🛠️ Easy setup with interactive installer
- 📊 Health check script to verify sites are working
- ⚙️ Simple settings management (no code editing required)
- 📁 Clean, organized folder structure

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

### Step 2: Download OpportunityAlert

**Option A: Download ZIP**
1. Click the green "Code" button above
2. Click "Download ZIP"
3. Extract the ZIP to any folder (e.g., `C:\Downloads\OpportunityAlert`)

**Option B: Clone with Git** (if you have Git installed)
```bash
git clone https://github.com/yourusername/OpportunityAlert.git
cd OpportunityAlert
```

### Step 3: Run the Installer

**EASIEST METHOD (Recommended):**
1. Navigate to the folder where you extracted the files
2. **Double-click `SETUP.bat`**
3. If you see a security warning, click "More info" → "Run anyway"
4. Follow the prompts

**If SETUP.bat doesn't work:**
1. Open PowerShell as Administrator (Win + X → "Windows PowerShell (Admin)")
2. Navigate to the folder: `cd "C:\path\to\OpportunityAlert"`
3. Run: `Set-ExecutionPolicy RemoteSigned`
4. Type `Y` and press Enter
5. Run `SETUP.bat` again

**Follow the installer prompts:**
- Enter your Gmail address
- Enter your Gmail App Password (see below)
- Enter job search keywords
- Enter career site URLs
- Choose installation location (default: C:\OpportunityAlert)
- Choose daily scan time

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

## Installed Folder Structure

After installation, you'll have:

```
C:\OpportunityAlert\
├── config.json              # Your settings
├── Scripts\
│   ├── opportunity_alert.py # Main scanner
│   ├── health_check.py      # Site testing
│   └── update_settings.py   # Settings manager
├── Batch\
│   ├── scan_jobs.bat        # Manual scan
│   ├── scan_all.bat         # Show all jobs
│   ├── scan_reset.bat       # Clear history
│   ├── health_check.bat     # Test sites
│   ├── update_settings.bat  # Change settings
│   └── open_failed_sites.bat # Open problem sites
└── Scanned_Results\
    ├── job_results.txt      # Latest results
    └── .job_history.json    # Tracking file
```

---

## Usage

### Automated Daily Scans

After installation, OpportunityAlert runs automatically every day at your chosen time. No action needed!

### Manual Scans

Navigate to `C:\OpportunityAlert\Batch\` and use these:

- **`scan_jobs.bat`** - Standard scan (shows new jobs, sends email if found)
- **`scan_all.bat`** - Show ALL matching jobs (not just new ones)
- **`scan_reset.bat`** - Clear history and treat all jobs as new
- **`health_check.bat`** - Test all sites to verify they're working

### Update Your Settings

Double-click **`update_settings.bat`** to:
- Add/remove job search keywords
- Add/remove negative keywords (jobs to exclude)
- Add/remove career sites
- View full configuration
- Create backup of settings

No code editing needed - everything is menu-driven!

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
- JavaScript-heavy sites (can't be scraped easily)

**What to do:**
- Click the provided links to check manually
- These sites often have good opportunities!
- Consider updating the URL if permanently broken

### Opening Failed Sites Quickly

**From your computer:**
- Navigate to `C:\OpportunityAlert\Batch\`
- Double-click `open_failed_sites.bat`
- All failed sites open in browser tabs at once

**From your phone/anywhere:**
- Click individual links in the email

---

## Customization

### Adding New Career Sites

1. Run `update_settings.bat` (in Batch folder)
2. Choose option 3 (Career sites)
3. Choose "Add new site"
4. Enter organization name and URL

### Changing Keywords

1. Run `update_settings.bat`
2. Choose option 1 (Keywords)
3. Add or remove search terms

### Advanced: Edit Config Directly

If comfortable with JSON, open `config.json` in any text editor:

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

Save and close - changes take effect on next scan.

---

## Testing & Troubleshooting

### Run the Health Check

Double-click `health_check.bat` (in Batch folder) to verify:
- Which sites are working
- How many jobs each site has
- Which jobs match your keywords
- Which sites need manual checking

**Example output:**
```
OHSU
----
✓ 47 total jobs found | 3 match your keywords
  Example: "Epic Ambulatory Analyst"
  
PeaceHealth
-----------
⚠️  0 jobs found (site may have changed or uses JavaScript)
   Manual check: https://careers.peacehealth.org
```

### Common Issues

**"Python not found" error:**
- Python isn't installed or not in PATH
- Reinstall Python and CHECK "Add Python to PATH"

**No emails received:**
- Verify Gmail App Password is correct (16 characters)
- Check spam folder
- Run `scan_reset.bat` to force an email test

**Task not running automatically:**
- The installer may not be able to create the Task Scheduler task on some systems
- You can set it up manually in 5 minutes (see Manual Task Scheduler Setup below)

**Manual Task Scheduler Setup:**

If the installer couldn't create the scheduled task automatically, follow these steps:

1. Press `Win + R`, type `taskschd.msc`, press Enter
2. Click "Create Basic Task" in the right panel
3. **Name:** OpportunityAlert
4. **Description:** Daily automated job scanning
5. Click Next

6. **Trigger:** Select "Daily", click Next
7. **Start date:** Today
8. **Time:** Choose your preferred scan time (e.g., 8:00 AM)
9. **Recur every:** 1 day
10. Click Next

11. **Action:** Select "Start a program", click Next
12. **Program/script:** Click Browse and navigate to:
    - `C:\OpportunityAlert\Batch\run_scheduled.bat`
13. **Start in:** Leave blank
14. Click Next, then Finish

15. **Final step - Important settings:**
    - Right-click the "OpportunityAlert" task you just created
    - Click "Properties"
    - Go to "Conditions" tab
    - **UNCHECK** "Start the task only if the computer is on AC power"
    - Click OK

Done! The task will now run daily at your chosen time.

**Sites showing 0 results:**
- Some sites block automated scraping
- Check manually using the provided link
- Run health check weekly to track which sites work

**Batch files not working:**
- Make sure you're running them from the Batch folder
- Right-click → "Run as administrator" if needed

---

## Uninstallation

**Manual Method:**

1. Open Task Scheduler (Win + R, type `taskschd.msc`)
2. Find "OpportunityAlert" task
3. Right-click → Delete
4. Delete the installation folder (`C:\OpportunityAlert\`)
5. Uninstall Python (if not using for other purposes)

---

## Tips for Best Results

- ✅ Run `health_check.bat` weekly to verify sites are working
- ✅ Check failed sites manually - they often have great opportunities
- ✅ Run `scan_reset.bat` monthly to see all current openings again
- ✅ Adjust keywords if getting too many/too few results
- ✅ Keep your keywords specific to your field
- ✅ Use negative keywords to filter out irrelevant jobs

---

## Privacy & Security

- ✅ All data stays on your computer
- ✅ No data sent anywhere except job site requests and email notifications
- ✅ Gmail password stored locally in config.json
- ✅ No tracking, no analytics, no cloud services
- ⚠️ Keep your `config.json` secure (contains email password)

---

## Examples

### Example Keywords (Healthcare IT):
```
Epic Analyst, Clinical Informatics, EHR Analyst, Ambulatory, 
Compass Rose, Cogito, Principal Trainer
```

### Example Negative Keywords:
```
nurse, physician, medical assistant, pharmacist
```

### Example Career Sites:
- OHSU: https://careersat-ohsu.icims.com/jobs/intro
- Providence: https://providence.jobs/locations/oregon/jobs/
- Kaiser Permanente: https://www.kaiserpermanentejobs.org/location/oregon-jobs/641/6252001-5744337/3

---

## Command-Line Options

For advanced users, you can run the scanner directly:

```bash
cd "C:\OpportunityAlert\Scripts"
python opportunity_alert.py           # Normal scan
python opportunity_alert.py --all     # Show all jobs
python opportunity_alert.py --reset   # Clear history
python opportunity_alert.py --no-email # Skip email
```

---

## Support & Issues

If something isn't working:

1. Run `health_check.bat` to diagnose site issues
2. Check Task Scheduler history for errors
3. Verify Python and packages are installed
4. Check `config.json` for typos
5. Review email spam folder
6. Open an issue on GitHub with details

---

## Roadmap

See [ROADMAP.md](ROADMAP.md) for planned features including:
- Web-based dashboard interface
- Job application tracking
- Analytics and trends
- Cloud hosting option
- Mobile app

---

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

---

## License

This project is open source and available under the MIT License.

---

## Credits

Created to help job seekers automate the tedious parts of job searching and focus on what matters - landing great opportunities.

**Version:** 1.0  
**Last Updated:** January 2026

---

## Frequently Asked Questions

**Q: Will this work on Mac or Linux?**  
A: Currently Windows only. Mac/Linux support is planned for a future release.

**Q: Can I monitor sites that aren't listed in the examples?**  
A: Yes! You can add any career website. Just add the name and URL using `update_settings.bat`.

**Q: How many sites can I monitor?**  
A: No hard limit, but we recommend 10-30 for best performance and to avoid overwhelming yourself with results.

**Q: Will this apply to jobs for me?**  
A: No, this tool only finds and alerts you to new opportunities. You still need to apply manually.

**Q: Is my data private?**  
A: Yes! Everything runs locally on your computer. No data is sent to any servers except the job sites you're monitoring and Gmail for email notifications.

**Q: Can I use a different email provider?**  
A: Currently only Gmail is supported. Other providers may be added in future releases.

**Q: Why do some sites always fail?**  
A: Some career sites use aggressive bot protection or require JavaScript to load job listings. These sites need to be checked manually.

---

*Happy job hunting! 🎯*
