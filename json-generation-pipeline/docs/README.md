# BC Building Code Transformation Pipeline - Technical Documentation

## Overview

This directory contains comprehensive technical documentation for each XSLT transformation in the BC Building Code JSON generation pipeline.

## Pipeline Architecture

The transformation pipeline consists of 6 XSLT stylesheets that work together to convert NBC 2020 XML to BC Building Code JSON:

```
NBC 2020 XML (Arbortext)
    ↓
[1] nbc-to-canonical.xsl
    ↓
NBC Canonical XML
    ↓
[2] combine-amendments.xsl ← BC Amendment Files
    ↓
Combined Amendments
    ↓
[3] merge-engine-v3.xsl
    ↓
BC Building Code XML (Phase 1)
    ↓
[2] combine-amendments.xsl ← BC Revision Files
    ↓
Combined Revisions
    ↓
[3] merge-engine-v3.xsl
    ↓
BC Building Code XML (Final)
    ↓
[4] validate-amendments.xsl → HTML Validation Report
    ↓
[5] canonical-to-json.xsl
    ↓
BC Building Code JSON (Full)

[6] canonical-to-json-minimal.xsl
    ↓
BC Building Code JSON (Minimal Sample)
```

## Documentation Files

### 1. [nbc-to-canonical.md](nbc-to-canonical.md)
**NBC to Canonical Transform**

Converts NBC 2020 Arbortext vendor XML to stable canonical format.

**Key Features**:
- Generates hierarchical canonical IDs
- Preserves vendor IDs for traceability
- Two-pass processing (structure + references)
- Handles all NBC content types
- Supports Volume 1 and Volume 2

**Input**: `nbc2020.xml` (11.76 MB)  
**Output**: `nbc-canonical.xml` (5.9 MB)  
**Time**: ~10 seconds

---

### 2. [combine-amendments.md](combine-amendments.md)
**Combine Multiple Amendment Files**

Merges multiple BC amendment files into a single combined overlay document.

**Key Features**:
- Resolves duplicate amendment IDs
- Renumbers amendments sequentially
- Preserves source file tracking
- Combines text replacement rules
- Maintains original metadata

**Input**: `amendment-list.xml` or `revision-list.xml`  
**Output**: `bc-amendments-combined.xml` or `bc-revisions-combined.xml`  
**Time**: ~2 seconds

---

### 3. [merge-engine-v3.md](merge-engine-v3.md)
**BC Overlay Merge Engine (Single-Pass Optimized)**

Applies BC amendments to NBC canonical XML with O(1) performance.

**Key Features**:
- Single-pass traversal with pre-indexed maps
- O(1) amendment lookups (10x faster)
- Global text replacements (pre-process)
- Revision history auto-population
- Dependent amendment chaining
- Supports all operations: replace, insert, modify, delete

**Input**: `nbc-canonical.xml` + `bc-amendments-combined.xml`  
**Output**: `bc-building-code.xml`  
**Time**: ~10 seconds for 284 amendments

---

### 4. [validate-amendments.md](validate-amendments.md)
**Amendment Validation Engine**

Validates that all amendments were properly applied to the building code.

**Key Features**:
- Verifies each amendment operation
- Generates HTML validation report
- Color-coded status (pass/fail/warning)
- Source file tracking
- Detailed error messages

**Input**: Combined amendments + merged code  
**Output**: `amendment-validation-report.html`  
**Time**: ~5 seconds

---

### 5. [canonical-to-json.md](canonical-to-json.md)
**Canonical to JSON Transform (Full)**

Converts merged canonical XML to structured JSON for AI/LLM systems.

**Key Features**:
- Hierarchical structure preservation
- Rich text with inline markup
- Multiple equation formats (LaTeX, plain text, MathML)
- Optional cross-reference index
- BC amendment tracking
- Revision history snapshots
- Glossary extraction

**Input**: `bc-building-code-final.xml` (5.9 MB)  
**Output**: `bc-building-code.json` (6.9 MB)  
**Time**: ~5 seconds

**Parameters**:
- `include-metadata` (default: true)
- `include-cross-references` (default: false)
- `include-bc-annotations` (default: true)
- `flatten-hierarchy` (default: false)

---

### 6. [canonical-to-json-minimal.md](canonical-to-json-minimal.md)
**Canonical to JSON Transform (Minimal Sample)**

Generates minimal representative sample for LLM study and testing.

**Key Features**:
- Samples all node types
- Configurable limits per level
- Includes total counts
- Embedded schema documentation
- Full statistics

**Input**: `bc-building-code-final.xml` (5.9 MB)  
**Output**: `bc-building-code-minimal.json` (150 KB)  
**Time**: ~2 seconds

**Parameters**:
- `max-parts` (default: 2)
- `max-sections` (default: 3)
- `max-subsections` (default: 3)
- `max-articles` (default: 3)
- `max-sentences` (default: 4)
- `max-clauses` (default: 3)
- `max-appnotes` (default: 5)

---

## Quick Start

### Complete Pipeline Execution

```bash
# Phase 1: NBC to Canonical
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/nbc-to-canonical.xsl \
  -s:json-generation-pipeline/source/nbc-2020-xml/nbc2020.xml \
  -o:json-generation-pipeline/output/nbc-canonical.xml

# Phase 2: Combine Overlay Amendments
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/combine-amendments.xsl \
  -s:proposed/amendment-list.xml \
  -o:json-generation-pipeline/output/bc-amendments-combined.xml

# Phase 3: Apply Overlay Amendments
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/merge-engine-v3.xsl \
  -s:json-generation-pipeline/output/nbc-canonical.xml \
  overlay-document=json-generation-pipeline/output/bc-amendments-combined.xml \
  -o:json-generation-pipeline/output/bc-building-code.xml

# Phase 4: Validate Overlay Amendments
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/validate-amendments.xsl \
  -s:json-generation-pipeline/output/bc-amendments-combined.xml \
  combined-amendments=json-generation-pipeline/output/bc-amendments-combined.xml \
  bc-building-code=json-generation-pipeline/output/bc-building-code.xml \
  -o:json-generation-pipeline/output/amendment-validation-report.html

# Phase 5: Combine Revision Amendments
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/combine-amendments.xsl \
  -s:proposed/revision-list.xml \
  -o:json-generation-pipeline/output/bc-revisions-combined.xml

# Phase 6: Apply Revision Amendments
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/merge-engine-v3.xsl \
  -s:json-generation-pipeline/output/bc-building-code.xml \
  overlay-document=json-generation-pipeline/output/bc-revisions-combined.xml \
  -o:json-generation-pipeline/output/bc-building-code-final.xml

# Phase 7: Validate Revision Amendments
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/validate-amendments.xsl \
  -s:json-generation-pipeline/output/bc-revisions-combined.xml \
  combined-amendments=json-generation-pipeline/output/bc-revisions-combined.xml \
  bc-building-code=json-generation-pipeline/output/bc-building-code-final.xml \
  -o:json-generation-pipeline/output/revision-validation-report.html

# Phase 8: Generate Full JSON
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/canonical-to-json.xsl \
  -s:json-generation-pipeline/output/bc-building-code-final.xml \
  -o:json-generation-pipeline/output/bc-building-code.json

# Phase 9: Generate Minimal JSON Sample
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/canonical-to-json-minimal.xsl \
  -s:json-generation-pipeline/output/bc-building-code-final.xml \
  -o:json-generation-pipeline/output/bc-building-code-minimal.json
```

**Total pipeline time**: ~40 seconds

---

## Performance Summary

| Transformation | Input Size | Output Size | Time | Memory |
|----------------|------------|-------------|------|--------|
| nbc-to-canonical | 11.76 MB | 5.9 MB | ~10s | ~500 MB |
| combine-amendments | N/A | ~500 KB | ~2s | ~100 MB |
| merge-engine-v3 | 5.9 MB | 5.9 MB | ~10s | ~800 MB |
| validate-amendments | N/A | ~500 KB | ~5s | ~200 MB |
| canonical-to-json | 5.9 MB | 6.9 MB | ~5s | ~600 MB |
| canonical-to-json-minimal | 5.9 MB | 150 KB | ~2s | ~200 MB |

**Total**: ~40 seconds, ~800 MB peak memory

---

## Technology Stack

### Core Technologies
- **XSLT 3.0**: All transformations use Saxon HE 12.9+
- **Java 8+**: Runtime environment
- **XML**: Source and intermediate formats
- **JSON**: Final output format
- **RELAX NG**: Schema validation

### Key Libraries
- **Saxon HE 12.9+**: `json-generation-pipeline/tools/saxon.jar`
- **Jing Validator**: `json-generation-pipeline/tools/jing.jar`

### Schemas
- **Canonical NBC**: `proposed/canonical-nbc.rng`
- **BC Overlay**: `proposed/bc-overlay.rng`
- **JSON Schema**: `bc-building-code-schema.json`

---

## File Locations

### Source Files
```
json-generation-pipeline/source/
├── nbc-2020-xml/
│   └── nbc2020.xml                    # NBC 2020 source (11.76 MB)
├── bc-amendments/
│   ├── xml/                           # BC overlay amendment files
│   └── amendment-list.xml             # Amendment file registry
└── bc-revisions/
    ├── xml/                           # BC revision amendment files
    └── revision-list.xml              # Revision file registry
```

### Transformation Files
```
json-generation-pipeline/transformation-xslt/
├── nbc-to-canonical.xsl               # NBC to canonical transform
├── combine-amendments.xsl             # Combine multiple amendments
├── merge-engine-v3.xsl                # Apply amendments (optimized)
├── validate-amendments.xsl            # Validate amendment application
├── canonical-to-json.xsl              # Generate full JSON
└── canonical-to-json-minimal.xsl      # Generate minimal JSON sample
```

### Output Files
```
json-generation-pipeline/output/
├── nbc-canonical.xml                  # Canonical NBC (5.9 MB)
├── bc-amendments-combined.xml         # Combined overlay amendments
├── bc-building-code.xml               # BC code after overlay amendments
├── amendment-validation-report.html   # Overlay validation report
├── bc-revisions-combined.xml          # Combined revision amendments
├── bc-building-code-final.xml         # Final BC code with revisions
├── revision-validation-report.html    # Revision validation report
├── bc-building-code.json              # Full JSON (6.9 MB)
├── bc-building-code-minimal.json      # Minimal JSON sample (150 KB)
└── bc-building-code-schema.json       # JSON schema
```

---

## Common Tasks

### Validate XML Output
```bash
# Validate canonical NBC
java -jar json-generation-pipeline/tools/jing.jar \
  proposed/canonical-nbc.rng \
  json-generation-pipeline/output/nbc-canonical.xml

# Validate BC overlay amendments
java -jar json-generation-pipeline/tools/jing.jar \
  proposed/bc-overlay.rng \
  json-generation-pipeline/output/bc-amendments-combined.xml

# Validate final BC building code
java -jar json-generation-pipeline/tools/jing.jar \
  proposed/canonical-nbc.rng \
  json-generation-pipeline/output/bc-building-code-final.xml
```

### Validate JSON Output
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

### Generate Custom JSON
```bash
# With cross-references (larger file, more features)
java -jar xmlToJson/saxon.jar \
  -xsl:proposed/canonical-to-json.xsl \
  -s:bc-building-code-final.xml \
  include-cross-references=true \
  -o:bc-building-code-with-refs.json

# Without metadata (smaller file)
java -jar xmlToJson/saxon.jar \
  -xsl:proposed/canonical-to-json.xsl \
  -s:bc-building-code-final.xml \
  include-metadata=false \
  include-bc-annotations=false \
  -o:bc-building-code-compact.json

# Custom minimal sample
java -jar xmlToJson/saxon.jar \
  -xsl:proposed/canonical-to-json-minimal.xsl \
  -s:bc-building-code-final.xml \
  max-parts=5 \
  max-sections=5 \
  max-articles=5 \
  -o:bc-building-code-large-sample.json
```

---

## Troubleshooting

### Common Issues

**1. Out of Memory Error**
```bash
# Increase Java heap size
java -Xmx2g -jar json-generation-pipeline/tools/saxon.jar ...
```

**2. Entity Resolution Errors**
```bash
# Use NO-DOCTYPE version of NBC XML
-s:json-generation-pipeline/source/nbc-2020-xml/nbc2020_p1-NO-DOCTYPE.xml
```

**3. Amendment Not Applied**
- Check target ID exists in source document
- Verify amendment sequence order
- Review validation report for details

**4. Invalid JSON Output**
- Validate against schema
- Check for special characters in text
- Verify all references are resolved

---

## Additional Resources

### Project Documentation
- **Main README**: `../README.md`
- **Workflow Guide**: `../WORKFLOW.md`
- **Amendment Guide**: `.kiro/steering/BC Builiding Code - Amendment Creation Guide.md`
- **Revision Guide**: `.kiro/steering/How to make Revision Amendments like Errata, Policy Change, Code revisions etc.md`

### Schemas
- **Canonical NBC**: `proposed/canonical-nbc.rng`
- **BC Overlay**: `proposed/bc-overlay.rng`
- **JSON Schema**: `bc-building-code-schema.json`

### Example Files
- **Amendment examples**: `proposed/amendments/`
- **Revision examples**: `proposed/revisions/`
- **Test files**: `proposed/test/`

---

## Contributing

When adding new transformations or modifying existing ones:

1. **Update documentation**: Add/update corresponding .md file
2. **Add examples**: Include command examples and use cases
3. **Document parameters**: List all parameters with defaults
4. **Include performance**: Add timing and memory usage
5. **Update this README**: Add to pipeline diagram and file list

---

## Version History

- **v3.0** (2025-01): Single-pass merge engine optimization
- **v2.0** (2024-12): Revision history support
- **v1.0** (2024-10): Initial pipeline implementation

---

## Contact

For questions or issues with the transformation pipeline, contact the BC Building Code development team.
