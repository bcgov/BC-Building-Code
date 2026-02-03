# BC Building Code Amendment System - Quick Reference

A single-page reference for common amendment tasks.

---

## Amendment File Template

```xml
<?xml version="1.0" encoding="UTF-8"?>
<bc-overlay id="bc-part3-amendments-2023" version="1.0"
            nbc-target-version="2020" effective-date="2023-12-15">
    <metadata>
        <title>BC Building Code Amendments - Part 3</title>
        <description>BC-specific amendments for Part 3</description>
        <authority>Province of British Columbia</authority>
        <author>BC Building Code Team</author>
        <source-document>Source document reference</source-document>
    </metadata>
    <amendments>
        <!-- Amendments here -->
    </amendments>
</bc-overlay>
```

---

## Operation Syntax Quick Reference

### Replace

```xml
<amendment id="bc-001" sequence="1" description="Replace sentence">
    <target type="canonical-id" id="nbc.divB.part3.sect1.art1.sent1"/>
    <replace preserve-references="false">
        <new-content source="bc">
            <sentence xml:id="nbc.divB.part3.sect1.art1.sent1" number="1">
                <text>New content...</text>
            </sentence>
        </new-content>
    </replace>
</amendment>
```

### Insert

```xml
<amendment id="bc-002" sequence="2" description="Insert new article">
    <target type="position" parent-id="nbc.divB.part3.sect1"
            position="after" reference-id="nbc.divB.part3.sect1.art1"/>
    <insert>
        <new-content source="bc">
            <article xml:id="nbc.divB.part3.sect1.art2" number="2">
                <title>New Article</title>
                <sentence xml:id="nbc.divB.part3.sect1.art2.sent1" number="1">
                    <text>Content...</text>
                </sentence>
            </article>
        </new-content>
    </insert>
</amendment>
```

### Modify - Text Change

```xml
<amendment id="bc-003" sequence="3" description="Change word">
    <target type="canonical-id" id="nbc.divB.part3.sect1.art1.sent1"/>
    <modify>
        <text-change xpath-within-target="text()">
            <find-replace>
                <find>old text</find>
                <replace>new text</replace>
            </find-replace>
        </text-change>
    </modify>
</amendment>
```

### Modify - Element Replace

```xml
<amendment id="bc-004" sequence="4" description="Replace text element">
    <target type="canonical-id" id="nbc.divB.part3.sect1.art1.sent1"/>
    <modify>
        <element-replace element="text" position="1">
            <new-content source="bc">
                <text>Complete new text with <ref type="term" target="term">term</ref>...</text>
            </new-content>
        </element-replace>
    </modify>
</amendment>
```

### Delete

```xml
<amendment id="bc-005" sequence="5" description="Delete sentence">
    <target type="canonical-id" id="nbc.divB.part3.sect1.art1.sent2"/>
    <delete/>
</amendment>
```

### Child Element Target (for titles)

```xml
<amendment id="bc-006" sequence="6" description="Change title">
    <target type="child-element" parent-id="nbc.divB.part3.sect1"
            element-name="title" position="1"/>
    <replace>
        <new-content source="bc">
            <title>New Section Title</title>
        </new-content>
    </replace>
</amendment>
```

---

## Revision Amendment Template

```xml
<amendment id="bc-mo-2024-01-001" sequence="1000"
           description="Update with revision history">
    <target type="canonical-id" id="nbc.divB.part3.sect1.art1.sent1"/>
    <replace preserve-references="false">
        <new-content source="bc">
            <sentence xml:id="nbc.divB.part3.sect1.art1.sent1"
                      number="1" revised="yes">
                <revision-history>
                    <original effective-date="2020-12-01">
                        <!-- Auto-populated by merge engine -->
                    </original>
                    <revision seq="1" type="amendment" effective-date="2024-04-05"
                              id="bc-mo-2024-01-001" status="current">
                        <content>
                            <text>New content...</text>
                        </content>
                        <change-summary>Brief description</change-summary>
                        <note>Ministerial Order BA 2024 01</note>
                    </revision>
                </revision-history>
            </sentence>
        </new-content>
    </replace>
</amendment>
```

---

## Deletion with Revision History

```xml
<sentence xml:id="nbc.divB.part3.sect1.art1.sent2"
          number="2" revised="yes" deleted="yes">
    <revision-history>
        <original effective-date="2020-12-01"/>
        <revision seq="1" type="amendment" effective-date="2024-04-05"
                  id="bc-mo-2024-01-002" status="current">
            <content><!-- Empty = deleted --></content>
            <change-summary>Sentence deleted - reason here</change-summary>
            <note>Ministerial Order BA 2024 01</note>
        </revision>
    </revision-history>
</sentence>
```

---

## Target Types

| Type | Required Attributes | Use For |
|------|---------------------|---------|
| `canonical-id` | `id` | Direct element targeting |
| `position` | `parent-id`, `position` | Inserting content |
| `table-row-insert` | `table-id`, `position`, `match-row-containing` | Table rows |
| `list-item-insert` | `parent-id`, `position`, `match-item-containing` | List items |
| `child-element` | `parent-id`, `element-name` | Elements without IDs |
| `xpath` | `xpath` | XPath expression |

## Position Values

| Position | Description |
|----------|-------------|
| `first-child` | Insert as first child |
| `last-child` | Insert as last child |
| `before` | Insert before reference-id |
| `after` | Insert after reference-id |

---

## ID Conventions

### Element IDs (Unified nbc. prefix)

```
nbc.divA.part1.sect1.subsect1.art1.sent1.clause1.subclause1
```

### Amendment IDs

```
bc-001              (Overlay amendment)
bc-mo-2024-01-001   (Revision amendment: year-order-sequence)
```

### Sequence Numbers

- Overlay amendments: 1, 2, 3...
- Revision amendments: 1000, 1001, 1002...

---

## Revision Types

| Type | Use Case |
|------|----------|
| `amendment` | Ministerial orders |
| `errata` | Error corrections |
| `policy` | Policy changes |
| `accessibility` | Accessibility updates |
| `correction` | Minor corrections |

---

## Commands

### Phase 1: Overlay Amendments

```bash
# Combine
java -jar saxon.jar -xsl:combine-amendments.xsl \
  -s:amendment-list.xml -o:bc-amendments-combined.xml

# Apply
java -jar saxon.jar -xsl:merge-engine.xsl \
  -s:nbc-canonical.xml overlay-document=bc-amendments-combined.xml \
  -o:bc-building-code.xml
```

### Phase 2: Revision Amendments

```bash
# Combine
java -jar saxon.jar -xsl:combine-amendments.xsl \
  -s:revision-list.xml -o:bc-revisions-combined.xml

# Apply
java -jar saxon.jar -xsl:merge-engine.xsl \
  -s:bc-building-code.xml overlay-document=bc-revisions-combined.xml \
  -o:bc-building-code-final.xml
```

### Generate JSON

```bash
java -jar saxon.jar -xsl:canonical-to-json.xsl \
  -s:bc-building-code-final.xml -o:bc-building-code.json
```

### Validate

```bash
java -jar saxon.jar -xsl:validate-amendments.xsl \
  -s:bc-amendments-combined.xml -o:validation-report.html
```

---

## Common Patterns

### Add Reference to Existing Text

Use `text-change` if no `<ref>` elements in find text:
```xml
<find>the building shall</find>
<replace>the building shall (See Note A-3.1.1.)</replace>
```

### Change Measurement Value

Use `element-replace` (measurements are elements):
```xml
<element-replace element="text">
    <new-content source="bc">
        <text>not less than <measurement units="metric">500 mm</measurement></text>
    </new-content>
</element-replace>
```

### Add Clause to Sentence

Use `insert` with `position="last-child"`:
```xml
<target type="position" parent-id="nbc.divB...sent1" position="last-child"/>
<insert>
    <new-content source="bc">
        <clause xml:id="nbc.divB...sent1.clause_new" letter="d">
            <text>new clause text</text>
        </clause>
    </new-content>
</insert>
```

---

## Troubleshooting Quick Fixes

| Problem | Solution |
|---------|----------|
| "Modified text not found" | Use `element-replace` instead of `text-change` |
| Find text contains `<ref>` | Use `element-replace` |
| Self-closing `<ref/>` display name | Use `element-replace` |
| Multiple amendments same element | Combine into single `element-replace` |
| Duplicate ID error | Check ID doesn't exist, use unique IDs |
| Schema validation error | Check element structure in schema |

---

## Checklist Before Commit

- [ ] All IDs use `nbc.` prefix
- [ ] `source="bc"` on BC-specific `<new-content>`
- [ ] Unique amendment IDs
- [ ] Correct sequence numbers
- [ ] Clear descriptions
- [ ] Validation passes
- [ ] For revisions: `revised="yes"` attribute present
- [ ] For deletions: `deleted="yes"` and empty `<content>`
