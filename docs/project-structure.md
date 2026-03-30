# Project Structure

## Root Directory Organization

```
BCBuildingCode/
├── json-generation-pipeline/        # Complete transformation pipeline (primary working area)
│   ├── source/                      # Source materials (NBC XML, amendments, revisions)
│   ├── transformation-xslt/         # XSLT transformation stylesheets
│   ├── tools/                       # Saxon and Jing JAR files
│   ├── output/                      # Generated XML and JSON files
│   └── docs/                        # Pipeline documentation
├── docs/                            # Repository-level documentation
├── bc-graphics/                     # BC-specific graphics (EPS format)
├── graphics/                        # NBC graphics (EPS/JPG/HTML)
├── NBC2020XML/                      # NBC 2020 Arbortext source project (legacy)
├── Word-BCBC-mark-ups/              # BC Building Code Word documents (legacy)
└── proposed/                        # Legacy XSLT and schemas (use json-generation-pipeline/ instead)
```

## Key Directories

### json-generation-pipeline/
Complete transformation pipeline — the primary working area:

**source/** - Source materials:
- `nbc-2020-xml/nbc2020.xml` - NBC 2020 source XML
- `bc-amendments/xml/` - BC overlay amendment files (structural changes)
- `bc-amendments/word/` - Original Word documents with BC amendments
- `bc-amendments/amendment-list.xml` - Registry of overlay amendment files
- `bc-revisions/xml/` - BC revision amendment files (date-based versioning)
- `bc-revisions/pdf/` - Original Ministerial Order PDFs
- `bc-revisions/revision-list.xml` - Registry of revision amendment files

**transformation-xslt/** - XSLT stylesheets:
- `nbc-to-canonical.xsl` - Converts NBC vendor XML to canonical format
- `merge-engine-v3.xsl` - Applies BC amendments/revisions to canonical NBC
- `combine-amendments.xsl` - Merges multiple amendment/revision files
- `canonical-to-json.xsl` - Generates full JSON output
- `canonical-to-json-minimal.xsl` - Generates minimal JSON output
- `validate-amendments.xsl` - Validates amendment/revision application

**tools/** - Java libraries:
- `saxon.jar` - Saxon HE 12.9+ XSLT processor
- `jing.jar` - RELAX NG validator

**output/** - Generated files:
- `nbc-canonical.xml` - NBC with canonical IDs (5.9 MB)
- `bc-amendments-combined.xml` - Combined BC overlay amendments
- `bc-building-code.xml` - BC Building Code after overlay amendments (5.9 MB)
- `bc-revisions-combined.xml` - Combined BC revision amendments
- `bc-building-code-final.xml` - Final BC Building Code with revisions
- `bc-building-code.json` - Full AI-optimized JSON (6.9 MB)
- `bc-building-code-minimal.json` - Minimal JSON output
- `bc-building-code-schema.json` - JSON Schema
- `schema/bc-overlay.rng` - RELAX NG schema for BC overlay format
- `schema/canonical-nbc.rng` - RELAX NG schema for canonical NBC format
- `amendment-validation-report.html` - Overlay amendment validation results
- `revision-validation-report.html` - Revision amendment validation results

**docs/** - Documentation:
- `docs/project/` - Comprehensive project documentation (system overview, guides, reference)
- `commands.txt` - Command reference for all transformations
- Individual XSLT documentation files

### NBC2020XML/ (Legacy)
Original NBC 2020 Arbortext project from National Research Council:
- `NBC_2020_p1_3.3/nbc2020_p1.xml` - Main NBC XML (11.76 MB, 264k lines)
- `NBC_2020_p1_3.3/nbc2020_p1-NO-DOCTYPE.xml` - Version without DOCTYPE (for processing)
- `NBC_2020_p1_3.3/graphic/` - 593 EPS graphics organized by category
- `AE_custom/doctypes/OBCode/` - Arbortext DTD and configuration
- `AE_custom/entities/` - Entity definitions and FOSI formatting
- `docs/` - Comprehensive Arbortext documentation

### bc-graphics/
BC-specific graphics in EPS format (figures referenced in BC amendments)

### graphics/
NBC graphics organized by category (EPS, JPG, HTML, MMF formats)

## File Naming Conventions

### Overlay Amendment Files (Structural Changes)
- By part: `bc-part-1-amendments.xml`
- By date: `bc-amendments-2024-10-29.xml`
- By topic: `bc-fire-safety-amendments.xml`
- All in `json-generation-pipeline/source/bc-amendments/xml/` directory

### Revision Amendment Files (Date-Based Versioning)
- By ministerial order: `Ministerial Order BA 2024 01.xml`
- By errata: `bc-errata-2025.xml`
- By policy: `bc-policy-updates-2025.xml`
- All in `json-generation-pipeline/source/bc-revisions/xml/` directory

### Canonical IDs
- Format: `nbc.divB.part3.sect7.subsect3.art1.sent1.clause1`
- All content (NBC and BC) uses `nbc.` prefix for unified namespace
- BC-specific content identified by `source="bc"` attribute
- Divisions: divA (Division A), divB (Division B), divBV2 (Division B Volume 2), divC (Appendices)

### Canonical XML Format

**Division Elements** include the following attributes:
- `xml:id`: Canonical ID (nbc.divA, nbc.divB, nbc.divBV2, nbc.divC)
- `letter`: Division letter (A, B, or C)
- `volume`: Physical publication volume (1 or 2)
- `vendor-id`: Original NBC vendor ID (optional)
- `source`: Source of division (nbc or bc) - optional

**Volume Attribute**:
- `volume="1"`: Division A, Division B (Parts 1-8), Division C
- `volume="2"`: Division B Part 9 only (divBV2)

**Example - Division BV2 (Volume 2)**:
```xml
<division xml:id="nbc.divBV2" letter="B" volume="2" vendor-id="nbc2020-b-v2">
  <title>Acceptable Solutions</title>
  <number>Division B</number>
  <part xml:id="nbc.divBV2.part9" number="9">
    <title>Housing and Small Buildings</title>
  </part>
</division>
```

### Vendor IDs (Original NBC)
- Articles: `ea` prefix (e.g., `ea004586`)
- Sentences: `es` prefix (e.g., `es007850`)
- Figures: `en` prefix (e.g., `en000045f1`)
- Tables: `et` prefix (e.g., `et000060`)
- Graphics: `EG` or `GG` prefix (e.g., `EG01200A`)

## Important Patterns

### Amendment Structure
Each amendment file follows BC overlay format:
```xml
<bc-overlay version="1.0" nbc-target-version="2020">
  <metadata>...</metadata>
  <amendments>
    <amendment id="bc-XXX" sequence="N">
      <target type="canonical-id" id="nbc.divB..."/>
      <replace|insert|modify|remove>
        <new-content source="bc">...</new-content>
      </replace|insert|modify|remove>
    </amendment>
  </amendments>
</bc-overlay>
```

### Hierarchical Structure
NBC follows strict hierarchy:
- Division → Part → Section → Subsection → Article → Sentence → Clause → Subclause

### Cross-References
- Internal: `<ref type="internal" target="nbc.divB.part3.sect7..."/>`
- Terms: `<ref type="term" target="bldng">building</ref>`
- Standards: `<ref type="standard" target="csac22.2no.141" standardId="csac22.2no.141"/>`
- BC codes: `<ref type="bc-code" target="bcfc">BC Fire Code</ref>`

## Documentation Map

### Repository-Level (docs/)
- `docs/product-overview.md` - Product overview and purpose
- `docs/technology-stack.md` - Technology stack, commands, performance
- `docs/project-structure.md` - This file
- `docs/VALIDATION_PIPELINE.md` - GitHub Actions JSON validation pipeline

### Pipeline Documentation (json-generation-pipeline/docs/project/)
- `01-system-overview.md` - System overview and key concepts
- `02-overlay-amendments-guide.md` - Phase 1 amendment guide
- `03-revision-amendments-guide.md` - Phase 2 amendment guide
- `04-merge-engine-reference.md` - Technical merge engine reference
- `05-validation-troubleshooting.md` - Validation error troubleshooting
- `06-quick-reference.md` - Single-page quick reference
- `07-examples-library.md` - Curated working examples
- `08-migration-guide.md` - Migration guide (legacy to new pipeline)
- `09-json-output-guide.md` - JSON output structure and usage
- `10-oxygen-xml-editor-guide.md` - Visual editing guide for Oxygen XML
- `11-global-text-replacements.md` - Global text replacements (pre-processing)

### XSLT Documentation (json-generation-pipeline/docs/)
- Individual documentation for each XSLT stylesheet
