# BC Building Code Transformation Pipeline — Documentation

## Overview

This directory contains all technical documentation for the BC Building Code JSON generation pipeline. The docs are organized into two tiers:

- **This folder** (`json-generation-pipeline/docs/`) — XSLT stylesheet references, command reference, and feature docs
- **Project subfolder** (`json-generation-pipeline/docs/project/`) — Comprehensive guides for amendment authoring, validation, and usage

---

## Repository-Level Documentation

These docs live in the root `docs/` folder and cover the project at a high level:

| Document | Description |
|----------|-------------|
| [Product Overview](../../docs/product-overview.md) | What the system does, key components, and purpose |
| [Technology Stack](../../docs/technology-stack.md) | Core technologies, commands, performance, and JSON output structure |
| [Project Structure](../../docs/project-structure.md) | Repository layout, file naming conventions, and key directories |
| [Validation Pipeline](../../docs/VALIDATION_PIPELINE.md) | End-to-end validation pipeline documentation |

---

## Project Guides (Comprehensive)

Full authoring and reference documentation lives in [`project/`](project/README.md):

| Document | Description |
|----------|-------------|
| [Documentation Index](project/README.md) | Start here — full index with quick links |
| [01 — System Overview](project/01-system-overview.md) | Pipeline architecture, two-phase amendment system, key concepts |
| [02 — Overlay Amendments Guide](project/02-overlay-amendments-guide.md) | Phase 1: structural changes (replace, insert, modify, delete) |
| [03 — Revision Amendments Guide](project/03-revision-amendments-guide.md) | Phase 2: date-based versioning, ministerial orders, errata |
| [04 — Merge Engine Reference](project/04-merge-engine-reference.md) | Technical reference for all merge engine operations |
| [05 — Validation Troubleshooting](project/05-validation-troubleshooting.md) | Fixing common validation errors and warnings |
| [06 — Quick Reference](project/06-quick-reference.md) | Single-page printable reference card |
| [07 — Examples Library](project/07-examples-library.md) | Curated working examples for each operation type |
| [08 — Migration Guide](project/08-migration-guide.md) | Migrating from legacy `proposed/` to `json-generation-pipeline/` |
| [09 — JSON Output Guide](project/09-json-output-guide.md) | JSON structure, usage, and standards reference mapping |
| [10 — Oxygen XML Editor Guide](project/10-oxygen-xml-editor-guide.md) | Visual editing for non-technical users |
| [11 — Global Text Replacements](project/11-global-text-replacements.md) | Bulk renumbering and reorganization via pre-processing |

---

## XSLT Stylesheet References

Detailed documentation for each transformation stylesheet:

| Document | Stylesheet | Description |
|----------|-----------|-------------|
| [nbc-to-canonical.md](nbc-to-canonical.md) | `nbc-to-canonical.xsl` | Converts NBC vendor XML to canonical format with hierarchical IDs |
| [combine-amendments.md](combine-amendments.md) | `combine-amendments.xsl` | Merges multiple amendment/revision files into one |
| [merge-engine-v3.md](merge-engine-v3.md) | `merge-engine-v3.xsl` | Applies amendments to canonical XML (single-pass, O(1) lookups) |
| [validate-amendments.md](validate-amendments.md) | `validate-amendments.xsl` | Validates amendment application, generates HTML report |
| [canonical-to-json.md](canonical-to-json.md) | `canonical-to-json.xsl` | Generates full AI-optimized JSON output |
| [canonical-to-json-minimal.md](canonical-to-json-minimal.md) | `canonical-to-json-minimal.xsl` | Generates minimal representative JSON sample |
| [deletion-tracking.md](deletion-tracking.md) | *(feature doc)* | How deletion tracking works across phases |

---

## Command Reference

| Document | Description |
|----------|-------------|
| [COMMANDS.md](COMMANDS.md) | Complete workflow commands for all phases, validation, and utilities |

---

## Pipeline Architecture

```
NBC 2020 XML (Arbortext)
    |
[1] nbc-to-canonical.xsl
    |
NBC Canonical XML
    |
[2] combine-amendments.xsl  <-  BC Amendment Files
    |
[3] merge-engine-v3.xsl     ->  bc-building-code.xml (Phase 1)
    |
[2] combine-amendments.xsl  <-  BC Revision Files
    |
[3] merge-engine-v3.xsl     ->  bc-building-code-final.xml (Phase 2)
    |
[4] validate-amendments.xsl ->  HTML Validation Report
    |
[5] canonical-to-json.xsl   ->  bc-building-code.json (Full)
[6] canonical-to-json-minimal.xsl -> bc-building-code-minimal.json (Sample)
```

Total pipeline time: ~40 seconds.

---

## Performance Summary

| Transformation | Input | Output | Time |
|----------------|-------|--------|------|
| nbc-to-canonical | 11.76 MB | 5.9 MB | ~10s |
| combine-amendments | N/A | ~500 KB | ~2s |
| merge-engine-v3 | 5.9 MB | 5.9 MB | ~10s |
| validate-amendments | N/A | ~500 KB | ~5s |
| canonical-to-json | 5.9 MB | 6.9 MB | ~5s |
| canonical-to-json-minimal | 5.9 MB | 150 KB | ~2s |

---

## Version History

- v3.0 (2025-01): Single-pass merge engine optimization
- v2.0 (2024-12): Revision history support
- v1.0 (2024-10): Initial pipeline implementation
