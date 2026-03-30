# Canonical to JSON Transform (canonical-to-json.xsl)

## Overview

Converts the merged canonical NBC+BC XML to structured JSON optimized for AI/LLM systems. Provides hierarchical navigation, rich text formatting, cross-references, and BC amendment tracking.

## Purpose

- **AI/LLM optimization**: Structured format for machine learning systems
- **Hierarchical navigation**: Nested structure mirrors building code organization
- **Rich text preservation**: Maintains formatting, references, equations
- **Cross-reference index**: Optional navigation and analysis support
- **BC tracking**: Includes amendment history and revision tracking
- **Multiple formats**: Equations in LaTeX, plain text, and MathML

## Input

- **Source**: `bc-building-code-final.xml` (or `bc-building-code.xml`)
- **Format**: Canonical NBC XML with BC amendments applied
- **Size**: ~5.9 MB

## Output

- **File**: `bc-building-code.json`
- **Format**: Structured JSON
- **Size**: ~6.9 MB (with cross-references), ~5.5 MB (without)
- **Schema**: `bc-building-code-schema.json`

## Command

```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/canonical-to-json.xsl \
  -s:json-generation-pipeline/output/bc-building-code-final.xml \
  -o:json-generation-pipeline/output/bc-building-code.json
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `include-metadata` | `true` | Include document metadata and publication info |
| `include-cross-references` | `false` | Generate cross-reference index for navigation |
| `include-bc-annotations` | `true` | Include BC amendments and revision history |
| `flatten-hierarchy` | `false` | Flatten hierarchical structure (experimental) |

### Parameter Usage

```bash
# Full JSON with cross-references (larger file, more features)
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/canonical-to-json.xsl \
  -s:json-generation-pipeline/output/bc-building-code-final.xml \
  include-cross-references=true \
  -o:json-generation-pipeline/output/bc-building-code.json

# Minimal JSON (smaller file, faster processing)
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/canonical-to-json.xsl \
  -s:json-generation-pipeline/output/bc-building-code-final.xml \
  include-metadata=false \
  include-cross-references=false \
  include-bc-annotations=false \
  -o:json-generation-pipeline/output/bc-building-code-minimal.json
```

## Key Features

### 1. Hierarchical Structure

Mirrors building code organization:

```json
{
  "document_type": "bc_building_code",
  "version": "2020",
  "canonical_version": "1.0",
  "generated_timestamp": "2025-01-20T10:45:30Z",
  
  "divisions": [
    {
      "id": "nbc.divB",
      "type": "division",
      "letter": "B",
      "title": "Division B - Acceptable Solutions",
      "parts": [
        {
          "id": "nbc.divB.part3",
          "type": "part",
          "number": 3,
          "title": "Fire Safety, Occupant Safety and Accessibility",
          "sections": [
            {
              "id": "nbc.divB.part3.sect8",
              "type": "section",
              "number": 8,
              "title": "Accessibility",
              "subsections": [
                {
                  "id": "nbc.divB.part3.sect8.subsect2",
                  "type": "subsection",
                  "number": 2,
                  "title": "Barrier-Free Path of Travel",
                  "articles": [
                    {
                      "id": "nbc.divB.part3.sect8.subsect2.art6",
                      "type": "article",
                      "number": 6,
                      "title": "Doors in Barrier-Free Path of Travel",
                      "content": [
                        {
                          "id": "nbc.divB.part3.sect8.subsect2.art6.sent1",
                          "type": "sentence",
                          "number": 1,
                          "text": "Except as permitted by Sentence (2)...",
                          "clauses": [...]
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

### 2. Rich Text Formatting

Preserves all formatting with inline markup:

```json
{
  "text": "The <bold>minimum</bold> width shall be <measurement>850 mm</measurement> except as permitted in [REF:internal:nbc.divB.part3.sect8.subsect2.art6.sent2]Sentence (2)[/REF]."
}
```

**Supported Markup**:
- `<bold>`, `<italic>`, `<underline>`: Emphasis styles
- `^{text}`: Superscript
- `_{text}`: Subscript
- `[REF:type:target]text[/REF]`: References
- `(units)`: Measurements
- `[EQ:type:id]`: Equation placeholders

### 3. Reference Types

Four types of references with structured format:

**Internal References**:
```json
{
  "text": "See [REF:internal:nbc.divB.part3.sect8.subsect2.art6]Article 3.8.2.6.[/REF]"
}
```

**Term References**:
```json
{
  "text": "A [REF:term:bldng]building[/REF] shall conform..."
}
```

**Standard References**:
```json
{
  "text": "Conform to [REF:standard:csac22.2no.141]CSA C22.2 No. 141[/REF]"
}
```

**External References**:
```json
{
  "text": "See [REF:external:bcfc]BC Fire Code[/REF]"
}
```

### 4. Equation Support

Multiple formats for maximum compatibility:

```json
{
  "equations": [
    {
      "id": "nbc.divB.part4.sect2.subsect1.art7.sent1.eq1",
      "type": "inline",
      "latex": "\\frac{A_s}{A_g} \\geq 0.01",
      "plainText": "(As)/(Ag) >= 0.01",
      "mathml": "<math xmlns='http://www.w3.org/1998/Math/MathML'>...</math>",
      "image": "eq00123a.eps",
      "imageSrc": "graphics/eg/004/eq00123a.eps"
    }
  ]
}
```

**Equation Formats**:
- **LaTeX**: For rendering with MathJax/KaTeX
- **Plain text**: For simple display or search
- **MathML**: For semantic understanding
- **Image**: Fallback EPS/PNG reference

### 5. Table Structure

Preserves table layout with metadata:

```json
{
  "type": "table",
  "id": "nbc.divB.part9.sect36.subsect2.art8.table3",
  "title": "Table 9.36.2.8.-C Maximum Spans for Floor Joists",
  "structure": {
    "columns": 7,
    "column_specs": [
      {"name": "col1", "width": "60.00*"},
      {"name": "col2", "width": "40.00*"}
    ],
    "header_rows": [
      [
        {"content": "Species^(1)", "align": "center"},
        {"content": "Grade", "align": "center"},
        {"content": "Spacing (mm)", "align": "center"}
      ]
    ],
    "body_rows": [
      [
        {"content": "Douglas Fir-Larch", "rowspan": 3},
        {"content": "No. 1/No. 2", "align": "center"},
        {"content": "2.95", "align": "center"}
      ]
    ]
  },
  "revisions": [...]
}
```

### 6. Cross-Reference Index

Optional index for navigation and analysis:

```json
{
  "cross_references": {
    "internal_references": [
      {
        "source_id": "nbc.divB.part3.sect8.subsect2.art6.sent1",
        "target_id": "nbc.divB.part3.sect8.subsect2.art6.sent2",
        "display_type": "sentence"
      }
    ],
    "external_references": [
      {
        "source_id": "nbc.divB.part3.sect3.subsect1.art2.sent1",
        "target": "bcfc",
        "text": "BC Fire Code"
      }
    ],
    "standard_references": [
      {
        "source_id": "nbc.divB.part6.sect2.subsect1.art3.sent1",
        "standard_id": "csac22.2no.141",
        "text": "CSA C22.2 No. 141"
      }
    ],
    "term_references": [
      {
        "source_id": "nbc.divB.part1.sect1.subsect1.art1.sent1",
        "term_id": "bldng",
        "text": "building"
      }
    ]
  }
}
```

### 7. BC Amendment Tracking

Tracks all BC-specific changes:

```json
{
  "bc_amendments": [
    {
      "location_id": "nbc.divB.part3.sect8.subsect2.art6.sent1",
      "type": "revision",
      "revision_type": "amendment",
      "revision_id": "bc-mo-2024-01-011",
      "sequence": 1,
      "effective_date": "2024-04-05",
      "status": "current",
      "content": "New sentence content...",
      "change_summary": "Changed reference from 3.2.2.92 to 3.2.2.93",
      "note": "Ministerial Order BA 2024 01"
    }
  ]
}
```

### 8. Revision History

Snapshot-based versioning for date queries:

```json
{
  "revisions": [
    {
      "type": "original",
      "effective_date": "2020-12-01",
      "text": "Original NBC 2020 content..."
    },
    {
      "type": "revision",
      "revision_type": "amendment",
      "revision_id": "bc-mo-2024-01-011",
      "sequence": 1,
      "effective_date": "2024-04-05",
      "status": "current",
      "text": "Revised content as of 2024-04-05...",
      "change_summary": "Updated reference",
      "note": "Ministerial Order BA 2024 01"
    }
  ]
}
```

### 9. Glossary

Extracted definitions for quick lookup:

```json
{
  "glossary": {
    "nbc.divA.part1.sect1.subsect1.art1.def.bldng": {
      "term": "building",
      "definition": "any structure used or intended for supporting or sheltering any use or occupancy",
      "location_id": "nbc.divA.part1.sect1.subsect1.art1"
    }
  }
}
```

### 10. Statistics

Document-level metrics:

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
    "total_spectables": 45,
    "total_application_notes": 567
  }
}
```

## Processing Modes

### 1. JSON Mode

Main transformation mode - converts XML to JSON structure:

```xslt
<xsl:template match="sentence" mode="json">
  <fn:map>
    <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
    <fn:string key="type">sentence</fn:string>
    <fn:number key="number"><xsl:value-of select="@number"/></fn:number>
    <fn:string key="text"><xsl:apply-templates select="text" mode="rich-text-json"/></fn:string>
    <!-- ... -->
  </fn:map>
</xsl:template>
```

### 2. Rich Text Mode

Converts XML rich text to inline markup:

```xslt
<xsl:template match="ref" mode="rich-text-json">
  <xsl:text>[REF:</xsl:text>
  <xsl:value-of select="@type"/>
  <xsl:text>:</xsl:text>
  <xsl:value-of select="@target"/>
  <xsl:text>]</xsl:text>
  <xsl:value-of select="."/>
  <xsl:text>[/REF]</xsl:text>
</xsl:template>
```

### 3. Text-Only Mode

Strips formatting for plain text:

```xslt
<xsl:template match="*" mode="text-only">
  <xsl:apply-templates select="text() | *" mode="text-only"/>
</xsl:template>

<xsl:template match="text()" mode="text-only">
  <xsl:value-of select="."/>
</xsl:template>
```

### 4. Equation Conversion

Converts MathML to multiple formats:

```xslt
<!-- MathML to LaTeX -->
<xsl:template match="*:mfrac" mode="mathml-to-latex">
  <xsl:text>\frac{</xsl:text>
  <xsl:apply-templates select="*[1]" mode="mathml-to-latex"/>
  <xsl:text>}{</xsl:text>
  <xsl:apply-templates select="*[2]" mode="mathml-to-latex"/>
  <xsl:text>}</xsl:text>
</xsl:template>

<!-- MathML to plain text -->
<xsl:template match="*:mfrac" mode="mathml-to-plaintext">
  <xsl:text>(</xsl:text>
  <xsl:apply-templates select="*[1]" mode="mathml-to-plaintext"/>
  <xsl:text>)/(</xsl:text>
  <xsl:apply-templates select="*[2]" mode="mathml-to-plaintext"/>
  <xsl:text>)</xsl:text>
</xsl:template>
```

## Output Schema

JSON follows this structure:

```json
{
  "document_type": "bc_building_code",
  "version": "string",
  "canonical_version": "string",
  "generated_timestamp": "ISO 8601 datetime",
  
  "metadata": {
    "title": "string",
    "subtitle": "string",
    "authority": "string",
    "publication_date": "string",
    "nrc_number": "string",
    "isbn": "string",
    "volumes": [...]
  },
  
  "divisions": [
    {
      "id": "string",
      "type": "division",
      "letter": "A|B|C",
      "title": "string",
      "number": "string",
      "parts": [
        {
          "id": "string",
          "type": "part",
          "number": 1-12,
          "title": "string",
          "sections": [
            {
              "id": "string",
              "type": "section",
              "number": 1-N,
              "title": "string",
              "subsections": [
                {
                  "id": "string",
                  "type": "subsection",
                  "number": 1-N,
                  "title": "string",
                  "articles": [
                    {
                      "id": "string",
                      "type": "article",
                      "number": 1-N,
                      "title": "string",
                      "content": [
                        {
                          "id": "string",
                          "type": "sentence|table|figure",
                          "number": 1-N,
                          "text": "string with inline markup",
                          "clauses": [...],
                          "equations": [...],
                          "revisions": [...]
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ],
          "special_tables": [...],
          "appendix": {...}
        }
      ]
    }
  ],
  
  "cross_references": {...},
  "bc_amendments": [...],
  "glossary": {...},
  "statistics": {...}
}
```

## Performance

- **Processing time**: ~5 seconds
- **Memory usage**: ~600 MB
- **Output size**: 6.9 MB (with cross-refs), 5.5 MB (without)
- **Compression**: ~1.2 MB gzipped

## Use Cases

### 1. AI/LLM Training

Structured format for machine learning:
```python
import json

# Load BC Building Code
with open('bc-building-code.json') as f:
    code = json.load(f)

# Extract all sentences for training
sentences = []
for div in code['divisions']:
    for part in div['parts']:
        for section in part['sections']:
            for subsection in section['subsections']:
                for article in subsection['articles']:
                    for item in article['content']:
                        if item['type'] == 'sentence':
                            sentences.append({
                                'id': item['id'],
                                'text': item['text'],
                                'context': f"{div['title']} > {part['title']} > {section['title']}"
                            })
```

### 2. Web Application

Navigate building code structure:
```javascript
// Load BC Building Code
fetch('bc-building-code.json')
  .then(response => response.json())
  .then(code => {
    // Find Division B, Part 3
    const divB = code.divisions.find(d => d.letter === 'B');
    const part3 = divB.parts.find(p => p.number === 3);
    
    // Display sections
    part3.sections.forEach(section => {
      console.log(`${section.number}. ${section.title}`);
    });
  });
```

### 3. Search and Analysis

Query building code content:
```python
import json

with open('bc-building-code.json') as f:
    code = json.load(f)

# Find all references to "accessible"
def find_term(obj, term, results=[]):
    if isinstance(obj, dict):
        if 'text' in obj and term.lower() in obj['text'].lower():
            results.append({
                'id': obj.get('id'),
                'text': obj['text']
            })
        for value in obj.values():
            find_term(value, term, results)
    elif isinstance(obj, list):
        for item in obj:
            find_term(item, term, results)
    return results

accessible_refs = find_term(code, 'accessible')
print(f"Found {len(accessible_refs)} references to 'accessible'")
```

### 4. Compliance Checking

Validate against requirements:
```python
# Check if building meets accessibility requirements
def check_accessibility(building_data, code):
    # Find Part 3, Section 8 (Accessibility)
    divB = next(d for d in code['divisions'] if d['letter'] == 'B')
    part3 = next(p for p in divB['parts'] if p['number'] == 3)
    sect8 = next(s for s in part3['sections'] if s['number'] == 8)
    
    # Extract requirements
    requirements = []
    for subsection in sect8['subsections']:
        for article in subsection['articles']:
            for item in article['content']:
                if item['type'] == 'sentence':
                    requirements.append({
                        'id': item['id'],
                        'requirement': item['text']
                    })
    
    # Check compliance
    # ... implementation ...
```

## Validation

Validate JSON output:
```bash
# Using Node.js ajv-cli
npm install -g ajv-cli
ajv validate -s bc-building-code-schema.json -d bc-building-code.json

# Using Python jsonschema
pip install jsonschema
python -c "
import json
import jsonschema

schema = json.load(open('bc-building-code-schema.json'))
data = json.load(open('bc-building-code.json'))
jsonschema.validate(data, schema)
print('✓ JSON is valid')
"
```

## Dependencies

- **Saxon HE 12.9+**: XSLT 3.0 processor with JSON support
- **Java 8+**: Runtime environment
- **Input file**: Canonical NBC XML with BC amendments

## Related Files

- **Minimal version**: `json-generation-pipeline/transformation-xslt/canonical-to-json-minimal.xsl`
- **Schema**: `bc-building-code-schema.json`
- **Source**: `json-generation-pipeline/output/bc-building-code-final.xml`
- **Merge engine**: `json-generation-pipeline/transformation-xslt/merge-engine-v3.xsl`
