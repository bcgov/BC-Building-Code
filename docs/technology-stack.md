# Technology Stack

## Core Technologies

- **XSLT 3.0**: All transformations use Saxon HE 12.9+ for XSLT 3.0 features
- **Java**: Required for Saxon execution (Java 8 or newer)
- **XML**: Source format (Arbortext vendor XML) and canonical format
- **RELAX NG**: Schema validation for canonical NBC and BC overlay formats
- **JSON**: Output format for AI/LLM consumption

## Key Libraries

- **Saxon HE 12.9+**: Located at `json-generation-pipeline/tools/saxon.jar`
- **Jing Validator**: Located at `json-generation-pipeline/tools/jing.jar`
- **Arbortext DTD**: Located at `NBC2020XML/AE_custom/doctypes/OBCode/`

## Build System

No build system required - direct XSLT transformation via command line.

## Common Commands

### Phase 1: Overlay Amendments (Structural Changes)

#### Transform NBC to Canonical Format
```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/nbc-to-canonical.xsl \
  -s:json-generation-pipeline/source/nbc-2020-xml/nbc2020.xml \
  -o:json-generation-pipeline/output/nbc-canonical.xml
```

#### Combine Multiple Amendment Files
```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/combine-amendments.xsl \
  -s:json-generation-pipeline/source/bc-amendments/amendment-list.xml \
  -o:json-generation-pipeline/output/bc-amendments-combined.xml
```

#### Apply Amendments to NBC
> **Important:** The `overlay-document` parameter must be an **absolute path**. Saxon resolves it
> relative to the `-o:` output file, not the working directory, so a relative path will be doubled
> and fail with `FODC0002`. Use `$PROJ` or `$(pwd)` to anchor it.

```bash
PROJ=/path/to/BC-Building-Code
java -jar "$PROJ/json-generation-pipeline/tools/saxon.jar" \
  -xsl:"$PROJ/json-generation-pipeline/transformation-xslt/merge-engine-v3.xsl" \
  -s:"$PROJ/json-generation-pipeline/output/nbc-canonical.xml" \
  overlay-document="$PROJ/json-generation-pipeline/output/bc-amendments-combined.xml" \
  -o:"$PROJ/json-generation-pipeline/output/bc-building-code.xml"
```

#### Validate Overlay Amendments
```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/validate-amendments.xsl \
  -s:json-generation-pipeline/output/bc-amendments-combined.xml \
  combined-amendments=json-generation-pipeline/output/bc-amendments-combined.xml \
  bc-building-code=json-generation-pipeline/output/bc-building-code.xml \
  -o:json-generation-pipeline/output/amendment-validation-report.html
```

### Phase 2: Revision Amendments (Date-Based Versioning)

#### Combine Revision Files
```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/combine-amendments.xsl \
  -s:json-generation-pipeline/source/bc-revisions/revision-list.xml \
  -o:json-generation-pipeline/output/bc-revisions-combined.xml
```

#### Apply Revisions to BC Building Code
```bash
PROJ=/path/to/BC-Building-Code
java -jar "$PROJ/json-generation-pipeline/tools/saxon.jar" \
  -xsl:"$PROJ/json-generation-pipeline/transformation-xslt/merge-engine-v3.xsl" \
  -s:"$PROJ/json-generation-pipeline/output/bc-building-code.xml" \
  overlay-document="$PROJ/json-generation-pipeline/output/bc-revisions-combined.xml" \
  -o:"$PROJ/json-generation-pipeline/output/bc-building-code-final.xml"
```

#### Validate Revisions
```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/validate-amendments.xsl \
  -s:json-generation-pipeline/output/bc-revisions-combined.xml \
  combined-amendments=json-generation-pipeline/output/bc-revisions-combined.xml \
  bc-building-code=json-generation-pipeline/output/bc-building-code-final.xml \
  -o:json-generation-pipeline/output/revision-validation-report.html
```

### Phase 3: Output Generation

#### Generate JSON Output
```bash
# Basic JSON generation (default settings)
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/canonical-to-json.xsl \
  -s:json-generation-pipeline/output/bc-building-code-final.xml \
  -o:json-generation-pipeline/output/bc-building-code.json

# With cross-references enabled (for navigation/analysis)
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/canonical-to-json.xsl \
  -s:json-generation-pipeline/output/bc-building-code-final.xml \
  include-cross-references=true \
  -o:json-generation-pipeline/output/bc-building-code.json

# Minimal JSON (no metadata, no BC annotations)
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/canonical-to-json-minimal.xsl \
  -s:json-generation-pipeline/output/bc-building-code-final.xml \
  -o:json-generation-pipeline/output/bc-building-code-minimal.json
```

**JSON Generation Parameters:**
- `include-metadata` (default: true) - Include document metadata and publication info
- `include-cross-references` (default: false) - Generate cross-reference index for navigation/analysis
- `include-bc-annotations` (default: true) - Include BC amendments and revision history
- `flatten-hierarchy` (default: false) - Flatten hierarchical structure (experimental)

#### Deploy JSON to Interactive Webapp

After generating `bc-building-code.json`, copy it to the interactive webapp source directory:

```bash
cp json-generation-pipeline/output/bc-building-code.json \
   ../HOUS-Interactive-BCBC/data/source/bcbc-2024.json
```

Then rebuild the webapp's search index and content chunks:

```bash
cd ../HOUS-Interactive-BCBC
npx pnpm generate-assets
```

#### Validate JSON Output
```bash
# Using Node.js ajv-cli (install: npm install -g ajv-cli)
ajv validate -s json-generation-pipeline/output/bc-building-code-schema.json -d json-generation-pipeline/output/bc-building-code.json

# Using Python jsonschema (install: pip install jsonschema)
python -c "import json; import jsonschema; \
  schema = json.load(open('json-generation-pipeline/output/bc-building-code-schema.json')); \
  data = json.load(open('json-generation-pipeline/output/bc-building-code.json')); \
  jsonschema.validate(data, schema); \
  print('✓ JSON is valid')"
```

### XML Schema Validation
```bash
java -jar json-generation-pipeline/tools/jing.jar \
  json-generation-pipeline/output/schema/canonical-nbc.rng \
  json-generation-pipeline/output/bc-building-code.xml
```

## Platform Notes

- **Windows**: Use forward slashes in paths for Git Bash compatibility
- **Entity Resolution**: NBC XML contains 300+ entity declarations for graphics
- **DOCTYPE Handling**: Use NO-DOCTYPE version or ensure DTD files are accessible

## Performance

### Phase 1: Overlay Amendments
- NBC to Canonical: ~10 seconds
- Combine + Apply Amendments: ~10 seconds

### Phase 2: Revision Amendments
- Combine Revisions: ~2 seconds
- Apply Revisions: ~10 seconds
- Validate Revisions: ~5 seconds

### Phase 3: Output Generation
- Generate JSON: ~5 seconds

**Total pipeline: ~40 seconds** (with revisions) or ~25 seconds (without revisions)

## JSON Output Structure

### Division Object Structure

Each division in the JSON output includes:
- `id`: Canonical ID (e.g., "nbc.divA", "nbc.divBV2")
- `type`: Always "division"
- `letter`: Division letter (A, B, or C)
- `volume`: Physical publication volume (1 or 2)
- `title`: Division title
- `number`: Division number
- `source`: Source of division (nbc or bc) - optional
- `parts`: Array of part objects

**Volume Distribution**:
- Volume 1: Division A, Division B (Parts 1-8), Division C
- Volume 2: Division B Part 9 only (represented as divBV2)

### Table JSON Structure (for web rendering)

Table objects include render-critical metadata for merged cells and notes:
- `table_notes[]` with `{id, content}` for footnotes; notes with an inline sub-list also include a `list` object `{type, items[]}` for structured rendering
- `structure.header_rows[]` / `structure.body_rows[]` with row objects (`id`, `type`, `cells`)
- Per-cell span metadata: `rowspan`, `colspan`
- Optional table/grid style metadata: `frame`, `structure.colsep`, `structure.rowsep`

## Validation Tools

- **RELAX NG Schemas**: `json-generation-pipeline/output/schema/bc-overlay.rng`, `json-generation-pipeline/output/schema/canonical-nbc.rng`
- **JSON Schema**: `json-generation-pipeline/output/bc-building-code-schema.json`
- **Jing Validator**: `json-generation-pipeline/tools/jing.jar`
- **xmllint**: Alternative validation via WSL on Windows
- **ajv-cli**: JSON Schema validator for Node.js
- **jsonschema**: JSON Schema validator for Python
