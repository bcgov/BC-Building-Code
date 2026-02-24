#!/usr/bin/env python3
"""
Fix nbc-to-canonical.xsl to remove .eps extension from graphic src attributes
"""

import re
from pathlib import Path

xsl_file = Path('json-generation-pipeline/transformation-xslt/nbc-to-canonical.xsl')
content = xsl_file.read_text(encoding='utf-8')

# Pattern to match the concat statements that add extensions
# Replace: concat(..., $id, '.', $extension) with concat(..., lower-case($id))
# Replace: concat(..., '.', $extension) with concat(..., lower-case($id))

# First pattern: EG/GG graphics with extension
pattern1 = r"concat\('graphics/', lower-case\(substring\(\$id, 1, 2\)\), '/', substring\(\$id, 3, 3\), '/', \$id, '\.', \$extension\)"
replacement1 = "concat('graphics/', lower-case(substring($id, 1, 2)), '/', substring($id, 3, 3), '/', lower-case($id))"

# Second pattern: other graphics with extension  
pattern2 = r"concat\('graphics/', \$id, '\.', \$extension\)"
replacement2 = "concat('graphics/', lower-case($id))"

# Apply replacements
new_content = re.sub(pattern1, replacement1, content)
new_content = re.sub(pattern2, replacement2, new_content)

# Add comment about the change
comment_pattern = r'(<xsl:variable name="id" select="normalize-space\(\$asset-id\)" />)'
comment_replacement = r'\1\n    <!-- NOTE: Extension parameter kept for backward compatibility but not appended to output -->\n    <!-- Rendering layer should append .jpg or .eps as needed -->'

new_content = re.sub(comment_pattern, comment_replacement, new_content)

if new_content != content:
    xsl_file.write_text(new_content, encoding='utf-8')
    print("✓ Updated nbc-to-canonical.xsl")
    print("  - Removed .eps extension from graphic src attributes")
    print("  - Converted asset IDs to lowercase")
    print("  - Added documentation comments")
else:
    print("No changes needed")
