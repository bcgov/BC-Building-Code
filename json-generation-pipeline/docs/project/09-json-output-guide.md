# BC Building Code JSON Output Guide

This document provides a comprehensive guide to the JSON output generated from the BC Building Code XML. It covers the complete document structure from the root document down to subclauses, including all element types, properties, and special features.

---

## 1. Overview

The JSON Generation Pipeline transforms the final `bc-building-code-final.xml` into a structured JSON file that can be consumed by:
- Web applications
- Search systems
- AI/LLM systems
- Mobile applications
- Third-party integrations

### Generation Command

```bash
java -jar saxon.jar -xsl:canonical-to-json.xsl \
  -s:bc-building-code-final.xml \
  -o:bc-building-code.json
```

### Configuration Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `include-metadata` | true | Include document metadata and publication info |
| `include-cross-references` | false | Generate cross-reference index for navigation |
| `include-bc-annotations` | true | Include BC amendments and revision history |
| `flatten-hierarchy` | false | Flatten hierarchical structure (experimental) |

---

## 2. Top-Level Document Structure

```json
{
  "document_type": "bc_building_code",
  "version": "2020",
  "canonical_version": "1.0",
  "generated_timestamp": "2026-02-03T10:26:50.5627748-08:00",

  "metadata": { ... },
  "front_matter": { ... },
  "divisions": [ ... ],
  "bc_amendments": [ ... ],
  "glossary": { ... },
  "standards": { ... },
  "statistics": { ... }
}
```

### Top-Level Properties

| Property | Type | Description |
|----------|------|-------------|
| `document_type` | string | Always `"bc_building_code"` |
| `version` | string | NBC version year (e.g., `"2020"`) |
| `canonical_version` | string | Schema version for the canonical format |
| `generated_timestamp` | string | ISO 8601 timestamp of JSON generation |
| `metadata` | object | Publication and catalog information |
| `front_matter` | object | Preface, introduction, committees |
| `divisions` | array | Main document content (Division A, B, C) |
| `bc_amendments` | array | List of BC-specific amendments applied |
| `glossary` | object | Term definitions |
| `standards` | object | Standards reference mapping |
| `statistics` | object | Document statistics |

---

## 3. Metadata Section

```json
"metadata": {
  "title": "National Building Code of Canada 2020",
  "subtitle": "Volume 1",
  "authority": "Issued by the Canadian Commission on Building and Fire Codes...",
  "publication_date": "2022",
  "nrc_number": "56435E",
  "isbn": "978-0-660-37913-5",
  "volumes": [
    {
      "volume": "1",
      "title": "National Building Code of Canada 2020",
      "subtitle": "Volume 1"
    },
    {
      "volume": "2",
      "title": "National Building Code of Canada 2020",
      "subtitle": "Volume 2"
    }
  ]
}
```

---

## 4. Document Hierarchy

The BC Building Code follows a strict hierarchical structure:

```
Document
└── Division (A, B, C)
    └── Part (1, 2, 3...)
        └── Section (1, 2, 3...)
            └── Subsection (1, 2, 3...)
                └── Article (1, 2, 3...)
                    └── Sentence (1, 2, 3...)
                        └── Clause (a, b, c...)
                            └── Subclause (i, ii, iii...)
```

---

## 5. Division Structure

Divisions are the top-level organizational units of the building code.

```json
{
  "id": "nbc.divA",
  "type": "division",
  "letter": "A",
  "title": "Compliance, Objectives and Functional Statements",
  "number": "",
  "parts": [ ... ]
}
```

### Division Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Canonical ID (e.g., `"nbc.divA"`, `"nbc.divB"`) |
| `type` | string | Always `"division"` |
| `letter` | string | Division letter (`"A"`, `"B"`, `"C"`) |
| `title` | string | Division title |
| `number` | string | Optional number (usually empty for divisions) |
| `parts` | array | Array of Part objects |

### Division IDs

| ID | Title |
|----|-------|
| `nbc.divA` | Compliance, Objectives and Functional Statements |
| `nbc.divB` | Acceptable Solutions |
| `nbc.divC` | Administrative Provisions |

---

## 6. Part Structure

Parts contain the major subject groupings within a division.

```json
{
  "id": "nbc.divB.part3",
  "type": "part",
  "number": 3,
  "title": "Fire Protection, Occupant Safety and Accessibility",
  "sections": [ ... ]
}
```

### Part Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Canonical ID (e.g., `"nbc.divB.part3"`) |
| `type` | string | Always `"part"` |
| `number` | number | Part number |
| `title` | string | Part title |
| `source` | string | `"bc"` if BC-specific content (optional) |
| `sections` | array | Array of Section objects |

---

## 7. Section Structure

Sections organize content within a part by topic.

```json
{
  "id": "nbc.divB.part3.sect1",
  "type": "section",
  "number": 1,
  "title": "General",
  "subsections": [ ... ]
}
```

### Section Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Canonical ID (e.g., `"nbc.divB.part3.sect1"`) |
| `type` | string | Always `"section"` |
| `number` | number | Section number |
| `title` | string | Section title |
| `source` | string | `"bc"` if BC-specific (optional) |
| `subsections` | array | Array of Subsection objects |

---

## 8. Subsection Structure

Subsections provide more detailed topic organization.

```json
{
  "id": "nbc.divB.part3.sect1.subsect1",
  "type": "subsection",
  "number": 1,
  "title": "Application of this Code",
  "articles": [ ... ]
}
```

### Subsection Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Canonical ID |
| `type` | string | Always `"subsection"` |
| `number` | number | Subsection number |
| `title` | string | Subsection title |
| `source` | string | `"bc"` if BC-specific (optional) |
| `articles` | array | Array of Article objects |

---

## 9. Article Structure

Articles are the primary regulatory units containing requirements.

```json
{
  "id": "nbc.divA.part1.sect1.subsect1.art1",
  "type": "article",
  "number": 1,
  "title": "Application of this Code",
  "source": "bc",
  "content": [ ... ]
}
```

### Article Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Canonical ID |
| `type` | string | Always `"article"` |
| `number` | number | Article number |
| `title` | string | Article title |
| `source` | string | `"bc"` if BC-specific (optional) |
| `deleted` | boolean | `true` if deleted by amendment (optional) |
| `revised` | boolean | `true` if has revision history (optional) |
| `content` | array | Sentences, tables, figures, notes |

### Article Content Types

The `content` array can contain:
- Sentences (`type: "sentence"`)
- Tables (`type: "table"`)
- Figures (`type: "figure"`)
- Application notes (`type: "application_note"`)

---

## 10. Sentence Structure

Sentences are individual numbered statements within an article.

```json
{
  "id": "nbc.divA.part1.sect1.subsect1.art1.sent1",
  "type": "sentence",
  "number": 1,
  "source": "bc",
  "text": "This Code applies to any one or more of the following:",
  "clauses": [ ... ]
}
```

### Sentence Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Canonical ID |
| `type` | string | Always `"sentence"` |
| `number` | number | Sentence number within the article |
| `source` | string | `"bc"` if BC-specific (optional) |
| `text` | string | Sentence text (may include references) |
| `deleted` | boolean | `true` if deleted (optional) |
| `revised` | boolean | `true` if has revision history (optional) |
| `clauses` | array | Array of Clause objects (optional) |
| `revision_history` | object | Revision tracking (if revised) |

### Text Content with References

Sentence text may include embedded references in a special format:

```
"text": "See [REF:term:bldng]building for definitions."
```

Reference formats:
- `[REF:term:bldng]` - Term/glossary reference
- `[REF:internal:nbc.divB.part3.sect1:short]` - Internal cross-reference (short form)
- `[REF:internal:nbc.divB.part3.sect1:long]` - Internal cross-reference (long form)
- `[REF:external:https://example.com]` - External URL reference
- `[REF:table-note:note-id]` - Table note reference

---

## 11. Clause Structure

Clauses are lettered subdivisions of a sentence.

```json
{
  "id": "nbc.divA.part1.sect1.subsect1.art1.sent1.clause1",
  "type": "clause",
  "letter": "a",
  "source": "bc",
  "text": "the design and construction of a new [REF:term:bldng]building,",
  "subclauses": [ ... ]
}
```

### Clause Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Canonical ID |
| `type` | string | Always `"clause"` |
| `letter` | string | Clause letter (`"a"`, `"b"`, `"c"`, etc.) |
| `source` | string | `"bc"` if BC-specific (optional) |
| `text` | string | Clause text |
| `deleted` | boolean | `true` if deleted (optional) |
| `revised` | boolean | `true` if has revision history (optional) |
| `subclauses` | array | Array of Subclause objects (optional) |

---

## 12. Subclause Structure

Subclauses are numbered subdivisions of a clause.

```json
{
  "id": "nbc.divA.part1.sect1.subsect1.art1.sent1.clause10.subclause1",
  "type": "subclause",
  "number": 1,
  "source": "bc",
  "text": "that remain after a demolition,"
}
```

### Subclause Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Canonical ID |
| `type` | string | Always `"subclause"` |
| `number` | number | Subclause number (1, 2, 3, etc.) |
| `source` | string | `"bc"` if BC-specific (optional) |
| `text` | string | Subclause text |
| `deleted` | boolean | `true` if deleted (optional) |
| `revised` | boolean | `true` if has revision history (optional) |

---

## 13. Complete Hierarchy Example

Here is a complete example showing the full hierarchy from Division to Subclause:

```json
{
  "divisions": [
    {
      "id": "nbc.divA",
      "type": "division",
      "letter": "A",
      "title": "Compliance, Objectives and Functional Statements",
      "parts": [
        {
          "id": "nbc.divA.part1",
          "type": "part",
          "number": 1,
          "title": "Compliance",
          "sections": [
            {
              "id": "nbc.divA.part1.sect1",
              "type": "section",
              "number": 1,
              "title": "General",
              "subsections": [
                {
                  "id": "nbc.divA.part1.sect1.subsect1",
                  "type": "subsection",
                  "number": 1,
                  "title": "Application of this Code",
                  "articles": [
                    {
                      "id": "nbc.divA.part1.sect1.subsect1.art1",
                      "type": "article",
                      "number": 1,
                      "title": "Application of this Code",
                      "content": [
                        {
                          "id": "nbc.divA.part1.sect1.subsect1.art1.sent1",
                          "type": "sentence",
                          "number": 1,
                          "source": "bc",
                          "text": "This Code applies to any one or more of the following:",
                          "clauses": [
                            {
                              "id": "nbc.divA.part1.sect1.subsect1.art1.sent1.clause1",
                              "type": "clause",
                              "letter": "a",
                              "source": "bc",
                              "text": "the design and construction of a new [REF:term:bldng]building,"
                            },
                            {
                              "id": "nbc.divA.part1.sect1.subsect1.art1.sent1.clause10",
                              "type": "clause",
                              "letter": "j",
                              "source": "bc",
                              "text": "the work necessary to ensure safety in parts of a [REF:term:bldng]building",
                              "subclauses": [
                                {
                                  "id": "nbc.divA.part1.sect1.subsect1.art1.sent1.clause10.subclause1",
                                  "type": "subclause",
                                  "number": 1,
                                  "source": "bc",
                                  "text": "that remain after a demolition,"
                                },
                                {
                                  "id": "nbc.divA.part1.sect1.subsect1.art1.sent1.clause10.subclause2",
                                  "type": "subclause",
                                  "number": 2,
                                  "source": "bc",
                                  "text": "that are affected by but that are not directly involved in [REF:term:ltrtn]alterations, or"
                                },
                                {
                                  "id": "nbc.divA.part1.sect1.subsect1.art1.sent1.clause10.subclause3",
                                  "type": "subclause",
                                  "number": 3,
                                  "source": "bc",
                                  "text": "that are affected by but not directly involved in additions,"
                                }
                              ]
                            }
                          ]
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

---

## 14. Table Structure

Tables contain structured data within articles.

```json
{
  "id": "nbc.divA.part1.sect1.subsect1.art1.table1",
  "type": "table",
  "frame": "all",
  "source": "bc",
  "title": "Alternate Compliance Methods for Heritage Buildings",
  "table_notes": [
    {
      "id": "nbc.divA.part1.sect1.subsect1.art1.table1.note1",
      "content": "See Note A-Table 1.1.1.1."
    },
    {
      "id": "nbc.divBV2.part9.sect8.subsect4.art1.table1.note1",
      "vendor_id": "et001049-2",
      "content": "Private stairs are exterior and interior stairs that serve",
      "list": {
        "type": "bulleted",
        "items": [
          "single [REF:term:dwllng-n:dwelling units] ,",
          "houses with a [REF:term:scnd-t:secondary suite] including their common spaces, or",
          "garages that serve houses described in Clause a) or b)."
        ]
      }
    }
  ],
  "structure": {
    "columns": 3,
    "colsep": "1",
    "rowsep": "1",
    "column_specs": [
      { "name": "col1", "width": "0.5*" },
      { "name": "col2", "width": "2*" },
      { "name": "col3", "width": "2*" }
    ],
    "header_rows": [
      {
        "id": "nbc.divA.part1.sect1.subsect1.art1.table1.row1",
        "type": "header_row",
        "cells": [
          { "content": [{ "type": "text", "value": "No." }], "align": "center", "rowspan": 2 },
          { "content": [{ "type": "text", "value": "Code Requirement in Division B" }], "align": "center", "colspan": 2 }
        ]
      }
    ],
    "body_rows": [
      {
        "id": "nbc.divA.part1.sect1.subsect1.art1.table1.row2",
        "type": "body_row",
        "cells": [
          { "content": [{ "type": "text", "value": "1" }], "align": "center" },
          { "content": [{ "type": "text", "value": "Fire Separations..." }], "align": "left" },
          { "content": [{ "type": "text", "value": "Except for F1 occupancies..." }], "align": "left" }
        ]
      }
    ]
  }
}
```

### Table Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Canonical ID |
| `type` | string | Always `"table"` |
| `frame` | string | Table frame styling from XML (optional) |
| `source` | string | `"bc"` if BC-specific (optional) |
| `title` | string | Table title |
| `table_notes` | array | Resolved table notes (optional). Each note has `id`, optional `vendor_id`, and `content` (string). Notes whose source XML contains an inline `<list>` also include a `list` object with `type` (e.g. `"bulleted"`) and `items` (array of strings), allowing the frontend to render the sub-list beneath the note text. |
| `structure.columns` | number | Number of columns |
| `structure.colsep` | string | Column separator style from XML (optional) |
| `structure.rowsep` | string | Row separator style from XML (optional) |
| `structure.column_specs` | array | Column width specifications |
| `structure.header_rows` | array | Header row data |
| `structure.body_rows` | array | Body row data |
| `structure.*.cells[].rowspan` | number | Numeric row span for merged cells (optional) |
| `structure.*.cells[].colspan` | number | Numeric column span for merged cells (optional) |

---

## 15. Revision History Structure

Elements with revision history include tracking of changes over time.

```json
{
  "id": "nbc.divA.part1.sect1.subsect1.art1.sent2.clause1",
  "type": "clause",
  "letter": "a",
  "source": "bc",
  "revised": true,
  "text": "current text content...",
  "revision_history": {
    "original": {
      "effective_date": "2020-12-01",
      "content": "original text content..."
    },
    "revisions": [
      {
        "seq": 1,
        "type": "amendment",
        "effective_date": "2025-06-16",
        "id": "bc-mo-2024-06-002",
        "status": "current",
        "content": "amended text content...",
        "change_summary": "Amended Clause by striking out...",
        "note": "Ministerial Order BA 2024 06"
      }
    ]
  }
}
```

### Revision History Properties

| Property | Type | Description |
|----------|------|-------------|
| `revised` | boolean | `true` if element has revision history |
| `revision_history.original` | object | Original content before amendments |
| `revision_history.original.effective_date` | string | Date original took effect |
| `revision_history.original.content` | string | Original text content |
| `revision_history.revisions` | array | Array of revisions |
| `revision_history.revisions[].seq` | number | Revision sequence number |
| `revision_history.revisions[].type` | string | `"amendment"`, `"errata"`, `"policy"` |
| `revision_history.revisions[].effective_date` | string | When revision takes effect |
| `revision_history.revisions[].id` | string | Amendment identifier |
| `revision_history.revisions[].status` | string | `"current"` or `"superseded"` |
| `revision_history.revisions[].content` | string | Revised content |
| `revision_history.revisions[].change_summary` | string | Description of changes |
| `revision_history.revisions[].note` | string | Authority reference (e.g., Ministerial Order) |

---

## 16. BC-Specific Content Identification

### The `source` Attribute

BC-specific content is identified by the `source` property set to `"bc"`:

```json
{
  "id": "nbc.divB.part10.sect1.art1",
  "type": "article",
  "source": "bc",
  "title": "BC-Specific Radon Requirements"
}
```

### Filtering BC Content

Applications can easily filter for BC-specific content:

```javascript
// Find all BC-specific articles
const bcArticles = articles.filter(art => art.source === 'bc');

// Find all original NBC articles (no source attribute or source="nbc")
const nbcArticles = articles.filter(art => !art.source || art.source === 'nbc');

// Display BC indicator badge
function renderArticle(article) {
  const bcBadge = article.source === 'bc'
    ? '<span class="badge badge-bc">BC</span>'
    : '';
  return `<div class="article">${bcBadge}${article.title}</div>`;
}
```

---

## 17. Standards Reference Mapping

The JSON includes a `standards` object that provides a complete mapping of all standard references found in the building code tables. This enables web applications to display detailed standard information in popups when users interact with standard references.

### Standards Object Structure

```json
"standards": {
  "aama501": {
    "standard_id": "aama501-05",
    "standard_ref_id": "aama501",
    "title": "Methods of Test for Exterior Walls",
    "full_title": "Methods of Test for Exterior Walls",
    "number": "501",
    "full_number": "501-05",
    "agency": "AAMA",
    "table_id": "nbc.divB.part1.sect3.subsect1.art2.table1",
    "location_id": "nbc.divB.part1.sect3.subsect1.art2"
  },
  "aama501.1": {
    "standard_id": "aama501.1-05",
    "standard_ref_id": "aama501.1",
    "title": "Standard Test Method for Water Penetration of Windows, Curtain Walls and Doors Using Dynamic Pressure",
    "full_title": "Standard Test Method for Water Penetration of Windows, Curtain Walls and Doors Using Dynamic Pressure",
    "number": "501.1",
    "full_number": "501.1-05",
    "agency": "AAMA",
    "table_id": "nbc.divB.part1.sect3.subsect1.art2.table1",
    "location_id": "nbc.divB.part1.sect3.subsect1.art2"
  }
}
```

### Standards Properties

| Property | Type | Description |
|----------|------|-------------|
| `standard_id` | string | Full standard identifier with version (e.g., `"aama501-05"`) |
| `standard_ref_id` | string | Base standard reference ID used as key (e.g., `"aama501"`) |
| `title` | string | Short title from StandRefTitle attribute |
| `full_title` | string | Complete title text from table entry |
| `number` | string | Base standard number (e.g., `"501"`) |
| `full_number` | string | Full standard number with version (e.g., `"501-05"`) |
| `agency` | string | Standards organization (e.g., `"AAMA"`, `"CSA"`, `"ASTM"`) |
| `table_id` | string | Canonical ID of the table containing this standard |
| `location_id` | string | Canonical ID of the article containing the table |

### Matching References to Standards

When rendering a `<ref type="standard">` element in the content:

```json
{
  "text": "Windows shall comply with [REF:standard:aama501]AAMA 501."
}
```

Look up the standard details using the reference ID:

```javascript
// Extract standard reference from text
const refPattern = /\[REF:standard:([^\]]+)\]/g;
const matches = text.matchAll(refPattern);

for (const match of matches) {
  const standardId = match[1]; // "aama501"
  const standardInfo = jsonData.standards[standardId];

  if (standardInfo) {
    // Display popup with standard details
    showStandardPopup(standardInfo);
  }
}
```

### Example: Standard Reference Popup

```javascript
function showStandardPopup(standard) {
  return `
    <div class="standard-popup">
      <div class="standard-header">
        <span class="standard-agency">${standard.agency}</span>
        <span class="standard-number">${standard.full_number}</span>
      </div>
      <div class="standard-title">${standard.full_title}</div>
      <div class="standard-footer">
        <a href="#${standard.table_id}">View in Standards Table</a>
      </div>
    </div>
  `;
}
```

### React Component Example

```jsx
function StandardReference({ standardId, standards, children }) {
  const [showPopup, setShowPopup] = useState(false);
  const standard = standards[standardId];

  if (!standard) {
    return <span>{children}</span>;
  }

  return (
    <span 
      className="standard-ref"
      onMouseEnter={() => setShowPopup(true)}
      onMouseLeave={() => setShowPopup(false)}
    >
      {children}
      {showPopup && (
        <div className="standard-popup">
          <div className="standard-header">
            <span className="standard-agency">{standard.agency}</span>
            <span className="standard-number">{standard.full_number}</span>
          </div>
          <div className="standard-title">{standard.full_title}</div>
          <div className="standard-footer">
            <a href={`#${standard.table_id}`}>View in Standards Table</a>
          </div>
        </div>
      )}
    </span>
  );
}
```

### Standards Statistics

The NBC 2020 contains approximately **506 unique standard references** in the standards mapping, covering organizations such as:
- AAMA (American Architectural Manufacturers Association)
- CSA (Canadian Standards Association)
- ASTM (American Society for Testing and Materials)
- ULC (Underwriters' Laboratories of Canada)
- NFPA (National Fire Protection Association)
- And many others

### Benefits

1. **Consistent Information**: All standard details come from authoritative standards tables
2. **Fast Lookup**: O(1) lookup time using standard reference ID as key
3. **Rich Metadata**: Includes agency, number, title, and location information
4. **Navigation**: Links back to source table for full context
5. **Similar to Glossary**: Follows the same pattern as the existing glossary feature

---

## 18. Statistics Section

The JSON includes document statistics for validation and reporting.

```json
"statistics": {
  "total_divisions": 3,
  "total_parts": 15,
  "total_sections": 125,
  "total_articles": 2847,
  "total_sentences": 15234,
  "total_tables": 156,
  "total_figures": 89,
  "total_spectables": 12,
  "total_application_notes": 234
}
```

---

## 19. Front Matter Structure

The front matter includes introductory content.

```json
"front_matter": {
  "id": "nbc.2020.frontmatter",
  "preface": {
    "id": "nbc.2020.preface",
    "type": "preface",
    "content": [
      {
        "type": "paragraph",
        "id": "nbc.2020.preface.para1",
        "content": "The BC Building Code of Canada 2020..."
      },
      {
        "type": "heading",
        "id": "nbc.2020.preface.div1.title",
        "content": "Development of the National Model Codes",
        "level": 2
      }
    ]
  },
  "introduction": { ... },
  "committees": { ... }
}
```

---

## 19. Deleted Content

Content deleted by BC amendments is marked with `deleted: true`:

```json
{
  "id": "nbc.divB.part3.sect1.art5.sent2",
  "type": "sentence",
  "number": 2,
  "deleted": true,
  "text": ""
}
```

Applications should:
- Hide deleted content from normal display
- Show deleted content in "show all changes" mode
- Include deletion tracking in audit reports

---

## 20. Working with the JSON

### Loading the JSON

```javascript
// Node.js
const fs = require('fs');
const bcCode = JSON.parse(fs.readFileSync('bc-building-code.json', 'utf8'));

// Browser (fetch)
const response = await fetch('bc-building-code.json');
const bcCode = await response.json();
```

### Navigating the Hierarchy

```javascript
// Get all parts in Division B
const divB = bcCode.divisions.find(d => d.letter === 'B');
const parts = divB.parts;

// Get all articles in Part 3, Section 1
const part3 = divB.parts.find(p => p.number === 3);
const section1 = part3.sections.find(s => s.number === 1);
const articles = section1.subsections.flatMap(sub => sub.articles);

// Find an article by ID
function findById(id) {
  // Recursive search through hierarchy
  function search(obj) {
    if (obj.id === id) return obj;
    for (const key of Object.keys(obj)) {
      if (Array.isArray(obj[key])) {
        for (const item of obj[key]) {
          const result = search(item);
          if (result) return result;
        }
      }
    }
    return null;
  }
  return search(bcCode);
}
```

### Date-Based Queries

```javascript
// Get content as of a specific date
function getContentAsOfDate(element, targetDate) {
  if (!element.revised || !element.revision_history) {
    return element.text || element.content;
  }

  const target = new Date(targetDate);
  const revisions = element.revision_history.revisions || [];

  // Find the applicable revision
  const applicableRevision = revisions
    .filter(r => new Date(r.effective_date) <= target)
    .sort((a, b) => new Date(b.effective_date) - new Date(a.effective_date))[0];

  if (applicableRevision) {
    return applicableRevision.content;
  }

  // Fall back to original if no revision applies
  return element.revision_history.original.content;
}
```

---

## 21. File Size and Performance

| Metric | Approximate Value |
|--------|-------------------|
| JSON file size | ~45 MB |
| Total elements | ~50,000+ |
| Load time (typical) | 2-5 seconds |
| Parse time (Node.js) | ~500ms |

### Performance Tips

1. **Use streaming parsers** for large datasets
2. **Index by ID** for quick lookups
3. **Cache parsed data** in memory
4. **Use pagination** for displaying large sections
5. **Consider GraphQL** for selective data loading

---

## 22. Figure (Image) Structure

Figures contain illustrations, diagrams, and images within the building code.

**Image Path Convention (IMPORTANT):**
- XML `src` attributes contain paths WITHOUT file extensions
- All paths are lowercase with hyphens
- Rendering layer appends `.jpg` (web) or `.eps` (print) as needed

### XML Representation

```xml
<figure xml:id="nbc.divA.part1.sect5.appnote6.figure1" vendor-id="en001231f1">
  <title>Application of the definition of grade</title>
  <!-- Note: No .eps extension, lowercase path -->
  <graphic src="graphics/eg/009/eg00907b" alt="Application of the definition of grade"/>
  <note>
    <para>See the definition of grade in Division A...</para>
  </note>
</figure>
```

### JSON Representation

```json
{
  "id": "nbc.divA.part1.sect5.appnote6.figure1",
  "type": "figure",
  "title": "Application of the definition of grade",
  "graphic": {
    "src": "graphics/eg/009/eg00907b",
    "alt_text": "Application of the definition of grade"
  },
  "source": "bc",
  "deleted": false,
  "notes": [
    {
      "type": "note",
      "content": "See the definition of grade in Division A..."
    }
  ]
}
```

### Figure Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Canonical ID for the figure |
| `type` | string | Always `"figure"` |
| `title` | string | Figure title/caption |
| `graphic` | object | Image details |
| `graphic.src` | string | Path to image WITHOUT extension (e.g., `"graphics/eg/009/eg00907b"`) |
| `graphic.alt_text` | string | Accessibility text for the image |
| `source` | string | `"bc"` if BC-specific (optional) |
| `deleted` | boolean | `true` if deleted by amendment (optional) |
| `notes` | array | Array of notes/captions (optional) |

### Image File Formats

The building code provides images in multiple formats:

| Format | Extension | Usage | Notes |
|--------|-----------|-------|-------|
| EPS | `.eps` | Vector graphics for print/PDF | High quality, scalable |
| JPG | `.jpg` | Raster graphics for web | Optimized for web display |

**Important:** The XML and JSON contain paths WITHOUT extensions. The rendering application must append the appropriate extension based on context:

```javascript
// Web application - append .jpg
const webImageSrc = graphic.src + '.jpg';  
// Result: "graphics/eg/009/eg00907b.jpg"

// PDF generator - append .eps
const printImageSrc = graphic.src + '.eps';  
// Result: "graphics/eg/009/eg00907b.eps"

// With fallback logic
function resolveImage(src, preferredFormat = 'jpg') {
    const path = src + '.' + preferredFormat;
    if (fileExists(path)) return path;
    // Fallback to other format
    const altFormat = preferredFormat === 'jpg' ? 'eps' : 'jpg';
    return src + '.' + altFormat;
}
```

### Figure Location in Hierarchy

Figures can appear in:
- Article content (`articles[].content[]`)
- Application notes (`application_notes[].content[]`)
- Appendices

```json
{
  "id": "nbc.divB.part3.sect1.art1",
  "type": "article",
  "content": [
    { "type": "sentence", "number": 1, "text": "..." },
    {
      "id": "nbc.divB.part3.sect1.art1.figure1",
      "type": "figure",
      "title": "Fire Separation Requirements",
      "graphic": {
        "src": "graphics/EG00123.eps",
        "alt_text": "Diagram showing fire separation requirements"
      }
    }
  ]
}
```

### Working with Figures

```javascript
// Extract all figures from an article
function getFigures(article) {
  return article.content.filter(item => item.type === 'figure');
}

// Convert EPS path to web-friendly format
function getWebImagePath(figure) {
  const src = figure.graphic.src;
  // Convert .eps to .png for web display
  return src.replace('.eps', '.png');
}

// Render figure with fallback
function renderFigure(figure) {
  const webPath = getWebImagePath(figure);
  return `
    <figure id="${figure.id}">
      <img src="${webPath}" alt="${figure.graphic.alt_text}" />
      <figcaption>${figure.title}</figcaption>
    </figure>
  `;
}
```

---

## 23. Equation Structure

Equations represent mathematical formulas using MathML, with conversions to LaTeX and plain text for different rendering needs.

### XML Representation

```xml
<sentence xml:id="nbc.divB.part4.sect1.subsect8.art5.sent1" vendor-id="es007652">
  <para>The <emph type="it">C</emph><sub>e</sub> factor in Sentence (1) shall
  be the greater of
  <equation type="display" image="eg02764a" image-src="graphics/eg02764a.eps">
    <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
      <msub><mi>C</mi><mi>e</mi></msub>
      <mo>=</mo>
      <msub><mi>C</mi><mi>s</mi></msub>
      <mfrac>
        <mrow><mn>60</mn><mo>°</mo><mo>−</mo><mi>α</mi></mrow>
        <mrow><mn>53</mn><mo>°</mo></mrow>
      </mfrac>
    </math>
  </equation>
  and 1.0, where...</para>
</sentence>
```

### JSON Representation

Equations are represented in two places in the JSON:

#### 1. Equation Object (in `equations` array)

```json
{
  "id": "eg02764a",
  "type": "display",
  "latex": "C_{e}=C_{s}\\frac{60\\text{°}-\\alpha}{53\\text{°}}",
  "plainText": "C_e = C_s × (60° - α) / 53°",
  "mathml": "<math xmlns=\"http://www.w3.org/1998/Math/MathML\" display=\"block\"><msub><mi>C</mi><mi>e</mi></msub><mo>=</mo>...</math>"
}
```

#### 2. Reference in Sentence Text

Sentence text uses a placeholder format to reference equations:

```json
{
  "id": "nbc.divB.part4.sect1.subsect8.art5.sent1",
  "type": "sentence",
  "text": "The C_e factor in Sentence (1) shall be the greater of [EQ:display:eg02764a] and 1.0, where..."
}
```

### Equation Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Equation identifier (e.g., `"eg02764a"`) |
| `type` | string | Display type: `"display"` (block) or `"inline"` |
| `latex` | string | LaTeX representation of the equation |
| `plainText` | string | Plain text approximation for accessibility |
| `mathml` | string | Serialized MathML markup |

### Equation Types

| Type | Description | Use Case |
|------|-------------|----------|
| `display` | Block-level equation, centered | Complex formulas, standalone equations |
| `inline` | Inline equation within text | Simple expressions within sentences |

### Equation Placeholder Format

The placeholder format in sentence text is:

```
[EQ:type:id]
```

Where:
- `type` is `display` or `inline`
- `id` is the equation identifier

### Working with Equations

```javascript
// Extract equations from JSON
function getEquations(json) {
  return json.equations || [];
}

// Find equation by ID
function findEquation(json, equationId) {
  return getEquations(json).find(eq => eq.id === equationId);
}

// Render equation placeholder in text
function renderTextWithEquations(sentence, equations) {
  let text = sentence.text;

  // Replace equation placeholders
  const eqPattern = /\[EQ:(display|inline):([^\]]+)\]/g;

  text = text.replace(eqPattern, (match, type, id) => {
    const equation = equations.find(eq => eq.id === id);
    if (!equation) return match;

    if (type === 'display') {
      // Render as block equation
      return `<div class="equation-block" data-latex="${equation.latex}">
        ${renderMathML(equation.mathml)}
      </div>`;
    } else {
      // Render as inline equation
      return `<span class="equation-inline" data-latex="${equation.latex}">
        ${renderMathML(equation.mathml)}
      </span>`;
    }
  });

  return text;
}

// Use MathJax or KaTeX to render LaTeX
function renderLatex(latex, displayMode) {
  // Using KaTeX
  return katex.renderToString(latex, {
    displayMode: displayMode,
    throwOnError: false
  });
}

// Parse MathML directly (for browsers that support it)
function renderMathML(mathml) {
  return mathml; // Browsers can render MathML directly
}
```

### Equation Rendering Options

Applications have three options for rendering equations:

| Method | Pros | Cons |
|--------|------|------|
| **MathML** | Native browser support, semantic | Limited browser support (Firefox best) |
| **LaTeX** | Wide library support (KaTeX, MathJax) | Requires JavaScript library |
| **Plain Text** | Universal, no dependencies | Limited visual accuracy |

### Example: Full Equation Rendering

```javascript
// Complete equation rendering with fallback
function renderEquation(equation) {
  const { id, type, latex, plainText, mathml } = equation;
  const isBlock = type === 'display';

  return `
    <div class="equation ${isBlock ? 'equation-block' : 'equation-inline'}"
         id="eq-${id}"
         aria-label="${plainText}">
      <!-- MathML for semantic browsers -->
      <span class="mathml-render">${mathml}</span>

      <!-- LaTeX for KaTeX/MathJax fallback -->
      <span class="latex-render" data-latex="${escapeHtml(latex)}"></span>

      <!-- Plain text for screen readers -->
      <span class="sr-only">${plainText}</span>
    </div>
  `;
}
```

### Equation Image Fallback

For environments that don't support MathML or JavaScript, the original XML includes image references:

```xml
<equation type="display" image="eg02764a" image-src="graphics/eg02764a.eps">
```

Applications can use these pre-rendered images as a fallback:

```javascript
// Fallback to pre-rendered image
function getEquationImage(equation) {
  return `graphics/${equation.id}.png`; // Assuming EPS converted to PNG
}
```

---

## 24. Special Content Elements Summary

This section summarizes all special content types that appear within the building code.

| Element Type | XML Element | JSON Type | Location |
|--------------|-------------|-----------|----------|
| Figure | `<figure>` | `"figure"` | Article content, appendices |
| Table | `<table>` | `"table"` | Article content |
| Equation | `<equation>` | `"equation"` | Within sentence text |
| Spectacle | `<spectacle>` | `"spectacle"` | Reference tables |
| Application Note | `<appnote>` | `"application_note"` | After articles |
| Note | `<note>` | `"note"` | Various locations |

### Content Type Detection

```javascript
// Detect content type and render appropriately
function renderContent(item) {
  switch (item.type) {
    case 'sentence':
      return renderSentence(item);
    case 'figure':
      return renderFigure(item);
    case 'table':
      return renderTable(item);
    case 'equation':
      return renderEquation(item);
    case 'application_note':
      return renderApplicationNote(item);
    case 'note':
      return renderNote(item);
    default:
      console.warn(`Unknown content type: ${item.type}`);
      return '';
  }
}
```

---

## Related Documentation

- [01-system-overview.md](01-system-overview.md) - Pipeline overview
- [03-revision-amendments-guide.md](03-revision-amendments-guide.md) - Revision history details
- [04-merge-engine-reference.md](04-merge-engine-reference.md) - Amendment processing
