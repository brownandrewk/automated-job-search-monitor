# OpportunityAlert - Product Roadmap

## Vision
Transform from a command-line job monitoring tool into a comprehensive job search management platform accessible from anywhere.

---

## Phase 1: Foundation (CURRENT - In Progress)
**Goal:** Ship a working, installable desktop tool with clean architecture

### Core Features
- ✅ Automated daily job scanning
- ✅ Email notifications for new opportunities
- ✅ Keyword and site management
- ✅ Organized folder structure (Scripts/, Batch/, Scanned_Results/)
- ⏳ Flag sites with zero results (connection failures vs. no matches)
- ⏳ Clean installation process
- ⏳ Interactive settings manager (Python-based, no PowerShell issues)

### Deliverables
- Windows installer (SETUP.bat → INSTALL.ps1)
- Batch file shortcuts for common tasks
- JSON-based configuration
- GitHub repository with documentation
- README with installation instructions

### Status: ~90% Complete
**Remaining:**
- Finalize clean file set
- Add zero-results flagging
- Test end-to-end installation
- Push to GitHub

---

## Phase 2: Web Interface (Next Major Release)
**Goal:** Create a local web dashboard for easier management and better visibility

### Features to Add

**Dashboard (Home Page):**
- Summary stats: jobs found today, this week, total tracked
- Recent scan results in a sortable table
- Quick actions: "Scan Now", "View Settings", "Health Check"
- Visual status indicators (sites working, sites failing, sites with 0 results)

**Job Management:**
- Searchable/filterable table of all discovered jobs
- Columns: Title, Company, Date Found, Status, URL
- Click to open job posting
- Mark jobs as: "Applied", "Not Interested", "Saved for Later"
- Notes field for each job

**Settings Interface:**
- Form-based keyword management (add/remove with buttons)
- Form-based site management (add/remove with buttons)
- Email configuration
- Schedule configuration
- Visual validation (shows if sites are reachable)

**Analytics/Trends:**
- Chart: Jobs found per day/week
- Chart: Jobs by company
- Chart: Most common keywords appearing in results
- Application tracking: applied vs. response rate

### Technical Approach
- **Backend:** Python Flask (lightweight, easy to add to existing codebase)
- **Frontend:** Simple HTML/CSS/JavaScript (Bootstrap for UI)
- **Storage:** Keep JSON for now, design for SQLite migration
- **Access:** Runs locally on http://localhost:5000
- **Auto-launch:** Opens browser when scanner starts
- **Background task:** Flask app keeps running, triggers scans on schedule

### New Files Needed
```
OpportunityAlert/
├── webapp/
│   ├── app.py (Flask server)
│   ├── templates/ (HTML pages)
│   ├── static/ (CSS, JS)
│   └── api/ (endpoints for actions)
```

### Installation Changes
- Installer adds Flask to dependencies (`pip install flask`)
- Creates desktop shortcut to launch web interface
- Batch file becomes: "Launch OpportunityAlert Dashboard"

---

## Phase 3: Cloud Hosting (Future)
**Goal:** Access your job search from anywhere - phone, work computer, home

### Features to Add

**Cloud Deployment:**
- Deploy to free tier hosting (Heroku, Railway, PythonAnywhere)
- User authentication (login system)
- Multi-user support (each user has own config)
- Secure credential storage (encrypted passwords)

**Mobile Access:**
- Responsive design works on phone
- Native mobile notifications option
- Quick "apply" actions from phone

**Advanced Features:**
- Resume upload and parsing
- Auto-fill applications (when possible)
- Integration with LinkedIn, Indeed APIs
- AI-powered job matching scores
- Cover letter generator based on job description
- Application deadline tracking with reminders

### Technical Approach
- **Hosting:** Railway or PythonAnywhere (free tier options)
- **Database:** PostgreSQL (for cloud) or SQLite (for smaller deployments)
- **Auth:** Flask-Login or similar
- **APIs:** OpenAI for AI features, LinkedIn/Indeed APIs
- **Security:** HTTPS, encrypted credentials, session management

---

## Phase 4: SaaS Product (Moonshot)
**Goal:** Turn into a commercial product others can subscribe to

### Product Features
- Freemium model (5 sites free, unlimited for $5/month)
- Pre-configured popular job boards (Indeed, LinkedIn, Glassdoor integration)
- Team/family plans (share job findings)
- Industry-specific templates (Healthcare IT, Software Engineering, etc.)
- Browser extension (one-click save jobs from any site)
- Integration with ATS tracking
- Job application status pipeline (Applied → Interviewing → Offer)

### Business Model
- **Free Tier:** 5 sites, daily scans, email notifications
- **Pro Tier ($5/mo):** Unlimited sites, hourly scans, SMS notifications, analytics
- **Team Tier ($15/mo):** Multiple users, shared job pool, collaboration features
- **Enterprise:** Custom integrations, API access, white-label

### Marketing
- GitHub as primary acquisition (open-source community)
- Blog posts on job search automation
- YouTube tutorials
- Reddit/HackerNews launches
- LinkedIn outreach to recruiters/job seekers

---

## Key Decisions & Open Questions

### Zero Results Flagging (Phase 1)
**Decision needed:** How to categorize sites?
- Option A: Two flags (connection error vs. zero results)
- Option B: Three categories (working, broken scraping, connection failed)
- Option C: Health score (0-100 based on historical success rate)

**Recommendation:** Start with Option A, easy to understand

### Data Storage Migration (Phase 2)
**Decision needed:** When to move from JSON to database?
- Option A: Phase 2 with web interface (better querying)
- Option B: Keep JSON, add SQLite as optional power-user feature
- Option C: Wait until Phase 3 (cloud hosting requires it)

**Recommendation:** Option B - offer both, let users choose

### Hosting Strategy (Phase 3)
**Decision needed:** Self-hosted vs. managed cloud?
- Option A: Provide Docker image (users host themselves)
- Option B: Managed hosting (we host, they pay subscription)
- Option C: Hybrid (free self-host, paid managed option)

**Recommendation:** Option C - serves both technical and non-technical users

---

## Success Metrics

### Phase 1 (Desktop Tool)
- ✅ 10+ GitHub stars
- ✅ 5+ user installations (beyond you and your friend)
- ✅ Zero critical bugs reported in first month

### Phase 2 (Web Interface)
- 50+ GitHub stars
- 25+ active users
- Average session time >5 minutes (users finding value)
- 5+ feature requests from community

### Phase 3 (Cloud Hosted)
- 100+ registered users
- 25+ paying users ($125/month revenue)
- 90%+ uptime
- <1 second average page load

### Phase 4 (SaaS)
- 1,000+ registered users
- 100+ paying subscribers ($500+/month revenue)
- Featured on ProductHunt
- Profitable (revenue > hosting costs)

---

## Timeline Estimates

| Phase | Estimated Time | Complexity |
|-------|---------------|------------|
| Phase 1 | 1-2 weeks | Low - mostly cleanup and packaging |
| Phase 2 | 3-4 weeks | Medium - new skills (Flask, front-end) |
| Phase 3 | 4-6 weeks | High - deployment, security, scaling |
| Phase 4 | 3-6 months | Very High - product, marketing, support |

**Note:** These are part-time effort estimates. Full-time could be 3-5x faster.

---

## Technical Debt to Address

### Before Phase 2
- [ ] Standardize error handling across all scripts
- [ ] Add logging (track what's happening without print statements)
- [ ] Write unit tests for core functions
- [ ] Refactor duplicate code (DRY principle)
- [ ] Add proper docstrings to all functions

### Before Phase 3
- [ ] Security audit (credential storage, API endpoints)
- [ ] Performance testing (can it handle 1000 sites?)
- [ ] Database migration scripts (JSON → SQLite)
- [ ] Backup and restore functionality
- [ ] Rate limiting (don't hammer job sites)

---

## Competitive Landscape

### Existing Solutions
- **Job search aggregators:** Indeed, LinkedIn (don't monitor custom sites)
- **Job alert services:** Google for Jobs (limited customization)
- **Web scraping tools:** ParseHub, Octoparse (generic, not job-focused)
- **IFTTT/Zapier:** Can monitor sites but complex to set up

### OpportunityAlert Advantages
- **Focused on job search** (not generic scraping)
- **Local-first** (privacy, no subscription for basic features)
- **Customizable** (works with any career site, not just major boards)
- **Open source** (community-driven improvements)
- **Epic/Healthcare IT niche** (specialized for this market initially)

---

## Community & Open Source Strategy

### Phase 1
- MIT License (permissive, encourages adoption)
- Clean README with screenshots
- CONTRIBUTING.md for future contributors
- Issue templates for bug reports and feature requests

### Phase 2
- Video tutorial (YouTube walkthrough)
- Blog post: "I automated my job search and here's what happened"
- Post to r/cscareerquestions, r/Python, r/jobs
- Product Hunt launch (soft launch, gather feedback)

### Phase 3
- Documentation site (GitBook or similar)
- API documentation for power users
- Plugin architecture (let others extend functionality)
- Community showcase (users share their success stories)

---

## Resources & Learning

### To Build Phase 2 (Web Interface)
- Flask Mega-Tutorial by Miguel Grinberg
- Bootstrap 5 documentation
- Chart.js for analytics visualizations
- SQLite tutorial (for future database migration)

### To Build Phase 3 (Cloud Hosting)
- Railway or PythonAnywhere deployment guides
- Flask-Login documentation (user authentication)
- PostgreSQL for Python developers
- Web security best practices (OWASP Top 10)

### To Build Phase 4 (SaaS)
- Stripe integration for payments
- Email marketing (Mailchimp, ConvertKit)
- SaaS metrics (MRR, churn, LTV)
- Customer support tools (Intercom, Zendesk)

---

## Revenue Potential (Phase 4 Projection)

**Conservative Estimate:**
- 1,000 free users (5% conversion to paid)
- 50 paid users @ $5/month = $250/month
- Annual: $3,000

**Moderate Estimate:**
- 5,000 free users (10% conversion)
- 500 paid users @ $5/month = $2,500/month
- Annual: $30,000

**Optimistic Estimate:**
- 20,000 free users (15% conversion)
- 3,000 paid users @ $5/month = $15,000/month
- Annual: $180,000

**Costs to Consider:**
- Hosting: $20-100/month (scales with users)
- Email service: $0-50/month
- Domain: $12/year
- Marketing: Variable
- Your time: Priceless 😉

---

## Next Steps (Immediate)

### This Week
1. ✅ Create this roadmap
2. ⏳ Finish Phase 1 clean file set
3. ⏳ Add zero-results flagging
4. ⏳ Test complete installation flow
5. ⏳ Push v1.0 to GitHub

### Next Week
1. Polish documentation
2. Create demo video
3. Soft launch to friends/family
4. Gather feedback
5. Start planning Phase 2 architecture

---

**Last Updated:** January 2026  
**Maintained By:** Andrew Brown  
**Status:** Phase 1 in progress (90% complete)

---

*This is a living document. Update as we learn and priorities shift.*
