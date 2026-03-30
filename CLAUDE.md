# CLAUDE.md

## Project Context

This repository contains the BC Building Code project, including XML-based building code documents, amendment generation tools, and JSON transformation pipelines.

## Important: Read Project Documentation First

Before working on this project, read the documentation in version control:

### Repository-level docs (`docs/`)
- `docs/product-overview.md` - Product overview and purpose
- `docs/technology-stack.md` - Technology stack, commands, performance
- `docs/project-structure.md` - Repository structure and file organization

### Pipeline docs (`json-generation-pipeline/docs/project/`)
- `json-generation-pipeline/docs/project/README.md` - Documentation index and quick links
- `json-generation-pipeline/docs/project/01-system-overview.md` - System overview
- `json-generation-pipeline/docs/project/02-overlay-amendments-guide.md` - Phase 1 amendment guide
- `json-generation-pipeline/docs/project/03-revision-amendments-guide.md` - Phase 2 amendment guide
- `json-generation-pipeline/docs/project/04-merge-engine-reference.md` - Merge engine reference
- `json-generation-pipeline/docs/project/05-validation-troubleshooting.md` - Validation troubleshooting
- `json-generation-pipeline/docs/project/06-quick-reference.md` - Quick reference card
- `json-generation-pipeline/docs/project/07-examples-library.md` - Working examples
- `json-generation-pipeline/docs/project/09-json-output-guide.md` - JSON output guide
- `json-generation-pipeline/docs/project/11-global-text-replacements.md` - Global text replacements

## Quick Start

1. Read `docs/product-overview.md` for project context
2. Read `json-generation-pipeline/docs/project/01-system-overview.md` for pipeline architecture
3. Understand the XML schema and amendment structure via the guides above
4. Use the JSON generation pipeline tools as documented in `docs/technology-stack.md`

## Command Conventions

- Use **Git Bash** style commands (forward slashes in paths)
- All tools are under `json-generation-pipeline/tools/`
- All XSLT transforms are under `json-generation-pipeline/transformation-xslt/`
- All outputs go to `json-generation-pipeline/output/`
