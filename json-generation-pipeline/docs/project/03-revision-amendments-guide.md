# Creating Revision Amendments Guide

This guide explains how to create **Phase 2 (Revision) Amendments** for tracking date-based changes to the BC Building Code, such as ministerial orders, errata, and policy updates.

---

## 1. Introduction to Revision Amendments

### What Are Revision Amendments?

Revision amendments add **revision history** to elements, enabling:
- Date-based queries ("What did the code say on January 1, 2024?")
- Change tracking over time
- Audit trails for regulatory compliance

Unlike overlay amendments (Phase 1), revision amendments don't just change content—they **preserve the history** of what changed and when.

### Difference from Overlay Amendments

| Aspect | Overlay Amendments (Phase 1) | Revision Amendments (Phase 2) |
|--------|------------------------------|-------------------------------|
| **Purpose** | Structural modifications | Historical tracking |
| **Source document** | nbc-canonical.xml | bc-building-code.xml |
| **Content history** | No (replaces content) | Yes (keeps original) |
| **Effective date tracking** | No | Yes |
| **Use case** | "What BC requires" | "What BC required on [date]" |

### When to Use Revision Amendments

Use revision amendments for:
- Ministerial orders with specific effective dates
- Errata corrections
- Policy changes
- Accessibility updates
- Any change where you need to track when it took effect

### Important: Target Document

**Revision amendments target `bc-building-code.xml`**, NOT `nbc-canonical.xml`.

This is because revision amendments are applied in Phase 2, **after** overlay amendments have already transformed the NBC into the BC Building Code.

---

## 2. Revision History Structure

### The `<revision-history>` Element

When an element has revision history, it contains:

```xml
<sentence xml:id="nbc.divB.part3.sect1.subsect2.art1.sent1" number="1" revised="yes">
    <revision-history>
        <!-- Original content (auto-populated by merge engine) -->
        <original effective-date="2020-12-01">
            <!-- Merge engine copies content from bc-building-code.xml -->
        </original>

        <!-- Revision with new content -->
        <revision seq="1" type="amendment" effective-date="2024-04-05"
                  id="bc-mo-2024-01-011" status="current">
            <content>
                <!-- Complete content as of this revision -->
                <text>New sentence text...</text>
            </content>
            <change-summary>Brief description of what changed</change-summary>
            <note>Ministerial Order BA 2024 01</note>
        </revision>
    </revision-history>
</sentence>
```

### Key Attributes

**On the parent element:**
- `revised="yes"` - Flags that this element has revision history

**On `<original>`:**
- `effective-date` - When the original content took effect (usually NBC publication date)

**On `<revision>`:**
| Attribute | Required | Description |
|-----------|----------|-------------|
| `seq` | Yes | Sequence number for ordering (1, 2, 3...) |
| `type` | Yes | Category: amendment, errata, policy, accessibility, correction |
| `effective-date` | Yes | When this revision takes effect |
| `id` | Yes | Links to amendment record (e.g., `bc-mo-2024-01-011`) |
| `status` | Yes | `current` or `superseded` |

### The Snapshot Approach

The revision history uses a **snapshot approach**:
- Each revision contains the **complete content** at that point in time
- The merge engine **auto-populates** the `<original>` element
- Display content is derived from the revision with `status="current"`

**You don't need to copy the original content yourself.** Just leave `<original>` empty and the merge engine fills it in.

---

## 3. Revision Attributes Reference

### Revision Types

| Type | Use Case |
|------|----------|
| `amendment` | Ministerial orders, code changes |
| `errata` | Corrections to errors in published code |
| `policy` | Policy directive changes |
| `accessibility` | Accessibility-related updates |
| `correction` | Minor corrections |

### Status Values

| Status | Meaning |
|--------|---------|
| `current` | This is the active revision |
| `superseded` | This revision has been replaced by a newer one |

Only **one revision** should have `status="current"` at any time.

---

## 4. Amendment File Template

### Basic File Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<bc-overlay id="bc-mo-ba-2024-01" version="1.0" nbc-target-version="2020"
            effective-date="2024-04-05">

  <metadata>
    <title>Ministerial Order BA 2024 01</title>
    <description>Description of amendments</description>
    <authority>BC Ministry of Housing - Building and Safety Standards Branch</authority>
    <author>BC Building and Safety Standards Branch</author>
    <source-document>Ministerial Order BA 2024 01</source-document>
  </metadata>

  <amendments>
    <!-- Individual amendments go here -->
  </amendments>
</bc-overlay>
```

### Individual Amendment Structure

```xml
<amendment id="bc-mo-2024-01-011" sequence="1010"
           description="Change reference from 3.2.2.92 to 3.2.2.93">
    <target type="canonical-id" id="nbc.divB.part3.sect2.subsect3.art9.sent1"/>
    <replace preserve-references="false">
        <new-content source="bc">
            <sentence xml:id="nbc.divB.part3.sect2.subsect3.art9.sent1"
                      number="1" revised="yes">
                <revision-history>
                    <original effective-date="2020-12-01">
                        <!-- Leave empty - merge engine auto-populates -->
                    </original>

                    <revision seq="1" type="amendment" effective-date="2024-04-05"
                              id="bc-mo-2024-01-011" status="current">
                        <content>
                            <text>New sentence content here...</text>
                        </content>
                        <change-summary>Changed reference from 3.2.2.92 to 3.2.2.93</change-summary>
                        <note>Ministerial Order BA 2024 01</note>
                    </revision>
                </revision-history>
            </sentence>
        </new-content>
    </replace>
</amendment>
```

### ID Conventions

**Amendment IDs:**
- Format: `bc-mo-YYYY-NN-XXX`
- Example: `bc-mo-2024-01-038`
  - `YYYY` = Year (2024)
  - `NN` = Ministerial order number (01)
  - `XXX` = Sequential amendment number (038)

**Sequence Numbers:**
- Start at 1000+ for revision amendments
- Increment by 1 for each amendment
- Example: 1000, 1001, 1002...

---

## 5. Revision Amendment Patterns

### Pattern 1: Simple Text Change with Revision History

**Use case:** Change a reference number or single word/phrase

```xml
<amendment id="bc-mo-2024-01-011" sequence="1010"
           description="Change reference from 3.2.2.92 to 3.2.2.93">
    <target type="canonical-id" id="nbc.divB.part3.sect2.subsect3.art9.sent1"/>
    <replace preserve-references="false">
        <new-content source="bc">
            <sentence xml:id="nbc.divB.part3.sect2.subsect3.art9.sent1"
                      number="1" revised="yes">
                <revision-history>
                    <original effective-date="2020-12-01">
                        <!-- Auto-populated -->
                    </original>
                    <revision seq="1" type="amendment" effective-date="2024-04-05"
                              id="bc-mo-2024-01-011" status="current">
                        <content>
                            <text>Updated text with 3.2.2.93 reference...</text>
                        </content>
                        <change-summary>Changed reference from 3.2.2.92 to 3.2.2.93</change-summary>
                        <note>Ministerial Order BA 2024 01</note>
                    </revision>
                </revision-history>
            </sentence>
        </new-content>
    </replace>
</amendment>
```

### Pattern 2: Table Row Update with Revision History

**Use case:** Update specific rows in a reference table

From `Ministerial Order BA 2024 01.xml`:

```xml
<amendment id="bc-mo-2024-01-001" sequence="1000"
           description="Add 3.1.6.6.(6)(c) to ASTM C840-18b Code Reference column">
    <target type="canonical-id" id="nbc.divB.part1.sect3.subsect1.art2.table1.row64"/>
    <replace preserve-references="true">
        <new-content source="bc">
            <row xml:id="nbc.divB.part1.sect3.subsect1.art2.table1.row64">
                <entry>ASTM</entry>
                <entry>C840-18b</entry>
                <entry>Standard Specification for Application and Finishing of Gypsum Board</entry>
                <entry revised="yes">
                    <revision-history>
                        <original effective-date="2020-12-01">
                            <!-- Auto-populated -->
                        </original>
                        <revision seq="1" type="amendment" effective-date="2024-04-05"
                                  id="bc-mo-2024-01-001" status="current">
                            <content>
                                <ref type="internal" target="nbc.divB.part3.sect1.subsect6.art6.sent2" display-type="number"/>
                                <ref type="internal" target="nbc.divB.part3.sect1.subsect6.art6.sent6.clause3" display-type="number"/>
                                <!-- More references... -->
                            </content>
                            <change-summary>Added 3.1.6.6.(6)(c) to Code Reference</change-summary>
                            <note>Ministerial Order BA 2024 01</note>
                        </revision>
                    </revision-history>
                </entry>
            </row>
        </new-content>
    </replace>
</amendment>
```

**Key point:** Only the `<entry>` that changes gets `revised="yes"` and `<revision-history>`. The other entries stay unchanged.

### Pattern 3: Replace Clause with Revision History

From `Ministerial Order BA 2024 06.xml`:

```xml
<amendment id="bc-mo-2024-06-002" sequence="4001"
           description="Amend Clause 1.1.1.1.(2)(a)">
    <target type="canonical-id" id="nbc.divA.part1.sect1.subsect1.art1.sent2.clause1"/>
    <replace preserve-references="false">
        <new-content source="bc">
            <clause xml:id="nbc.divA.part1.sect1.subsect1.art1.sent2.clause1"
                    letter="a" revised="yes">
                <revision-history>
                    <original effective-date="2020-12-01">
                        <!-- Merge engine will auto-populate -->
                    </original>
                    <revision seq="1" type="amendment" effective-date="2025-06-16"
                              id="bc-mo-2024-06-002" status="current">
                        <content>
                            <text><ref type="term" target="swg">sewage</ref>, water, electrical,
                            telephone, rail or similar public infrastructure systems...</text>
                        </content>
                        <change-summary>Amended by striking out "sewage" and substituting "sewage"</change-summary>
                        <note>Ministerial Order BA 2024 06</note>
                    </revision>
                </revision-history>
            </clause>
        </new-content>
    </replace>
</amendment>
```

### Pattern 4: Child Element Amendment (Titles Without IDs)

**Use case:** Amend elements like `<title>` that don't have their own IDs

Use `type="child-element"` targeting:

```xml
<amendment id="bc-mo-2024-06-007" sequence="4006"
           description="Amend Subsection 1.1.3. title">
    <target type="child-element"
            parent-id="nbc.divA.part1.sect1.subsect3"
            element-name="title"
            position="1"/>
    <replace preserve-references="false">
        <new-content source="bc">
            <title revised="yes">
                <revision-history>
                    <original effective-date="2020-12-01">
                        <!-- Merge engine auto-populates original title -->
                    </original>
                    <revision seq="1" type="amendment" effective-date="2025-06-16"
                              id="bc-mo-2024-06-007" status="current">
                        <content>Notes</content>
                        <change-summary>Amended title by striking out "Appendices," and "and Annotations"</change-summary>
                        <note>Ministerial Order BA 2024 06</note>
                    </revision>
                </revision-history>
            </title>
        </new-content>
    </replace>
</amendment>
```

**Key attributes:**
- `type="child-element"` - Indicates targeting a child element
- `parent-id` - The xml:id of the parent element
- `element-name` - Name of the child element (e.g., "title")
- `position` - Which occurrence (1-based, defaults to 1)

---

## 6. Finding Element IDs

### Step 1: Search bc-building-code.xml (NOT nbc-canonical.xml)

Remember: Revision amendments target `bc-building-code.xml` because they're applied in Phase 2.

### Step 2: Use Grep/Search

```bash
# Find by article number pattern
grep -n "part3.sect2.subsect5.art7" bc-building-code.xml

# Find by sentence number
grep -n "3\.2\.5\.7\.\(2\)" bc-building-code.xml

# Find by table ID
grep -n "sect1.subsect3.art1.table1" bc-building-code.xml
```

### Step 3: Extract the xml:id

Look for the `xml:id` attribute:

```xml
<sentence xml:id="nbc.divB.part3.sect2.subsect5.art7.sent2" number="2" ...>
```

The target ID is: `nbc.divB.part3.sect2.subsect5.art7.sent2`

---

## 7. Multiple Revisions on Same Element

When an element is revised multiple times over time:

```xml
<sentence xml:id="nbc.divB.part3.sect1.art1.sent1" number="1" revised="yes">
    <revision-history>
        <original effective-date="2020-12-01">
            <!-- Original NBC content -->
        </original>

        <!-- First revision - now superseded -->
        <revision seq="1" type="amendment" effective-date="2024-04-05"
                  id="bc-mo-2024-01-011" status="superseded">
            <content>...</content>
            <change-summary>First change</change-summary>
            <note>Ministerial Order BA 2024 01</note>
        </revision>

        <!-- Second revision - current -->
        <revision seq="2" type="amendment" effective-date="2025-06-16"
                  id="bc-mo-2024-06-015" status="current">
            <content>...</content>
            <change-summary>Second change</change-summary>
            <note>Ministerial Order BA 2024 06</note>
        </revision>
    </revision-history>
</sentence>
```

**Key points:**
- Earlier revisions change to `status="superseded"`
- Only the latest revision has `status="current"`
- Sequence numbers increment (1, 2, 3...)
- All revisions are preserved for historical queries

---

## 8. Deletion Tracking

### Overview

When content is **deleted** (not just modified), use the `deleted="yes"` attribute with an empty `<content>` element in the revision.

### Supported Element Types

The `deleted="yes"` attribute can be applied to:
- Sentences
- Clauses
- Subclauses
- Articles
- Sections
- Subsections
- Tables
- Table rows
- Figures
- Application notes

### XML Representation

```xml
<amendment id="bc-mo-2024-06-134" sequence="4104"
           description="Delete Table 9.38.1.1. row for Article 9.8.5.5.">
    <target type="canonical-id" id="nbc.divBV2.part9.sect38.subsect1.art1.table1.row393"/>
    <replace preserve-references="false">
        <new-content source="bc">
            <row xml:id="nbc.divBV2.part9.sect38.subsect1.art1.table1.row393"
                 revised="yes" deleted="yes">
                <revision-history>
                    <original effective-date="2020-12-01">
                        <!-- Merge engine will auto-populate original content -->
                    </original>
                    <revision seq="1" type="amendment" effective-date="2025-06-16"
                              id="bc-mo-2024-06-134" status="current">
                        <content>
                            <!-- Empty content indicates deletion -->
                        </content>
                        <change-summary>Row deleted - Article 9.8.5.5. entry removed from table</change-summary>
                        <note>Ministerial Order BA 2024 06</note>
                    </revision>
                </revision-history>
            </row>
        </new-content>
    </replace>
</amendment>
```

### Key Points for Deletions

1. **Use `deleted="yes"` on the element** - This marks the element as deleted
2. **Use `revised="yes"`** - The element still has revision history
3. **Leave `<content>` empty** - An empty content element indicates deletion
4. **Provide clear change-summary** - Explain why the deletion occurred
5. **Include ministerial order reference** - In the `<note>` element

### JSON Output for Deletions

The JSON output will include:

```json
{
  "id": "nbc.divBV2.part9.sect38.subsect1.art1.table1.row393",
  "type": "row",
  "deleted": true,
  "revisions": [
    {
      "type": "original",
      "effective_date": "2020-12-01",
      "content": "..."
    },
    {
      "type": "revision",
      "revision_type": "amendment",
      "revision_id": "bc-mo-2024-06-134",
      "sequence": 1,
      "effective_date": "2025-06-16",
      "status": "current",
      "deleted": true,
      "change_summary": "Row deleted - Article 9.8.5.5. entry removed from table",
      "note": "Ministerial Order BA 2024 06"
    }
  ]
}
```

### Use Cases for Applications

**Filtering deleted content:**
```javascript
const activeRows = table.rows.filter(row => !row.deleted);
```

**Showing deletion history:**
```javascript
const deletedItems = element.revisions.filter(rev =>
  rev.deleted && rev.type === 'revision'
);
```

**Date-based queries:**
```javascript
function getContentAtDate(element, targetDate) {
  // Find the applicable revision for the date
  const applicableRevision = element.revisions
    .filter(rev => rev.effective_date <= targetDate)
    .sort((a, b) => b.effective_date.localeCompare(a.effective_date))[0];

  // If deleted at that date, return null
  if (applicableRevision?.deleted) return null;

  return element;
}
```

### Best Practices for Deletions

1. **Always use revision history** when deleting - Don't just remove the element
2. **Provide clear change summaries** - Explain why the deletion occurred
3. **Include ministerial order references** - For audit trail
4. **Don't permanently remove elements** - They stay in the XML with `deleted="yes"`

---

## 9. Execution Commands

### Combine Revision Files

```bash
java -jar xmlToJson/saxon.jar \
  -xsl:proposed/combine-amendments.xsl \
  -s:proposed/revision-list.xml \
  -o:bc-revisions-combined.xml
```

### Apply Revisions

```bash
java -jar xmlToJson/saxon.jar \
  -xsl:proposed/merge-engine.xsl \
  -s:bc-building-code.xml \
  overlay-document=bc-revisions-combined.xml \
  -o:bc-building-code-final.xml
```

### Validate Revisions

```bash
java -jar xmlToJson/saxon.jar \
  -xsl:proposed/validate-amendments.xsl \
  -s:bc-revisions-combined.xml \
  combined-amendments=bc-revisions-combined.xml \
  bc-building-code=bc-building-code-final.xml \
  -o:revision-validation-report.html
```

---

## 10. Authoring Checklist

Before submitting a revision amendment:

### Structure
- [ ] Amendment has unique `id` (format: bc-mo-YYYY-NN-XXX)
- [ ] `sequence` number starts at 1000+
- [ ] `description` clearly states what changes
- [ ] Target type and ID are correct

### Revision History
- [ ] Parent element has `revised="yes"`
- [ ] `<original>` element present (can be empty)
- [ ] `<revision>` has all required attributes (seq, type, effective-date, id, status)
- [ ] `<content>` contains complete new content (or empty for deletions)
- [ ] `<change-summary>` clearly describes the change
- [ ] `<note>` references the ministerial order

### For Deletions
- [ ] Element has `deleted="yes"` attribute
- [ ] `<content>` is empty
- [ ] Change summary explains deletion reason

### ID Conventions
- [ ] All `xml:id` attributes use `nbc.` prefix
- [ ] `source="bc"` on `<new-content>` for BC-specific content

---

## Next Steps

- **[04-merge-engine-reference.md](04-merge-engine-reference.md)** - Technical reference for all operations
- **[05-validation-troubleshooting.md](05-validation-troubleshooting.md)** - Fixing common errors
- **[07-examples-library.md](07-examples-library.md)** - More working examples
