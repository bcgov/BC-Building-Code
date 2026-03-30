# AGENTS.md

This file is the startup context for any agent working in this repository.

## 1) Project Summary

- Repository: BC Building Code transformation and publication pipeline.
- Goal: transform NBC 2020 vendor XML into BC Building Code outputs (XML + JSON).
- Core model: **two-phase amendments** on canonical NBC XML.
  - Phase 1: overlay amendments (structural changes).
  - Phase 2: revision amendments (date-based history, ministerial orders, errata, policy).

## 2) Mandatory Read-First Documents

Read these before making edits:

### Repository-level docs (`docs/`)

- `docs/product-overview.md` - Product overview and purpose
- `docs/technology-stack.md` - Technology stack, commands, performance
- `docs/project-structure.md` - Repository structure and file organization

### Pipeline docs (`json-generation-pipeline/docs/project/`)

- `json-generation-pipeline/docs/project/README.md` - Documentation index
- `json-generation-pipeline/docs/project/01-system-overview.md` - System overview and key concepts
- `json-generation-pipeline/docs/project/02-overlay-amendments-guide.md` - Phase 1 amendment guide
- `json-generation-pipeline/docs/project/03-revision-amendments-guide.md` - Phase 2 amendment guide
- `json-generation-pipeline/docs/project/04-merge-engine-reference.md` - Merge engine operations reference
- `json-generation-pipeline/docs/project/05-validation-troubleshooting.md` - Validation error troubleshooting
- `json-generation-pipeline/docs/project/06-quick-reference.md` - Single-page quick reference
- `json-generation-pipeline/docs/project/07-examples-library.md` - Curated working examples
- `json-generation-pipeline/docs/project/08-migration-guide.md` - Migration guide (legacy to new pipeline)
- `json-generation-pipeline/docs/project/09-json-output-guide.md` - JSON output structure and usage
- `json-generation-pipeline/docs/project/10-oxygen-xml-editor-guide.md` - Oxygen XML Editor guide
- `json-generation-pipeline/docs/project/11-global-text-replacements.md` - Global text replacements (pre-processing)

## 3) Pipeline Architecture (Authoritative Mental Model)

1. Normalize vendor NBC XML to canonical XML (`nbc-to-canonical.xsl`).
2. Apply **Phase 1 overlay amendments** to produce `bc-building-code.xml`.
3. Apply **Phase 2 revision amendments** to produce `bc-building-code-final.xml`.
4. Generate JSON (`canonical-to-json.xsl` / minimal variant).
5. Validate XML and JSON outputs.

Primary working area is `json-generation-pipeline/`.

## 4) Non-Negotiable Authoring Rules

- Use **unified `nbc.` hierarchical IDs** for structural content.
- Mark BC-added/BC-modified insert/replace content with `source="bc"` on `<new-content>`.
- Do not invent mixed ID schemes (`bc.` hierarchical IDs are deprecated in migrated flow).
- Keep canonical hierarchy valid:
  - division → part → section → subsection → article → sentence → clause → subclause
- Keep numbering/letters aligned with visible code numbering.
- Maintain reference integrity (`<ref>` targets must resolve).

### Exception

- BC term identifiers may still use `bc-...` (term namespace), e.g., specific glossary terms.

## 5) Overlay vs Revision (When to Use What)

Use **overlay amendments (Phase 1)** for structural edits:

- replace
- insert
- modify (`text-change` / `element-replace`)
- delete (hard remove in phase 1)

Use **revision amendments (Phase 2)** for dated change history:

- add `revised="yes"`
- embed `<revision-history>`
- use effective dates and statuses (`current` / `superseded`)
- for deletions, use `deleted="yes"` with empty revision `<content>`

Important: revision targets are looked up in `bc-building-code.xml` (not `nbc-canonical.xml`).

## 6) Operation Guidance

- `text-change` is good for plain text node edits.
- Prefer `element-replace` when text crosses inline elements (`<ref>`, `<measurement>`, etc.) or complex XPath is needed.
- Use `child-element` target for children without IDs (e.g., `title` under a parent ID).
- Use position-based insert for before/after/first-child/last-child changes.
- Use global `<text-replacements>` for broad pre-processing renumbering/reorganization.

## 7) Common Failure Pattern (Critical)

Most frequent warning:

- `Modified text not found exactly`

Typical fix path:

1. Inspect target element in merged output XML.
2. If target text crosses inline child elements or uses self-closing refs, stop using `text-change`.
3. Copy current element content and apply `element-replace`.
4. Re-run combine/merge/validate.

See: `json-generation-pipeline/docs/project/05-validation-troubleshooting.md`

## 8) Command Conventions

- Environment convention in this repo: generate commands for **Git Bash** style usage.
- Prefer forward slashes in paths.
- All commands use current pipeline paths under `json-generation-pipeline/`.

## 9) Key Paths

- Source NBC XML: `json-generation-pipeline/source/nbc-2020-xml/`
- Overlay amendment XML: `json-generation-pipeline/source/bc-amendments/xml/`
- Revision amendment XML: `json-generation-pipeline/source/bc-revisions/xml/`
- Amendment registries:
  - `json-generation-pipeline/source/bc-amendments/amendment-list.xml`
  - `json-generation-pipeline/source/bc-revisions/revision-list.xml`
- XSLT transforms: `json-generation-pipeline/transformation-xslt/`
- Output artifacts: `json-generation-pipeline/output/`
- Schemas: `json-generation-pipeline/output/schema/`
- Graphics: `bc-graphics/` and `graphics/`

## 10) Validation Expectations Before Handoff

- Amendment files are schema-valid and merge without fatal errors.
- No unresolved cross-references introduced.
- New IDs are unique and canonical.
- Revision metadata (`effective-date`, `seq`, `status`, `change-summary`, `note`) is complete where applicable.
- JSON generation succeeds and expected structures appear (source flags, revisions, deletions).

## 11) Fast Orientation for New Agents

1. Read Section 2 docs in order.
2. Identify whether task is Phase 1 or Phase 2.
3. Locate target IDs in correct base file (`nbc-canonical.xml` for Phase 1, `bc-building-code.xml` for Phase 2).
4. Implement with minimal operation needed.
5. Run combine → merge → validate (and JSON generation if output-impacting).
6. Report changed files + validation outcome + any residual warnings.
