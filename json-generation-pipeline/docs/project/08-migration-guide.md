# BC Prefix to Source Attribute Migration Guide

This document describes the migration from the `bc.` prefix approach to the unified `nbc.` namespace with `source="bc"` attribute for identifying BC-specific content.

**Migration Completed:** 2026-02-02

---

## 1. Migration Overview

### The Problem

Previously, BC-specific content used a separate `bc.` prefix for IDs:
- NBC content: `nbc.divB.part3.sect1.art1`
- BC content: `bc.divB.part10.sect1.art1`

This caused **cross-namespace reference issues**:
```xml
<!-- BC content trying to reference NBC content -->
<sentence xml:id="bc.divB.part10.sect1.art1.sent1">
    <text>See <ref target="nbc.divB.part3.sect1">Part 3</ref></text>
</sentence>
```

The reference from `bc.divB...` to `nbc.divB...` crossed namespaces, causing validation and resolution issues.

### The Solution

**Unified namespace with source attribute:**
- All IDs use `nbc.` prefix
- BC-specific content identified by `source="bc"` attribute
- Merge engine propagates source attribute to all structural children

### Migration Status

| Phase | Description | Status |
|-------|-------------|--------|
| Phase 1 | Schema Updates | ✅ Complete |
| Phase 2 | Merge Engine Updates | ✅ Complete |
| Phase 3 | JSON Generation Updates | ✅ Complete |
| Phase 4 | Amendment File Migration | ✅ Complete |
| Phase 5 | Testing & Validation | ✅ Complete |
| Phase 6 | Documentation Updates | ✅ Complete |

---

## 2. What Changed

### Before Migration

```xml
<!-- Amendment file -->
<new-content>
    <part xml:id="bc.divB.part10">
        <section xml:id="bc.divB.part10.sect1">
            <sentence xml:id="bc.divB.part10.sect1.art1.sent1">
                <text>References <ref target="nbc.divB.part3.sect1">NBC content</ref></text>
            </sentence>
        </section>
    </part>
</new-content>
```

**Problems:**
- `bc.` prefix for BC content
- Cross-namespace references
- Dual ID management complexity

### After Migration

```xml
<!-- Amendment file -->
<new-content source="bc">
    <part xml:id="nbc.divB.part10">
        <section xml:id="nbc.divB.part10.sect1">
            <sentence xml:id="nbc.divB.part10.sect1.art1.sent1">
                <text>References <ref target="nbc.divB.part3.sect1">NBC content</ref></text>
            </sentence>
        </section>
    </part>
</new-content>
```

**Improvements:**
- Unified `nbc.` prefix for all content
- `source="bc"` attribute identifies BC-specific content
- Seamless cross-references

### Merged Output

```xml
<part xml:id="nbc.divB.part10" source="bc">
    <section xml:id="nbc.divB.part10.sect1" source="bc">
        <sentence xml:id="nbc.divB.part10.sect1.art1.sent1" source="bc">
            <text>References <ref target="nbc.divB.part3.sect1">NBC content</ref></text>
        </sentence>
    </section>
</part>
```

---

## 3. Amendment File Changes

### Required Changes for New Amendments

When creating new BC-specific amendments:

1. **Use `nbc.` prefix for all IDs:**
   ```xml
   <!-- Correct -->
   <article xml:id="nbc.divB.part10.sect1.art1">

   <!-- Wrong - don't use bc. prefix -->
   <article xml:id="bc.divB.part10.sect1.art1">
   ```

2. **Add `source="bc"` to `<new-content>`:**
   ```xml
   <!-- Correct -->
   <new-content source="bc">
       <article xml:id="nbc.divB.part10.sect1.art1">

   <!-- Wrong - missing source attribute -->
   <new-content>
       <article xml:id="nbc.divB.part10.sect1.art1">
   ```

### What the Migration Script Changed

The migration script performed these replacements:

| Pattern | Replacement |
|---------|-------------|
| `xml:id="bc.` | `xml:id="nbc.` |
| `target="bc.` | `target="nbc.` |
| `reference-id="bc.` | `reference-id="nbc.` |
| `parent-id="bc.` | `parent-id="nbc.` |
| `<new-content>` | `<new-content source="bc">` |

### Files Updated

**Overlay Amendments (12 files):**
- `json-generation-pipeline/source/bc-amendments/xml/*.xml`

**Revision Amendments (6 files):**
- `json-generation-pipeline/source/bc-revisions/xml/*.xml`

---

## 4. Schema Changes

### ID Patterns

ID patterns now only accept `nbc` prefix:

**Before:**
```rng
<data type="string">
    <param name="pattern">(nbc|bc)\.divA\.part\d+\.sect\d+\.subsect\d+\.art\d+\.sent\d+</param>
</data>
```

**After:**
```rng
<data type="string">
    <param name="pattern">nbc\.divA\.part\d+\.sect\d+\.subsect\d+\.art\d+\.sent\d+</param>
</data>
```

### Source Attribute

Added source attribute to all structural elements:

```rng
<optional>
    <attribute name="source">
        <choice>
            <value>nbc</value>
            <value>bc</value>
        </choice>
    </attribute>
</optional>
```

**Elements with source attribute:**
- division
- part
- section
- subsection
- article
- sentence
- clause
- subclause
- table
- figure
- application-note
- note-division
- spectables

### BC Overlay Schema

Added source attribute to `<new-content>` elements:

```rng
<element name="new-content">
    <optional>
        <attribute name="source">
            <choice>
                <value>bc</value>
                <value>nbc</value>
            </choice>
        </attribute>
    </optional>
    <!-- content... -->
</element>
```

---

## 5. JSON Output Changes

### Before

```json
{
  "id": "bc.divB.part10.sect1.art1",
  "type": "article",
  "content": [...]
}
```

### After

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

Applications can now filter BC-specific content:

```javascript
// Find all BC-specific articles
const bcArticles = code.articles.filter(art => art.source === 'bc');

// Find all NBC (original) articles
const nbcArticles = code.articles.filter(art => !art.source || art.source === 'nbc');

// Display BC badge for modified content
function renderArticle(article) {
    return `
        <div class="article ${article.source === 'bc' ? 'bc-modified' : ''}">
            ${article.source === 'bc' ? '<span class="badge">BC</span>' : ''}
            ${article.text}
        </div>
    `;
}
```


## 7. Validation Results

After migration completion:

| Metric | Result |
|--------|--------|
| `bc.` hierarchical IDs remaining | 0 |
| `source="bc"` attributes in XML | 1913 |
| `source` attributes in JSON | 1760 |
| Reference resolution success | 100% |
| Schema validation | Pass |

---

## 8. For New Amendment Authors

### DO:

✅ Use `nbc.` prefix for **all** hierarchical IDs:
```xml
<article xml:id="nbc.divB.part10.sect1.art1">
```

✅ Add `source="bc"` to `<new-content>` for BC-specific content:
```xml
<new-content source="bc">
    <article xml:id="nbc.divB.part10.sect1.art1">
```

✅ Let the merge engine propagate source to children (automatic)

### DON'T:

❌ Use `bc.` prefix for hierarchical IDs:
```xml
<!-- WRONG -->
<article xml:id="bc.divB.part10.sect1.art1">
```

❌ Forget the source attribute on BC-specific content:
```xml
<!-- WRONG - missing source="bc" -->
<new-content>
    <article xml:id="nbc.divB.part10.sect1.art1">
```

❌ Add source attribute manually to every child element (merge engine does this automatically):
```xml
<!-- UNNECESSARY - merge engine handles this -->
<new-content source="bc">
    <article xml:id="nbc.divB.part10.sect1.art1" source="bc">
        <sentence xml:id="..." source="bc">
```

### Exception: BC Term IDs

BC-specific **term definitions** still use `bc-` prefix:
- `bc-scnd-t` (secondary suite)
- `bc-rsd-cr-hm` (residential care home)

These are in a different namespace (term definitions) and were not affected by the migration.

---

## 9. Key Benefits

### 1. Unified ID Namespace
- Single `nbc.` prefix for all content
- No cross-namespace reference issues
- Simpler ID management

### 2. Cleaner Validation
- Single ID pattern to validate
- Clear schema rules
- No duplicate validation logic

### 3. Better JSON Output
- Source attribute captured for filtering
- Easy to identify BC-specific content
- Supports queries like "show only BC changes"

### 4. Easier Maintenance
- No duplicate ID management
- References work seamlessly
- Simplified merge engine logic

---

## 10. Troubleshooting

### Problem: Reference not resolving

**Symptom:** Reference shows as broken/unresolved

**Solution:** Check that target ID uses `nbc.` prefix (not `bc.`):
```xml
<!-- Correct -->
<ref target="nbc.divB.part3.sect1.art1">

<!-- Wrong -->
<ref target="bc.divB.part3.sect1.art1">
```

### Problem: BC content not showing source attribute in JSON

**Symptom:** JSON output missing `"source": "bc"` property

**Solution:** Ensure `<new-content>` has `source="bc"` attribute:
```xml
<!-- Correct -->
<new-content source="bc">

<!-- Wrong -->
<new-content>
```

### Problem: Schema validation error for ID pattern

**Symptom:** Error like "ID does not match pattern"

**Solution:** Change `bc.` prefix to `nbc.`:
```xml
<!-- Correct -->
xml:id="nbc.divB.part10.sect1.art1"

<!-- Wrong -->
xml:id="bc.divB.part10.sect1.art1"
```

---

## 11. Rollback Plan (If Needed)

If critical issues arise, revert using git:

```powershell
# Revert schemas
git checkout -- json-generation-pipeline/output/schema/*.rng

# Revert merge engine
git checkout -- json-generation-pipeline/transformation-xslt/merge-engine-v3.xsl

# Revert JSON generation
git checkout -- json-generation-pipeline/transformation-xslt/canonical-to-json.xsl

# Revert amendment files
git checkout -- json-generation-pipeline/source/bc-amendments/xml/*.xml
git checkout -- json-generation-pipeline/source/bc-revisions/xml/*.xml
```

---

## Related Documentation

- [01-system-overview.md](01-system-overview.md) - System overview with ID conventions
- [02-overlay-amendments-guide.md](02-overlay-amendments-guide.md) - Creating overlay amendments
- [04-merge-engine-reference.md](04-merge-engine-reference.md) - Source attribute propagation details