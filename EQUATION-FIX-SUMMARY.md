# Equation Processing Fix

## Issue
Equations appeared in JSON but with empty `id`, `latex`, `plainText`, and `mathml` fields.

## Root Cause
XSLT templates used `select="math"` but MathML elements are namespaced, so selector didn't match.

## Fix Applied
Updated both XSLT files to use namespace-agnostic selectors:
- Changed `select="math"` to `select="*[local-name()='math']"`
- Added fallback ID: `if (@xml:id) then @xml:id else if (@image) then @image else ''`

## Files Modified
1. `json-generation-pipeline/transformation-xslt/canonical-to-json.xsl`
2. `json-generation-pipeline/transformation-xslt/canonical-to-json-minimal.xsl`

## To Apply
Regenerate JSON using Oxygen XML Editor or run:
```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/canonical-to-json.xsl \
  -s:json-generation-pipeline/output/bc-building-code-final.xml \
  -o:json-generation-pipeline/output/bc-building-code.json
```

Note: Command-line Saxon requires xmlresolver library. Use Oxygen XML Editor if you encounter ClassNotFoundException.
