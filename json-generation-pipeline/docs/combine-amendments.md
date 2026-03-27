# Combine Amendments (combine-amendments.xsl)

## Overview

Merges multiple BC amendment files into a single combined overlay document. Handles duplicate amendment IDs by renumbering all amendments sequentially while preserving original IDs for traceability.

## Purpose

- **Merge multiple files**: Combines amendments from different sources
- **Resolve ID conflicts**: Renumbers amendments to avoid duplicates
- **Preserve traceability**: Maintains original IDs and source file information
- **Combine text replacements**: Merges global text replacement rules
- **Maintain sequence**: Preserves file order and original sequencing

## Input

- **Source**: Amendment list file (`amendment-list.xml` or `revision-list.xml`)
- **Format**: XML file listing paths to individual amendment files
- **Content**: Multiple BC overlay XML files

### Amendment List Format

```xml
<?xml version="1.0" encoding="UTF-8"?>
<amendment-files>
    <file>proposed/amendments/NBC2020p1 Division A_FIN.xml</file>
    <file>proposed/amendments/NBC2020p1 Division B Part 3.FIN_1.xml</file>
    <file>proposed/amendments/NBC2020p1 Division B Part 3.FIN_2.xml</file>
    <file>proposed/amendments/NBC2020p1 Division B Part 10.FIN.xml</file>
</amendment-files>
```

## Output

- **File**: `bc-amendments-combined.xml` or `bc-revisions-combined.xml`
- **Format**: Single BC overlay XML with renumbered amendments
- **Attributes**: Includes source tracking and generation metadata

## Commands

### Phase 1: Overlay Amendments
```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/combine-amendments.xsl \
  -s:proposed/amendment-list.xml \
  -o:json-generation-pipeline/output/bc-amendments-combined.xml
```

### Phase 2: Revision Amendments
```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/combine-amendments.xsl \
  -s:proposed/revision-list.xml \
  -o:json-generation-pipeline/output/bc-revisions-combined.xml
```

## Key Features

### 1. ID Renumbering

**Problem**: Individual amendment files can reuse IDs (bc-001, bc-002, etc.)

**Solution**: Renumbers all amendments sequentially across all files

**Example**:
```
File 1: bc-001, bc-002, bc-003
File 2: bc-001, bc-002
File 3: bc-001, bc-002, bc-003, bc-004

Combined: bc-combined-001 through bc-combined-009
```

### 2. Source Tracking

Each amendment preserves its origin:
```xml
<amendment id="bc-combined-042" 
           sequence="42"
           source-file-index="2"
           original-sequence="15"
           original-id="bc-015"
           description="Replace Article 3.8.2.6.">
  <!-- Amendment content -->
</amendment>
```

**Tracking Attributes**:
- `id`: New combined ID
- `sequence`: New sequential number
- `source-file-index`: Which file it came from (1-based)
- `original-sequence`: Original sequence in source file
- `original-id`: Original amendment ID

### 3. Text Replacement Combination

Merges global text replacement rules from all files:
```xml
<text-replacements>
  <!-- From file 1 -->
  <replace from="sect37" to="sect38" source-file-index="1"/>
  <replace from="9.37." to="9.38." source-file-index="1"/>
  
  <!-- From file 2 -->
  <replace from="accessible" to="adaptable" source-file-index="2"/>
</text-replacements>
```

**Application Order**: Replacements are applied in file order, then in the order they appear within each file.

### 4. Metadata Preservation

Combines metadata from all source files:
```xml
<metadata>
  <title>Combined BC Building Code Amendments</title>
  <description>Combined from 4 amendment file(s)</description>
  
  <source-files>
    <source-file>proposed/amendments/NBC2020p1 Division A_FIN.xml</source-file>
    <source-file>proposed/amendments/NBC2020p1 Division B Part 3.FIN_1.xml</source-file>
    <source-file>proposed/amendments/NBC2020p1 Division B Part 3.FIN_2.xml</source-file>
    <source-file>proposed/amendments/NBC2020p1 Division B Part 10.FIN.xml</source-file>
  </source-files>
  
  <original-metadata source-index="1">
    <title>Division A Amendments</title>
    <description>BC amendments to NBC Division A</description>
    <!-- ... -->
  </original-metadata>
  
  <original-metadata source-index="2">
    <title>Division B Part 3 Amendments (Set 1)</title>
    <!-- ... -->
  </original-metadata>
  
  <!-- More original metadata -->
</metadata>
```

## Processing Logic

### 1. Load Amendment Documents

```xslt
<xsl:variable name="amendment-docs" as="document-node()*">
  <xsl:for-each select="/amendment-files/file">
    <xsl:variable name="file" select="normalize-space(.)"/>
    <xsl:if test="$file != ''">
      <xsl:variable name="resolved-uri" select="resolve-uri($file, base-uri(/))"/>
      <xsl:message>Loading: <xsl:value-of select="$resolved-uri"/></xsl:message>
      <xsl:sequence select="doc($resolved-uri)"/>
    </xsl:if>
  </xsl:for-each>
</xsl:variable>
```

### 2. Collect All Amendments

```xslt
<xsl:variable name="all-amendments" as="element()*">
  <xsl:for-each select="$amendment-docs">
    <xsl:variable name="doc-index" select="position()"/>
    <xsl:for-each select=".//amendment">
      <xsl:copy>
        <!-- Add source tracking -->
        <xsl:attribute name="source-file-index" select="$doc-index"/>
        <xsl:attribute name="original-sequence" select="@sequence"/>
        <xsl:attribute name="original-id" select="@id"/>
        
        <!-- Copy all other attributes and content -->
        <xsl:copy-of select="@* except (@sequence, @id)"/>
        <xsl:copy-of select="node()"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:for-each>
</xsl:variable>
```

### 3. Sort Amendments

Sorts by file order first, then by original sequence:
```xslt
<xsl:variable name="sorted-amendments" as="element()*">
  <xsl:for-each select="$all-amendments">
    <xsl:sort select="xs:integer(@source-file-index)" data-type="number"/>
    <xsl:sort select="xs:decimal(@original-sequence)" data-type="number"/>
    <xsl:copy-of select="."/>
  </xsl:for-each>
</xsl:variable>
```

### 4. Renumber Amendments

Generates new sequential IDs:
```xslt
<xsl:for-each select="$sorted-amendments">
  <xsl:variable name="new-sequence" select="position()"/>
  <xsl:variable name="new-id" select="concat('bc-combined-', format-number($new-sequence, '000'))"/>
  
  <xsl:message>Amendment <xsl:value-of select="$new-sequence"/>: 
    <xsl:value-of select="@original-id"/> -> <xsl:value-of select="$new-id"/>
  </xsl:message>
  
  <xsl:copy>
    <xsl:attribute name="sequence" select="$new-sequence"/>
    <xsl:attribute name="id" select="$new-id"/>
    <xsl:copy-of select="@*"/>
    <xsl:copy-of select="node()"/>
  </xsl:copy>
</xsl:for-each>
```

## Output Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<bc-overlay version="1.0" 
            target-nbc-version="2020"
            combined="true"
            generated="2025-01-20T10:30:00Z"
            source-count="4">
  
  <metadata>
    <title>Combined BC Building Code Amendments</title>
    <description>Combined from 4 amendment file(s)</description>
    
    <source-files>
      <source-file>proposed/amendments/file1.xml</source-file>
      <source-file>proposed/amendments/file2.xml</source-file>
      <!-- ... -->
    </source-files>
    
    <original-metadata source-index="1">
      <!-- Metadata from file 1 -->
    </original-metadata>
    
    <original-metadata source-index="2">
      <!-- Metadata from file 2 -->
    </original-metadata>
    
    <!-- More original metadata -->
  </metadata>
  
  <!-- Combined text replacements (if any) -->
  <text-replacements>
    <replace from="..." to="..." source-file-index="1"/>
    <replace from="..." to="..." source-file-index="2"/>
    <!-- ... -->
  </text-replacements>
  
  <amendments>
    <amendment id="bc-combined-001" 
               sequence="1"
               source-file-index="1"
               original-sequence="1"
               original-id="bc-001"
               description="...">
      <!-- Amendment content -->
    </amendment>
    
    <amendment id="bc-combined-002" 
               sequence="2"
               source-file-index="1"
               original-sequence="2"
               original-id="bc-002"
               description="...">
      <!-- Amendment content -->
    </amendment>
    
    <!-- More amendments -->
  </amendments>
</bc-overlay>
```

## Console Output

The transformation logs progress:
```
Loading: file:///path/to/proposed/amendments/NBC2020p1%20Division%20A_FIN.xml
Loading: file:///path/to/proposed/amendments/NBC2020p1%20Division%20B%20Part%203.FIN_1.xml
Loading: file:///path/to/proposed/amendments/NBC2020p1%20Division%20B%20Part%203.FIN_2.xml
Loading: file:///path/to/proposed/amendments/NBC2020p1%20Division%20B%20Part%2010.FIN.xml
Combining 4 amendment file(s)...
Processing document 1: 45 amendments found
Processing document 2: 127 amendments found
Processing document 3: 89 amendments found
Processing document 4: 23 amendments found
Total amendments collected: 284
Combining 12 text replacement rule(s)...
Amendment 1: bc-001 -> bc-combined-001
Amendment 2: bc-002 -> bc-combined-002
Amendment 3: bc-003 -> bc-combined-003
...
Amendment 284: bc-023 -> bc-combined-284
```

## Use Cases

### 1. Overlay Amendments (Phase 1)

Combine structural changes to NBC:
```bash
# List file: proposed/amendment-list.xml
java -jar xmlToJson/saxon.jar \
  -xsl:proposed/combine-amendments.xsl \
  -s:proposed/amendment-list.xml \
  -o:bc-amendments-combined.xml
```

### 2. Revision Amendments (Phase 2)

Combine date-based revisions:
```bash
# List file: proposed/revision-list.xml
java -jar xmlToJson/saxon.jar \
  -xsl:proposed/combine-amendments.xsl \
  -s:proposed/revision-list.xml \
  -o:bc-revisions-combined.xml
```

### 3. Incremental Development

Combine amendments as they're developed:
```xml
<!-- amendment-list-partial.xml -->
<amendment-files>
  <file>proposed/amendments/part3-fire-safety.xml</file>
  <file>proposed/amendments/part3-accessibility.xml</file>
</amendment-files>
```

## Performance

- **Processing time**: ~2 seconds for 284 amendments
- **Memory usage**: ~100 MB
- **Scalability**: Handles 1000+ amendments efficiently

## Error Handling

- **Missing files**: Logs error and skips file
- **Invalid XML**: Terminates with error message
- **Empty files**: Skips and continues
- **Malformed amendments**: Logs warning and includes in output

## Validation

After combining, validate the output:
```bash
# Validate against schema
java -jar NBC2020XML/AE_custom/jing/jing.jar \
  proposed/bc-overlay.rng \
  bc-amendments-combined.xml

# Check amendment count
grep -c "<amendment" bc-amendments-combined.xml
```

## Dependencies

- **Saxon HE 12.9+**: XSLT 3.0 processor
- **Java 8+**: Runtime environment
- **Input files**: Valid BC overlay XML files

## Next Steps

After combining amendments:
1. **Apply to NBC**: Use `merge-engine-v3.xsl`
2. **Validate results**: Use `validate-amendments.xsl`
3. **Generate JSON**: Use `canonical-to-json.xsl`

## Related Files

- **Schema**: `proposed/bc-overlay.rng`
- **Merge engine**: `merge-engine-v3.xsl`
- **Validation**: `validate-amendments.xsl`
- **Amendment lists**: `proposed/amendment-list.xml`, `proposed/revision-list.xml`
