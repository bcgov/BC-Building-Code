# BC Building Code - JSON Generation Pipeline

A complete XML transformation pipeline that converts the National Building Code (NBC) 2020 to the BC Building Code by applying British Columbia-specific amendments, then generates AI-optimized JSON output.

## Quick Start

All commands run from the BCBuildingCode root directory:

```bash
# Complete pipeline (all phases)
java -jar json-generation-pipeline/tools/saxon.jar -xsl:json-generation-pipeline/transformation-xslt/nbc-to-canonical.xsl -s:json-generation-pipeline/source/nbc-2020-xml/nbc2020.xml -o:json-generation-pipeline/output/nbc-canonical.xml

java -jar json-generation-pipeline/tools/saxon.jar -xsl:json-generation-pipeline/transformation-xslt/combine-amendments.xsl -s:json-generation-pipeline/source/bc-amendments/amendment-list.xml -o:json-generation-pipeline/output/bc-amendments-combined.xml

java -jar json-generation-pipeline/tools/saxon.jar -xsl:json-generation-pipeline/transformation-xslt/merge-engine-v3.xsl -s:json-generation-pipeline/output/nbc-canonical.xml overlay-document=json-generation-pipeline/output/bc-amendments-combined.xml -o:json-generation-pipeline/output/bc-building-code.xml

java -jar json-generation-pipeline/tools/saxon.jar -xsl:json-generation-pipeline/transformation-xslt/combine-amendments.xsl -s:json-generation-pipeline/source/bc-revisions/revision-list.xml -o:json-generation-pipeline/output/bc-revisions-combined.xml

java -jar json-generation-pipeline/tools/saxon.jar -xsl:json-generation-pipeline/transformation-xslt/merge-engine-v3.xsl -s:json-generation-pipeline/output/bc-building-code.xml overlay-document=json-generation-pipeline/output/bc-revisions-combined.xml -o:json-generation-pipeline/output/bc-building-code-final.xml

java -jar json-generation-pipeline/tools/saxon.jar -xsl:json-generation-pipeline/transformation-xslt/canonical-to-json.xsl -s:json-generation-pipeline/output/bc-building-code-final.xml -o:json-generation-pipeline/output/bc-building-code.json
```

## Documentation

- **[FOLDER-STRUCTURE.md](FOLDER-STRUCTURE.md)** - Complete folder structure with descriptions
- **[docs/commands.txt](docs/commands.txt)** - All transformation commands with detailed explanations
- **[.kiro/steering/](../.kiro/steering/)** - Amendment creation guides and patterns

## Pipeline Overview

### Phase 1: NBC to Canonical Format
Converts NBC vendor XML to stable hierarchical format with canonical IDs.

**Input:** `source/nbc-2020-xml/nbc2020.xml`  
**Output:** `output/nbc-canonical.xml`  
**XSLT:** `transformation-xslt/nbc-to-canonical.xsl`

### Phase 2: Overlay Amendments (Structural Changes)
Applies BC-specific structural changes to the NBC.

**Input:** `output/nbc-canonical.xml` + `source/bc-amendments/xml/*.xml`  
**Output:** `output/bc-building-code.xml`  
**XSLT:** `transformation-xslt/combine-amendments.xsl` + `transformation-xslt/merge-engine-v3.xsl`

### Phase 3: Revision Amendments (Date-Based Versioning)
Applies ministerial orders, errata, and policy changes with effective dates.

**Input:** `output/bc-building-code.xml` + `source/bc-revisions/xml/*.xml`  
**Output:** `output/bc-building-code-final.xml`  
**XSLT:** `transformation-xslt/combine-amendments.xsl` + `transformation-xslt/merge-engine-v3.xsl`

### Phase 4: JSON Generation
Generates AI-optimized JSON from the final BC Building Code.

**Input:** `output/bc-building-code-final.xml`  
**Output:** `output/bc-building-code.json` (full) or `output/bc-building-code-minimal.json` (minimal)  
**XSLT:** `transformation-xslt/canonical-to-json.xsl` or `transformation-xslt/canonical-to-json-minimal.xsl`

## Folder Structure

```
json-generation-pipeline/
├── source/                      # Source materials
│   ├── nbc-2020-xml/           # NBC 2020 source XML
│   ├── bc-amendments/          # BC overlay amendments (Phase 2)
│   │   ├── xml/                # Amendment XML files
│   │   ├── word/               # Original Word documents
│   │   └── amendment-list.xml  # Registry of amendments
│   └── bc-revisions/           # BC revision amendments (Phase 3)
│       ├── xml/                # Revision XML files
│       ├── pdf/                # Original Ministerial Order PDFs
│       └── revision-list.xml   # Registry of revisions
├── transformation-xslt/         # XSLT transformation stylesheets
├── tools/                       # Saxon and Jing JAR files
├── output/                      # Generated XML and JSON files
│   └── schema/                 # RELAX NG schemas
└── docs/                        # Command reference documentation
```

## Key Files

### Source Files
- `source/nbc-2020-xml/nbc2020.xml` - NBC 2020 source XML (Arbortext format)
- `source/bc-amendments/amendment-list.xml` - Registry of overlay amendment files
- `source/bc-revisions/revision-list.xml` - Registry of revision amendment files

### XSLT Transformations
- `transformation-xslt/nbc-to-canonical.xsl` - NBC to canonical format
- `transformation-xslt/combine-amendments.xsl` - Combine multiple amendment files
- `transformation-xslt/merge-engine-v3.xsl` - Apply amendments to canonical XML
- `transformation-xslt/canonical-to-json.xsl` - Generate full JSON output
- `transformation-xslt/canonical-to-json-minimal.xsl` - Generate minimal JSON output
- `transformation-xslt/validate-amendments.xsl` - Validate amendment application

### Output Files
- `output/nbc-canonical.xml` - NBC with canonical IDs (6.5 MB)
- `output/bc-amendments-combined.xml` - Combined overlay amendments
- `output/bc-building-code.xml` - BC Building Code after overlay amendments (6.5 MB)
- `output/bc-revisions-combined.xml` - Combined revision amendments
- `output/bc-building-code-final.xml` - Final BC Building Code with revisions (6.5 MB)
- `output/bc-building-code.json` - Full AI-optimized JSON (6.9 MB)
- `output/bc-building-code-minimal.json` - Minimal JSON output (~5 MB)
- `output/bc-building-code-schema.json` - JSON Schema

### Schemas
- `output/schema/bc-overlay.rng` - RELAX NG schema for BC overlay format
- `output/schema/canonical-nbc.rng` - RELAX NG schema for canonical NBC format

## Tools

- **Saxon HE 12.9+** (`tools/saxon.jar`) - XSLT 3.0 processor
- **Jing** (`tools/jing.jar`) - RELAX NG validator

## Performance

- **Phase 1** (NBC to Canonical): ~10 seconds
- **Phase 2** (Overlay Amendments): ~10 seconds
- **Phase 3** (Revision Amendments): ~10 seconds
- **Phase 4** (JSON Generation): ~5 seconds

**Total pipeline: ~35 seconds**

## Amendment Creation

See the comprehensive guides in `.kiro/steering/`:
- **BC Builiding Code - Amendment Creation Guide.md** - How to create overlay amendments
- **How to make Revision Amendments like Errata, Policy Change, Code revisions etc.md** - How to create revision amendments
- **Global Text Replacements Feature.md** - Bulk find-replace operations

## Validation

```bash
# Validate overlay amendments
java -jar json-generation-pipeline/tools/saxon.jar -xsl:json-generation-pipeline/transformation-xslt/validate-amendments.xsl -s:json-generation-pipeline/output/bc-amendments-combined.xml "combined-amendments=json-generation-pipeline/output/bc-amendments-combined.xml" "bc-building-code=json-generation-pipeline/output/bc-building-code.xml" -o:json-generation-pipeline/output/amendment-validation-report.html

# Validate revisions
java -jar json-generation-pipeline/tools/saxon.jar -xsl:json-generation-pipeline/transformation-xslt/validate-amendments.xsl -s:json-generation-pipeline/output/bc-revisions-combined.xml "combined-amendments=json-generation-pipeline/output/bc-revisions-combined.xml" "bc-building-code=json-generation-pipeline/output/bc-building-code-final.xml" -o:json-generation-pipeline/output/revision-validation-report.html

# Validate XML against RELAX NG schema
java -jar json-generation-pipeline/tools/jing.jar json-generation-pipeline/output/schema/canonical-nbc.rng json-generation-pipeline/output/bc-building-code-final.xml

# Validate JSON against JSON Schema (requires Node.js ajv-cli)
ajv validate -s json-generation-pipeline/output/bc-building-code-schema.json -d json-generation-pipeline/output/bc-building-code.json
```

## Requirements

- Java 8 or newer
- 1-2 GB RAM for transformations
- Windows, macOS, or Linux

## License

See [LICENSE](../LICENSE) file in root directory.
