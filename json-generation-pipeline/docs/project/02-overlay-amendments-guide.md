# Creating BC Amendments - Overlay Amendments Guide

This guide explains how to create **Phase 1 (Overlay) Amendments** that structurally modify the National Building Code to produce the BC Building Code.

---

## 1. Introduction to Overlay Amendments

### What Are Overlay Amendments?

Overlay amendments are XML files that describe **structural changes** to the NBC. They:
- Add new content (articles, sections, parts)
- Replace existing content with BC-specific versions
- Modify text within existing elements
- Delete content that doesn't apply to BC

### When to Use Overlay Amendments vs. Revision Amendments

| Use Overlay Amendments (Phase 1) | Use Revision Amendments (Phase 2) |
|----------------------------------|-----------------------------------|
| Adding new BC-specific content | Tracking changes over time |
| Replacing NBC content with BC version | Adding effective dates to changes |
| Modifying existing text | Ministerial order updates |
| One-time structural changes | Errata and corrections with history |

**Rule of thumb:** If you need to track *when* a change took effect, use revision amendments. Otherwise, use overlay amendments.

---

## 2. Amendment File Anatomy

### Basic Structure

Every overlay amendment file follows this structure:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<bc-overlay id="bc-part3-amendments-2023"
            version="1.0"
            nbc-target-version="2020"
            effective-date="2023-12-15">

    <metadata>
        <title>BC Building Code Amendments to NBC 2020 - Part 3</title>
        <description>British Columbia-specific amendments for Part 3</description>
        <authority>Province of British Columbia</authority>
        <author>BC Building Code Team</author>
        <source-document>NBC2020p1 Division B Part 3.FIN.docx</source-document>
    </metadata>

    <amendments>
        <!-- Individual amendments go here -->
    </amendments>
</bc-overlay>
```

### Attributes on `<bc-overlay>`

| Attribute | Required | Description |
|-----------|----------|-------------|
| `id` | Yes | Unique identifier for this amendment file |
| `version` | Yes | Version of this amendment file |
| `nbc-target-version` | Yes | NBC version being amended (e.g., "2020") |
| `effective-date` | No | When amendments become effective |

### Metadata Section

| Element | Description |
|---------|-------------|
| `<title>` | Human-readable title |
| `<description>` | What this amendment file does |
| `<authority>` | Legal authority (usually "Province of British Columbia") |
| `<author>` | Who created the amendments |
| `<source-document>` | Original source document reference |

### Individual Amendment Structure

```xml
<amendment id="bc-012" sequence="1"
           description="Add Article 3.1.2.7. to the list of exceptions">
    <target type="canonical-id" id="nbc.divB.part3.sect1.subsect2.art1.sent1"/>
    <replace preserve-references="true">
        <new-content source="bc">
            <!-- New content here -->
        </new-content>
    </replace>
</amendment>
```

### Amendment Attributes

| Attribute | Required | Description |
|-----------|----------|-------------|
| `id` | Yes | Unique identifier (e.g., `bc-012`) |
| `sequence` | Yes | Order of application (amendments applied in sequence order) |
| `description` | Yes | Human-readable description of what this amendment does |

---

## 3. Amendment Operations Reference

### Operation 1: Replace

**When to use:** Replace entire elements (sentences, articles, tables, sections)

**Syntax:**
```xml
<amendment id="bc-001" sequence="1"
           description="Replace Sentence 1 with detailed clauses">
    <target type="canonical-id" id="nbc.divA.part1.sect1.subsect1.art1.sent1"/>
    <replace preserve-references="false">
        <new-content source="bc">
            <sentence xml:id="nbc.divA.part1.sect1.subsect1.art1.sent1" number="1">
                <text>This Code applies to any one or more of the following:</text>
                <clause xml:id="nbc.divA.part1.sect1.subsect1.art1.sent1.clause1" letter="a">
                    <text>the design and construction of a new building,</text>
                </clause>
                <!-- More clauses... -->
            </sentence>
        </new-content>
    </replace>
</amendment>
```

**Key attribute - `preserve-references`:**
- `"true"` - Keep internal references from old content (useful when replacing sentences but keeping same ID)
- `"false"` - Don't preserve old references (use for complete replacements)

### Working Example: Replace Article with BC Requirements

From `NBC2020p1 Division B Part 3.FIN_1.xml`:

```xml
<amendment id="bc-018" sequence="7"
           description="Replace Article 3.1.4.8. with BC-specific exterior cladding requirements">
    <target type="canonical-id" id="nbc.divB.part3.sect1.subsect4.art8"/>
    <replace preserve-references="true">
        <new-content source="bc">
            <article xml:id="nbc.divB.part3.sect1.subsect4.art8" number="8">
                <title>Exterior Cladding</title>
                <sentence xml:id="nbc.divB.part3.sect1.subsect4.art8.sent1" number="1">
                    <text>Except as provided in Sentence (2), cladding on an exterior wall assembly...</text>
                    <clause xml:id="nbc.divB.part3.sect1.subsect4.art8.sent1.clause1" letter="a">
                        <text>noncombustible cladding, or</text>
                    </clause>
                    <clause xml:id="nbc.divB.part3.sect1.subsect4.art8.sent1.clause2" letter="b">
                        <text>a wall assembly that satisfies the criteria...</text>
                    </clause>
                </sentence>
                <!-- More sentences... -->
            </article>
        </new-content>
    </replace>
</amendment>
```

---

### Operation 2: Insert

**When to use:** Add new content (sentences, articles, tables, sections, entire parts)

**Position options:**
- `first-child` - Insert as first child of parent
- `last-child` - Insert as last child of parent
- `before` - Insert before a reference element
- `after` - Insert after a reference element

**Syntax for `after` position:**
```xml
<amendment id="bc-014" sequence="3"
           description="Add new sentence 2 for care facilities">
    <target type="position"
            parent-id="nbc.divB.part3.sect1.subsect2.art5"
            position="after"
            reference-id="nbc.divB.part3.sect1.subsect2.art5.sent1"/>
    <insert>
        <new-content source="bc">
            <sentence xml:id="nbc.divB.part3.sect1.subsect2.art5.sent2" number="2">
                <text>A care facility accepted for residential use...</text>
                <clause xml:id="nbc.divB.part3.sect1.subsect2.art5.sent2.clause1" letter="a">
                    <text>occupants live as a single housekeeping unit...</text>
                </clause>
                <!-- More clauses... -->
            </sentence>
        </new-content>
    </insert>
</amendment>
```

### Working Example: Insert New Article

From `NBC2020p1 Division B Part 3.FIN_1.xml`:

```xml
<amendment id="bc-015" sequence="4"
           description="Add new Article 3.1.2.7. for Group A, Division 2 low occupant load">
    <target type="position"
            parent-id="nbc.divB.part3.sect1.subsect2"
            position="after"
            reference-id="nbc.divB.part3.sect1.subsect2.art6"/>
    <insert>
        <new-content source="bc">
            <article xml:id="nbc.divB.part3.sect1.subsect2.art7" number="7">
                <title>Group A, Division 2, Low Occupant Load</title>
                <sentence xml:id="nbc.divB.part3.sect1.subsect2.art7.sent1" number="1">
                    <text>A suite of Group A, Division 2 assembly occupancy...</text>
                    <!-- Clauses... -->
                </sentence>
                <sentence xml:id="nbc.divB.part3.sect1.subsect2.art7.sent2" number="2">
                    <text>The fire separation required by Sentence (1)...</text>
                </sentence>
            </article>
        </new-content>
    </insert>
</amendment>
```

### Working Example: Chained Inserts (Referencing Newly Inserted Content)

When you need to insert multiple elements that reference each other, use sequence ordering:

```xml
<!-- First: Insert Article 3.1.2.7 -->
<amendment id="bc-015" sequence="4"
           description="Add new Article 3.1.2.7.">
    <target type="position"
            parent-id="nbc.divB.part3.sect1.subsect2"
            position="after"
            reference-id="nbc.divB.part3.sect1.subsect2.art6"/>
    <insert>
        <new-content source="bc">
            <article xml:id="nbc.divB.part3.sect1.subsect2.art7" number="7">
                <!-- Content -->
            </article>
        </new-content>
    </insert>
</amendment>

<!-- Second: Insert Article 3.1.2.8 after the newly inserted art7 -->
<amendment id="bc-016" sequence="5"
           description="Add new Article 3.1.2.8.">
    <target type="position"
            parent-id="nbc.divB.part3.sect1.subsect2"
            position="after"
            reference-id="nbc.divB.part3.sect1.subsect2.art7"/>  <!-- References bc-015's output -->
    <insert>
        <new-content source="bc">
            <article xml:id="nbc.divB.part3.sect1.subsect2.art8" number="8">
                <!-- Content -->
            </article>
        </new-content>
    </insert>
</amendment>
```

**Key point:** Amendment bc-016 (sequence="5") references the element inserted by bc-015 (sequence="4"). The merge engine applies amendments in sequence order, so this works correctly.

---

### Operation 3: Modify - Text Change

**When to use:** Small text edits without changing element structure

**Syntax:**
```xml
<amendment id="bc-013" sequence="2"
           description="Update Article 3.1.2.5. title">
    <target type="canonical-id" id="nbc.divB.part3.sect1.subsect2.art5"/>
    <modify>
        <text-change xpath-within-target=".//title">
            <find-replace>
                <find>Convalescent and Children's Custodial Homes</find>
                <replace>Convalescent, Children's Custodial, and Residential Care Homes</replace>
            </find-replace>
        </text-change>
    </modify>
</amendment>
```

### XPath Patterns for text-change

| Pattern | Use Case |
|---------|----------|
| `text()` | Direct text nodes in target element |
| `.//text()` | All descendant text nodes |
| `.//title` | Find title element within target |
| `.//element-name` | Any descendant element by name |
| `.//element-name[N]` | Nth occurrence of element |

### Working Example: Change Single Word

From `NBC2020p1 Division B Part 3.FIN_1.xml`:

```xml
<amendment id="bc-017" sequence="6"
           description="Change 'required to be' to 'permitted to be'">
    <target type="canonical-id" id="nbc.divB.part3.sect1.subsect4.art2.sent2"/>
    <modify>
        <text-change xpath-within-target="text()">
            <find-replace>
                <find>required to be of</find>
                <replace>permitted to be of</replace>
            </find-replace>
        </text-change>
    </modify>
</amendment>
```

---

### Operation 4: Modify - Element Replace

**When to use:** Replace child elements that don't have their own IDs, or when text-change fails because the find text contains XML elements (like `<ref>`).

**Why text-change fails with `<ref>` elements:**
The find text `"the <ref>building</ref> shall"` won't match because `<ref>` elements split the text into separate text nodes.

**Syntax:**
```xml
<amendment id="bc-044" sequence="44"
           description="Replace definition element">
    <target type="canonical-id" id="nbc.divA.part1.sect4.subsect1.art2.term15"/>
    <modify>
        <element-replace element="definition" position="1">
            <new-content source="bc">
                <definition>
                    <paragraph>
                        <text>A building or part of a building...</text>
                    </paragraph>
                </definition>
            </new-content>
        </element-replace>
    </modify>
</amendment>
```

**Attributes:**
- `element` - Name of the element to replace
- `position` - Which occurrence (1-based)

---

### Operation 5: Delete

**When to use:** Remove elements entirely from the code

**Syntax:**
```xml
<amendment id="bc-099" sequence="99"
           description="Delete sentence 3">
    <target type="canonical-id" id="nbc.divB.part3.sect1.subsect2.art5.sent3"/>
    <delete/>
</amendment>
```

**Warning:** Deletions are permanent in Phase 1. If you need to track deletion history (for date-based queries), use Phase 2 revision amendments with deletion tracking instead.

---

## 4. Special Cases

### Tables

Tables use CALS table format with specific structure:

```xml
<table xml:id="nbc.divA.part1.sect1.subsect1.art1.table1">
    <title>Table 1.1.1.1.(5) - BC Definitions</title>
    <ref type="internal" target="nbc.divA.part1.sect1.subsect1.art1.sent5" display-type="short"/>
    <tgroup cols="2">
        <colspec colname="1" colwidth="50*"/>
        <colspec colname="2" colwidth="50*"/>
        <thead>
            <row>
                <entry align="center">Term</entry>
                <entry align="center">Definition</entry>
            </row>
        </thead>
        <tbody>
            <row xml:id="nbc.divA.part1.sect1.subsect1.art1.table1.row1">
                <entry>Example Term</entry>
                <entry>Example definition text...</entry>
            </row>
            <!-- More rows... -->
        </tbody>
    </tgroup>
    <table-notes>
        <note xml:id="nbc.divA.part1.sect1.subsect1.art1.table1.note1">
            <text>Note text here...</text>
        </note>
    </table-notes>
</table>
```

**Key points:**
- Use `<tgroup>`, `<colspec>`, `<thead>`, `<tbody>` structure
- Table notes go in `<table-notes>` section
- Row IDs follow pattern: `...table1.row1`, `...table1.row2`

### Table Row Insertions

Use `type="table-row-insert"` to insert rows into existing tables:

```xml
<amendment id="bc-050" sequence="50"
           description="Insert new row after 'Fire-Resistance Rating'">
    <target type="table-row-insert"
            table-id="nbc.divB.part3.sect1.subsect3.art1.table1"
            position="after"
            match-row-containing="Fire-Resistance Rating"/>
    <insert>
        <new-content source="bc">
            <row xml:id="nbc.divB.part3.sect1.subsect3.art1.table1.row_new">
                <entry>New Row Content</entry>
                <entry>Value</entry>
            </row>
        </new-content>
    </insert>
</amendment>
```

### Figures and Graphics

**Image Naming Convention (IMPORTANT):**
- Use lowercase filenames with hyphens
- NO file extensions in XML `src` attributes
- Rendering layer appends `.jpg` (web) or `.eps` (print) as needed

```xml
<!-- CORRECT: Lowercase, no extension -->
<figure xml:id="nbc.divB.part3.sect1.appnote1.figure1">
    <title>Figure A-3.1.1.1. Example Diagram</title>
    <graphic src="bc-graphics/figure-a-3-1-1-1-example" alt="Description of the figure for accessibility"/>
</figure>

<!-- WRONG: Has extension -->
<graphic src="bc-graphics/figure-a-3-1-1-1-example.png" alt="..."/>

<!-- WRONG: Uppercase -->
<graphic src="bc-graphics/Figure-A-3.1.1.1-Example" alt="..."/>
```

**Key points:**
- Graphics path uses `bc-graphics/` folder for BC-specific images
- Graphics path uses `graphics/` folder for NBC images
- Always use lowercase with hyphens (e.g., `figure-a-9-23-13-7-4-a`)
- Never include file extensions (`.eps`, `.jpg`, `.png`) in XML
- Always include `<alt>` text for accessibility

### Application Notes

Application notes use `<application-note>` and `<note-division>` structure:

```xml
<application-note xml:id="nbc.divB.part3.sect1.appnote1">
    <number>A-3.1.1.1.</number>
    <title>Application Note Title</title>
    <note-division xml:id="nbc.divB.part3.sect1.appnote1.div1">
        <paragraph>
            <text>Explanatory text...</text>
        </paragraph>
    </note-division>
</application-note>
```

---

## 5. Global Text Replacements

### What Are Global Text Replacements?

Global text replacements are **pre-processing** operations that modify the source document *before* amendments are applied. They're useful for:
- Renumbering sections (e.g., changing 9.37 to 9.38)
- Bulk terminology changes
- Preparing the document for structural amendments

### Syntax

Add a `<text-replacements>` section at the top of the amendments section:

```xml
<amendments>
    <text-replacements>
        <replacement>
            <find-text>Section 9.37.</find-text>
            <replace-text>Section 9.38.</replace-text>
            <scope>global</scope>
        </replacement>
        <replacement>
            <find-text regex="true">Article 9\.37\.(\d+)\.</find-text>
            <replace-text>Article 9.38.$1.</replace-text>
            <scope>global</scope>
        </replacement>
    </text-replacements>

    <!-- Regular amendments follow -->
</amendments>
```

### Use Case: Renumbering for New Section Insert

When inserting a new section (e.g., Section 9.37) into Part 9, you need to:
1. Renumber existing Section 9.37 → 9.38, 9.38 → 9.39, etc.
2. Insert the new section
3. Update all cross-references

Global text replacements handle step 1 and 3, while regular insert amendments handle step 2.

---

## 6. Decision Guide: Choosing the Right Operation

```
Need to change content?
├── Adding completely new content?
│   └── INSERT (with position targeting)
│       └── Where does it go?
│           ├── After existing element? → position="after" + reference-id
│           ├── Before existing element? → position="before" + reference-id
│           ├── First child? → position="first-child"
│           └── Last child? → position="last-child"
│
├── Replacing entire element?
│   └── REPLACE
│       └── Does the new content reference existing elements?
│           ├── Yes → preserve-references="true"
│           └── No → preserve-references="false"
│
├── Small text edit?
│   ├── Does the find text contain <ref> or other elements?
│   │   └── Yes → MODIFY with element-replace
│   └── Plain text only?
│       └── MODIFY with text-change
│           └── What scope?
│               ├── Just the text node → xpath="text()"
│               ├── Specific child element → xpath=".//title"
│               └── Any text in descendants → xpath=".//text()"
│
├── Removing content entirely?
│   └── DELETE
│       └── Need to track history?
│           ├── Yes → Use Phase 2 revision amendment instead
│           └── No → DELETE operation is fine
│
└── Renumbering sections/articles?
    └── GLOBAL TEXT REPLACEMENTS + INSERT/MODIFY
```

---

## 7. Authoring Checklist

Before submitting an amendment, verify:

### ID Conventions
- [ ] All `xml:id` attributes use `nbc.` prefix (unified namespace)
- [ ] IDs follow hierarchical pattern: `nbc.divX.partN.sectN.subsectN.artN.sentN`
- [ ] No duplicate IDs within the file

### BC Content Identification
- [ ] `source="bc"` added to `<new-content>` for BC-specific content
- [ ] Merge engine will propagate source attribute to child elements

### Content Accuracy
- [ ] Numbering matches official source (article numbers, sentence numbers, clause letters)
- [ ] All `<ref>` elements have correct `target` attributes
- [ ] Measurements use `<measurement units="metric">` wrapper

### Amendment Structure
- [ ] Amendment has unique `id` attribute
- [ ] `sequence` number is appropriate for ordering
- [ ] `description` is clear and accurate
- [ ] Target type is correct (canonical-id, position, etc.)

### Testing
- [ ] Amendment validates against bc-overlay.rng schema
- [ ] Amendment applies without errors
- [ ] Output content is correct when viewed in bc-building-code.xml

---

## 8. Common Mistakes to Avoid

### Wrong: Using bc. prefix for IDs
```xml
<!-- WRONG -->
<article xml:id="bc.divB.part10.sect1.art1">
```

### Right: Using nbc. prefix with source attribute
```xml
<!-- CORRECT -->
<new-content source="bc">
    <article xml:id="nbc.divB.part10.sect1.art1">
```

### Wrong: Missing source attribute on BC content
```xml
<!-- WRONG - BC content won't be identified -->
<new-content>
    <article xml:id="nbc.divB.part10.sect1.art1">
```

### Right: Including source attribute
```xml
<!-- CORRECT -->
<new-content source="bc">
    <article xml:id="nbc.divB.part10.sect1.art1">
```

### Wrong: Using text-change when find text contains elements
```xml
<!-- WRONG - Will fail because <ref> splits text -->
<text-change xpath-within-target="text()">
    <find>the <ref type="term" target="bldng">building</ref> shall</find>
```

### Right: Using element-replace for complex content
```xml
<!-- CORRECT -->
<element-replace element="sentence" position="1">
    <new-content source="bc">
        <sentence>...</sentence>
    </new-content>
</element-replace>
```

---

## Next Steps

- **[03-revision-amendments-guide.md](03-revision-amendments-guide.md)** - Learn to create Phase 2 amendments with revision history
- **[04-merge-engine-reference.md](04-merge-engine-reference.md)** - Technical reference for all operations
- **[05-validation-troubleshooting.md](05-validation-troubleshooting.md)** - Fixing common errors
