# Merge Engine Operations Reference

This document provides a technical reference for all operations supported by the BC Building Code merge engine (`merge-engine-v3.xsl`).

---

## 1. Architecture Overview

### Single-Pass Optimization

The merge engine uses a **single-pass approach** with pre-indexed maps for O(1) lookups:

```
┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│   Pre-Process    │ →  │      Merge       │ →  │   Post-Process   │
│                  │    │                  │    │                  │
│ • Build ID maps  │    │ • Apply amends   │    │ • Clean up       │
│ • Index targets  │    │ • Process refs   │    │ • Validate       │
└──────────────────┘    └──────────────────┘    └──────────────────┘
```

### Processing Phases

1. **Pre-processing**
   - Builds maps of all element IDs
   - Indexes amendment targets
   - Applies global text replacements

2. **Merge**
   - Traverses source document
   - Applies amendments in sequence order
   - Propagates source attributes

3. **Post-processing**
   - Resolves cross-references
   - Validates output
   - Cleans up temporary markers

---

## 2. Target Types

The merge engine supports multiple ways to target elements for modification.

### Type: `canonical-id`

**Purpose:** Target an element directly by its unique ID

**Required Attributes:**
- `id` - The xml:id of the target element

**Example:**
```xml
<target type="canonical-id" id="nbc.divB.part3.sect1.subsect2.art1.sent1"/>
```

**Use when:** You know the exact ID of the element to modify.

---

### Type: `position`

**Purpose:** Insert content at a specific position relative to existing elements

**Required Attributes:**
- `parent-id` - The xml:id of the parent container
- `position` - Where to insert: `first-child`, `last-child`, `before`, `after`

**Optional Attributes:**
- `reference-id` - For `before`/`after`, the element to position relative to

**Examples:**

Insert as first child:
```xml
<target type="position"
        parent-id="nbc.divB.part3.sect1.subsect2"
        position="first-child"/>
```

Insert after specific element:
```xml
<target type="position"
        parent-id="nbc.divB.part3.sect1.subsect2.art5"
        position="after"
        reference-id="nbc.divB.part3.sect1.subsect2.art5.sent1"/>
```

---

### Type: `table-row-insert`

**Purpose:** Insert rows into existing tables

**Required Attributes:**
- `table-id` - The xml:id of the table
- `position` - Where to insert: `before`, `after`
- `match-row-containing` - Text to match for finding the reference row

**Example:**
```xml
<target type="table-row-insert"
        table-id="nbc.divB.part3.sect1.subsect3.art1.table1"
        position="after"
        match-row-containing="Fire-Resistance Rating"/>
```

---

### Type: `list-item-insert`

**Purpose:** Insert items into existing lists

**Required Attributes:**
- `parent-id` - The xml:id of the list or containing element
- `position` - Where to insert: `before`, `after`
- `match-item-containing` - Text to match for finding the reference item

**Example:**
```xml
<target type="list-item-insert"
        parent-id="nbc.divB.part3.sect1.art1.sent1"
        position="after"
        match-item-containing="clause (a)"/>
```

---

### Type: `child-element`

**Purpose:** Target child elements that don't have their own IDs (like `<title>`)

**Required Attributes:**
- `parent-id` - The xml:id of the parent element
- `element-name` - Name of the child element to target

**Optional Attributes:**
- `position` - Which occurrence (1-based, defaults to 1)

**Example:**
```xml
<target type="child-element"
        parent-id="nbc.divA.part1.sect1.subsect3"
        element-name="title"
        position="1"/>
```

**Use when:** Targeting elements like `<title>`, `<number>`, or other children without xml:id.

---

### Type: `xpath`

**Purpose:** Target elements using XPath expressions

**Required Attributes:**
- `xpath` - The XPath expression

**Example:**
```xml
<target type="xpath" xpath="//article[@number='7']/sentence[@number='1']"/>
```

**Warning:** Use sparingly. XPath targeting is less reliable than ID-based targeting and can break if document structure changes.

---

## 3. Operations

### Replace Operation

**Purpose:** Replace an element's content entirely

**Syntax:**
```xml
<replace preserve-references="true|false">
    <new-content source="bc">
        <!-- New element content -->
    </new-content>
</replace>
```

**Attributes:**
- `preserve-references` - Whether to keep internal references from old content
  - `"true"` - Preserve references (use when IDs stay the same)
  - `"false"` - Don't preserve (use for complete replacements)

**Example:**
```xml
<amendment id="bc-018" sequence="7"
           description="Replace Article 3.1.4.8.">
    <target type="canonical-id" id="nbc.divB.part3.sect1.subsect4.art8"/>
    <replace preserve-references="true">
        <new-content source="bc">
            <article xml:id="nbc.divB.part3.sect1.subsect4.art8" number="8">
                <title>Exterior Cladding</title>
                <sentence xml:id="nbc.divB.part3.sect1.subsect4.art8.sent1" number="1">
                    <text>New content...</text>
                </sentence>
            </article>
        </new-content>
    </replace>
</amendment>
```

---

### Insert Operation

**Purpose:** Add new content to the document

**Syntax:**
```xml
<insert>
    <new-content source="bc">
        <!-- New element(s) to insert -->
    </new-content>
</insert>
```

**Example:**
```xml
<amendment id="bc-015" sequence="4"
           description="Add new Article 3.1.2.7.">
    <target type="position"
            parent-id="nbc.divB.part3.sect1.subsect2"
            position="after"
            reference-id="nbc.divB.part3.sect1.subsect2.art6"/>
    <insert>
        <new-content source="bc">
            <article xml:id="nbc.divB.part3.sect1.subsect2.art7" number="7">
                <title>Group A, Division 2, Low Occupant Load</title>
                <sentence xml:id="nbc.divB.part3.sect1.subsect2.art7.sent1" number="1">
                    <text>Content...</text>
                </sentence>
            </article>
        </new-content>
    </insert>
</amendment>
```

---

### Modify Operation - text-change

**Purpose:** Make small text changes without replacing the entire element

**Syntax:**
```xml
<modify>
    <text-change xpath-within-target="...">
        <find-replace>
            <find>old text</find>
            <replace>new text</replace>
        </find-replace>
    </text-change>
</modify>
```

**XPath Patterns:**

| Pattern | Description |
|---------|-------------|
| `text()` | Direct text nodes in target element |
| `.//text()` | All descendant text nodes |
| `.//title` | Title element within target |
| `.//element-name` | Any descendant element by name |
| `.//element-name[N]` | Nth occurrence of element |

**Example:**
```xml
<amendment id="bc-017" sequence="6"
           description="Change 'required' to 'permitted'">
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

**Limitation:** Text-change fails when the find text spans XML element boundaries (e.g., contains `<ref>` elements). Use element-replace instead.

---

### Modify Operation - element-replace

**Purpose:** Replace child elements when text-change can't work

**Syntax:**
```xml
<modify>
    <element-replace element="element-name" position="N">
        <new-content source="bc">
            <!-- Replacement element -->
        </new-content>
    </element-replace>
</modify>
```

**Attributes:**
- `element` - Name of the element to replace
- `position` - Which occurrence (1-based)

**Example:**
```xml
<amendment id="bc-044" sequence="44"
           description="Replace definition element">
    <target type="canonical-id" id="nbc.divA.part1.sect4.subsect1.art2.term15"/>
    <modify>
        <element-replace element="definition" position="1">
            <new-content source="bc">
                <definition>
                    <paragraph>
                        <text>New definition text...</text>
                    </paragraph>
                </definition>
            </new-content>
        </element-replace>
    </modify>
</amendment>
```

---

### Delete Operation

**Purpose:** Remove an element from the document

**Syntax:**
```xml
<delete/>
```

**Example:**
```xml
<amendment id="bc-099" sequence="99"
           description="Delete sentence 3">
    <target type="canonical-id" id="nbc.divB.part3.sect1.subsect2.art5.sent3"/>
    <delete/>
</amendment>
```

**Note:** For Phase 2 amendments with historical tracking, use revision history with `deleted="yes"` instead of direct deletion.

---

## 4. Position Options

When using `type="position"` targeting:

| Position | Description |
|----------|-------------|
| `first-child` | Insert as first child of parent |
| `last-child` | Insert as last child of parent |
| `before` | Insert before reference element (requires `reference-id`) |
| `after` | Insert after reference element (requires `reference-id`) |

---

## 5. Global Text Replacements

### What They Are

Global text replacements are **pre-processing** operations applied to the source document before any amendments.

### Syntax

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

    <!-- Regular amendments -->
</amendments>
```

### Attributes

| Element | Description |
|---------|-------------|
| `<find-text>` | Text to find (literal or regex) |
| `<replace-text>` | Replacement text |
| `<scope>` | Scope: `global` for entire document |

Add `regex="true"` attribute to `<find-text>` for regex patterns.

### Use Cases

- Renumbering sections when inserting new content
- Bulk terminology changes
- Cross-reference updates

---

## 6. Reference Updates

### Purpose

Handle cross-reference updates when IDs change.

### Syntax

```xml
<reference-updates>
    <update old-target="nbc.divB.part3.sect1.art5"
            new-target="nbc.divB.part3.sect1.art6"/>
</reference-updates>
```

---

## 7. Dependent Amendment Chaining

Amendments can reference content created by earlier amendments in the same file.

### How It Works

1. Amendments are applied in `sequence` order
2. Later amendments can reference IDs created by earlier amendments
3. The merge engine processes amendments incrementally

### Example

```xml
<!-- Sequence 4: Insert Article 3.1.2.7 -->
<amendment id="bc-015" sequence="4" ...>
    <target type="position"
            parent-id="nbc.divB.part3.sect1.subsect2"
            position="after"
            reference-id="nbc.divB.part3.sect1.subsect2.art6"/>
    <insert>
        <new-content source="bc">
            <article xml:id="nbc.divB.part3.sect1.subsect2.art7" number="7">
                ...
            </article>
        </new-content>
    </insert>
</amendment>

<!-- Sequence 5: Insert Article 3.1.2.8 after the newly created art7 -->
<amendment id="bc-016" sequence="5" ...>
    <target type="position"
            parent-id="nbc.divB.part3.sect1.subsect2"
            position="after"
            reference-id="nbc.divB.part3.sect1.subsect2.art7"/>  <!-- Created by bc-015 -->
    <insert>
        <new-content source="bc">
            <article xml:id="nbc.divB.part3.sect1.subsect2.art8" number="8">
                ...
            </article>
        </new-content>
    </insert>
</amendment>
```

**Key point:** Amendment bc-016 (sequence 5) references `art7` which was created by bc-015 (sequence 4).

---

## 8. Source Attribute Propagation

### How It Works

When you add `source="bc"` to a `<new-content>` element, the merge engine automatically propagates this attribute to all **structural child elements**.

### Supported Structural Elements

The `source` attribute is propagated to:
- `division`
- `part`
- `section`
- `subsection`
- `article`
- `sentence`
- `clause`
- `subclause`
- `table`
- `figure`
- `application-note`
- `note-division`
- `spectables`

### Example

```xml
<new-content source="bc">
    <article xml:id="nbc.divB.part10.sect1.art1" number="1">
        <sentence xml:id="nbc.divB.part10.sect1.art1.sent1" number="1">
            <text>...</text>
        </sentence>
    </article>
</new-content>
```

After processing, both the `<article>` and `<sentence>` will have `source="bc"` attribute.

### JSON Output

The source attribute appears in JSON output:

```json
{
  "id": "nbc.divB.part10.sect1.art1",
  "type": "article",
  "source": "bc",
  "content": [
    {
      "id": "nbc.divB.part10.sect1.art1.sent1",
      "type": "sentence",
      "source": "bc",
      "text": "..."
    }
  ]
}
```

### Filtering BC Content

Applications can filter BC-specific content:

```javascript
const bcContent = code.articles.filter(art => art.source === 'bc');
```

---

## 9. Processing Order

The merge engine processes in this order:

1. **Global text replacements** (if any)
2. **Amendments in sequence order** (lowest sequence first)
3. **Reference updates** (if any)
4. **Source attribute propagation**
5. **Validation and cleanup**

**Important:** Sequence numbers determine processing order, not document order.

---

## 10. Common Patterns Quick Reference

| Need to... | Use |
|------------|-----|
| Replace entire element | `<replace>` with `canonical-id` target |
| Add new element | `<insert>` with `position` target |
| Change small text | `<modify>` + `<text-change>` |
| Replace child without ID | `<modify>` + `<element-replace>` |
| Remove element | `<delete>` |
| Insert table row | `table-row-insert` target |
| Modify title | `child-element` target |
| Renumber sections | Global text replacements |

---

## Next Steps

- **[05-validation-troubleshooting.md](05-validation-troubleshooting.md)** - Fixing common errors
- **[06-quick-reference.md](06-quick-reference.md)** - Printable reference card
- **[07-examples-library.md](07-examples-library.md)** - Working examples for each operation
