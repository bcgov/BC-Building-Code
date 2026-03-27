# Canonical to JSON Minimal Transform (canonical-to-json-minimal.xsl)

## Overview

Generates a minimal representative sample of the BC Building Code in JSON format. Designed for LLM study, testing, and documentation purposes. Includes all node types but limits the quantity of each to keep file size manageable.

## Purpose

- **LLM study**: Compact sample for understanding structure
- **Testing**: Quick validation of JSON processing
- **Documentation**: Examples of all content types
- **Schema generation**: Reference for JSON schema design
- **Rapid prototyping**: Fast iteration during development

## Input

- **Source**: `bc-building-code-final.xml` (or `bc-building-code.xml`)
- **Format**: Canonical NBC XML with BC amendments applied
- **Size**: ~5.9 MB

## Output

- **File**: `bc-building-code-minimal.json`
- **Format**: Structured JSON with limited samples
- **Size**: ~150 KB (vs 6.9 MB for full version)
- **Content**: Representative sample of all node types

## Command

```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/canonical-to-json-minimal.xsl \
  -s:json-generation-pipeline/output/bc-building-code-final.xml \
  -o:json-generation-pipeline/output/bc-building-code-minimal.json
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `max-parts` | `2` | Maximum parts per division |
| `max-sections` | `3` | Maximum sections per part |
| `max-subsections` | `3` | Maximum subsections per section |
| `max-articles` | `3` | Maximum articles per subsection |
| `max-sentences` | `4` | Maximum sentences per article |
| `max-clauses` | `3` | Maximum clauses per sentence |
| `max-appnotes` | `5` | Maximum application notes per appendix |

### Custom Limits

```bash
# Generate larger sample
java -jar xmlToJson/saxon.jar \
  -xsl:proposed/canonical-to-json-minimal.xsl \
  -s:bc-building-code-final.xml \
  max-parts=5 \
  max-sections=5 \
  max-articles=5 \
  -o:bc-building-code-sample.json

# Generate tiny sample for testing
java -jar xmlToJson/saxon.jar \
  -xsl:proposed/canonical-to-json-minimal.xsl \
  -s:bc-building-code-final.xml \
  max-parts=1 \
  max-sections=1 \
  max-articles=1 \
  max-sentences=2 \
  -o:bc-building-code-tiny.json
```

## Key Features

### 1. Sampling Strategy

Includes first N items of each type:

```
Division A (all divisions included)
├── Part 1 (first 2 parts)
│   ├── Section 1 (first 3 sections)
│   │   ├── Subsection 1 (first 3 subsections)
│   │   │   ├── Article 1 (first 3 articles)
│   │   │   │   ├── Sentence 1 (first 4 sentences)
│   │   │   │   │   ├── Clause a (first 3 clauses)
│   │   │   │   │   └── Clause b
│   │   │   │   ├── Sentence 2
│   │   │   │   └── ...
│   │   │   ├── Article 2
│   │   │   └── Article 3
│   │   ├── Subsection 2
│   │   └── Subsection 3
│   ├── Section 2
│   └── Section 3
├── Part 2
└── [total_parts: 12]
```

### 2. Total Counts

Includes actual totals for context:

```json
{
  "divisions": [
    {
      "id": "nbc.divB",
      "type": "division",
      "letter": "B",
      "title": "Division B - Acceptable Solutions",
      "parts": [
        {
          "id": "nbc.divB.part3",
          "sections": [...],
          "total_sections": 12
        },
        {
          "id": "nbc.divB.part9",
          "sections": [...],
          "total_sections": 40
        }
      ],
      "total_parts": 12
    }
  ]
}
```

### 3. All Content Types

Includes samples of every node type:

**Structural**:
- Division, Part, Section, Subsection, Article, Sentence, Clause, Subclause

**Content**:
- Tables (with header and body rows)
- Figures (with graphics)
- Special tables (spectables)
- Application notes
- Note divisions

**Semantic**:
- Objectives
- Functional statements
- Definitions

**References**:
- Internal references
- Term references
- Standard references
- External references

**BC-Specific**:
- Revision history
- Amendment tracking
- BC annotations

### 4. Simplified Rich Text

Uses simplified inline markup:

```json
{
  "text": "[REF:internal:nbc.divB.part3.sect8.subsect2.art6]Article 3.8.2.6.[/REF]"
}
```

**Markup Patterns**:
- `[REF:type:target]text`: References
- `^{text}`: Superscript
- `_{text}`: Subscript
- `(units)`: Measurements
- `[EQ:type:id]`: Equations

### 5. Equation Samples

Includes equations in multiple formats:

```json
{
  "equations": [
    {
      "id": "nbc.divB.part4.sect2.subsect1.art7.sent1.eq1",
      "type": "inline",
      "latex": "\\frac{A_s}{A_g} \\geq 0.01",
      "plainText": "(As)/(Ag) >= 0.01"
    }
  ]
}
```

### 6. Cross-Reference Samples

Limited samples of each reference type:

```json
{
  "cross_references_sample": {
    "internal": [
      {
        "source": "nbc.divB.part3.sect8.subsect2.art6.sent1",
        "target": "nbc.divB.part3.sect8.subsect2.art6.sent2"
      }
    ],
    "terms": [
      {
        "term": "bldng",
        "text": "building"
      }
    ],
    "standards": [
      {
        "standard": "csac22.2no.141",
        "text": "CSA C22.2 No. 141"
      }
    ]
  }
}
```

### 7. BC Amendment Samples

Limited samples of revision history:

```json
{
  "bc_amendments_sample": [
    {
      "location": "nbc.divB.part3.sect2.subsect3.art9.sent1",
      "original_date": "2020-12-01",
      "revisions": [
        {
          "type": "amendment",
          "id": "bc-mo-2024-01-011",
          "date": "2024-04-05",
          "status": "current",
          "summary": "Changed reference from 3.2.2.92 to 3.2.2.93"
        }
      ]
    }
  ]
}
```

### 8. Glossary Sample

Limited definition samples:

```json
{
  "glossary_sample": {
    "nbc.divA.part1.sect1.subsect1.art1.def.bldng": {
      "term": "building",
      "definition": "any structure used or intended for supporting or sheltering any use or occupancy"
    }
  }
}
```

### 9. Schema Documentation

Includes embedded schema documentation:

```json
{
  "schema_doc": {
    "hierarchy": {
      "description": "BC Building Code follows strict hierarchy: division > part > section > subsection > article > sentence > clause > subclause",
      "levels": [
        {"level": 1, "name": "division", "example": "nbc.divA, nbc.divB"},
        {"level": 2, "name": "part", "example": "nbc.divB.part3"},
        {"level": 3, "name": "section", "example": "nbc.divB.part3.sect8"},
        {"level": 4, "name": "subsection", "example": "nbc.divB.part3.sect8.subsect2"},
        {"level": 5, "name": "article", "example": "nbc.divB.part3.sect8.subsect2.art6"},
        {"level": 6, "name": "sentence", "example": "nbc.divB.part3.sect8.subsect2.art6.sent1"},
        {"level": 7, "name": "clause", "example": "nbc.divB.part3.sect8.subsect2.art6.sent1.clause1"},
        {"level": 8, "name": "subclause", "example": "nbc.divB.part3.sect8.subsect2.art6.sent1.clause1.subclause1"}
      ]
    },
    "content_types": {
      "structural": ["division", "part", "section", "subsection", "article", "sentence", "clause", "subclause"],
      "content": ["table", "figure", "spectables", "application_note", "note_division"],
      "semantic": ["objective", "functional_statement", "definition"],
      "references": ["internal", "term", "standard", "external"]
    },
    "bc_specific": {
      "description": "BC-specific content uses bc. prefix instead of nbc.",
      "example": "bc.divB.part10.sect1.subsect1.art1",
      "amendment_types": ["replace", "insert", "modify", "remove"]
    },
    "revision_history": {
      "description": "Tracks changes over time with effective dates",
      "types": ["amendment", "errata", "policy", "accessibility", "correction"],
      "status": ["current", "superseded"]
    }
  }
}
```

### 10. Statistics

Full document statistics:

```json
{
  "statistics": {
    "total_divisions": 4,
    "total_parts": 12,
    "total_sections": 156,
    "total_articles": 3421,
    "total_sentences": 12847,
    "total_tables": 892,
    "total_figures": 234,
    "total_application_notes": 567,
    "total_revisions": 284
  }
}
```

## Output Structure

```json
{
  "document_type": "bc_building_code_minimal_sample",
  "description": "Minimal representative sample of all node types for LLM study",
  "version": "2020",
  "canonical_version": "1.0",
  
  "metadata": {
    "title": "National Building Code of Canada 2020",
    "subtitle": "Incorporating British Columbia Amendments",
    "authority": "National Research Council Canada"
  },
  
  "divisions": [
    {
      "id": "nbc.divA",
      "type": "division",
      "letter": "A",
      "title": "Division A - Compliance, Objectives and Functional Statements",
      "parts": [
        {
          "id": "nbc.divA.part1",
          "type": "part",
          "number": 1,
          "title": "Compliance and General",
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
                  "title": "Application and Definitions",
                  "articles": [
                    {
                      "id": "nbc.divA.part1.sect1.subsect1.art1",
                      "type": "article",
                      "number": 1,
                      "title": "Application",
                      "content": [
                        {
                          "id": "nbc.divA.part1.sect1.subsect1.art1.sent1",
                          "type": "sentence",
                          "number": 1,
                          "text": "This Code applies to the design and construction of new buildings...",
                          "clauses": [...]
                        }
                      ]
                    }
                  ],
                  "total_articles": 5
                }
              ],
              "total_subsections": 4
            }
          ],
          "total_sections": 6
        }
      ],
      "total_parts": 2
    }
  ],
  
  "cross_references_sample": {...},
  "bc_amendments_sample": [...],
  "glossary_sample": {...},
  "statistics": {...},
  "schema_doc": {...}
}
```

## Processing Logic

### Sampling Template

```xslt
<xsl:template match="part" mode="json">
  <fn:map>
    <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
    <fn:string key="type">part</fn:string>
    <fn:number key="number"><xsl:value-of select="@number"/></fn:number>
    <fn:string key="title"><xsl:apply-templates select="title" mode="text"/></fn:string>
    
    <!-- Sample first N sections -->
    <fn:array key="sections">
      <xsl:apply-templates select="section[position() &lt;= $max-sections]" mode="json"/>
    </fn:array>
    
    <!-- Include total count -->
    <fn:number key="total_sections"><xsl:value-of select="count(section)"/></fn:number>
  </fn:map>
</xsl:template>
```

### Revision History Sampling

```xslt
<xsl:template name="build-revisions">
  <!-- Original baseline -->
  <fn:map>
    <fn:string key="type">original</fn:string>
    <fn:string key="date"><xsl:value-of select="revision-history/original/@effective-date"/></fn:string>
  </fn:map>
  
  <!-- First 2 revisions only -->
  <xsl:for-each select="revision-history/revision[position() &lt;= 2]">
    <fn:map>
      <fn:string key="type">revision</fn:string>
      <fn:string key="revision_type"><xsl:value-of select="@type"/></fn:string>
      <fn:string key="id"><xsl:value-of select="@id"/></fn:string>
      <fn:string key="date"><xsl:value-of select="@effective-date"/></fn:string>
      <fn:string key="status"><xsl:value-of select="@status"/></fn:string>
      <xsl:if test="change-summary">
        <fn:string key="summary"><xsl:value-of select="change-summary"/></fn:string>
      </xsl:if>
    </fn:map>
  </xsl:for-each>
</xsl:template>
```

## Performance

- **Processing time**: ~2 seconds
- **Memory usage**: ~200 MB
- **Output size**: ~150 KB
- **Compression**: ~25 KB gzipped

## Use Cases

### 1. LLM Training Sample

Quick sample for understanding structure:
```python
import json

# Load minimal sample
with open('bc-building-code-minimal.json') as f:
    sample = json.load(f)

# Understand structure
print(f"Document type: {sample['document_type']}")
print(f"Total divisions: {sample['statistics']['total_divisions']}")
print(f"Total articles: {sample['statistics']['total_articles']}")

# Examine first article
div = sample['divisions'][0]
part = div['parts'][0]
section = part['sections'][0]
subsection = section['subsections'][0]
article = subsection['articles'][0]

print(f"\nSample article: {article['title']}")
print(f"Sentences: {len(article['content'])}")
```

### 2. Schema Generation

Generate JSON schema from sample:
```python
import json
from genson import SchemaBuilder

# Load minimal sample
with open('bc-building-code-minimal.json') as f:
    sample = json.load(f)

# Generate schema
builder = SchemaBuilder()
builder.add_object(sample)
schema = builder.to_schema()

# Save schema
with open('bc-building-code-schema.json', 'w') as f:
    json.dump(schema, f, indent=2)
```

### 3. Testing

Quick validation of JSON processing:
```javascript
// Load minimal sample
fetch('bc-building-code-minimal.json')
  .then(response => response.json())
  .then(sample => {
    // Test navigation
    const divB = sample.divisions.find(d => d.letter === 'B');
    console.assert(divB, 'Division B not found');
    
    const part3 = divB.parts.find(p => p.number === 3);
    console.assert(part3, 'Part 3 not found');
    
    console.log('✓ All tests passed');
  });
```

### 4. Documentation

Generate documentation from sample:
```python
import json

with open('bc-building-code-minimal.json') as f:
    sample = json.load(f)

# Generate markdown documentation
md = f"# BC Building Code Structure\n\n"
md += f"## Statistics\n\n"
for key, value in sample['statistics'].items():
    md += f"- **{key.replace('_', ' ').title()}**: {value}\n"

md += f"\n## Hierarchy\n\n"
md += sample['schema_doc']['hierarchy']['description'] + "\n\n"

for level in sample['schema_doc']['hierarchy']['levels']:
    md += f"{level['level']}. **{level['name'].title()}**: `{level['example']}`\n"

with open('STRUCTURE.md', 'w') as f:
    f.write(md)
```

## Comparison with Full Version

| Feature | Minimal | Full |
|---------|---------|------|
| File size | 150 KB | 6.9 MB |
| Processing time | 2 sec | 5 sec |
| Divisions | All (4) | All (4) |
| Parts per division | 2 | All (12) |
| Sections per part | 3 | All (~13) |
| Articles per subsection | 3 | All (~22) |
| Sentences per article | 4 | All (~4) |
| Cross-references | Samples | Complete index |
| BC amendments | Samples | Complete history |
| Glossary | Samples | Complete |

## Validation

Validate minimal JSON:
```bash
# Using Node.js ajv-cli
ajv validate -s bc-building-code-schema.json -d bc-building-code-minimal.json

# Using Python jsonschema
python -c "
import json
import jsonschema

schema = json.load(open('bc-building-code-schema.json'))
data = json.load(open('bc-building-code-minimal.json'))
jsonschema.validate(data, schema)
print('✓ Minimal JSON is valid')
"
```

## Dependencies

- **Saxon HE 12.9+**: XSLT 3.0 processor with JSON support
- **Java 8+**: Runtime environment
- **Input file**: Canonical NBC XML with BC amendments

## Related Files

- **Full version**: `canonical-to-json.xsl`
- **Schema**: `bc-building-code-schema.json`
- **Source**: `bc-building-code-final.xml`
- **Merge engine**: `merge-engine-v3.xsl`
