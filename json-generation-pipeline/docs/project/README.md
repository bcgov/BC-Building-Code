# BC Building Code Amendment System Documentation

Welcome to the comprehensive documentation for the BC Building Code JSON Generation Pipeline. This documentation is designed to enable both technical and non-technical users to create, update, review, and debug amendments to the National Building Code (NBC) for the BC Building Code.

---

## Documentation Overview

### Getting Started

| Document | Description |
|----------|-------------|
| [01-system-overview.md](01-system-overview.md) | **Start here!** Introduction to the pipeline, two-phase amendment system, and key concepts |

### Creating Amendments

| Document | Description |
|----------|-------------|
| [02-overlay-amendments-guide.md](02-overlay-amendments-guide.md) | Guide for Phase 1 (Overlay) amendments - structural changes to NBC |
| [03-revision-amendments-guide.md](03-revision-amendments-guide.md) | Guide for Phase 2 (Revision) amendments - date-based versioning, ministerial orders |

### Technical Reference

| Document | Description |
|----------|-------------|
| [04-merge-engine-reference.md](04-merge-engine-reference.md) | Technical reference for all merge engine operations |
| [05-validation-troubleshooting.md](05-validation-troubleshooting.md) | Fixing common validation errors and warnings |
| [09-json-output-guide.md](09-json-output-guide.md) | Comprehensive JSON output structure and usage guide |

### Quick Reference

| Document | Description |
|----------|-------------|
| [06-quick-reference.md](06-quick-reference.md) | Single-page printable reference card for common tasks |
| [07-examples-library.md](07-examples-library.md) | Curated collection of working examples for each operation |

---

## Quick Links

### I want to...

| Task | Go to |
|------|-------|
| Understand how the system works | [01-system-overview.md](01-system-overview.md) |
| Create a new BC-specific article | [02-overlay-amendments-guide.md](02-overlay-amendments-guide.md) → Insert Operations |
| Replace existing NBC content | [02-overlay-amendments-guide.md](02-overlay-amendments-guide.md) → Replace Operations |
| Track changes with effective dates | [03-revision-amendments-guide.md](03-revision-amendments-guide.md) |
| Delete content with history | [03-revision-amendments-guide.md](03-revision-amendments-guide.md) → Deletion Tracking |
| Fix "Modified text not found" error | [05-validation-troubleshooting.md](05-validation-troubleshooting.md) |
| See working examples | [07-examples-library.md](07-examples-library.md) |
| Look up operation syntax quickly | [06-quick-reference.md](06-quick-reference.md) |
| Understand JSON output structure | [09-json-output-guide.md](09-json-output-guide.md) |
| Work with JSON in applications | [09-json-output-guide.md](09-json-output-guide.md) → Working with the JSON |

---

## Key Concepts Summary

### Two-Phase Amendment System

1. **Phase 1: Overlay Amendments** - Structural changes to NBC
   - Source: `nbc-canonical.xml`
   - Output: `bc-building-code.xml`

2. **Phase 2: Revision Amendments** - Date-based versioning
   - Source: `bc-building-code.xml`
   - Output: `bc-building-code-final.xml`

### ID Convention

All IDs use unified `nbc.` prefix:
```
nbc.divB.part3.sect1.subsect2.art1.sent1
```

BC-specific content identified by `source="bc"` attribute.

### Operations

| Operation | Use For |
|-----------|---------|
| Replace | Replace entire elements |
| Insert | Add new content |
| Modify (text-change) | Small text edits |
| Modify (element-replace) | Replace child elements |
| Delete | Remove content |

---

## Getting Help

1. **Validation errors**: See [05-validation-troubleshooting.md](05-validation-troubleshooting.md)
2. **Operation syntax**: See [06-quick-reference.md](06-quick-reference.md)
3. **Working examples**: See [07-examples-library.md](07-examples-library.md)
4. **Technical details**: See [04-merge-engine-reference.md](04-merge-engine-reference.md)

---

## File Locations

| Purpose | Location |
|---------|----------|
| NBC Source | `source/nbc-canonical.xml` |
| Overlay Amendments | `source/bc-amendments/xml/` |
| Revision Amendments | `source/bc-revisions/xml/` |
| XSLT Transforms | `transformation-xslt/` |
| Output | `output/` |
| Schemas | `output/schema/` |

---

## Confluence Migration

When copying this documentation to Confluence:

1. Convert markdown to Confluence wiki markup (or use paste-as-markdown)
2. Code blocks should use `{code:xml}` macro
3. Tables may need manual formatting
4. Cross-document links should be converted to Confluence page links
5. Consider creating a documentation space with these pages as children

---

*Documentation created: 2026-02-02*
*Last updated: 2026-02-08*
