#!/usr/bin/env python3
"""
OpportunityAlert - Site Health Check
Tests career sites to verify they're returning job listings
"""

import requests
import json
import re
from pathlib import Path
from urllib.parse import urljoin, urlparse

# Load configuration
CONFIG_FILE = Path(__file__).parent.parent / "config.json"

def load_config():
    """Load configuration from config.json"""
    with open(CONFIG_FILE, 'r') as f:
        return json.load(f)

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

def extract_all_jobs(html, base_url):
    """Extract ALL job listings from HTML (no keyword filtering)."""
    jobs = []
    if not html:
        return jobs
    
    # Find all links and their text
    link_pattern = r'<a[^>]*href=["\']([^"\']*)["\'][^>]*>([^<]*)</a>'
    matches = re.findall(link_pattern, html, re.IGNORECASE)
    
    for href, text in matches:
        text = text.strip()
        # Very lenient filter - just needs to look like it could be a job title
        if len(text) > 10 and len(text) < 200:
            # Skip obvious navigation items
            if any(skip in text.lower() for skip in ['home', 'about', 'contact', 'login', 'sign in', 'careers home']):
                continue
            
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
                'url': full_url
            })
    
    # Also check for job titles in common patterns
    title_patterns = [
        r'class="[^"]*title[^"]*"[^>]*>([^<]+)<',
        r'class="[^"]*job[^"]*"[^>]*>([^<]+)<',
        r'<h[23][^>]*>([^<]+)</h[23]>',
        r'"title"\s*:\s*"([^"]+)"',
    ]
    
    for pattern in title_patterns:
        matches = re.findall(pattern, html, re.IGNORECASE)
        for match in matches:
            text = match.strip()
            if len(text) > 10 and len(text) < 150:
                if any(skip in text.lower() for skip in ['home', 'about', 'contact', 'login']):
                    continue
                jobs.append({
                    'title': text,
                    'url': base_url
                })
    
    # Remove duplicates
    seen_titles = set()
    unique_jobs = []
    for job in jobs:
        if job['title'].lower() not in seen_titles:
            seen_titles.add(job['title'].lower())
            unique_jobs.append(job)
    
    return unique_jobs

def matches_keywords(text, keywords):
    """Check if text matches any keyword."""
    text_lower = text.lower()
    for keyword in keywords:
        if keyword.lower() in text_lower:
            return True
    return False

def test_site(name, url, keywords):
    """Test a single career site."""
    print(f"\n{name}")
    print("-" * len(name))
    
    html = fetch_page(url)
    if not html:
        print(f"❌ Failed to load")
        print(f"   Manual check: {url}")
        return {
            'name': name,
            'url': url,
            'total_jobs': 0,
            'matching_jobs': 0,
            'example': None,
            'failed': True
        }
    
    # Extract all jobs
    all_jobs = extract_all_jobs(html, url)
    
    # Filter for keyword matches
    matching_jobs = [j for j in all_jobs if matches_keywords(j['title'], keywords)]
    
    if len(all_jobs) == 0:
        print(f"⚠️  0 jobs found (site may have changed or uses JavaScript)")
        print(f"   Manual check: {url}")
        return {
            'name': name,
            'url': url,
            'total_jobs': 0,
            'matching_jobs': 0,
            'example': None,
            'failed': True
        }
    
    print(f"✓ {len(all_jobs)} total jobs found | {len(matching_jobs)} match your keywords")
    
    # Show one example
    if matching_jobs:
        example = matching_jobs[0]
        print(f"   Example: \"{example['title']}\"")
        print(f"   {example['url']}")
    elif all_jobs:
        # Show a non-matching example so they can verify site is working
        example = all_jobs[0]
        print(f"   (No keyword matches, but site is working)")
        print(f"   Example job: \"{example['title']}\"")
    
    return {
        'name': name,
        'url': url,
        'total_jobs': len(all_jobs),
        'matching_jobs': len(matching_jobs),
        'example': matching_jobs[0] if matching_jobs else all_jobs[0] if all_jobs else None,
        'failed': False
    }

def main():
    """Main entry point."""
    print("\n🔍 OpportunityAlert - Site Health Check")
    print("=" * 60)
    print("Testing all career sites...")
    print("=" * 60)
    
    config = load_config()
    
    results = []
    for site in config['career_sites']:
        result = test_site(site['name'], site['url'], config['keywords'])
        results.append(result)
    
    # Summary
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    
    working = [r for r in results if not r['failed'] and r['total_jobs'] > 0]
    failed = [r for r in results if r['failed'] or r['total_jobs'] == 0]
    
    print(f"\n✓ {len(working)} sites working")
    print(f"❌ {len(failed)} sites need attention")
    
    total_jobs = sum(r['total_jobs'] for r in results)
    total_matches = sum(r['matching_jobs'] for r in results)
    
    print(f"\n📊 {total_jobs} total jobs across all sites")
    print(f"🎯 {total_matches} jobs match your keywords")
    
    if failed:
        print(f"\n⚠️  Failed sites:")
        for r in failed:
            print(f"   • {r['name']}")
            print(f"     {r['url']}")
    
    print("\n" + "=" * 60)
    print("Health check complete!")
    print("=" * 60)

if __name__ == "__main__":
    main()
