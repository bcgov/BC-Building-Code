# NBC to Canonical Transform (nbc-to-canonical.xsl)

## Overview

Converts the National Building Code (NBC) 2020 from Arbortext vendor XML format to a stable, hierarchical canonical format with consistent IDs. This is the first transformation in the pipeline.

## Purpose

- **Normalize vendor XML**: Converts proprietary Arbortext format to a standardized structure
- **Generate canonical IDs**: Creates stable, hierarchical identifiers for all elements
- **Preserve vendor IDs**: Maintains original IDs for traceability
- **Prepare for amendments**: Establishes a stable base for BC overlay amendments

## Input

- **Source**: NBC 2020 Arbortext XML (`nbc2020_p1.xml` or `nbc2020_p1-NO-DOCTYPE.xml`)
- **Format**: Arbortext vendor XML with custom DTD
- **Size**: ~11.76 MB, 264k lines
- **Structure**: OBCode root with divisions, parts, sections, subsections, articles, sentences

## Output

- **File**: `nbc-canonical.xml`
- **Format**: Canonical NBC XML with stable IDs
- **Size**: ~5.9 MB
- **Schema**: `proposed/canonical-nbc.rng` (RELAX NG)

## Command

```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/nbc-to-canonical.xsl \
  -s:json-generation-pipeline/source/nbc-2020-xml/nbc2020.xml \
  -o:json-generation-pipeline/output/nbc-canonical.xml
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `target-version` | `'2020'` | NBC version year |
| `canonical-version` | `'1.0'` | Canonical format version |

## Key Features

### 1. Canonical ID Generation

Creates stable, hierarchical IDs following the pattern:
```
nbc.{division}.{part}.{section}.{subsection}.{article}.{sentence}.{clause}.{subclause}
```

**Examples:**
- Division: `nbc.divB`
- Part: `nbc.divB.part3`
- Section: `nbc.divB.part3.sect8`
- Article: `nbc.divB.part3.sect8.subsect2.art6`
- Sentence: `nbc.divB.part3.sect8.subsect2.art6.sent1`
- Clause: `nbc.divB.part3.sect8.subsect2.art6.sent1.clause1`

### 2. Vendor ID Preservation

Original Arbortext IDs are preserved in `vendor-id` attributes:
```xml
<article xml:id="nbc.divB.part3.sect8.subsect2.art6" 
         vendor-id="ea004586" 
         number="6">
```

### 3. Division Handling

Supports all NBC divisions with special handling for Volume 2:
- **Division A**: Compliance, Objectives, Functional Statements
- **Division B**: Acceptable Solutions (Volume 1: Parts 1-8)
- **Division BV2**: Acceptable Solutions (Volume 2: Parts 9-12)
- **Division C**: Administrative Provisions

### 4. Two-Pass Processing

**Pass 1: Structure Creation**
- Builds canonical structure with vendor IDs
- Generates canonical IDs
- Preserves all content and metadata

**Pass 2: Reference Resolution**
- Updates all internal references to use canonical IDs
- Resolves cross-references
- Updates intent references

### 5. Content Type Support

Transforms all NBC content types:
- **Structural**: divisions, parts, sections, subsections, articles, sentences, clauses
- **Tables**: Regular tables, special tables (fire/sound resistance, span tables)
- **Figures**: Graphics with EPS file references
- **Application Notes**: Part appendices with numbered notes
- **Appendices**: Division-level appendices (C, D, etc.)
- **Objectives & Functional Statements**: Division A content
- **Definitions**: Glossary terms

## Processing Logic

### Metadata Extraction

```xml
<metadata>
  <catalog-info>
    <nrc-number>...</nrc-number>
    <isbn>...</isbn>
  </catalog-info>
  <publication-info volume="1">
    <title>National Building Code of Canada 2020</title>
    <authority>National Research Council Canada</authority>
    <publication-date>2020</publication-date>
  </publication-info>
</metadata>
```

### Hierarchical Structure

```
OBCode (root)
├── metadata
├── front-matter
│   ├── preface
│   ├── introduction
│   └── committees
├── division (A, B, BV2, C)
│   ├── part (1-12)
│   │   ├── section (1-N)
│   │   │   ├── subsection (1-N)
│   │   │   │   └── article (1-N)
│   │   │   │       ├── sentence (1-N)
│   │   │   │       │   ├── clause (a-z)
│   │   │   │       │   │   └── subclause (1-N)
│   │   │   │       │   ├── objectives
│   │   │   │       │   └── functional-statements
│   │   │   │       ├── table
│   │   │   │       └── figure
│   │   │   └── part-appendix (application notes)
│   │   └── spectables (special tables)
│   └── appendix (C, D, etc.)
└── back-matter
```

### Section Number Extraction

Extracts section numbers from vendor IDs:
```xslt
<!-- Extract section number from vendor ID (e.g., ep001029.37 -> 37) -->
<xsl:variable name="section-number" select="
  if (@id and contains(@id, '.')) then
    substring-after(@id, '.')
  else
    position()"/>
```

### Reference Resolution

Updates all references in Pass 2:
```xslt
<!-- Internal references -->
<ref type="internal" target="nbc.divB.part3.sect8.subsect2.art6">
  Article 3.8.2.6.
</ref>

<!-- Term references -->
<ref type="term" target="bldng">building</ref>

<!-- Standard references -->
<ref type="standard" target="csac22.2no.141" standardId="csac22.2no.141">
  CSA C22.2 No. 141
</ref>
```

## Special Handling

### 1. Volume 2 Parts

Parts in Division BV2 are numbered starting from 9:
```xslt
<xsl:variable name="part-number" select="
  if ($div-letter = 'BV2') then position() + 8
  else position()"/>
```

### 2. Application Notes

Part appendices contain application notes with:
- Introduction text
- Numbered notes with titles
- Paragraphs, tables, figures
- Note divisions (sub-sections)

### 3. Special Tables (spectables)

Fire/sound resistance tables, span tables, etc.:
```xml
<spectables xml:id="nbc.divB.part9.spectables1" 
            table-prefix="A-9.23.4.2." 
            toc-entry="Span Tables for Joists, Rafters and Beams">
  <title>Span Tables</title>
  <table>...</table>
</spectables>
```

### 4. Appendices

Division-level appendices (e.g., Appendix C, D):
```xml
<appendix xml:id="nbc.divB.appendixC" 
          letter="C" 
          number="3">
  <title>Climatic and Seismic Information for Building Design in Canada</title>
  <appsection>...</appsection>
</appendix>
```

### 5. Objectives and Functional Statements

Division A content with hierarchical objectives:
```xml
<objectives>
  <objective xml:id="nbc.divA.obj.OS" key="OS">
    <title>Safety</title>
    <definition>...</definition>
    <sub-objective xml:id="nbc.divA.obj.OS1" key="OS1">
      <title>Structural Safety</title>
      <definition>...</definition>
    </sub-objective>
  </objective>
</objectives>
```

## Output Schema

The canonical format follows this schema:

```xml
<nbc version="2020" edition="15" canonical-version="1.0">
  <metadata>...</metadata>
  <front-matter>...</front-matter>
  <division letter="A|B|C" volume="1|2">
    <part number="1-12">
      <section number="1-N">
        <subsection number="1-N">
          <article number="1-N">
            <sentence number="1-N">
              <text>...</text>
              <clause letter="a-z">
                <subclause number="1-N">...</subclause>
              </clause>
            </sentence>
            <table>...</table>
            <figure>...</figure>
          </article>
        </subsection>
      </section>
      <spectables>...</spectables>
      <part-appendix>...</part-appendix>
    </part>
    <appendix letter="C|D|E">...</appendix>
  </division>
  <back-matter>...</back-matter>
</nbc>
```

## Performance

- **Processing time**: ~10 seconds
- **Memory usage**: ~500 MB
- **Output size**: 5.9 MB (from 11.76 MB input)

## Validation

Validate output against RELAX NG schema:
```bash
java -jar json-generation-pipeline/tools/jing.jar \
  proposed/canonical-nbc.rng \
  json-generation-pipeline/output/nbc-canonical.xml
```

## Error Handling

- **Missing elements**: Generates IDs based on position
- **Invalid vendor IDs**: Falls back to position-based numbering
- **Duplicate IDs**: Logs warnings but continues processing
- **Entity resolution**: Handles 300+ entity declarations for graphics

## Dependencies

- **Saxon HE 12.9+**: XSLT 3.0 processor
- **Java 8+**: Runtime environment
- **Input XML**: NBC 2020 Arbortext format

## Next Steps

After generating canonical XML:
1. **Combine amendments**: Use `combine-amendments.xsl`
2. **Apply amendments**: Use `merge-engine-v3.xsl`
3. **Generate JSON**: Use `canonical-to-json.xsl`

## Related Files

- **Schema**: `proposed/canonical-nbc.rng`
- **Merge engine**: `merge-engine-v3.xsl`
- **JSON generator**: `canonical-to-json.xsl`
- **Source XML**: `json-generation-pipeline/source/nbc-2020-xml/nbc2020.xml`
