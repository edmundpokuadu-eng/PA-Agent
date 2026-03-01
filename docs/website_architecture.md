# Researcher Website Architecture
## Edmund Poku Adu — epokuadu.github.io

**Stack:** Quarto + GitHub Pages
**Domain:** epokuadu.github.io (or custom: edmundpokuadu.com)
**Auto-push:** GitHub Actions workflow on every session end

---

## Site Structure

```
epokuadu.github.io/
├── index.qmd          Home page
├── research.qmd       Active papers + working papers
├── pa-agent.qmd       PA-Agent tool page (the artifact)
├── data.qmd           Public datasets + replication archives
├── teaching.qmd       Courses (A-State)
├── cv.qmd             CV (PDF embed)
└── blog/              Research notes (optional)
    └── posts/
```

---

## Page Specifications

### index.qmd — Home
- One-sentence position statement: "I study public administration using quantitative
  methods and agentic AI research workflows."
- Photo (optional)
- 3 featured working papers (cards with journal target + status badge)
- PA-Agent feature box: "I built PA-Agent — an open-source agentic research pipeline
  for PA scholars. [Get it on GitHub →]"
- Contact: eadu@astate.edu | Arkansas State | Google Scholar | GitHub

### research.qmd — Papers
Sections:
1. **Under Review**
   - "The Researcher-Agent Problem" → PAR (2026)
   - Denton/DCTA Transit Resilience → PAR/JPART
   - GIQ submission (TikTok/IRS warning)
2. **Working Papers**
   - [Future pipeline papers]
3. **Publications**
   - [Published work]

Each paper card shows: title, journal target, abstract toggle, PDF link, replication link.

### pa-agent.qmd — The Tool
- What it is (one paragraph)
- The RAPH governance architecture (diagram)
- Quick-start install instructions
- The 6 agents with slash commands
- Link to GitHub repo
- Cite the PAR paper

### data.qmd — Datasets
- Texas cities fiscal panel 2000–2023
- Tax burden panel (820 rows)
- County census panel 2012–2022
- Denton transit DDD panel
- Ghana electoral + census files
- Each: description, variables, download link (or request link if not public)

---

## Auto-Push Agent (GitHub Actions)

`.github/workflows/publish.yml`:
```yaml
name: Publish Quarto Site
on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  build-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: quarto-dev/quarto-actions/setup@v2
      - name: Render and Publish
        uses: quarto-dev/quarto-actions/publish@v2
        with:
          target: gh-pages
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

Every `git push` to main automatically rebuilds and redeploys the site.

---

## Pioneer Positioning Elements

1. **PA-Agent badge** on every paper page: "Produced with PA-Agent"
2. **RAPH governance notice** on all AI-assisted papers: links to the PAR paper and
   the commitment gate documentation
3. **Research timeline** on home page showing paper → agent → website as coordinated
   pioneer move (Feb 2026)
4. **Google Scholar** profile linked; update as papers move through review

---

## Build Commands

```bash
# Install Quarto (if needed)
brew install quarto

# Initialize site
quarto create project website epokuadu-site
cd epokuadu-site

# Preview locally
quarto preview

# Publish to GitHub Pages
quarto publish gh-pages
```

---

## Sequence (Pioneer Deployment)

1. Create GitHub repo: `github.com/epokuadu/epokuadu.github.io`
2. Build Quarto site with skeleton pages
3. Push to GitHub → Actions auto-deploys
4. Add PA-Agent repo: `github.com/epokuadu/PA-Agent`
5. Link both from site
6. Submit PAR paper citing both URLs
7. Site and repo exist before paper appears in print — establishing timestamp priority
