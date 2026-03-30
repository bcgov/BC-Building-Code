# Deletion Tracking in BC Building Code

This document describes how element deletions are tracked in the BC Building Code XML and JSON output.

## Overview

The BC Building Code uses a `deleted="yes"` attribute to mark elements that have been removed through amendments or revisions. This deletion status is preserved in the JSON output through a `deleted` boolean property.

## XML Representation

### Marking Elements as Deleted

Any element can be marked as deleted by adding the `deleted="yes"` attribute:

```xml
<sentence xml:id="bc.divBV2.part9.sect23.subsect13.art4.sent2" 
          number="2" 
          revised="yes" 
          deleted="yes">
  <revision-history>
    <original effective-date="2020-12-01">
      <text>For split-level buildings, a braced wall band shall be located 
            where there is a change in floor level greater than the depth 
            of one floor joist.</text>
    </original>
    <revision seq="1" type="amendment" effective-date="2025-06-16" 
             id="bc-mo-2024-06-153" status="current">
      <content></content>
      <change-summary>Sentence deleted - Figure A-9.13.4.3.(2)(b) and (3)(b) 
                      illustration removed</change-summary>
      <note>Ministerial Order BA 2024 06</note>
    </revision>
  </revision-history>
</sentence>
```

### Supported Element Types

The `deleted="yes"` attribute can be applied to:
- Sentences
- Clauses
- Subclauses
- Articles
- Sections
- Subsections
- Tables
- Figures
- Application notes

## JSON Representation

### Main Element Deletion

When an element has `deleted="yes"`, the JSON output includes a `deleted: true` property:

```json
{
  "id": "bc.divBV2.part9.sect23.subsect13.art4.sent2",
  "type": "sentence",
  "number": 2,
  "deleted": true,
  "text": "",
  "revisions": [...]
}
```

### Revision History Deletion

Within revision history, a revision is marked as deleted when its content is empty:

```json
{
  "revisions": [
    {
      "type": "original",
      "effective_date": "2020-12-01",
      "text": "For split-level buildings, a braced wall band shall be located..."
    },
    {
      "type": "revision",
      "revision_type": "amendment",
      "revision_id": "bc-mo-2024-06-153",
      "sequence": 1,
      "effective_date": "2025-06-16",
      "status": "current",
      "deleted": true,
      "text": "",
      "change_summary": "Sentence deleted - Figure A-9.13.4.3.(2)(b) and (3)(b) illustration removed",
      "note": "Ministerial Order BA 2024 06"
    }
  ]
}
```

## Detection Logic

### XSLT Transformation

The `canonical-to-json.xsl` transformation detects deletions using two methods:

1. **Attribute-based detection** (for main elements):
   ```xsl
   <xsl:if test="@deleted = 'yes'">
     <fn:boolean key="deleted">true</fn:boolean>
   </xsl:if>
   ```

2. **Content-based detection** (for revisions):
   ```xsl
   <xsl:choose>
     <xsl:when test="not(content/node()) or normalize-space(content) = ''">
       <fn:boolean key="deleted">true</fn:boolean>
     </xsl:when>
   </xsl:choose>
   ```

### Element-Specific Detection

Different element types have specific content checks:

- **Sentences**: Empty text content
- **Articles**: No sentence/table/figure children and empty content
- **Tables**: No tgroup and empty content
- **Application notes**: No number/title/paragraph and empty content

## JSON Schema Validation

The JSON schema (`bc-building-code-schema.json`) includes the `deleted` property for all applicable element types:

```json
{
  "sentence": {
    "properties": {
      "deleted": {
        "type": "boolean",
        "description": "Indicates if this sentence has been deleted (true when deleted='yes' attribute is present)"
      }
    }
  }
}
```

## Use Cases

### 1. Filtering Deleted Content

Applications can filter out deleted elements:

```javascript
const activeSentences = article.content.filter(item => 
  item.type === 'sentence' && !item.deleted
);
```

### 2. Showing Deletion History

Display what was deleted and when:

```javascript
const deletedRevisions = sentence.revisions.filter(rev => 
  rev.deleted && rev.type === 'revision'
);

deletedRevisions.forEach(rev => {
  console.log(`Deleted on ${rev.effective_date}: ${rev.change_summary}`);
});
```

### 3. Date-Based Queries

Show content as it existed on a specific date:

```javascript
function getContentAtDate(element, targetDate) {
  if (!element.revisions) return element;
  
  // Find the latest revision before or on target date
  const applicableRevision = element.revisions
    .filter(rev => rev.effective_date <= targetDate)
    .sort((a, b) => b.effective_date.localeCompare(a.effective_date))[0];
  
  // If the applicable revision is deleted, return null
  if (applicableRevision?.deleted) return null;
  
  return element;
}
```

### 4. Audit Trail

Track all changes including deletions:

```javascript
function getChangeHistory(element) {
  if (!element.revisions) return [];
  
  return element.revisions.map(rev => ({
    date: rev.effective_date,
    type: rev.revision_type,
    action: rev.deleted ? 'deleted' : 'modified',
    summary: rev.change_summary,
    note: rev.note
  }));
}
```

## Best Practices

### For Amendment Authors

1. **Always use revision history** when deleting elements:
   ```xml
   <sentence deleted="yes" revised="yes">
     <revision-history>
       <original>...</original>
       <revision>
         <content></content>
         <change-summary>Explain why deleted</change-summary>
       </revision>
     </revision-history>
   </sentence>
   ```

2. **Provide clear change summaries** explaining the deletion reason

3. **Include ministerial order references** in the note field

### For Application Developers

1. **Check both flags**: Check both the main `deleted` property and revision `deleted` flags

2. **Respect effective dates**: Use effective dates for date-based queries

3. **Preserve history**: Don't permanently remove deleted elements from your database

4. **Display context**: Show users what was deleted and why

## Examples

### Complete Sentence Deletion

```json
{
  "id": "bc.divBV2.part9.sect23.subsect13.art4.sent2",
  "type": "sentence",
  "number": 2,
  "deleted": true,
  "text": "",
  "revisions": [
    {
      "type": "original",
      "effective_date": "2020-12-01",
      "text": "For split-level buildings, a braced wall band shall be located where there is a change in floor level greater than the depth of one floor joist."
    },
    {
      "type": "revision",
      "revision_type": "amendment",
      "revision_id": "bc-mo-2024-06-153",
      "sequence": 1,
      "effective_date": "2025-06-16",
      "status": "current",
      "deleted": true,
      "text": "",
      "change_summary": "Sentence deleted - Figure A-9.13.4.3.(2)(b) and (3)(b) illustration removed",
      "note": "Ministerial Order BA 2024 06"
    }
  ]
}
```

### Article with Deleted Sentence

```json
{
  "id": "nbc.divBV2.part9.sect23.subsect13.art4",
  "type": "article",
  "number": 4,
  "title": "Braced Wall Bands",
  "content": [
    {
      "id": "nbc.divBV2.part9.sect23.subsect13.art4.sent1",
      "type": "sentence",
      "number": 1,
      "text": "Braced wall bands shall be located..."
    },
    {
      "id": "bc.divBV2.part9.sect23.subsect13.art4.sent2",
      "type": "sentence",
      "number": 2,
      "deleted": true,
      "text": "",
      "revisions": [...]
    }
  ]
}
```

## Related Documentation

- [BC Building Code - Overlay Amendments Guide](project/02-overlay-amendments-guide.md)
- [Revision Amendments Guide](project/03-revision-amendments-guide.md)
- [JSON Schema](../output/bc-building-code-schema.json)
- [Canonical to JSON Transform](../transformation-xslt/canonical-to-json.xsl)
