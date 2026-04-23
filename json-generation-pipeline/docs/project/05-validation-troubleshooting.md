# Validation and Troubleshooting Guide

This guide explains how to validate amendments and fix common issues that arise during the amendment process.

---

## 1. Running the Validation Pipeline

### Step 1: Combine Amendment Files

```bash
# For overlay amendments (Phase 1)
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/combine-amendments.xsl \
  -s:json-generation-pipeline/source/bc-amendments/amendment-list.xml \
  -o:json-generation-pipeline/output/bc-amendments-combined.xml

# For revision amendments (Phase 2)
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/combine-amendments.xsl \
  -s:json-generation-pipeline/source/bc-revisions/revision-list.xml \
  -o:json-generation-pipeline/output/bc-revisions-combined.xml
```

### Step 2: Apply Amendments

```bash
# Phase 1: Apply overlay amendments
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/merge-engine-v3.xsl \
  -s:json-generation-pipeline/output/nbc-canonical.xml \
  overlay-document=json-generation-pipeline/output/bc-amendments-combined.xml \
  -o:json-generation-pipeline/output/bc-building-code.xml

# Phase 2: Apply revision amendments
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/merge-engine-v3.xsl \
  -s:json-generation-pipeline/output/bc-building-code.xml \
  overlay-document=json-generation-pipeline/output/bc-revisions-combined.xml \
  -o:json-generation-pipeline/output/bc-building-code-final.xml
```

### Step 3: Validate

```bash
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/validate-amendments.xsl \
  -s:json-generation-pipeline/output/bc-amendments-combined.xml \
  combined-amendments=json-generation-pipeline/output/bc-amendments-combined.xml \
  bc-building-code=json-generation-pipeline/output/bc-building-code.xml \
  -o:json-generation-pipeline/output/amendment-validation-report.html
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
<list list-type="unordered">
    <list-item>Content</list-item>
</list>
```

**Correct:**
```xml
<list type="bulleted">
    <item xml:id="bc.divB.appendixC.div1.list1.item1">Content</item>
</list>
```

**Rules:**
- Element name is `item`, not `list-item`
- Attribute is `type`, not `list-type`
- Values are `bulleted` or `numbered`, not `unordered` or `ordered`
- Do NOT add `xml:id` to `<list>` elements (only to items)

#### Paragraph Wrapper Issues

Items should contain rich-text directly, not wrapped in `<paragraph>` elements:

**Wrong:**
```xml
<item xml:id="bc.id">
    <paragraph>Item text here</paragraph>
</item>
```

**Correct:**
```xml
<item xml:id="bc.id">Item text here</item>
```

#### Line-break Elements

`<line-break/>` is not part of the canonical NBC schema:

**Wrong:**
```xml
<item>First line<line-break/>Second line</item>
```

**Correct:**
```xml
<item>First line
Second line</item>
```

#### Note-division in Appendix Context

`<note-division>` is only valid inside `<application-note>` elements in Part appendices, not in Division C appendices:

**Wrong:**
```xml
<note-division>
    <title>Example</title>
    <paragraph>Content</paragraph>
</note-division>
```

**Correct (in Division C appendix context):**
```xml
<paragraph xml:id="bc.divB.appendixC.div1.para1">
    <emphasis role="bold">Example</emphasis>: Content
</paragraph>
```

#### Modifying Titles with set-text

When modifying title content, use `<set-text>` instead of `<find-replace>` to preserve the `<title>` wrapper:

**Wrong (strips `<title>` wrapper):**
```xml
<text-change xpath-within-target=".//title">
    <find-replace>
        <find>Old Title</find>
        <replace>New Title</replace>
    </find-replace>
</text-change>
```

**Correct:**
```xml
<text-change xpath-within-target=".//title">
    <set-text>New Title</set-text>
</text-change>
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
# grep (Git Bash)
grep -n "nbc.divB.part3.sect1.art1.sent1" json-generation-pipeline/output/bc-building-code.xml
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
java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/combine-amendments.xsl \
  -s:json-generation-pipeline/source/bc-amendments/amendment-list.xml \
  -o:json-generation-pipeline/output/bc-amendments-combined.xml

java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/merge-engine-v3.xsl \
  -s:json-generation-pipeline/output/nbc-canonical.xml \
  overlay-document=json-generation-pipeline/output/bc-amendments-combined.xml \
  -o:json-generation-pipeline/output/bc-building-code.xml

java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/validate-amendments.xsl \
  -s:json-generation-pipeline/output/bc-amendments-combined.xml \
  combined-amendments=json-generation-pipeline/output/bc-amendments-combined.xml \
  bc-building-code=json-generation-pipeline/output/bc-building-code.xml \
  -o:json-generation-pipeline/output/amendment-validation-report.html
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
grep -A 10 "xml:id=\"nbc.divB.part3.sect1.art1.sent1\"" json-generation-pipeline/output/bc-building-code.xml
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
grep "nbc.divB.part3.sect1.art1" json-generation-pipeline/output/bc-building-code.xml
```

### Review Schema When Unsure

Check the canonical schema (`json-generation-pipeline/output/schema/canonical-nbc.rng`) for allowed element structures.

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

### Example E: Table Dropped by Article Replace (9.8.7.1)

- **Target**: `nbc.divBV2.part9.sect8.subsect7.art1`
- **Problem**: Amendment `bc-070` replaced the article to renumber sentences and add secondary suite references, but `<new-content>` only contained the sentences — not the "Number of Sides of Stair or Ramp Required to Have a Handrail" table (`et001232`). The table was silently dropped. The only symptom was a broken reference in `broken-references-full.txt`: `Target (Not Found): nbc.divBV2.part9.sect8.subsect7.art1.table1`
- **Fix**: Add the full `<table>` block from `nbc-canonical.xml` into `<new-content>` between sentence 1 and sentence 2
- **Rule**: When replacing an article with `<replace>`, always copy all `<table>` children from the canonical source into `<new-content>`

### Example F: Application Note Content Missing — `<example>` Not Processed (A-9.36.1.1.(1))

- **Target**: `nbc.divBV2.part9.appendix.appnote210`
- **Problem**: The NBC source XML wraps the formula content (a borderless 3-column table) inside an `<example>` element directly under `<appnote>`. The `nbc-to-canonical.xsl` appnote template processed `para`, `division`, `table`, and `figure` children but had no handler for direct `<example>` children — so the formula table was silently dropped during canonical conversion. The note rendered with only its title in the output.
- **Affected notes**: 4 total — `en001737` (A-9.36.1.1.(1)), `en001794`, `en001795` (Trading R-values of Windows), `en000324` (Concrete Topping)
- **Fix**: Added `<xsl:apply-templates select="example">` at the appnote level in `nbc-to-canonical.xsl`, passing `$appnote-id` as `parent-id`. Requires full pipeline rebuild from canonical step.
- **Rule**: If an appendix note appears in the output with only `<number>` and `<title>` but visibly has content in the Word doc, check whether the NBC source uses `<example>` directly inside `<appnote>` rather than `<para>`.

### Example G: NBC Source Wrong Sentence Number — D-2.3.3.(3)

- **Target**: `nbc.divB.appendixD.appsect2.subsect3.article3.para3`
- **Problem**: The NBC vendor XML (`en000477.3`) has `<number>4)</number>` for what is visibly the 3rd sentence in D-2.3.3. There is no sentence 3 in the source — it jumps from 2 to 4. The rendered output shows `4)` instead of `3)`.
- **Fix**: Phase 1 overlay amendment `bc-019` using `element-replace` to replace the full paragraph, correcting `4)` → `3)` and supplying explicit display text on the three `<ref>` elements (see below).
- **Rule**: When the NBC source has a wrong sentence number, use `element-replace` on the paragraph rather than `text-change`, especially when the paragraph also contains `<ref>` elements that need fixing.

### Example H: Table Refs Rendering Wrong Label — D-2.3.3 Tables D-2.3.4.-A/B/C

- **Target**: `nbc.divB.appendixD.appsect2.subsect3.article3.para3` (same as Example G)
- **Problem**: The three `<ref>` elements in D-2.3.3.(3) point to `article4.table1/2/3`. The front-end derives labels from the canonical ID, rendering them as `D.2.3.4.`, `D.2.3.4.` and `D.2.3.4.` (dots, no letter suffix) instead of `D-2.3.4.-A`, `D-2.3.4.-B` and `D-2.3.4.-C`.
- **Fix**: Combined with Example G in amendment `bc-019`. Each `<ref>` is given explicit display text content (`Table D-2.3.4.-A`, `D-2.3.4.-B`, `D-2.3.4.-C`) so the front-end uses that text rather than auto-generating from the ID.
- **Rule**: When a table's canonical ID does not produce the correct BC-style label (e.g. letter suffix `-A`, `-B`, `-C`), supply explicit display text inside the `<ref>` element rather than relying on `display-type` auto-generation.

### Example I: NBC Source Missing Sentence Numbers — D-2.11.4 and D-2.3.15

- **Targets**: `nbc.divB.appendixD.appsect2.subsect11.article4.para1` through `para6` (D-2.11.4), `nbc.divB.appendixD.appsect2.subsect3.article15.para2` (D-2.3.15)
- **Problem**: The NBC vendor XML omits the `<number>` element entirely for these paragraphs. The `nbc-to-canonical.xsl` transform only includes sentence numbers when a `<number>` child exists, so the canonical output has no `1)`, `2)`, etc. prefix on the paragraph text.
- **Fix**: Phase 1 overlay amendments `bc-020` through `bc-026` using `replace` to prepend the correct sentence number to each paragraph. All use `preserve-references="true"` and copy the full paragraph content from `nbc-canonical.xml` with the number added.
- **Important**: Do NOT use `text-change` with `xpath-within-target="text()[1]"` — the merge engine does not support the `[1]` positional predicate. Always use `replace` for paragraphs that contain `<ref>`, `<measurement>`, or `<list>` child elements.
- **Rule**: When the NBC source is missing `<number>` elements on `<para-nmbrd>`, use `replace` on the canonical paragraph to prepend the sentence number. Check the vendor XML (`nbc2020.xml`) to confirm the `<number>` child is absent rather than just empty.

### Example J: BC Amendment Refs Rendering Wrong Labels — 9.32.3.4.(6)

- **Source file**: `json-generation-pipeline/source/bc-amendments/xml/NBC2020p1 Division B Part 9.FIN_1.xml`
- **Target**: `nbc.divBV2.part9.sect32.subsect3.art4.sent6` (BC-authored content, `source="bc"`)
- **Problem**: Multiple self-closing `<ref/>` elements in BC-authored sentence 6 rendered incorrect labels in the front-end:
  - Subclause (a)(i): ref rendered as "Sentence 1.1.3.(1) of Division A" instead of "Article 1.1.3.1."
  - Subclause (a)(ii): missing "(see Note A-9.32.3.4.(6)(a)(ii))" text
  - Subclause (a)(iv): refs rendered with "of Division BV2" suffix instead of plain "Subsection 9.36.6. or 10.2.3."
  - Clause (b)(i): ref rendered as "Subclause (iii)" instead of "Subclause (2)(a)(iii)"
- **Fix**: Directly edited the BC amendment source file to add explicit display text inside each `<ref>` element and add the missing note reference text. No new overlay amendment needed.
- **Key distinction**: This was a direct edit to the amendment file, NOT a new overlay amendment, because the content is BC-authored (`source="bc"`). The rule is:
  - **NBC source errors** → write a new overlay amendment
  - **BC amendment errors** → directly edit the amendment source file

### Example K: BC Amendment Refs with "of Division B/BV2" Suffix — 9.33.1.1.(2)

- **Source file**: `json-generation-pipeline/source/bc-amendments/xml/NBC2020p1 Division B Part 9.FIN_1.xml`
- **Target**: `nbc.divBV2.part9.sect33.subsect1.art1.sent2` (BC-authored content)
- **Problem**: Refs to `nbc.divB.part6` and `nbc.divBV2.part9.sect10.subsect10` with `display-type="long"` auto-generated labels "Part 6 of Division B" and "Subsection 9.10.10. of Division BV2" instead of "Part 6" and "Subsection 9.10.10."
- **Fix**: Direct edit — added explicit display text `Part 6` and `Subsection 9.10.10.` inside the `<ref>` elements.
- **Rule**: When a ref target crosses division boundaries (e.g. from Division BV2 content referencing Division B), the auto-generated label appends "of Division X". Supply explicit display text to suppress this.

### Example L: Unresolved Vendor-ID Refs in Application Note — A-3.2.6.6.(1)

- **Target**: `nbc.divB.part3.appendix.appnote107.para1`
- **Problem**: The `nbc-to-canonical.xsl` transform left vendor IDs (`en000439.1`, `en000439.2`, etc.) as ref targets instead of mapping them to canonical sentence IDs. The front-end rendered the raw vendor IDs as text.
- **Fix**: Phase 1 overlay amendment `bc-139` in `NBC2020p1 Division B Part 3.FIN_2.xml` replacing the paragraph with correct canonical targets (`nbc.divB.part3.sect2.subsect6.art6.sent1` through `sent9`) and explicit display text.
- **Rule**: When an application note contains refs with `target="enXXXXXX.N"` vendor IDs that don't resolve, replace the paragraph with an overlay amendment using canonical IDs. Check the article's sentences in `bc-building-code.xml` to find the correct canonical targets.

### Example M: Equation Content Missing from JSON — LaTeX Handler

- **Target**: `nbc.divBV2.part9.appendix.appnote129a.div5.eq1`
- **Problem**: The `canonical-to-json.xsl` equation template handled MathML (`<math>`) and plain text (`<text>`) children but had no handler for `<latex>` children. Equations with `<latex>` content produced JSON with only `id` and `type` fields — no renderable content. The front-end fell back to displaying the equation's `xml:id`.
- **Fix**: Added a `<latex>` handler in the `equation-json` template in `canonical-to-json.xsl` that outputs both `latex` and `plainText` keys. Also corrected the LaTeX formula to use `\frac{}{}` notation for proper fraction rendering.
- **Rule**: When adding new equation formats to the canonical XML, ensure the `equation-json` template in `canonical-to-json.xsl` has a matching handler. Currently supported: MathML (`<math>`), LaTeX (`<latex>`), plain text (`<text>`).

### Example N: Sentence Trailing Text Concatenated into Text Field — 9.36.5.3.(1)

- **Source file**: `json-generation-pipeline/source/bc-amendments/xml/NBC2020p1 Division B Part 9.FIN_2.xml`
- **Target**: `nbc.divBV2.part9.sect36.subsect5.art3.sent1` (BC-authored content)
- **Problem**: The sentence had two `<text>` children — the main sentence text and a trailing `(See Note ...)` after the clauses. The XSLT `select="text"` grabbed both and concatenated them into one `text` field, producing `"...in accordance with(See Note A-9.36.5.3.(1).)"`.
- **Fix**: Changed the trailing `<text>` to a `<see-also>` element in the amendment source. The XSLT already handles `<see-also>` as a separate JSON field (`see_also`), so it no longer gets concatenated into the sentence text.
- **Rule**: Never use multiple `<text>` children inside a `<sentence>`. The XSLT concatenates all `<text>` children into one `text` field. Use `<see-also>` for trailing note references after clauses.

### Example O: Article-Level Note Not Output to JSON — 9.36.5.3

- **Source file**: `json-generation-pipeline/transformation-xslt/canonical-to-json.xsl`
- **Target**: `nbc.divBV2.part9.sect36.subsect5.art3` (article with `<note>` child)
- **Problem**: The article had a `<note>` child element containing `(See Note A-9.36.5.3.)` that should render before sentence 1. The XSLT article template only processed `sentence | table | figure` children — `<note>` was silently dropped from the JSON output.
- **Fix**: Added `<note>` handling in the article template in `canonical-to-json.xsl`. When an article has a `<note>` child, it outputs a `"note"` string field in the article JSON object.
- **Front-end dependency**: The JSON now includes the `note` field, but the front-end renderer must be updated to display `article.note` when present (rendered before the first sentence).
- **Rule**: When adding new child element types to articles in the canonical XML, ensure the article template in `canonical-to-json.xsl` processes them. Currently handled: `sentence`, `table`, `figure`, `see-also`, `note`.

---

## Next Steps

- **[06-quick-reference.md](06-quick-reference.md)** - Printable reference card
- **[07-examples-library.md](07-examples-library.md)** - More working examples
