# Validation and Troubleshooting Guide

This guide explains how to validate amendments and fix common issues that arise during the amendment process.

---

## 1. Running the Validation Pipeline

### Step 1: Combine Amendment Files

```bash
# For overlay amendments (Phase 1)
java -jar xmlToJson/saxon.jar \
  -xsl:proposed/combine-amendments.xsl \
  -s:proposed/amendment-list.xml \
  -o:bc-amendments-combined.xml

# For revision amendments (Phase 2)
java -jar xmlToJson/saxon.jar \
  -xsl:proposed/combine-amendments.xsl \
  -s:proposed/revision-list.xml \
  -o:bc-revisions-combined.xml
```

### Step 2: Apply Amendments

```bash
# Phase 1: Apply overlay amendments
java -jar xmlToJson/saxon.jar \
  -xsl:proposed/merge-engine.xsl \
  -s:nbc-canonical.xml \
  overlay-document=bc-amendments-combined.xml \
  -o:bc-building-code.xml

# Phase 2: Apply revision amendments
java -jar xmlToJson/saxon.jar \
  -xsl:proposed/merge-engine.xsl \
  -s:bc-building-code.xml \
  overlay-document=bc-revisions-combined.xml \
  -o:bc-building-code-final.xml
```

### Step 3: Validate

```bash
java -jar xmlToJson/saxon.jar \
  -xsl:proposed/validate-amendments.xsl \
  -s:bc-amendments-combined.xml \
  combined-amendments=bc-amendments-combined.xml \
  bc-building-code=bc-building-code.xml \
  -o:validation-report.html
```

### Understanding the Validation Report

The validation report shows:
- ✅ **Success** - Amendment applied correctly
- ⚠ **Warning** - Amendment may have issues (e.g., text not found)
- ❌ **Error** - Amendment failed to apply

---

## 2. Common Validation Errors

### Error: "Modified text not found exactly"

This is the most common warning. It means the merge engine couldn't find the text you're trying to change with `text-change`.

#### Root Cause #1: Find Text Spans a `<ref>` Element Boundary

**Problem:** The text you want to find contains words that are split between plain text and a child `<ref>` element.

**Example - Source XML:**
```xml
<sentence xml:id="nbc.divB.part3.sect3.subsect1.art1.sent1">
  <text>..., each <ref type="term" target="t">suite</ref> in other than...</text>
</sentence>
```

**Amendment that FAILS:**
```xml
<text-change xpath-within-target="text()">
    <find-replace>
        <find>each suite</find>  <!-- ❌ "suite" is inside <ref>, not in text() -->
        <replace>a suite</replace>
    </find-replace>
</text-change>
```

**Why it fails:** The `text()` nodes contain `"each "` and `" in other than..."` but NOT `"suite"` — that word lives inside `<ref type="term">suite</ref>`.

**THE FIX:** Use `element-replace`:

```xml
<modify>
    <element-replace element="text">
        <new-content source="bc">
            <text>..., a <ref type="term" target="t">suite</ref> in other than...</text>
        </new-content>
    </element-replace>
</modify>
```

---

#### Root Cause #2: Self-Closing `<ref>` Elements

**Problem:** Some references are self-closing tags that resolve to display text at render time. They have no text content to match against.

**Example:**
```xml
<clause>
  <text>the <ref type="standard" target="nrcc-nfc" standardId="nrcc-nfc"/>,
    in the absence of the regulations...</text>
</clause>
```

**Amendment that FAILS:**
```xml
<find-replace>
    <find>National Fire Code</find>  <!-- ❌ This text doesn't exist -->
    <replace>British Columbia Fire Code</replace>
</find-replace>
```

**Why it fails:** "National Fire Code" is the display name of the `<ref>`, not actual text content.

**THE FIX:** Use `element-replace`:

```xml
<element-replace element="text">
    <new-content source="bc">
        <text>the British Columbia Fire Code,
            in the absence of the regulations...</text>
    </new-content>
</element-replace>
```

---

#### Root Cause #3: Multiple Amendments Target Same Element

**Problem:** Two amendments both target the same element, and one uses `element-replace` which changes the content the other expects.

**THE FIX:** Combine both changes into a single `element-replace` in the earlier amendment.

---

#### Root Cause #4: Complex XPath Not Supported

**Problem:** The merge engine supports basic xpath patterns but not complex predicates.

**Supported:**
- `text()`
- `.//text()`
- `.//element-name`
- `.//element-name[N]`

**NOT Supported:**
- `.//measurement[@units='metric']`
- `text()[last()]`
- Complex predicates with attributes

**THE FIX:** Use `element-replace`.

---

#### Root Cause #5: Find/Replace Contains XML Elements

**Problem:** When `<find>` or `<replace>` contains XML elements like `<ref>`, the merge engine treats them as text patterns.

**Amendment that FAILS:**
```xml
<find-replace>
    <find><ref type="internal" target="some.id"/>.</find>
    <replace><ref type="internal" target="some.id"/>, and</replace>
</find-replace>
```

**THE FIX:** Use `element-replace`.

---

#### Root Cause #6: Text Split Across XML Lines

**Problem:** Text spanning line breaks in source XML occasionally fails to match.

**THE FIX:** Use `element-replace`.

---

### Error: "element X not allowed here"

**Problem:** The XML structure doesn't match the schema.

#### List Element Issues

**Wrong:**
```xml
<list>
    <item>First item</item>  <!-- ❌ Should be <list-item> -->
</list>
```

**Correct:**
```xml
<list list-type="lettered">
    <list-item>
        <text>First item</text>
    </list-item>
</list>
```

#### Paragraph Wrapper Issues

**Wrong:**
```xml
<note-division>
    <text>Some text</text>  <!-- ❌ Needs paragraph wrapper -->
</note-division>
```

**Correct:**
```xml
<note-division>
    <paragraph>
        <text>Some text</text>
    </paragraph>
</note-division>
```

---

### Error: "ID already exists"

**Problem:** Duplicate `xml:id` values.

**THE FIX:**
- Check if the ID already exists in the source document
- Use unique IDs following the naming convention
- Remember: all IDs use `nbc.` prefix now

---

### Error: "text not allowed; expected element"

**Problem:** Missing required wrapper elements.

**Example - Application Note Missing Title:**

**Wrong:**
```xml
<application-note xml:id="nbc.divB.part3.appnote1">
    Notes about this section...  <!-- ❌ Needs structure -->
</application-note>
```

**Correct:**
```xml
<application-note xml:id="nbc.divB.part3.appnote1">
    <number>A-3.1.1.1.</number>
    <title>Application Note Title</title>
    <note-division xml:id="nbc.divB.part3.appnote1.div1">
        <paragraph>
            <text>Notes about this section...</text>
        </paragraph>
    </note-division>
</application-note>
```

---

## 3. Debugging Workflow

### Step 1: Check the Validation Report

Open the validation report HTML and find the warning/error.

### Step 2: Find Target Element in bc-building-code.xml

```bash
# PowerShell
Select-String -Path "output/bc-building-code.xml" -Pattern '"nbc.divB.part3.sect1.art1.sent1"' -Context 0,15

# Or grep
grep -n "nbc.divB.part3.sect1.art1.sent1" output/bc-building-code.xml
```

### Step 3: Compare Amendment with Source

Look at:
- The exact text content in the source
- Any `<ref>` elements that might split the text
- Whether your `<find>` text matches exactly

### Step 4: Apply the Fix

Usually: change `text-change` to `element-replace`.

### Step 5: Re-run Pipeline

```bash
# Rebuild and validate
java -jar saxon.jar -xsl:proposed/combine-amendments.xsl ...
java -jar saxon.jar -xsl:proposed/merge-engine.xsl ...
java -jar saxon.jar -xsl:proposed/validate-amendments.xsl ...
```

---

## 4. Quick Decision Tree

```
Got a "Modified text not found" warning?
│
├─ Check the target element in bc-building-code.xml
│  (search for xml:id="<target-id>")
│
├─ Does the <find> text contain words inside <ref> elements?
│  └─ YES → Use element-replace (Root Cause #1)
│
├─ Does the <find> text refer to a self-closing <ref/> display name?
│  └─ YES → Use element-replace (Root Cause #2)
│
├─ Does another amendment also target the same element?
│  └─ YES → Fold changes into one element-replace (Root Cause #3)
│
├─ Does the xpath use complex predicates?
│  └─ YES → Use element-replace (Root Cause #4)
│
├─ Does <find> or <replace> contain XML elements like <ref>?
│  └─ YES → Use element-replace (Root Cause #5)
│
├─ Is the text split across lines in the source XML?
│  └─ YES → Use element-replace (Root Cause #6)
│
└─ None of the above?
   └─ Check for typos — compare character-by-character
```

---

## 5. Step-by-Step Fix Process

### For "Modified text not found" Warnings

1. **Identify the target element** from the warning (note the `canonical-id`)

2. **Find it in the merged output:**
   ```bash
   grep -A 10 "xml:id=\"nbc.divB.part3.sect1.art1.sent1\"" bc-building-code.xml
   ```

3. **Copy the `<text>` element** (or `<definition>`, `<title>`, etc.) from the output

4. **Apply your intended change** to the copied content

5. **Replace the `text-change`** with `element-replace`:
   ```xml
   <modify>
       <element-replace element="text">
           <new-content source="bc">
               <!-- Your modified copy goes here -->
           </new-content>
       </element-replace>
   </modify>
   ```

6. **Re-run the pipeline** and verify the warning is gone

---

## 6. When `text-change` IS Fine

Don't over-correct — `text-change` works perfectly when:

- The `<find>` text is entirely within **one plain text node** (no `<ref>` elements in between)
- The text doesn't reference display names from self-closing elements
- No other amendment targets the same element with `element-replace`

**Example of a working `text-change`:**
```xml
<!-- The word "accessible" is plain text, not inside a <ref> -->
<text-change xpath-within-target="text()">
    <find-replace>
        <find>shall be accessible</find>
        <replace>shall be universally accessible</replace>
    </find-replace>
</text-change>
```

---

## 7. Best Practices

### Test Amendments Individually

Before adding many amendments, test complex ones individually to catch issues early.

### Use grep to Verify IDs

```bash
# Verify the ID exists before creating amendment
grep "nbc.divB.part3.sect1.art1" bc-building-code.xml
```

### Review Schema When Unsure

Check the canonical schema (`canonical-nbc.rng`) for allowed element structures.

### Follow the Checklist

Before committing amendments:
- [ ] All IDs use `nbc.` prefix
- [ ] `source="bc"` on BC-specific `<new-content>`
- [ ] Unique amendment IDs
- [ ] Correct sequence numbers
- [ ] Clear descriptions
- [ ] Validation passes without errors

---

## 8. Real Examples from This Project

### Example A: "each suite" → "a suite"

- **Target**: `nbc.divB.part3.sect3.subsect1.art1.sent1`
- **Problem**: "suite" is inside `<ref type="term">`
- **Fix**: `element-replace element="text"`

### Example B: "National Fire Code" → "British Columbia Fire Code"

- **Targets**: Various clauses in Section 3.3.5, 3.3.6
- **Problem**: "National Fire Code" resolves from `<ref type="standard"/>`
- **Fix**: `element-replace element="text"` replacing `<ref>` with plain text

### Example C: Multiple Changes to Same Element

- **Target**: `nbc.divB.part3.sect3.subsect1.art7.sent1`
- **Problem**: bc-053 and bc-058 both targeted same element
- **Fix**: Combined both changes into single `element-replace`

### Example D: Complex XPath Selector

- **Target**: `nbc.divB.part3.sect8.subsect3.art14.sent1.clause1`
- **Problem**: XPath `.//measurement[@units='metric']` not supported
- **Fix**: `element-replace element="text"`

---

## Next Steps

- **[06-quick-reference.md](06-quick-reference.md)** - Printable reference card
- **[07-examples-library.md](07-examples-library.md)** - More working examples
