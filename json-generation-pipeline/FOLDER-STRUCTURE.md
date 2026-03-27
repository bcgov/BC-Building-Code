# JSON Generation Pipeline - Folder Structure

```
json-generation-pipeline/
│
├── docs/
│   └── commands.txt                                    # Command reference documentation
│
├── output/                                             # Generated output files
│   ├── schema/
│   │   ├── bc-overlay.rng                             # RELAX NG schema for BC overlay format
│   │   └── canonical-nbc.rng                          # RELAX NG schema for canonical NBC format
│   │
│   ├── bc-amendments-combined.xml                     # Combined BC overlay amendments
│   ├── bc-building-code-final.xml                     # Final BC Building Code (after revisions)
│   ├── bc-building-code-minimal.json                  # Minimal JSON output (no metadata/annotations)
│   ├── bc-building-code-schema.json                   # JSON Schema for BC Building Code
│   ├── bc-building-code.json                          # Full JSON output with metadata
│   ├── bc-building-code.xml                           # BC Building Code (after overlay amendments)
│   ├── bc-revisions-combined.xml                      # Combined BC revision amendments
│   ├── nbc-canonical-author.css                       # CSS for canonical XML viewing
│   ├── nbc-canonical.xml                              # NBC in canonical format with stable IDs
│   └── sample_canonical.xml                           # Sample canonical XML for testing
│
├── oxygen-scenarios/
│   └── scenario.scenarios                             # Oxygen XML Editor transformation scenarios
│
├── source/                                             # Source materials
│   ├── bc-amendments/                                 # BC overlay amendments (Phase 1)
│   │   ├── word/                                      # Original Word documents with BC amendments
│   │   │   ├── NBC2020p1 Division A_FIN.docx
│   │   │   ├── NBC2020p1 Division B Appendix C and D.FIN.docx
│   │   │   ├── NBC2020p1 Division B Part 1.FIN.docx
│   │   │   ├── NBC2020p1 Division B Part 10.FIN.docx
│   │   │   ├── NBC2020p1 Division B Part 2.FIN.docx
│   │   │   ├── NBC2020p1 Division B Part 3.FIN.docx
│   │   │   ├── NBC2020p1 Division B Part 4-8.FIN.docx
│   │   │   ├── NBC2020p1 Division B Part 9.FIN_backup.docx
│   │   │   └── NBC2020p1 Preface.docx
│   │   │
│   │   ├── xml/                                       # BC overlay amendment XML files
│   │   │   ├── NBC2020p1 Division A_FIN.xml
│   │   │   ├── NBC2020p1 Division B Appendix C and D.FIN.xml
│   │   │   ├── NBC2020p1 Division B Part 1 FIN.xml
│   │   │   ├── NBC2020p1 Division B Part 10.FIN.xml
│   │   │   ├── NBC2020p1 Division B Part 3.FIN_1.xml
│   │   │   ├── NBC2020p1 Division B Part 3.FIN_2.xml
│   │   │   ├── NBC2020p1 Division B Part 4-8.FIN.xml
│   │   │   ├── NBC2020p1 Division B Part 9.FIN_1.xml
│   │   │   ├── NBC2020p1 Division B Part 9.FIN_2.xml
│   │   │   ├── NBC2020p1 Division B Part 9.FIN_3.xml
│   │   │   ├── NBC2020p1 Division B Part 9.FIN_4.xml
│   │   │   ├── NBC2020p1 Preface.xml
│   │   │   └── re-organize-nodes.xml
│   │   │
│   │   └── amendment-list.xml                         # Registry of overlay amendment files
│   │
│   ├── bc-revisions/                                  # BC revision amendments (Phase 2)
│   │   ├── pdf/                                       # Original Ministerial Order PDFs
│   │   │   ├── Ministerial Order BA 2024 01.pdf
│   │   │   ├── Ministerial Order BA 2024 02.pdf
│   │   │   ├── Ministerial Order BA 2024 03.pdf
│   │   │   ├── Ministerial Order BA 2024 04.pdf
│   │   │   ├── Ministerial Order BA 2024 05.pdf
│   │   │   └── Ministerial Order BA 2024 06.pdf
│   │   │
│   │   ├── xml/                                       # BC revision amendment XML files
│   │   │   ├── Ministerial Order BA 2024 01.xml
│   │   │   ├── Ministerial Order BA 2024 02.xml
│   │   │   ├── Ministerial Order BA 2024 03.xml
│   │   │   ├── Ministerial Order BA 2024 04.xml
│   │   │   ├── Ministerial Order BA 2024 05.xml
│   │   │   └── Ministerial Order BA 2024 06.xml
│   │   │
│   │   └── revision-list.xml                          # Registry of revision amendment files
│   │
│   └── nbc-2020-xml/
│       └── nbc2020.xml                                # NBC 2020 source XML (Arbortext format)
│
├── tools/                                              # Java libraries
│   ├── jing.jar                                       # RELAX NG validator
│   └── saxon.jar                                      # Saxon HE 12.9+ XSLT 3.0 processor
│
└── transformation-xslt/                                # XSLT transformation stylesheets
    ├── canonical-to-json-minimal.xsl                  # Generate minimal JSON output
    ├── canonical-to-json.xsl                          # Generate full JSON output
    ├── combine-amendments.xsl                         # Combine multiple amendment files
    ├── merge-engine-v3.xsl                            # Apply amendments to canonical XML
    ├── nbc-to-canonical.xsl                           # Convert NBC vendor XML to canonical
    └── validate-amendments.xsl                        # Validate amendment application
```

## Directory Descriptions

### `/docs`
Documentation files including command reference for running transformations.

### `/output`
Generated files from the transformation pipeline:
- **schema/**: RELAX NG schemas for validation
- **XML outputs**: Canonical NBC, BC Building Code (intermediate and final)
- **JSON outputs**: AI-optimized JSON in full and minimal formats
- **Combined amendments**: Merged overlay and revision amendment files

### `/source`
Source materials organized by type:
- **bc-amendments/**: Phase 1 overlay amendments (structural changes to NBC)
  - **word/**: Original Word documents with BC amendments marked in green
  - **xml/**: Structured BC overlay amendment files
- **bc-revisions/**: Phase 2 revision amendments (date-based versioning)
  - **pdf/**: Original Ministerial Order PDFs
  - **xml/**: Structured BC revision amendment files
- **nbc-2020-xml/**: Original NBC 2020 source XML

### `/tools`
Java libraries required for transformations:
- **saxon.jar**: XSLT 3.0 processor (Saxon HE 12.9+)
- **jing.jar**: RELAX NG schema validator

### `/transformation-xslt`
XSLT 3.0 stylesheets for the transformation pipeline:
- NBC to canonical format conversion
- Amendment combining and merging
- JSON generation (full and minimal)
- Validation and reporting

### `/oxygen-scenarios`
Pre-configured transformation scenarios for Oxygen XML Editor.

## Transformation Pipeline Flow

```
Phase 1: Overlay Amendments (Structural Changes)
┌─────────────────────────────────────────────────────────────────┐
│ nbc2020.xml                                                     │
│    ↓ [nbc-to-canonical.xsl]                                     │
│ nbc-canonical.xml                                               │
│    ↓ [combine-amendments.xsl + amendment-list.xml]             │
│ bc-amendments-combined.xml                                      │
│    ↓ [merge-engine-v3.xsl]                                      │
│ bc-building-code.xml                                            │
└─────────────────────────────────────────────────────────────────┘

Phase 2: Revision Amendments (Date-Based Versioning)
┌─────────────────────────────────────────────────────────────────┐
│ bc-building-code.xml                                            │
│    ↓ [combine-amendments.xsl + revision-list.xml]              │
│ bc-revisions-combined.xml                                       │
│    ↓ [merge-engine-v3.xsl]                                      │
│ bc-building-code-final.xml                                      │
└─────────────────────────────────────────────────────────────────┘

Phase 3: JSON Generation
┌─────────────────────────────────────────────────────────────────┐
│ bc-building-code-final.xml                                      │
│    ↓ [canonical-to-json.xsl]                                    │
│ bc-building-code.json (full)                                    │
│    ↓ [canonical-to-json-minimal.xsl]                            │
│ bc-building-code-minimal.json                                   │
└─────────────────────────────────────────────────────────────────┘
```

## File Counts

- **BC Overlay Amendments (XML)**: 13 files
- **BC Overlay Amendments (Word)**: 9 files
- **BC Revision Amendments (XML)**: 6 files
- **BC Revision Amendments (PDF)**: 6 files
- **XSLT Transformations**: 6 files
- **Output Files**: 10 files
- **Schema Files**: 2 files
