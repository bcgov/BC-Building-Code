# BC Building Code Amendment System - System Overview

## 1. What is the JSON Generation Pipeline?

The JSON Generation Pipeline is a system that transforms the **National Building Code of Canada (NBC)** into the **British Columbia Building Code (BC Building Code)**. It takes the NBC as a foundation and applies BC-specific amendments to produce a customized building code that meets British Columbia's unique requirements.

### Why "JSON Generation Pipeline"?

The final output is a JSON file that can be consumed by web applications, search systems, and other digital tools. The pipeline:

1. **Normalizes** the vendor NBC XML into a canonical format with standardized IDs
2. **Applies** BC-specific amendments (structural changes and revisions)
3. **Transforms** the result into a JSON format

This JSON output powers the BC Building Code digital platform, enabling features like:
- Full-text search
- Cross-reference navigation
- Date-based code queries (seeing the code as it was on any specific date)
- Filtering BC-specific content from NBC content

---

## 2. Why Do We Need This System?

British Columbia adopts the National Building Code as its foundation but makes significant modifications:

- **New sections** specific to BC (e.g., Part 10 for radon protection)
- **Modified requirements** that differ from the NBC
- **Additional provisions** for BC's unique climate, seismic conditions, and policy requirements
- **Periodic updates** through Ministerial Orders

Without this system, maintaining the BC Building Code would require:
- Manual editing of thousands of pages
- Error-prone copy-paste operations
- No audit trail of changes
- Difficulty tracking which content is BC-specific vs. NBC

The amendment system solves these problems by:
- **Automating** the merge of NBC + BC amendments
- **Tracking** every change with full revision history
- **Validating** amendments before they're applied
- **Enabling** date-based queries for any point in time

---

## 3. High-Level Architecture

The pipeline consists of four main stages:

```
  ┌─────────────────────────────────────────────────────────────────────────────────┐
  │                          JSON GENERATION PIPELINE                                │
  ├─────────────────────────────────────────────────────────────────────────────────┤
  │                                                                                  │
  │  STAGE 0: NORMALIZATION                                                         │
  │  ┌─────────────────┐        ┌─────────────────┐        ┌─────────────────┐      │
  │  │   NBC 2020      │        │  Normalization  │        │  nbc-canonical  │      │
  │  │   Vendor XML    │───────►│  (XSLT)         │───────►│      .xml       │      │
  │  │   (Arbortext)   │        │                 │        │                 │      │
  │  └─────────────────┘        └─────────────────┘        └────────┬────────┘      │
  │     Inconsistent IDs           Generates stable             Canonical IDs       │
  │     Vendor format              hierarchical IDs             nbc.divB.part3...   │
  │                                                                  │              │
  │  STAGE 1: OVERLAY AMENDMENTS                                     ▼              │
  │  ┌─────────────────┐        ┌─────────────────┐        ┌─────────────────┐      │
  │  │  BC Overlay     │───────►│  Merge Engine   │◄───────│  nbc-canonical  │      │
  │  │  Amendments     │        │  (Phase 1)      │        │      .xml       │      │
  │  └─────────────────┘        └────────┬────────┘        └─────────────────┘      │
  │     Replace, Insert,                 │                                          │
  │     Modify, Delete                   ▼                                          │
  │                             ┌─────────────────┐                                 │
  │                             │ bc-building-    │                                 │
  │                             │ code.xml        │                                 │
  │                             └────────┬────────┘                                 │
  │                                      │                                          │
  │  STAGE 2: REVISION AMENDMENTS        ▼                                          │
  │  ┌─────────────────┐        ┌─────────────────┐        ┌─────────────────┐      │
  │  │  Revision       │───────►│  Merge Engine   │───────►│ bc-building-    │      │
  │  │  Amendments     │        │  (Phase 2)      │        │ code-final.xml  │      │
  │  └─────────────────┘        └─────────────────┘        └────────┬────────┘      │
  │     Effective dates,                                            │              │
  │     History tracking                                            ▼              │
  │                                                         ┌─────────────────┐     │
  │  STAGE 3: JSON TRANSFORMATION                           │ JSON Transform  │     │
  │                                                         └────────┬────────┘     │
  │                                                                  │              │
  │                                                         ┌────────▼────────┐     │
  │                                                         │ bc-building-    │     │
  │                                                         │ code.json       │     │
  │                                                         └─────────────────┘     │
  │                                                            Web-ready output     │
  └─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Stage 0: NBC Normalization

Before any amendments can be applied, the NBC source XML from the vendor (Arbortext) must be **normalized** into a canonical format. This is a critical preparatory step.

### Why Normalization is Needed

The vendor-supplied NBC XML has:
- **Inconsistent IDs** - IDs like `ea004586`, `es007850` that have no semantic meaning
- **Vendor-specific markup** - Elements named for the publishing tool, not the content
- **No stable references** - Different publishing runs may generate different IDs

### What Normalization Does

The normalization step (`nbc-to-canonical.xsl`) transforms vendor XML into a clean, predictable format:

| Before (Vendor XML) | After (Canonical XML) |
|--------------------|-----------------------|
| `<OBCode>` root element | `<nbc>` root element |
| `<OBCode.div>`, `<subsect>`, etc. | `<division>`, `<subsection>`, etc. |
| `id="ea004586"` (vendor ID) | `xml:id="nbc.divB.part3.sect8.subsect2.art6"` (canonical ID) |
| Inconsistent whitespace | Normalized whitespace |
| Vendor markup | Standard XML structure |

### Canonical ID Generation

The normalization step generates **hierarchical canonical IDs** that encode the location in the document:

```
nbc.divB.part3.sect8.subsect2.art6.sent1.cl-a.subcl-i
│    │    │     │    │        │    │     │    └── Subclause i
│    │    │     │    │        │    │     └─────── Clause a
│    │    │     │    │        │    └────────────── Sentence 1
│    │    │     │    │        └─────────────────── Article 6
│    │    │     │    └──────────────────────────── Subsection 2
│    │    │     └───────────────────────────────── Section 8
│    │    └─────────────────────────────────────── Part 3
│    └──────────────────────────────────────────── Division B
└───────────────────────────────────────────────── NBC namespace
```

### Vendor ID Preservation

Original vendor IDs are preserved as `vendor-id` attributes for traceability:

```xml
<article xml:id="nbc.divB.part3.sect8.subsect2.art6" vendor-id="ea004586">
```

### Reference Remapping

The normalization also updates all internal cross-references from vendor IDs to canonical IDs:

```xml
<!-- Before (vendor XML) -->
<ref target="es007850">Sentence 3.8.2.6.(1)</ref>

<!-- After (canonical XML) -->
<ref target="nbc.divB.part3.sect8.subsect2.art6.sent1">Sentence 3.8.2.6.(1)</ref>
```

### Technical Details

- **XSLT Transform:** `transformation-xslt/nbc-to-canonical.xsl`
- **Input:** `source/nbc-2020-xml/nbc2020.xml` (11.76 MB vendor file)
- **Output:** `output/nbc-canonical.xml` (~6.5 MB normalized)
- **Processing time:** ~10 seconds

---

## 5. The Two-Phase Amendment System

The BC Building Code uses a **two-phase amendment system** that separates structural changes from date-based versioning:

### Phase 1: Overlay Amendments (Structural Changes)

**Purpose:** Make fundamental structural changes to the NBC

**What it does:**
- Replaces NBC content with BC-specific content
- Inserts new articles, sections, or entire parts
- Modifies text within existing elements
- Deletes NBC content that doesn't apply to BC

**Input:** `nbc-canonical.xml` + Overlay Amendment files
**Output:** `bc-building-code.xml`

**Example uses:**
- Adding Part 10 (BC-specific radon protection)
- Replacing Division A application statements
- Inserting new classification articles

### Phase 2: Revision Amendments (Date-Based Versioning)

**Purpose:** Track changes over time for date-based queries

**What it does:**
- Adds revision history to elements
- Enables querying the code as it was on any date
- Tracks ministerial orders, errata, and policy changes

**Input:** `bc-building-code.xml` + Revision Amendment files
**Output:** `bc-building-code-final.xml`

**Example uses:**
- Ministerial Order BA 2024 01 changes
- Errata corrections
- Policy updates effective on specific dates

### Why Two Phases?

| Aspect | Phase 1 (Overlay) | Phase 2 (Revision) |
|--------|-------------------|-------------------|
| **Purpose** | Structural modifications | Historical tracking |
| **Source** | nbc-canonical.xml | bc-building-code.xml |
| **Date tracking** | No | Yes (effective-date) |
| **Use case** | "What BC requires" | "What BC required on [date]" |

---

## 6. Key Concepts and Terminology

### Canonical IDs

Every element in the building code has a unique **canonical ID** that follows a hierarchical pattern:

```
nbc.divB.part3.sect1.subsect2.art1.sent1
│    │    │     │    │        │    └── Sentence 1
│    │    │     │    │        └─────── Article 1
│    │    │     │    └──────────────── Subsection 2
│    │    │     └───────────────────── Section 1
│    │    └─────────────────────────── Part 3
│    └──────────────────────────────── Division B
└───────────────────────────────────── NBC namespace (all content)
```

### Unified Namespace (nbc. prefix)

**All content uses the `nbc.` prefix**, regardless of whether it's original NBC content or BC-specific content. This ensures:
- Seamless cross-references between NBC and BC content
- Single ID namespace management
- No broken links when referencing BC-specific articles from NBC content

### Source Attribute for BC Content

BC-specific content is identified by the **`source="bc"`** attribute on the `<new-content>` element:

```xml
<new-content source="bc">
  <article xml:id="nbc.divB.part10.sect1.subsect1.art1">
    <!-- BC-specific content here -->
  </article>
</new-content>
```

The merge engine automatically propagates this attribute to all child elements, allowing applications to:
- Filter BC-specific content
- Display visual indicators for BC modifications
- Generate reports on BC customizations

### Overlay Documents

An **overlay document** is an XML file containing one or more amendments. Each overlay:
- Has metadata (title, description, authority)
- Contains one or more `<amendment>` elements
- Targets specific elements in the source document

### Merge Engine

The **merge engine** (`merge-engine-v3.xsl`) is the XSLT transformation that:
1. Reads the source document
2. Applies amendments in sequence order
3. Propagates source attributes
4. Produces the merged output

---

## 7. Pipeline Workflow Summary

### Step 0: Normalize NBC Source (One-time setup)

```bash
# Convert vendor NBC XML to canonical format
java -jar saxon.jar -xsl:nbc-to-canonical.xsl \
  -s:source/nbc-2020-xml/nbc2020.xml \
  -o:output/nbc-canonical.xml
```

This step only needs to be run once when a new NBC edition is released.

### Step 1: Combine Amendment Files

```bash
# Phase 1: Combine overlay amendments
java -jar saxon.jar -xsl:combine-amendments.xsl \
  -s:amendment-list.xml -o:bc-amendments-combined.xml

# Phase 2: Combine revision amendments
java -jar saxon.jar -xsl:combine-amendments.xsl \
  -s:revision-list.xml -o:bc-revisions-combined.xml
```

### Step 2: Apply Amendments

```bash
# Phase 1: Apply overlay amendments to NBC
java -jar saxon.jar -xsl:merge-engine.xsl \
  -s:nbc-canonical.xml \
  overlay-document=bc-amendments-combined.xml \
  -o:bc-building-code.xml

# Phase 2: Apply revision amendments
java -jar saxon.jar -xsl:merge-engine.xsl \
  -s:bc-building-code.xml \
  overlay-document=bc-revisions-combined.xml \
  -o:bc-building-code-final.xml
```

### Step 3: Generate JSON Output

```bash
java -jar saxon.jar -xsl:canonical-to-json.xsl \
  -s:bc-building-code-final.xml \
  -o:bc-building-code.json
```

### Step 4: Validate

```bash
java -jar saxon.jar -xsl:validate-amendments.xsl \
  -s:bc-amendments-combined.xml \
  -o:validation-report.html
```

---

## 8. File Locations Quick Reference

| Purpose | Location |
|---------|----------|
| **NBC Vendor XML** | `source/nbc-2020-xml/nbc2020.xml` |
| **NBC Canonical XML** | `output/nbc-canonical.xml` |
| **Overlay Amendments** | `source/bc-amendments/xml/` |
| **Revision Amendments** | `source/bc-revisions/xml/` |
| **Amendment List (Phase 1)** | `source/bc-amendments/amendment-list.xml` |
| **Revision List (Phase 2)** | `source/bc-revisions/revision-list.xml` |
| **XSLT Transforms** | `transformation-xslt/` |
| **Output XML** | `output/` |
| **Output JSON** | `output/bc-building-code.json` |
| **Schemas** | `schemas/` |

---

## 9. Migration Note: bc. Prefix to Source Attribute

**Completed: 2026-02-02**

Previously, BC-specific content used a separate `bc.` prefix for IDs (e.g., `bc.divB.part10.sect1...`). This caused issues with cross-namespace references.

The system now uses:
- **Unified `nbc.` prefix** for ALL content
- **`source="bc"` attribute** to identify BC-specific content

### What This Means for You

When creating amendments:
- ✅ **DO:** Use `nbc.` prefix for all IDs
- ✅ **DO:** Add `source="bc"` to `<new-content>` for BC content
- ❌ **DON'T:** Use `bc.` prefix for hierarchical IDs

**Exception:** BC-specific term definitions still use `bc-` prefix (e.g., `bc-scnd-t` for "secondary suite"). These are in a different namespace (term definitions) and were not affected by the migration.

---

## Next Steps

Now that you understand the system overview, proceed to:

- **[02-overlay-amendments-guide.md](02-overlay-amendments-guide.md)** - Learn to create Phase 1 amendments
- **[03-revision-amendments-guide.md](03-revision-amendments-guide.md)** - Learn to create Phase 2 amendments
- **[04-merge-engine-reference.md](04-merge-engine-reference.md)** - Technical reference for all operations
