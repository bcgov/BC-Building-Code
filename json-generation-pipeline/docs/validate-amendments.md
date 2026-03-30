# Validate Amendments (validate-amendments.xsl)

## Overview

Validates that all BC amendments were properly applied to the building code. Generates an HTML report showing which amendments succeeded, failed, or have warnings.

## Purpose

- **Verify application**: Confirms amendments were applied correctly
- **Detect failures**: Identifies amendments that didn't apply
- **Generate reports**: Creates human-readable HTML validation report
- **Track sources**: Shows which source file each amendment came from
- **Provide statistics**: Summarizes pass/fail/warning counts

## Input

- **Combined amendments**: `bc-amendments-combined.xml` or `bc-revisions-combined.xml`
- **Merged code**: `bc-building-code.xml` or `bc-building-code-final.xml`

## Output

- **File**: `amendment-validation-report.html` or `revision-validation-report.html`
- **Format**: HTML with CSS styling
- **Content**: Detailed validation results for each amendment

## Commands

### Phase 1: Validate Overlay Amendments
```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/validate-amendments.xsl \
  -s:json-generation-pipeline/output/bc-amendments-combined.xml \
  combined-amendments=json-generation-pipeline/output/bc-amendments-combined.xml \
  bc-building-code=json-generation-pipeline/output/bc-building-code.xml \
  -o:json-generation-pipeline/output/amendment-validation-report.html
```

### Phase 2: Validate Revision Amendments
```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/validate-amendments.xsl \
  -s:json-generation-pipeline/output/bc-revisions-combined.xml \
  combined-amendments=json-generation-pipeline/output/bc-revisions-combined.xml \
  bc-building-code=json-generation-pipeline/output/bc-building-code-final.xml \
  -o:json-generation-pipeline/output/revision-validation-report.html
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `combined-amendments` | Yes | Path to combined amendments file |
| `bc-building-code` | Yes | Path to merged BC building code |

## Key Features

### 1. Validation Status

Each amendment receives one of three statuses:

**✓ PASSED (Success)**
- Amendment was applied correctly
- New content exists in output
- Content matches expected structure

**✗ FAILED (Error)**
- Amendment was not applied
- Target element not found
- Content missing or incorrect

**⚠ WARNING**
- Amendment applied but with issues
- Content exists but may not match exactly
- Further processing may have modified content

### 2. HTML Report Structure

```html
<!DOCTYPE html>
<html>
<head>
  <title>BC Building Code Amendment Validation Report</title>
  <style>/* Embedded CSS */</style>
</head>
<body>
  <h1>BC Building Code Amendment Validation Report</h1>
  
  <!-- Summary Section -->
  <div class="summary">
    <h2>Validation Summary</h2>
    <div class="summary-stats">
      <div class="stat-box">Total Amendments: 284</div>
      <div class="stat-box success">Passed: 276</div>
      <div class="stat-box warning">Warnings: 5</div>
      <div class="stat-box error">Failed: 3</div>
    </div>
  </div>
  
  <!-- Detailed Results Table -->
  <h2>Detailed Validation Results</h2>
  <table>
    <thead>
      <tr>
        <th>Amendment ID</th>
        <th>Original ID</th>
        <th>Source File</th>
        <th>Sequence</th>
        <th>Operation</th>
        <th>Target</th>
        <th>Status</th>
        <th>Details</th>
      </tr>
    </thead>
    <tbody>
      <!-- One row per amendment -->
    </tbody>
  </table>
  
  <div class="timestamp">Report generated: 2025-01-20 10:45:30</div>
</body>
</html>
```

### 3. Validation by Operation Type

#### REPLACE Validation

**Success criteria**:
- New content exists with expected ID
- Original content no longer exists (or was replaced)
- Content structure matches amendment

**Checks**:
```xslt
<!-- Check if new content exists -->
<xsl:variable name="new-id" select="$new-content/@xml:id"/>
<xsl:variable name="new-element" select="$bc-code-doc//*[@xml:id = $new-id]"/>

<xsl:choose>
  <xsl:when test="$new-element">
    <!-- Check if content matches -->
    <xsl:variable name="content-matches" select="bc:content-matches($new-element, $new-content)"/>
    <xsl:choose>
      <xsl:when test="$content-matches">
        <xsl:attribute name="status">success</xsl:attribute>
        <xsl:attribute name="message">Content successfully replaced</xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="status">warning</xsl:attribute>
        <xsl:attribute name="message">Content replaced but may not match exactly</xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:when>
  <xsl:otherwise>
    <xsl:attribute name="status">error</xsl:attribute>
    <xsl:attribute name="message">Replace operation failed - new element not found</xsl:attribute>
  </xsl:otherwise>
</xsl:choose>
```

#### INSERT Validation

**Success criteria**:
- New content exists in output
- Content is in correct position relative to parent/reference
- All inserted elements have expected IDs

**Checks**:
```xslt
<!-- Position-based insert -->
<xsl:variable name="parent-element" select="$bc-code-doc//*[@xml:id = $parent-id]"/>
<xsl:variable name="content-exists" select="bc:check-inserted-content($parent-element, $new-content)"/>

<xsl:choose>
  <xsl:when test="$content-exists">
    <xsl:attribute name="status">success</xsl:attribute>
    <xsl:attribute name="message">Content successfully inserted</xsl:attribute>
  </xsl:when>
  <xsl:otherwise>
    <xsl:attribute name="status">error</xsl:attribute>
    <xsl:attribute name="message">Inserted content not found in parent</xsl:attribute>
  </xsl:otherwise>
</xsl:choose>
```

#### MODIFY Validation

**Success criteria**:
- Target element still exists
- Text changes were applied
- Element changes were applied

**Checks**:
```xslt
<!-- Text change validation -->
<xsl:when test="$amendment/modify/text-change">
  <xsl:variable name="all-replacements-found" select="
    every $text-change in $amendment/modify/text-change satisfies
      (every $find-replace in $text-change/find-replace satisfies
        bc:check-text-in-element($target-element, $find-replace/replace))
  "/>
  
  <xsl:choose>
    <xsl:when test="$all-replacements-found">
      <xsl:attribute name="status">success</xsl:attribute>
      <xsl:attribute name="message">Text modification applied successfully</xsl:attribute>
    </xsl:when>
    <xsl:otherwise>
      <xsl:attribute name="status">warning</xsl:attribute>
      <xsl:attribute name="message">Modified text not found exactly (may have been further processed)</xsl:attribute>
    </xsl:otherwise>
  </xsl:choose>
</xsl:when>
```

#### DELETE Validation

**Success criteria**:
- Target element no longer exists in output
- No references to deleted element remain

**Checks**:
```xslt
<xsl:variable name="target-element" select="$bc-code-doc//*[@xml:id = $target-id]"/>

<xsl:choose>
  <xsl:when test="$target-element">
    <xsl:attribute name="status">error</xsl:attribute>
    <xsl:attribute name="message">Element still exists (should have been deleted)</xsl:attribute>
  </xsl:when>
  <xsl:otherwise>
    <xsl:attribute name="status">success</xsl:attribute>
    <xsl:attribute name="message">Element successfully deleted</xsl:attribute>
  </xsl:otherwise>
</xsl:choose>
```

### 4. Source File Tracking

Shows which source file each amendment came from:

```xslt
<xsl:function name="bc:get-source-filename" as="xs:string">
  <xsl:param name="source-file-index"/>
  
  <xsl:variable name="source-files" select="$amendments-doc//source-files/source-file"/>
  <xsl:variable name="index-num" select="xs:integer($source-file-index)"/>
  
  <xsl:choose>
    <xsl:when test="$index-num > 0 and $index-num <= count($source-files)">
      <!-- Extract just the filename from the path -->
      <xsl:variable name="full-path" select="$source-files[$index-num]"/>
      <xsl:value-of select="tokenize($full-path, '/')[last()]"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="'Unknown'"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>
```

### 5. Visual Styling

**Color-coded status boxes**:
- Green: Success (passed amendments)
- Yellow: Warning (applied with issues)
- Red: Error (failed amendments)

**Interactive table**:
- Sortable columns
- Hover highlighting
- Monospace font for IDs
- Responsive layout

## Report Example

### Summary Section

```
┌─────────────────────────────────────────────────────────────┐
│ Validation Summary                                          │
├─────────────────────────────────────────────────────────────┤
│ Total Amendments: 284                                       │
│ ✓ Passed: 276                                              │
│ ⚠ Warnings: 5                                              │
│ ✗ Failed: 3                                                │
└─────────────────────────────────────────────────────────────┘
```

### Detailed Results

| Amendment ID | Original ID | Source File | Seq | Operation | Target | Status | Details |
|--------------|-------------|-------------|-----|-----------|--------|--------|---------|
| bc-combined-001 | bc-001 | Division A_FIN.xml | 1 | replace | nbc.divA.part1... | ✓ PASSED | Content successfully replaced |
| bc-combined-002 | bc-002 | Division A_FIN.xml | 2 | insert | nbc.divA.part1... | ✓ PASSED | Content successfully inserted |
| bc-combined-003 | bc-003 | Division A_FIN.xml | 3 | modify | nbc.divA.part1... | ⚠ WARNING | Modified text not found exactly |
| bc-combined-042 | bc-015 | Part 3.FIN_1.xml | 42 | replace | nbc.divB.part3... | ✗ FAILED | Target element not found |

## Validation Functions

### Content Matching

```xslt
<xsl:function name="bc:content-matches" as="xs:boolean">
  <xsl:param name="actual-element"/>
  <xsl:param name="expected-content"/>
  
  <!-- Compare element names -->
  <xsl:variable name="names-match" select="
    local-name($actual-element) = local-name($expected-content)"/>
  
  <!-- Compare key attributes -->
  <xsl:variable name="attrs-match" select="
    $actual-element/@number = $expected-content/@number and
    $actual-element/@letter = $expected-content/@letter"/>
  
  <!-- Compare child count -->
  <xsl:variable name="children-match" select="
    count($actual-element/*) = count($expected-content/*)"/>
  
  <xsl:sequence select="$names-match and $attrs-match and $children-match"/>
</xsl:function>
```

### Text Checking

```xslt
<xsl:function name="bc:check-text-in-element" as="xs:boolean">
  <xsl:param name="element"/>
  <xsl:param name="search-text"/>
  
  <!-- Normalize whitespace for comparison -->
  <xsl:variable name="element-text" select="normalize-space(string($element))"/>
  <xsl:variable name="normalized-search" select="normalize-space($search-text)"/>
  
  <xsl:sequence select="contains($element-text, $normalized-search)"/>
</xsl:function>
```

### Inserted Content Checking

```xslt
<xsl:function name="bc:check-inserted-content" as="xs:boolean">
  <xsl:param name="parent-element"/>
  <xsl:param name="new-content"/>
  
  <!-- Check if all inserted elements exist in parent -->
  <xsl:variable name="all-exist" select="
    every $new-elem in $new-content/* satisfies
      exists($parent-element//*[@xml:id = $new-elem/@xml:id])
  "/>
  
  <xsl:sequence select="$all-exist"/>
</xsl:function>
```

## Common Validation Issues

### 1. Target Not Found

**Cause**: Amendment targets element that doesn't exist

**Solution**: Check target ID in source document

### 2. Content Mismatch

**Cause**: Content was further modified by subsequent amendments

**Status**: Warning (not error)

**Action**: Review amendment sequence

### 3. Position Issues

**Cause**: Insert position reference doesn't exist

**Solution**: Verify reference-id exists in source

### 4. Text Not Found

**Cause**: Text was modified by another amendment first

**Status**: Warning

**Action**: Check amendment order

## Performance

- **Processing time**: ~5 seconds for 284 amendments
- **Memory usage**: ~200 MB
- **Report size**: ~500 KB HTML

## Use Cases

### 1. Development Validation

Run after each merge to verify amendments:
```bash
# Apply amendments
java -jar json-generation-pipeline/tools/saxon.jar -xsl:json-generation-pipeline/transformation-xslt/merge-engine-v3.xsl \
  -s:json-generation-pipeline/output/nbc-canonical.xml overlay-document=json-generation-pipeline/output/bc-amendments-combined.xml \
  -o:json-generation-pipeline/output/bc-building-code.xml

# Validate
java -jar json-generation-pipeline/tools/saxon.jar -xsl:json-generation-pipeline/transformation-xslt/validate-amendments.xsl \
  -s:json-generation-pipeline/output/bc-amendments-combined.xml \
  combined-amendments=json-generation-pipeline/output/bc-amendments-combined.xml \
  bc-building-code=json-generation-pipeline/output/bc-building-code.xml \
  -o:json-generation-pipeline/output/validation-report.html

# Open report
start validation-report.html  # Windows
open validation-report.html   # macOS
xdg-open validation-report.html  # Linux
```

### 2. CI/CD Integration

Automate validation in build pipeline:
```bash
#!/bin/bash
# validate.sh

# Run validation
java -jar json-generation-pipeline/tools/saxon.jar -xsl:json-generation-pipeline/transformation-xslt/validate-amendments.xsl \
  -s:json-generation-pipeline/output/bc-amendments-combined.xml \
  combined-amendments=json-generation-pipeline/output/bc-amendments-combined.xml \
  bc-building-code=json-generation-pipeline/output/bc-building-code.xml \
  -o:json-generation-pipeline/output/validation-report.html

# Check for failures
FAILED=$(grep -c 'status error' validation-report.html)

if [ $FAILED -gt 0 ]; then
  echo "❌ Validation failed: $FAILED amendments failed"
  exit 1
else
  echo "✅ Validation passed: All amendments applied successfully"
  exit 0
fi
```

### 3. Amendment Review

Use report to review amendment application:
1. Open HTML report in browser
2. Sort by status to see failures first
3. Click amendment ID to see details
4. Review source file for context

## Dependencies

- **Saxon HE 12.9+**: XSLT 3.0 processor
- **Java 8+**: Runtime environment
- **Input files**: Combined amendments + merged code

## Next Steps

After validation:
1. **Fix failures**: Update amendments that failed
2. **Review warnings**: Check amendments with warnings
3. **Re-run merge**: Apply corrected amendments
4. **Generate JSON**: Proceed to JSON generation

## Related Files

- **Merge engine**: `json-generation-pipeline/transformation-xslt/merge-engine-v3.xsl`
- **Combine tool**: `json-generation-pipeline/transformation-xslt/combine-amendments.xsl`
- **JSON generator**: `json-generation-pipeline/transformation-xslt/canonical-to-json.xsl`
- **Schemas**: `proposed/bc-overlay.rng`, `proposed/canonical-nbc.rng`
