#!/usr/bin/env python3
"""
OpportunityAlert - Settings Manager
Interactive tool to update your job search settings
"""

import json
import os
from pathlib import Path
from datetime import datetime

CONFIG_FILE = Path(__file__).parent.parent / "config.json"

def clear_screen():
    """Clear the console screen"""
    os.system('cls' if os.name == 'nt' else 'clear')

def load_config():
    """Load configuration from file"""
    with open(CONFIG_FILE, 'r') as f:
        config = json.load(f)
    
    # Convert keywords from string to list if needed
    if isinstance(config.get('keywords'), str):
        config['keywords'] = [k.strip() for k in config['keywords'].split(',') if k.strip()]
    
    # Convert negative_keywords from string to list if needed
    if isinstance(config.get('negative_keywords'), str):
        config['negative_keywords'] = [k.strip() for k in config['negative_keywords'].split(',') if k.strip()]
    
    return config

def save_config(config):
    """Save configuration to file"""
    with open(CONFIG_FILE, 'w') as f:
        json.dump(config, f, indent=2)

def pause():
    """Wait for user to press Enter"""
    input("\nPress Enter to continue...")

def show_header():
    """Display the header"""
    clear_screen()
    print("=" * 60)
    print("   OPPORTUNITYALERT - SETTINGS MANAGER")
    print("=" * 60)
    print()

def manage_keywords(config):
    """Manage job search keywords"""
    while True:
        show_header()
        print("JOB SEARCH KEYWORDS")
        print("-" * 60)
        print()
        print("Current keywords:")
        for i, keyword in enumerate(config['keywords'], 1):
            print(f"  {i}. {keyword}")
        print()
        print("Options:")
        print("  A - Add new keyword")
        print("  R - Remove keyword")
        print("  B - Back to main menu")
        print()
        
        choice = input("Choice: ").strip().upper()
        
        if choice == 'A':
            print()
            new_keyword = input("Enter new keyword: ").strip()
            if new_keyword and new_keyword not in config['keywords']:
                config['keywords'].append(new_keyword)
                print(f"✓ Added: {new_keyword}")
                pause()
            elif new_keyword in config['keywords']:
                print("⚠ Keyword already exists")
                pause()
        
        elif choice == 'R':
            print()
            try:
                num = int(input(f"Enter keyword number to remove (1-{len(config['keywords'])}): "))
                if 1 <= num <= len(config['keywords']):
                    removed = config['keywords'].pop(num - 1)
                    print(f"✓ Removed: {removed}")
                    pause()
                else:
                    print("Invalid number")
                    pause()
            except ValueError:
                print("Please enter a valid number")
                pause()
        
        elif choice == 'B':
            break

def manage_negative_keywords(config):
    """Manage negative keywords"""
    while True:
        show_header()
        print("NEGATIVE KEYWORDS (Jobs to Exclude)")
        print("-" * 60)
        print()
        
        if config.get('negative_keywords'):
            print("Current negative keywords:")
            for i, keyword in enumerate(config['negative_keywords'], 1):
                print(f"  {i}. {keyword}")
        else:
            print("No negative keywords set")
        
        print()
        print("Options:")
        print("  A - Add negative keyword")
        print("  R - Remove negative keyword")
        print("  B - Back to main menu")
        print()
        
        choice = input("Choice: ").strip().upper()
        
        if choice == 'A':
            print()
            new_keyword = input("Enter keyword to exclude: ").strip()
            if new_keyword:
                if 'negative_keywords' not in config:
                    config['negative_keywords'] = []
                if new_keyword not in config['negative_keywords']:
                    config['negative_keywords'].append(new_keyword)
                    print(f"✓ Added: {new_keyword}")
                    pause()
                else:
                    print("⚠ Keyword already exists")
                    pause()
        
        elif choice == 'R':
            if config.get('negative_keywords'):
                print()
                try:
                    num = int(input(f"Enter keyword number to remove (1-{len(config['negative_keywords'])}): "))
                    if 1 <= num <= len(config['negative_keywords']):
                        removed = config['negative_keywords'].pop(num - 1)
                        print(f"✓ Removed: {removed}")
                        pause()
                    else:
                        print("Invalid number")
                        pause()
                except ValueError:
                    print("Please enter a valid number")
                    pause()
            else:
                print()
                print("No negative keywords to remove")
                pause()
        
        elif choice == 'B':
            break

def manage_career_sites(config):
    """Manage career sites"""
    while True:
        show_header()
        print("CAREER SITES TO MONITOR")
        print("-" * 60)
        print()
        print(f"Current sites ({len(config['career_sites'])}):")
        print()
        
        for i, site in enumerate(config['career_sites'], 1):
            print(f"  {i}. {site['name']}")
            print(f"     {site['url']}")
            print()
        
        print("Options:")
        print("  A - Add new site")
        print("  R - Remove site")
        print("  B - Back to main menu")
        print()
        
        choice = input("Choice: ").strip().upper()
        
        if choice == 'A':
            print()
            site_name = input("Site name (e.g., 'OHSU'): ").strip()
            if not site_name:
                continue
            
            site_url = input("Site URL: ").strip()
            if not site_url:
                continue
            
            # Check for duplicates
            if any(s['name'] == site_name for s in config['career_sites']):
                print(f"⚠ Site '{site_name}' already exists")
                pause()
                continue
            
            config['career_sites'].append({
                'name': site_name,
                'url': site_url
            })
            print(f"✓ Added: {site_name}")
            pause()
        
        elif choice == 'R':
            print()
            try:
                num = int(input(f"Enter site number to remove (1-{len(config['career_sites'])}): "))
                if 1 <= num <= len(config['career_sites']):
                    removed = config['career_sites'].pop(num - 1)
                    print(f"✓ Removed: {removed['name']}")
                    pause()
                else:
                    print("Invalid number")
                    pause()
            except ValueError:
                print("Please enter a valid number")
                pause()
        
        elif choice == 'B':
            break

def view_config(config):
    """View full configuration"""
    show_header()
    print("FULL CONFIGURATION")
    print("-" * 60)
    print()
    
    print(f"Email: {config['email']}")
    print(f"Schedule: Daily at {config['schedule_time']}")
    print(f"Installation: {config['install_path']}")
    print()
    
    print(f"Keywords ({len(config['keywords'])}):")
    for keyword in config['keywords']:
        print(f"  • {keyword}")
    print()
    
    if config.get('negative_keywords'):
        print(f"Negative Keywords ({len(config['negative_keywords'])}):")
        for keyword in config['negative_keywords']:
            print(f"  • {keyword}")
        print()
    
    print(f"Career Sites ({len(config['career_sites'])}):")
    for site in config['career_sites']:
        print(f"  • {site['name']}")
        print(f"    {site['url']}")
    
    print()
    pause()

def backup_config():
    """Create a backup of the configuration"""
    show_header()
    print("BACKUP CONFIGURATION")
    print("-" * 60)
    print()
    
    backup_name = f"config_backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    backup_path = CONFIG_FILE.parent / backup_name
    
    try:
        with open(CONFIG_FILE, 'r') as f:
            config_data = f.read()
        
        with open(backup_path, 'w') as f:
            f.write(config_data)
        
        print(f"✓ Backup created: {backup_name}")
    except Exception as e:
        print(f"✗ Backup failed: {e}")
    
    pause()

def main():
    """Main menu loop"""
    if not CONFIG_FILE.exists():
        print("Error: config.json not found!")
        print(f"Make sure you're running this from: {CONFIG_FILE.parent.parent}")
        pause()
        return
    
    config = load_config()
    config_modified = False
    
    while True:
        show_header()
        
        print(f"Email: {config['email']}")
        print(f"Keywords: {len(config['keywords'])} configured")
        print(f"Negative Keywords: {len(config.get('negative_keywords', []))} configured")
        print(f"Career Sites: {len(config['career_sites'])} configured")
        print(f"Schedule: Daily at {config['schedule_time']}")
        print()
        print("-" * 60)
        print()
        print("What would you like to update?")
        print()
        print("  1. Job search keywords")
        print("  2. Negative keywords (exclude)")
        print("  3. Career sites")
        print("  4. View full configuration")
        print("  5. Backup configuration")
        print("  6. Save and Exit")
        print("  7. Exit without saving")
        print()
        
        choice = input("Enter your choice (1-7): ").strip()
        
        if choice == '1':
            manage_keywords(config)
            config_modified = True
        
        elif choice == '2':
            manage_negative_keywords(config)
            config_modified = True
        
        elif choice == '3':
            manage_career_sites(config)
            config_modified = True
        
        elif choice == '4':
            view_config(config)
        
        elif choice == '5':
            backup_config()
        
        elif choice == '6':
            if config_modified:
                save_config(config)
                print()
                print("✓ Configuration saved!")
                print()
                print("Changes will take effect on the next scheduled scan.")
                print("Or run scan_jobs.bat manually to test.")
            else:
                print()
                print("No changes to save.")
            print()
            pause()
            break
        
        elif choice == '7':
            if config_modified:
                print()
                confirm = input("Exit without saving changes? (yes/no): ").strip().lower()
                if confirm == 'yes':
                    break
            else:
                break

if __name__ == "__main__":
    main()
