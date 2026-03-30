# Global Text Replacements (Pre-Processing)

The merge engine supports a `<text-replacements>` element for bulk find-replace operations across the **entire source document**. This is applied during **pre-processing** (before amendments are applied), so subsequent amendments can reference the new/updated IDs.

---

## Overview

- Affects **ALL text content AND ALL attribute values**: `xml:id`, `vendor-id`, `target`, text nodes, etc.
- Applied **before** amendments, so you can target the new IDs in your amendments
- Useful for reorganizing content, renumbering sections, or bulk terminology changes

## Use Cases

1. **Renumbering sections** when content is reorganized (e.g., `sect37` → `sect38`)
2. **Bulk ID updates** when parts/sections are moved
3. **Global terminology changes** across the entire document
4. **Fixing systematic errors** in IDs or references

---

## Syntax

```xml
<bc-overlay id="reorganize-part9" version="1.0" nbc-target-version="2020">
  <metadata>...</metadata>
  
  <!-- Applied FIRST, before any amendments -->
  <text-replacements>
    <!-- Simple literal replacement (default) -->
    <replace from="sect37" to="sect38"/>
    <replace from="9.37." to="9.38."/>
    
    <!-- Regex replacement -->
    <replace from="9\.37\.(\d+)" to="9.38.$1" regex="true"/>
  </text-replacements>
  
  <amendments>
    <!-- Now you can target the NEW IDs created by text-replacements -->
    <amendment id="bc-001" sequence="1">
      <target type="canonical-id" id="nbc.divBV2.part9.sect38.subsect1.art1"/>
      <modify>...</modify>
    </amendment>
  </amendments>
</bc-overlay>
```

## Key Points

- `<text-replacements>` is a sibling of `<amendments>`, placed before it
- Each `<replace>` has `from` and `to` attributes
- Set `regex="true"` for regex patterns (uses XSLT `replace()` function syntax)
- Replacements are applied in order, so later rules can build on earlier ones
- At least one `<amendment>` is still required in the file

---

## Example: Renumbering Section 9.37 to 9.38

When you need to renumber a section (e.g., because you're inserting a new section before it), use text-replacements to update all IDs and references:

```xml
<text-replacements>
  <!-- Update canonical IDs -->
  <replace from="sect37" to="sect38"/>
  
  <!-- Update display text references -->
  <replace from="9.37." to="9.38."/>
  <replace from="Section 9.37" to="Section 9.38"/>
  <replace from="Subsection 9.37" to="Subsection 9.38"/>
</text-replacements>
```

This will transform:
- `xml:id="nbc.divBV2.part9.sect37.subsect1.art1"` → `xml:id="nbc.divBV2.part9.sect38.subsect1.art1"`
- `vendor-id="ep001029.37.1"` → `vendor-id="ep001029.38.1"`
- `<ref target="nbc.divBV2.part9.sect37...">` → `<ref target="nbc.divBV2.part9.sect38...">`
- Text "see Section 9.37.1." → "see Section 9.38.1."

---

## Example: Complete Reorganization File

```xml
<?xml version="1.0" encoding="UTF-8"?>
<bc-overlay id="bc-part9-reorganize" version="1.0" nbc-target-version="2020">
  
  <metadata>
    <title>Part 9 Section Reorganization</title>
    <description>Renumber sections 37-40 to make room for new BC section</description>
    <authority>BC Building and Safety Standards Branch</authority>
    <author>BC Building Code Team</author>
    <source-document>BC Building Code 2024 Update</source-document>
  </metadata>
  
  <!-- Step 1: Renumber existing sections (applied first) -->
  <text-replacements>
    <!-- Renumber sect40 -> sect41 first (work backwards to avoid conflicts) -->
    <replace from="sect40" to="sect41"/>
    <replace from="9.40." to="9.41."/>
    
    <!-- Renumber sect39 -> sect40 -->
    <replace from="sect39" to="sect40"/>
    <replace from="9.39." to="9.40."/>
    
    <!-- Renumber sect38 -> sect39 -->
    <replace from="sect38" to="sect39"/>
    <replace from="9.38." to="9.39."/>
    
    <!-- Renumber sect37 -> sect38 -->
    <replace from="sect37" to="sect38"/>
    <replace from="9.37." to="9.38."/>
  </text-replacements>
  
  <amendments>
    <!-- Step 2: Now insert new BC section 9.37 -->
    <amendment id="bc-part9-new-sect37" sequence="1" 
               description="Insert new BC Section 9.37">
      <target type="position" 
              parent-id="nbc.divBV2.part9" 
              position="before" 
              reference-id="nbc.divBV2.part9.sect38"/>
      <insert>
        <new-content>
          <section xml:id="bc.divBV2.part9.sect37" number="9.37.">
            <title>New BC Section Title</title>
            <!-- Section content here -->
          </section>
        </new-content>
      </insert>
    </amendment>
  </amendments>
</bc-overlay>
```

---

## Example: Insert New Article Between Existing Articles

When you need to insert a new article between two existing articles, you must first renumber the subsequent articles to make room. Work backwards (highest number first) to avoid conflicts.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<bc-overlay id="bc-insert-article-example" version="1.0" nbc-target-version="2020">
  
  <metadata>
    <title>Insert New Article Example</title>
    <description>Insert new Article 9.36.2.3. between existing 9.36.2.2. and 9.36.2.3.</description>
    <authority>BC Building and Safety Standards Branch</authority>
    <author>BC Building Code Team</author>
    <source-document>BC Building Code Amendment</source-document>
  </metadata>
  
  <text-replacements>
    <!-- Renumber art5 -> art6 first (if exists) -->
    <replace from="nbc.divBV2.part9.sect36.subsect2.art5" to="nbc.divBV2.part9.sect36.subsect2.art6"/>
    <replace from="9.36.2.5." to="9.36.2.6."/>
    
    <!-- Renumber art4 -> art5 -->
    <replace from="nbc.divBV2.part9.sect36.subsect2.art4" to="nbc.divBV2.part9.sect36.subsect2.art5"/>
    <replace from="9.36.2.4." to="9.36.2.5."/>
    
    <!-- Renumber art3 -> art4 -->
    <replace from="nbc.divBV2.part9.sect36.subsect2.art3" to="nbc.divBV2.part9.sect36.subsect2.art4"/>
    <replace from="9.36.2.3." to="9.36.2.4."/>
  </text-replacements>
  
  <amendments>
    <amendment id="bc-insert-art3" sequence="1" 
               description="Insert new Article 9.36.2.3. - New BC Requirement">
      <target type="position" 
              parent-id="nbc.divBV2.part9.sect36.subsect2"
              position="after" 
              reference-id="nbc.divBV2.part9.sect36.subsect2.art2"/>
      <insert>
        <new-content>
          <article xml:id="bc.divBV2.part9.sect36.subsect2.art3" number="9.36.2.3.">
            <title>New BC Article Title</title>
            <sentence xml:id="bc.divBV2.part9.sect36.subsect2.art3.sent1" number="1">
              <text>This is the new BC-specific requirement.</text>
            </sentence>
          </article>
        </new-content>
      </insert>
    </amendment>
  </amendments>
</bc-overlay>
```

**Key points for inserting articles:**
1. **Work backwards** when renumbering — start with the highest article number
2. **Use `bc.` prefix** for the new article's `xml:id` since it's BC-only content
3. **Reference the unchanged article** (`art2`) for the insert position
4. **Update both ID patterns and display text**
5. **Cross-references in new content** should point to the NEW IDs

---

## Regex Replacement Examples

For complex patterns, use `regex="true"`:

```xml
<text-replacements>
  <!-- Replace all 9.37.X references with 9.38.X (preserving the subsection number) -->
  <replace from="9\.37\.(\d+)" to="9.38.$1" regex="true"/>
  
  <!-- Replace Article references like "Article 9.37.1.2" -->
  <replace from="Article 9\.37\.(\d+)\.(\d+)" to="Article 9.38.$1.$2" regex="true"/>
  
  <!-- Case-insensitive replacement (add (?i) at start) -->
  <replace from="(?i)section 9\.37" to="Section 9.38" regex="true"/>
</text-replacements>
```

---

## Example: Swapping Two Sections

To swap two sections (e.g., swap sect36 and sect37), use a temporary name to avoid conflicts:

```xml
<text-replacements>
  <!-- Swap sect36 and sect37 using temp -->
  <replace from="nbc.divBV2.part9.sect36" to="nbc.divBV2.part9.sect36_bkp"/>
  <replace from="nbc.divBV2.part9.sect37" to="nbc.divBV2.part9.sect36"/>
  <replace from="nbc.divBV2.part9.sect36_bkp" to="nbc.divBV2.part9.sect37"/>
  
  <!-- Swap display text references -->
  <replace from="9.36." to="9.36_bkp."/>
  <replace from="9.37." to="9.36."/>
  <replace from="9.36_bkp." to="9.37."/>
</text-replacements>
```

This is like swapping two variables using a temp variable in programming.

---

## Processing Order

1. **Pre-process**: Global text replacements are applied to the entire source document
2. **Merge**: Amendments are applied to the pre-processed document (can reference new IDs)
3. **Post-process**: Reference updates and cross-reference resolution

---

## Next Steps

- **[02-overlay-amendments-guide.md](02-overlay-amendments-guide.md)** - Creating overlay amendments
- **[04-merge-engine-reference.md](04-merge-engine-reference.md)** - Merge engine operations reference
- **[07-examples-library.md](07-examples-library.md)** - Working examples
