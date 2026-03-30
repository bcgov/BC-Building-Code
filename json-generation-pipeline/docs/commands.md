# BC Building Code — Complete Workflow Commands

All commands use the `json-generation-pipeline/` folder structure.
Run from the `BCBuildingCode` root directory.

---

## Step 1: Convert NBC Vendor XML to Canonical Format

Creates hierarchical IDs and preserves vendor IDs for reference mapping.

```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/nbc-to-canonical.xsl \
  -s:json-generation-pipeline/source/nbc-2020-xml/nbc2020.xml \
  -o:json-generation-pipeline/output/nbc-canonical.xml
```

Output: `json-generation-pipeline/output/nbc-canonical.xml` (6.5 MB)
- Hierarchical IDs: `nbc.divA.part1.sect1.subsect1.art1.sent1`
- Vendor IDs preserved as `vendor-id` attributes
- Application notes included

---

## Phase 1: Overlay Amendments (Structural Changes)

### Step 2.1: Combine All Overlay Amendment Files

Edit `json-generation-pipeline/source/bc-amendments/amendment-list.xml` to list your amendment files.

```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/combine-amendments.xsl \
  -s:json-generation-pipeline/source/bc-amendments/amendment-list.xml \
  -o:json-generation-pipeline/output/bc-amendments-combined.xml
```

Output: `json-generation-pipeline/output/bc-amendments-combined.xml`

### Step 2.2: Apply Overlay Amendments to NBC

```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/merge-engine-v3.xsl \
  -s:json-generation-pipeline/output/nbc-canonical.xml \
  overlay-document=json-generation-pipeline/output/bc-amendments-combined.xml \
  -o:json-generation-pipeline/output/bc-building-code.xml
```

Output: `json-generation-pipeline/output/bc-building-code.xml` (6.5 MB)

### Step 2.3: Validate Overlay Amendments

```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/validate-amendments.xsl \
  -s:json-generation-pipeline/output/bc-amendments-combined.xml \
  "combined-amendments=json-generation-pipeline/output/bc-amendments-combined.xml" \
  "bc-building-code=json-generation-pipeline/output/bc-building-code.xml" \
  -o:json-generation-pipeline/output/amendment-validation-report.html 2>&1
```

---

## Phase 2: Revision Amendments (Date-Based Versioning)

### Step 3.1: Combine All Revision Amendment Files

Edit `json-generation-pipeline/source/bc-revisions/revision-list.xml` to list your revision files.

```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/combine-amendments.xsl \
  -s:json-generation-pipeline/source/bc-revisions/revision-list.xml \
  -o:json-generation-pipeline/output/bc-revisions-combined.xml
```

Output: `json-generation-pipeline/output/bc-revisions-combined.xml`

### Step 3.2: Apply Revisions to BC Building Code

```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/merge-engine-v3.xsl \
  -s:json-generation-pipeline/output/bc-building-code.xml \
  overlay-document=json-generation-pipeline/output/bc-revisions-combined.xml \
  -o:json-generation-pipeline/output/bc-building-code-final.xml
```

Output: `json-generation-pipeline/output/bc-building-code-final.xml` (6.5 MB)

### Step 3.3: Validate Revisions

```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/validate-amendments.xsl \
  -s:json-generation-pipeline/output/bc-revisions-combined.xml \
  "combined-amendments=json-generation-pipeline/output/bc-revisions-combined.xml" \
  "bc-building-code=json-generation-pipeline/output/bc-building-code-final.xml" \
  -o:json-generation-pipeline/output/revision-validation-report.html 2>&1
```

---

## Phase 3: JSON Generation

### Step 4.1: Generate Full JSON Output

```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/canonical-to-json.xsl \
  -s:json-generation-pipeline/output/bc-building-code-final.xml \
  -o:json-generation-pipeline/output/bc-building-code.json
```

Output: `json-generation-pipeline/output/bc-building-code.json` (6.9 MB)
- AI-optimized hierarchical JSON structure
- All cross-references preserved
- Rich text formatting maintained
- Includes metadata and BC annotations

### Step 4.2: Generate Minimal JSON Output (Optional)

```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/canonical-to-json-minimal.xsl \
  -s:json-generation-pipeline/output/bc-building-code-final.xml \
  -o:json-generation-pipeline/output/bc-building-code-minimal.json
```

Output: `json-generation-pipeline/output/bc-building-code-minimal.json` — minimal JSON without metadata or BC annotations.

---

## Complete Workflow — All Phases

Run all steps in sequence:

```bash
# Phase 1: NBC to Canonical
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/nbc-to-canonical.xsl \
  -s:json-generation-pipeline/source/nbc-2020-xml/nbc2020.xml \
  -o:json-generation-pipeline/output/nbc-canonical.xml

# Phase 2: Overlay Amendments
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/combine-amendments.xsl \
  -s:json-generation-pipeline/source/bc-amendments/amendment-list.xml \
  -o:json-generation-pipeline/output/bc-amendments-combined.xml

java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/merge-engine-v3.xsl \
  -s:json-generation-pipeline/output/nbc-canonical.xml \
  overlay-document=json-generation-pipeline/output/bc-amendments-combined.xml \
  -o:json-generation-pipeline/output/bc-building-code.xml

# Phase 3: Revision Amendments
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/combine-amendments.xsl \
  -s:json-generation-pipeline/source/bc-revisions/revision-list.xml \
  -o:json-generation-pipeline/output/bc-revisions-combined.xml

java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/merge-engine-v3.xsl \
  -s:json-generation-pipeline/output/bc-building-code.xml \
  overlay-document=json-generation-pipeline/output/bc-revisions-combined.xml \
  -o:json-generation-pipeline/output/bc-building-code-final.xml

# Phase 4: JSON Generation
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/canonical-to-json.xsl \
  -s:json-generation-pipeline/output/bc-building-code-final.xml \
  -o:json-generation-pipeline/output/bc-building-code.json
```

---

## Validation Commands

```bash
# Validate overlay amendments
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/validate-amendments.xsl \
  -s:json-generation-pipeline/output/bc-amendments-combined.xml \
  "combined-amendments=json-generation-pipeline/output/bc-amendments-combined.xml" \
  "bc-building-code=json-generation-pipeline/output/bc-building-code.xml" \
  -o:json-generation-pipeline/output/amendment-validation-report.html 2>&1

# Validate revisions
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/validate-amendments.xsl \
  -s:json-generation-pipeline/output/bc-revisions-combined.xml \
  "combined-amendments=json-generation-pipeline/output/bc-revisions-combined.xml" \
  "bc-building-code=json-generation-pipeline/output/bc-building-code-final.xml" \
  -o:json-generation-pipeline/output/revision-validation-report.html 2>&1

# Validate XML against RELAX NG schema
java -jar json-generation-pipeline/tools/jing.jar \
  json-generation-pipeline/output/schema/canonical-nbc.rng \
  json-generation-pipeline/output/bc-building-code-final.xml

# Validate JSON against JSON Schema (requires Node.js ajv-cli)
ajv validate \
  -s json-generation-pipeline/output/bc-building-code-schema.json \
  -d json-generation-pipeline/output/bc-building-code.json
```

---

## Utility Commands

```bash
# Check file sizes
ls -lh json-generation-pipeline/output/*.xml json-generation-pipeline/output/*.json

# View first 50 lines of JSON output
head -n 50 json-generation-pipeline/output/bc-building-code.json

# Search for specific element in canonical XML
grep -A 5 'xml:id="nbc.divA.part1.sect1.subsect1.art1.sent1"' \
  json-generation-pipeline/output/nbc-canonical.xml

# Count amendments in combined file
grep -c '<amendment' json-generation-pipeline/output/bc-amendments-combined.xml

# Count revisions in combined file
grep -c '<amendment' json-generation-pipeline/output/bc-revisions-combined.xml
```

---

## Expected Output Files

| File | Size | Description |
|------|------|-------------|
| `output/nbc-canonical.xml` | 6.5 MB | Canonical NBC with hierarchical IDs |
| `output/bc-amendments-combined.xml` | ~16 KB | Combined overlay amendments |
| `output/bc-building-code.xml` | 6.5 MB | BC Building Code after overlay amendments |
| `output/bc-revisions-combined.xml` | ~8 KB | Combined revision amendments |
| `output/bc-building-code-final.xml` | 6.5 MB | Final BC Building Code with revisions |
| `output/bc-building-code.json` | 6.9 MB | Full AI-optimized JSON format |
| `output/bc-building-code-minimal.json` | ~5 MB | Minimal JSON format |

---

## Troubleshooting

- "No amendments found" — Check that overlay file contains `<amendment>` elements and verify file path.
- "File not found" — Ensure you're running from `BCBuildingCode` root directory and all source files exist.
- "Broken reference" warnings — Some warnings are normal for notes/definitions without vendor IDs. Structural references should work correctly.
- Slow transformation — Ensure Java 8+ is installed. Transformations can use 1–2 GB RAM.

---

## Equation Processing Fix (Applied 2025-01-19)

Issue: Equations appeared in JSON but with empty `id`, `latex`, `plainText`, `mathml` fields.
Fix: Updated XSLT to use namespace-agnostic selectors for MathML elements.

Files modified:
- `json-generation-pipeline/transformation-xslt/canonical-to-json.xsl`
- `json-generation-pipeline/transformation-xslt/canonical-to-json-minimal.xsl`

After regenerating JSON, equations will have populated fields: `id`, `latex`, `plainText`, `mathml`, `image`, `imageSrc`.

```bash
# Verify equations are working
grep -A 10 '"equations"' json-generation-pipeline/output/bc-building-code.json | head -30

# Count equations with non-empty latex field
grep -c '"latex" : "[^"]' json-generation-pipeline/output/bc-building-code.json
```

Note: Command-line Saxon requires the xmlresolver library. If you encounter `ClassNotFoundException: org.xmlresolver.Resolver`, use Oxygen XML Editor's built-in Saxon processor instead.
