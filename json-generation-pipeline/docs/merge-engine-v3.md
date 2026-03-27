# BC Overlay Merge Engine V3 (merge-engine-v3.xsl)

## Overview

Single-pass optimized merge engine that applies BC amendments to the NBC canonical XML. Uses pre-indexed maps for O(1) lookups, dramatically improving performance over sequential processing.

## Purpose

- **Apply amendments**: Merges BC overlay amendments into NBC canonical XML
- **High performance**: Single-pass traversal with O(1) map lookups
- **Support all operations**: replace, insert, modify, delete
- **Handle revisions**: Auto-populates revision history
- **Resolve references**: Updates cross-references after merge

## Input

- **Source**: NBC canonical XML (`nbc-canonical.xml` or `bc-building-code.xml`)
- **Overlay**: Combined amendments (`bc-amendments-combined.xml` or `bc-revisions-combined.xml`)
- **Format**: Canonical NBC + BC overlay XML

## Output

- **Phase 1**: `bc-building-code.xml` (NBC + overlay amendments)
- **Phase 2**: `bc-building-code-final.xml` (BC code + revisions)
- **Format**: Canonical NBC XML with BC amendments applied

## Commands

### Phase 1: Apply Overlay Amendments
```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/merge-engine-v3.xsl \
  -s:json-generation-pipeline/output/nbc-canonical.xml \
  overlay-document=json-generation-pipeline/output/bc-amendments-combined.xml \
  -o:json-generation-pipeline/output/bc-building-code.xml
```

### Phase 2: Apply Revision Amendments
```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/merge-engine-v3.xsl \
  -s:json-generation-pipeline/output/bc-building-code.xml \
  overlay-document=json-generation-pipeline/output/bc-revisions-combined.xml \
  -o:json-generation-pipeline/output/bc-building-code-final.xml
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `overlay-document` | (required) | Path to combined amendments file |
| `validate-references` | `false` | Enable reference validation |
| `preserve-nbc-ids` | `true` | Keep original NBC IDs |

## Key Features

### 1. Single-Pass Optimization

**Traditional Approach** (N passes):
- Pass 1: Apply amendment 1
- Pass 2: Apply amendment 2
- ...
- Pass N: Apply amendment N
- **Time complexity**: O(N × M) where N = amendments, M = document size

**V3 Approach** (1 pass):
- Pre-index all amendments by target ID
- Single traversal with O(1) map lookups
- **Time complexity**: O(M) where M = document size

**Performance Improvement**: ~10x faster for 284 amendments

### 2. Pre-Computed Amendment Indexes

Six specialized maps for O(1) lookups:

```xslt
<!-- Map: canonical-id -> amendments targeting that ID -->
<xsl:variable name="amendments-by-canonical-id" as="map(xs:string, element()*)">
  <xsl:map>
    <xsl:for-each-group select="$sorted-amendments[target/@type = 'canonical-id']"
                       group-by="string(target/@id)">
      <xsl:map-entry key="current-grouping-key()" select="current-group()"/>
    </xsl:for-each-group>
  </xsl:map>
</xsl:variable>

<!-- Map: parent-id -> position-based amendments -->
<xsl:variable name="amendments-by-parent-id" as="map(xs:string, element()*)">
  <!-- ... -->
</xsl:variable>

<!-- Map: reference-id -> sibling insertion amendments -->
<xsl:variable name="amendments-by-reference-id" as="map(xs:string, element()*)">
  <!-- ... -->
</xsl:variable>

<!-- Map: table-id -> table-row-insert amendments -->
<xsl:variable name="amendments-by-table-id" as="map(xs:string, element()*)">
  <!-- ... -->
</xsl:variable>

<!-- Map: appnote-id -> list-item-insert amendments -->
<xsl:variable name="amendments-by-appnote-id" as="map(xs:string, element()*)">
  <!-- ... -->
</xsl:variable>

<!-- Map: parent-id -> child-element amendments -->
<xsl:variable name="amendments-by-child-element-parent" as="map(xs:string, element()*)">
  <!-- ... -->
</xsl:variable>
```

### 3. Three-Phase Processing

**Phase 1: Pre-Process (Global Text Replacements)**
- Applied to entire source document BEFORE merge
- Allows amendments to reference new/updated IDs
- Affects ALL text content and ALL attribute values

**Phase 2: Merge (Single Pass)**
- Traverse document once
- O(1) lookup for amendments at each element
- Apply operations in sequence order

**Phase 3: Post-Process (Reference Resolution)**
- Update cross-references
- Resolve canonical IDs
- Clean up temporary attributes

### 4. Global Text Replacements

Applied in pre-process phase:
```xml
<text-replacements>
  <!-- Literal replacement (default) -->
  <replace from="sect37" to="sect38"/>
  <replace from="9.37." to="9.38."/>
  
  <!-- Regex replacement -->
  <replace from="9\.37\.(\d+)" to="9.38.$1" regex="true"/>
</text-replacements>
```

**Affects**:
- All `xml:id` attributes
- All `vendor-id` attributes
- All `target` attributes (references)
- All text nodes
- All other attribute values

**Exclusions**:
- Application note numbers (preserved during section renumbering)
- Note division numbers

### 5. Supported Amendment Operations

#### Replace
Replaces entire element with new content:
```xml
<amendment id="bc-001" sequence="1">
  <target type="canonical-id" id="nbc.divB.part3.sect8.subsect2.art6"/>
  <replace preserve-references="false">
    <new-content>
      <article xml:id="bc.divB.part3.sect8.subsect2.art6" number="6">
        <!-- New BC content -->
      </article>
    </new-content>
  </replace>
</amendment>
```

#### Insert
Inserts new content at specified position:
```xml
<amendment id="bc-002" sequence="2">
  <target type="position" 
          parent-id="nbc.divB.part3.sect8.subsect2.art6"
          position="after"
          reference-id="nbc.divB.part3.sect8.subsect2.art6.sent3"/>
  <insert>
    <new-content>
      <sentence xml:id="bc.divB.part3.sect8.subsect2.art6.sent4" number="4">
        <!-- New sentence -->
      </sentence>
    </new-content>
  </insert>
</amendment>
```

**Position options**:
- `first-child`: Insert as first child of parent
- `last-child`: Insert as last child of parent
- `before`: Insert before reference element
- `after`: Insert after reference element

#### Modify
Modifies text or structure within element:
```xml
<amendment id="bc-003" sequence="3">
  <target type="canonical-id" id="nbc.divB.part3.sect8.subsect2.art6.sent1"/>
  <modify>
    <!-- Text change -->
    <text-change xpath-within-target="text()">
      <find-replace>
        <find>accessible</find>
        <replace>adaptable</replace>
      </find-replace>
    </text-change>
    
    <!-- Element replace -->
    <element-replace element="definition" position="1">
      <new-content>
        <definition>New definition text</definition>
      </new-content>
    </element-replace>
    
    <!-- Element change -->
    <element-change xpath-within-target=".//paragraph[1]">
      <remove-element/>
    </element-change>
  </modify>
</amendment>
```

#### Delete
Removes element entirely:
```xml
<amendment id="bc-004" sequence="4">
  <target type="canonical-id" id="nbc.divB.part3.sect8.subsect2.art6.sent5"/>
  <delete/>
</amendment>
```

### 6. Special Handlers

#### Table Row Insertions
Optimized handling for table row amendments:
```xml
<amendment id="bc-005" sequence="5">
  <target type="table-row-insert"
          table-id="nbc.divB.part9.sect36.subsect2.art8.table3"
          position="after"
          match-row-containing="Supported"/>
  <insert>
    <new-content>
      <row xml:id="bc.divB.part9.sect36.subsect2.art8.table3.row15">
        <entry>New row content</entry>
      </row>
    </new-content>
  </insert>
</amendment>
```

#### List Item Insertions
Optimized handling for list item amendments:
```xml
<amendment id="bc-006" sequence="6">
  <target type="list-item-insert"
          parent-id="nbc.divB.part5.sect10.appnote47"
          position="last-child"/>
  <insert>
    <new-content>
      <item xml:id="bc.divB.part5.sect10.appnote47.list1.item8">
        New list item
      </item>
    </new-content>
  </insert>
</amendment>
```

#### Child Element Targeting
Target child elements without IDs:
```xml
<amendment id="bc-007" sequence="7">
  <target type="child-element"
          parent-id="nbc.divA.part1.sect1.subsect3"
          element-name="title"
          position="1"/>
  <replace preserve-references="false">
    <new-content>
      <title revised="yes">
        <revision-history>
          <original effective-date="2020-12-01"/>
          <revision seq="1" type="amendment" effective-date="2025-06-16"
                   id="bc-007" status="current">
            <content>New Title</content>
            <change-summary>Updated title text</change-summary>
          </revision>
        </revision-history>
      </title>
    </new-content>
  </replace>
</amendment>
```

### 7. Revision History Auto-Population

The merge engine automatically populates `<original>` elements in revision history:

**Amendment Input**:
```xml
<sentence xml:id="nbc.divB.part3.sect2.subsect3.art9.sent1" number="1" revised="yes">
  <revision-history>
    <original effective-date="2020-12-01">
      <!-- Leave blank - merge engine auto-populates -->
    </original>
    <revision seq="1" type="amendment" effective-date="2024-04-05" 
             id="bc-mo-2024-01-011" status="current">
      <content>
        <text>New sentence content...</text>
      </content>
      <change-summary>Changed reference from 3.2.2.92 to 3.2.2.93</change-summary>
    </revision>
  </revision-history>
</sentence>
```

**Merge Output**:
```xml
<sentence xml:id="nbc.divB.part3.sect2.subsect3.art9.sent1" number="1" revised="yes">
  <revision-history>
    <original effective-date="2020-12-01">
      <!-- Auto-populated from source document -->
      <text>Original sentence content from NBC...</text>
    </original>
    <revision seq="1" type="amendment" effective-date="2024-04-05" 
             id="bc-mo-2024-01-011" status="current">
      <content>
        <text>New sentence content...</text>
      </content>
      <change-summary>Changed reference from 3.2.2.92 to 3.2.2.93</change-summary>
    </revision>
  </revision-history>
</sentence>
```

### 8. Dependent Amendment Chaining

Handles amendments that reference newly inserted content:

**Scenario**: Insert sentence 4, then insert sentence 5 after sentence 4

```xml
<!-- Amendment 1: Insert sentence 4 -->
<amendment id="bc-008" sequence="8">
  <target type="position" 
          parent-id="nbc.divB.part3.sect8.subsect2.art6"
          position="after"
          reference-id="nbc.divB.part3.sect8.subsect2.art6.sent3"/>
  <insert>
    <new-content>
      <sentence xml:id="bc.divB.part3.sect8.subsect2.art6.sent4" number="4">
        <!-- Sentence 4 content -->
      </sentence>
    </new-content>
  </insert>
</amendment>

<!-- Amendment 2: Insert sentence 5 after sentence 4 (newly inserted) -->
<amendment id="bc-009" sequence="9">
  <target type="position" 
          parent-id="nbc.divB.part3.sect8.subsect2.art6"
          position="after"
          reference-id="bc.divB.part3.sect8.subsect2.art6.sent4"/>
  <insert>
    <new-content>
      <sentence xml:id="bc.divB.part3.sect8.subsect2.art6.sent5" number="5">
        <!-- Sentence 5 content -->
      </sentence>
    </new-content>
  </insert>
</amendment>
```

The merge engine automatically detects and handles this dependency chain.

## Processing Logic

### Element Processing Flow

```
For each element with xml:id:
  1. O(1) lookup: Get direct amendments (replace/delete/modify)
  2. O(1) lookup: Get parent amendments (child insertions)
  3. O(1) lookup: Get reference amendments (sibling insertions)
  4. O(1) lookup: Get child-element amendments
  5. Check XPath amendments (only if XPath amendments exist)
  
  6. Determine action:
     - DELETE: Skip element entirely
     - REPLACE: Output new content
     - MODIFY: Apply modifications and process children
     - DEFAULT: Copy element and process children
  
  7. Process children with position-based insertions:
     - Before insertions (before first child)
     - First-child insertions
     - For each child:
       - Before insertions (by reference-id)
       - Process child
       - After insertions (by reference-id)
     - After insertions (after last child)
     - Last-child insertions
```

### Text Change Processing

**Cross-Node Text Replacement**:
Handles text split across multiple lines or mixed with child elements:

```xml
<!-- Source XML -->
<definition>a person with a physical or sensory
limitation will be impeded</definition>

<!-- Amendment -->
<text-change xpath-within-target=".//definition">
  <find-replace>
    <find>a person with a physical or sensory limitation</find>
    <replace>persons with disabilities</replace>
  </find-replace>
</text-change>

<!-- Result -->
<definition>persons with disabilities
will be impeded</definition>
```

**Whitespace Normalization**:
- Normalizes whitespace in find patterns: `\s+` matches any whitespace
- Preserves original whitespace in replacement text
- Handles line breaks and indentation

### Reference Resolution

Post-process phase updates all references:
```xslt
<!-- Update internal references -->
<xsl:template match="ref[@type='internal']/@target" mode="post-process">
  <xsl:attribute name="target">
    <xsl:value-of select="bc:resolve-canonical-id(.)"/>
  </xsl:attribute>
</xsl:template>
```

## Performance

### Benchmark Results

| Metric | Value |
|--------|-------|
| Amendments | 284 |
| Source size | 5.9 MB |
| Processing time | ~10 seconds |
| Memory usage | ~800 MB |
| Output size | 5.9 MB |

### Optimization Techniques

1. **Pre-indexing**: Build maps once, use many times
2. **Single pass**: Traverse document only once
3. **O(1) lookups**: Map-based amendment retrieval
4. **Lazy evaluation**: Only process when needed
5. **Streaming**: Process large documents efficiently

## Console Output

```
BC Merge Engine V3 - Single Pass Mode
Processing 284 amendments...
  - By canonical-id: 156 targets
  - By parent-id: 89 targets
  - By reference-id: 34 targets
  - XPath-based: 5 amendments
  - Global text replacements: 12 rules
  Applying global text replacements to source document...
Merge complete.
```

## Error Handling

- **Missing target**: Logs warning, skips amendment
- **Invalid operation**: Logs error, continues processing
- **Circular dependencies**: Detects and breaks cycles
- **Malformed content**: Logs error, preserves original

## Validation

After merging, validate the output:
```bash
# Schema validation
java -jar NBC2020XML/AE_custom/jing/jing.jar \
  proposed/canonical-nbc.rng \
  bc-building-code.xml

# Amendment validation
java -jar xmlToJson/saxon.jar \
  -xsl:proposed/validate-amendments.xsl \
  -s:bc-amendments-combined.xml \
  combined-amendments=bc-amendments-combined.xml \
  bc-building-code=bc-building-code.xml \
  -o:amendment-validation-report.html
```

## Dependencies

- **Saxon HE 12.9+**: XSLT 3.0 processor with map support
- **Java 8+**: Runtime environment
- **Input files**: Canonical NBC XML + combined amendments

## Next Steps

After merging:
1. **Validate**: Use `validate-amendments.xsl`
2. **Apply revisions**: Use merge engine again for Phase 2
3. **Generate JSON**: Use `canonical-to-json.xsl`

## Related Files

- **Schema**: `proposed/canonical-nbc.rng`, `proposed/bc-overlay.rng`
- **Validation**: `validate-amendments.xsl`
- **JSON generator**: `canonical-to-json.xsl`
- **Combine tool**: `combine-amendments.xsl`
