# Macawi mdLib - Documentation Repository

**Professional mdBook documentation for all Macawi AI projects.**

[![License](https://img.shields.io/badge/license-AGPL%203.0-orange)](LICENSE)
[![mdBook](https://img.shields.io/badge/built%20with-mdBook-blue)](https://rust-lang.github.io/mdBook/)

---

## Overview

This repository hosts comprehensive mdBook documentation for Macawi AI projects, making our technical documentation accessible anywhere—from sales calls to hotel work to customer presentations.

**Why GitHub-hosted mdBooks?**
- ✅ **Portable**: Access from anywhere with just a URL
- ✅ **Professional**: Clean, searchable, customer-ready
- ✅ **Version-controlled**: Track documentation evolution
- ✅ **GitHub Pages**: Free hosting with custom domain support

---

## Documentation Sites

### 🧛 [Strigoi](./strigoi/)
**AI/LLM Security Assessment Platform**
- Production-ready: v1.0.0
- Pages: 85
- Topics: Installation, user guide, operations, testing, security deep-dives
- Status: ✅ Initial structure complete, iterative content population

**View Live**: [docs.macawi.ai/strigoi](https://docs.macawi.ai/strigoi)

---

## Repository Structure

```
mdLib/
├── strigoi/                    # Strigoi documentation
│   ├── book.toml              # mdBook configuration
│   ├── src/                   # Markdown source files
│   │   ├── SUMMARY.md         # Navigation structure
│   │   ├── introduction.md    # Landing page
│   │   ├── getting-started/   # Installation & quick start
│   │   ├── user-guide/        # User documentation
│   │   ├── operations/        # Deployment & maintenance
│   │   ├── testing/           # Test scenarios & demos
│   │   ├── security/          # Security deep-dives
│   │   ├── architecture/      # System architecture
│   │   ├── integration/       # Integration guides
│   │   └── reference/         # API reference & troubleshooting
│   └── book/                  # Build output (generated)
│
├── [future projects]/          # Additional mdBooks as added
│   ├── project-management-platform/
│   ├── sdpmp/
│   ├── hresonator/
│   └── ...
│
└── README.md                  # This file
```

---

## Building Documentation

### Prerequisites

Install mdBook:
```bash
cargo install mdbook
```

### Build a Specific Project

```bash
# Build Strigoi documentation
cd strigoi
mdbook build

# View locally
mdbook serve --open
```

### Build All Projects

```bash
# From repository root
for dir in */; do
  if [ -f "$dir/book.toml" ]; then
    echo "Building $dir..."
    cd "$dir"
    mdbook build
    cd ..
  fi
done
```

---

## Adding New Documentation

### 1. Create New mdBook

```bash
# From mdLib/ directory
mdbook init my-project

# Configure book.toml
cd my-project
# Edit book.toml with project details
```

### 2. Structure Your Content

Follow the Strigoi example:
- **Introduction**: Landing page with overview
- **Getting Started**: Installation, quick start, first steps
- **User Guide**: How to use the product
- **Operations**: Deployment, configuration, maintenance
- **Reference**: API specs, troubleshooting, FAQ

### 3. Build and Test

```bash
mdbook build
mdbook serve --open  # View at http://localhost:3000
```

### 4. Commit to Repository

```bash
git add my-project/
git commit -m "docs: Add my-project mdBook"
git push origin main
```

---

## GitHub Pages Deployment

Each mdBook can be deployed to GitHub Pages:

### Option 1: GitHub Actions (Recommended)

Create `.github/workflows/deploy-docs.yml`:
```yaml
name: Deploy mdBooks to GitHub Pages

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install mdBook
        run: |
          cargo install mdbook
      - name: Build all books
        run: |
          for dir in */; do
            if [ -f "$dir/book.toml" ]; then
              cd "$dir"
              mdbook build
              cd ..
            fi
          done
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./
```

### Option 2: Manual Deployment

```bash
# Build all books
for dir in */; do
  if [ -f "$dir/book.toml" ]; then
    cd "$dir"
    mdbook build
    cd ..
  fi
done

# Deploy to gh-pages branch
git worktree add gh-pages
cd gh-pages
# Copy build outputs
git add .
git commit -m "Deploy documentation"
git push origin gh-pages
```

---

## Documentation Standards

### Writing Guidelines

1. **Customer-Facing Language**
   - Professional tone
   - Clear value propositions
   - Avoid excessive jargon
   - Banking/enterprise focus

2. **Structure**
   - Start with overview/introduction
   - Provide quick start guides
   - Include real-world examples
   - End with reference material

3. **Code Examples**
   - Use fenced code blocks with language hints
   - Include full context (not snippets out of context)
   - Add comments for clarity
   - Show expected output

4. **Navigation**
   - Keep SUMMARY.md clean and hierarchical
   - Use descriptive link text
   - Provide "Next Steps" at page ends
   - Cross-link related content

### Visual Elements

- Use tables for comparisons
- Include architecture diagrams (ASCII art or images)
- Add badges for versions, status, platforms
- Use blockquotes for important notes

---

## Migrating Existing mdBooks

To migrate mdBooks from resonance (192.168.1.253:8080):

```bash
# On local machine
scp -r synth@192.168.1.253:/home/synth/library/books/project-name ./

# Clean up any build artifacts
cd project-name
rm -rf book/

# Rebuild locally
mdbook build

# Commit to mdLib
git add project-name/
git commit -m "docs: Migrate project-name from resonance"
git push
```

---

## Use Cases

### Sales Calls
Open docs URL on customer screen—professional, searchable, always up-to-date.

### Hotel Work
No VPN needed, edit and view from anywhere.

### Presentations
Share docs URL, customers can explore at their own pace.

### Customer Self-Service
Reduce support burden, empower customers with comprehensive docs.

---

## Contributing

### Content Updates

1. Edit markdown files in `src/` directories
2. Test locally with `mdbook serve`
3. Commit changes
4. Push to GitHub (triggers auto-deploy if configured)

### New Sections

1. Add entries to `SUMMARY.md`
2. Create corresponding markdown files
3. Use stub generation script if needed
4. Fill in content iteratively

### Reporting Issues

- Typos/errors: Open GitHub issue
- Missing content: Label as "documentation"
- Broken links: Label as "bug"

---

## License

All documentation is licensed under AGPL 3.0 unless otherwise noted.

Individual projects may have different licenses—see their respective directories.

---

## Contact

**Macawi AI**
- Website: [macawi.ai](https://macawi.ai)
- Email: [security@macawi.ai](mailto:security@macawi.ai)
- GitHub: [github.com/macawi-ai](https://github.com/macawi-ai)

---

*Professional documentation. Portable access. Revenue-ready.*
