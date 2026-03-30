# BC Building Code Amendment System

## Product Overview

This is an XML transformation pipeline that converts the National Building Code (NBC) 2020 to the BC Building Code by applying British Columbia-specific amendments. The system uses XSLT 3.0 transformations to normalize vendor XML, apply structured amendments, and generate AI-optimized JSON output.

## Key Components

- **NBC Canonical Transform**: Converts Arbortext vendor XML to stable hierarchical format with canonical IDs
- **BC Overlay System**: Structured amendment format for documenting BC-specific changes
- **BC Revision System**: Date-based versioning for tracking errata, policy changes, and ministerial orders
- **Merge Engine**: Applies amendments and revisions to generate BC Building Code
- **JSON Generator**: Produces AI-ready hierarchical JSON from canonical XML

## Purpose

The system enables:
- Version-controlled building code amendments
- Date-based revision tracking for errata and policy changes
- Stable cross-references across NBC updates
- Automated BC Building Code generation
- AI/LLM integration via structured JSON output
- Professional publishing via Arbortext/OpenText TeamSite

## Two-Phase Amendment System

**Phase 1: Overlay Amendments** (Structural changes)
- Applied to `nbc-canonical.xml` → produces `bc-building-code.xml`
- Handles: replace, insert, modify, remove operations
- Files in: `json-generation-pipeline/source/bc-amendments/xml/`

**Phase 2: Revision Amendments** (Date-based versioning)
- Applied to `bc-building-code.xml` → produces `bc-building-code-final.xml`
- Handles: errata, policy changes, ministerial orders with effective dates
- Files in: `json-generation-pipeline/source/bc-revisions/xml/`

## Source Materials

- **NBC 2020 XML**: Arbortext vendor format from National Research Council
- **BC Word Documents**: BC Building Code amendments (green text indicates changes)
- **Amendment Files**: Structured BC overlay XML documenting all BC-specific changes
