#!/usr/bin/env python3
"""
OpportunityAlert - Automated Job Scanner
Scans career sites for job postings matching your criteria
"""

import requests
import json
import re
import sys
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime
from pathlib import Path
from urllib.parse import urljoin, urlparse

# Load configuration
CONFIG_FILE = Path(__file__).parent.parent / "config.json"
HISTORY_FILE = Path(__file__).parent.parent / "Scanned_Results" / ".job_history.json"
OUTPUT_FILE = Path(__file__).parent.parent / "Scanned_Results" / "job_results.txt"
FAILED_SITES_BAT = Path(__file__).parent.parent / "Batch" / "open_failed_sites.bat"

def load_config():
    """Load configuration from config.json"""
    with open(CONFIG_FILE, 'r') as f:
        return json.load(f)

def load_history():
    """Load previously seen job IDs from file."""
    if HISTORY_FILE.exists():
        try:
            with open(HISTORY_FILE, 'r') as f:
                return json.load(f)
        except:
            return {"seen_jobs": [], "last_scan": None}
    return {"seen_jobs": [], "last_scan": None}

def save_history(history):
    """Save seen job IDs to file."""
    history["last_scan"] = datetime.now().isoformat()
    HISTORY_FILE.parent.mkdir(exist_ok=True)
    with open(HISTORY_FILE, 'w') as f:
        json.dump(history, f, indent=2)

def job_id(site_name, title, url=""):
    """Create a unique identifier for a job."""
    return f"{site_name}|{title}|{url}"[:200]

def matches_keywords(text, keywords, negative_keywords):
    """Check if text contains target keywords and no negative keywords."""
    text_lower = text.lower()
    
    # Check negative keywords first
    for neg in negative_keywords:
        if neg.lower() in text_lower:
            return False
    
    # Check positive keywords
    for keyword in keywords:
        if keyword.lower() in text_lower:
            return True
    return False

def fetch_page(url, timeout=15):
    """Fetch a webpage and return its content."""
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept-Encoding': 'gzip, deflate, br',
        'DNT': '1',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
        'Sec-Fetch-Dest': 'document',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-Site': 'none',
        'Sec-Fetch-User': '?1',
        'Cache-Control': 'max-age=0',
    }
    try:
        response = requests.get(url, headers=headers, timeout=timeout)
        response.raise_for_status()
        return response.text
    except requests.exceptions.RequestException:
        return None

def extract_jobs(html, base_url, site_name, keywords, negative_keywords):
    """Extract job listings from HTML."""
    jobs = []
    if not html:
        return jobs
    
    # Find all links and their text
    link_pattern = r'<a[^>]*href=["\']([^"\']*)["\'][^>]*>([^<]*)</a>'
    matches = re.findall(link_pattern, html, re.IGNORECASE)
    
    for href, text in matches:
        text = text.strip()
        if len(text) > 10 and matches_keywords(text, keywords, negative_keywords):
            # Make URL absolute
            if href.startswith('/'):
                parsed = urlparse(base_url)
                full_url = f"{parsed.scheme}://{parsed.netloc}{href}"
            elif not href.startswith('http'):
                full_url = urljoin(base_url, href)
            else:
                full_url = href
            
            jobs.append({
                'title': text[:100],
                'url': full_url,
                'site': site_name
            })
    
    # Also check for job titles in common patterns
    title_patterns = [
        r'class="[^"]*title[^"]*"[^>]*>([^<]+)<',
        r'<h[23][^>]*>([^<]+)</h[23]>',
        r'"title"\s*:\s*"([^"]+)"',
    ]
    
    for pattern in title_patterns:
        matches = re.findall(pattern, html, re.IGNORECASE)
        for match in matches:
            text = match.strip()
            if len(text) > 10 and len(text) < 150 and matches_keywords(text, keywords, negative_keywords):
                jobs.append({
                    'title': text,
                    'url': base_url,
                    'site': site_name
                })
    
    # Remove duplicates
    seen_titles = set()
    unique_jobs = []
    for job in jobs:
        if job['title'].lower() not in seen_titles:
            seen_titles.add(job['title'].lower())
            unique_jobs.append(job)
    
    return unique_jobs

def check_site(name, url, keywords, negative_keywords):
    """Check a single career site for matching jobs."""
    print(f"  Scanning {name}...", end=" ", flush=True)
    
    html = fetch_page(url)
    if not html:
        print("❌")
        return [], url
    
    jobs = extract_jobs(html, url, name, keywords, negative_keywords)
    print(f"✓ ({len(jobs)} matches)")
    return jobs, None

def send_email(config, subject, body):
    """Send email notification."""
    try:
        msg = MIMEMultipart()
        msg['From'] = config['email']
        msg['To'] = config['email']
        msg['Subject'] = subject
        
        msg.attach(MIMEText(body, 'plain'))
        
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(config['email'], config['email_password'])
        server.send_message(msg)
        server.quit()
        
        print("✉️  Email notification sent!")
        
    except Exception as e:
        print(f"⚠ Failed to send email: {e}")

def format_email_body(new_jobs, failed_sites):
    """Format email body with job listings."""
    lines = []
    lines.append(f"OpportunityAlert found {len(new_jobs)} new job(s)!")
    lines.append(f"Scanned: {datetime.now().strftime('%Y-%m-%d at %I:%M %p')}")
    lines.append("=" * 60)
    lines.append("")
    
    # Group by site
    by_site = {}
    for job in new_jobs:
        site = job['site']
        if site not in by_site:
            by_site[site] = []
        by_site[site].append(job)
    
    for site in sorted(by_site.keys()):
        lines.append(f"{site}")
        lines.append("-" * len(site))
        for job in by_site[site]:
            lines.append(f"• {job['title']}")
            lines.append(f"  {job['url']}")
        lines.append("")
    
    # Add failed sites
    if failed_sites:
        lines.append("=" * 60)
        lines.append(f"⚠️  SITES TO CHECK MANUALLY ({len(failed_sites)}):")
        lines.append("")
        for name, url in failed_sites:
            lines.append(f"• {name}")
            lines.append(f"  {url}")
        lines.append("")
    
    lines.append("=" * 60)
    lines.append("Good luck with your applications!")
    
    return "\n".join(lines)

def format_results(new_jobs, all_jobs, failed_sites, show_all=False):
    """Format results for display and file output."""
    lines = []
    lines.append("=" * 70)
    lines.append(f"OPPORTUNITYALERT SCAN RESULTS - {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    lines.append("=" * 70)
    
    if show_all:
        lines.append(f"\nShowing ALL {len(all_jobs)} matching jobs:\n")
        jobs_to_show = all_jobs
    else:
        lines.append(f"\n🆕 {len(new_jobs)} NEW jobs found (out of {len(all_jobs)} total matches):\n")
        jobs_to_show = new_jobs
    
    if not jobs_to_show:
        lines.append("No matching jobs found.\n")
    else:
        by_site = {}
        for job in jobs_to_show:
            site = job['site']
            if site not in by_site:
                by_site[site] = []
            by_site[site].append(job)
        
        for site in sorted(by_site.keys()):
            lines.append(f"\n--- {site} ---")
            for job in by_site[site]:
                lines.append(f"  • {job['title']}")
                lines.append(f"    {job['url']}")
    
    # Add failed sites section
    if failed_sites:
        lines.append("\n" + "=" * 70)
        lines.append(f"\n⚠️  FAILED SITES - Manual Check Needed ({len(failed_sites)}):\n")
        for name, url in failed_sites:
            lines.append(f"  • {name}")
            lines.append(f"    {url}")
    
    lines.append("\n" + "=" * 70)
    return "\n".join(lines)

def create_failed_sites_bat(failed_sites):
    """Create batch file to open failed sites."""
    if not failed_sites:
        content = "@echo off\necho No failed sites from last scan.\npause"
    else:
        lines = ["@echo off", "echo Opening failed sites in your browser..."]
        for name, url in failed_sites:
            lines.append(f'start "" "{url}"')
        lines.append("echo Done!")
        lines.append("pause")
        content = "\n".join(lines)
    
    with open(FAILED_SITES_BAT, 'w') as f:
        f.write(content)

def main():
    """Main entry point."""
    show_all = "--all" in sys.argv
    reset = "--reset" in sys.argv
    no_email = "--no-email" in sys.argv
    
    print("\n🔍 OpportunityAlert - Job Scanner")
    print("-" * 40)
    
    # Load config
    config = load_config()
    
    # Load or reset history
    if reset:
        history = {"seen_jobs": [], "last_scan": None}
        print("History cleared.\n")
    else:
        history = load_history()
        if history.get("last_scan"):
            print(f"Last scan: {history['last_scan']}\n")
    
    # Check all sites
    all_jobs = []
    failed_sites = []
    print("Scanning career sites:\n")
    
    for site in config['career_sites']:
        jobs, failed_url = check_site(
            site['name'], 
            site['url'], 
            config['keywords'], 
            config.get('negative_keywords', [])
        )
        all_jobs.extend(jobs)
        if failed_url:
            failed_sites.append((site['name'], failed_url))
    
    # Find new jobs
    seen_set = set(history["seen_jobs"])
    new_jobs = []
    
    for job in all_jobs:
        jid = job_id(job['site'], job['title'], job['url'])
        if jid not in seen_set:
            new_jobs.append(job)
            history["seen_jobs"].append(jid)
    
    # Keep history manageable
    history["seen_jobs"] = history["seen_jobs"][-1000:]
    
    # Save history
    save_history(history)
    
    # Format and display results
    results = format_results(new_jobs, all_jobs, failed_sites, show_all)
    print("\n" + results)
    
    # Save to file
    OUTPUT_FILE.parent.mkdir(exist_ok=True)
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write(results)
    print(f"\n📄 Results saved to: {OUTPUT_FILE}")
    
    # Create failed sites batch file
    create_failed_sites_bat(failed_sites)
    
    # Send email if there are new jobs or failed sites
    if (new_jobs or failed_sites) and not show_all and not no_email:
        subject = f"🎯 {len(new_jobs)} New Job(s) Found!"
        if failed_sites:
            subject += f" + {len(failed_sites)} Site(s) Need Manual Check"
        body = format_email_body(new_jobs, failed_sites)
        send_email(config, subject, body)
    
    # Summary
    if new_jobs and not show_all:
        print(f"\n✨ {len(new_jobs)} new job(s) found! Check them out above.")
    elif not new_jobs and not show_all:
        print("\n😴 No new jobs since last scan.")
    
    if failed_sites:
        print(f"\n⚠️  {len(failed_sites)} site(s) failed - run open_failed_sites.bat to check them")

if __name__ == "__main__":
    main()
