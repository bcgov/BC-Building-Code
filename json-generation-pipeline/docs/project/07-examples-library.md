# BC Building Code Amendment System - Examples Library

A curated collection of working examples for each operation type, organized by use case.

---

## Table of Contents

1. [Replace Operations](#1-replace-operations)
2. [Insert Operations](#2-insert-operations)
3. [Modify Operations - Text Change](#3-modify-operations---text-change)
4. [Modify Operations - Element Replace](#4-modify-operations---element-replace)
5. [Delete Operations](#5-delete-operations)
6. [Revision Amendments](#6-revision-amendments)
7. [Deletion Tracking](#7-deletion-tracking)
8. [Special Targets](#8-special-targets)

---

## 1. Replace Operations

### Example 1.1: Replace Sentence with Clauses

**Source:** `json-generation-pipeline/source/bc-amendments/xml/NBC2020p1 Division A_FIN.xml`
**Amendment ID:** `bc-001`
**Description:** Replace a simple sentence with detailed clause structure

```xml
<amendment id="bc-001" sequence="1"
           description="Replace Sentence 1 with detailed application clauses">
    <target type="canonical-id" id="nbc.divA.part1.sect1.subsect1.art1.sent1"/>
    <replace preserve-references="false">
        <new-content source="bc">
            <sentence xml:id="nbc.divA.part1.sect1.subsect1.art1.sent1" number="1">
                <text>This Code applies to any one or more of the following:</text>
                <clause xml:id="nbc.divA.part1.sect1.subsect1.art1.sent1.clause1" letter="a">
                    <text>the design and construction of a new
                        <ref type="term" target="bldng">building</ref>,</text>
                </clause>
                <clause xml:id="nbc.divA.part1.sect1.subsect1.art1.sent1.clause2" letter="b">
                    <text>the <ref type="term" target="ccpnc">occupancy</ref> of any
                        <ref type="term" target="bldng">building</ref>,</text>
                </clause>
                <!-- More clauses... -->
            </sentence>
        </new-content>
    </replace>
</amendment>
```

**Why this approach:**
- `preserve-references="false"` because we're completely restructuring the content
- `source="bc"` identifies this as BC-specific content
- Each clause has unique hierarchical ID

---

### Example 1.2: Replace Article with BC Requirements

**Source:** `json-generation-pipeline/source/bc-amendments/xml/NBC2020p1 Division B Part 3.FIN_1.xml`
**Amendment ID:** `bc-018`
**Description:** Replace entire article with BC-specific exterior cladding requirements

```xml
<amendment id="bc-018" sequence="7"
           description="Replace Article 3.1.4.8. with BC-specific exterior cladding requirements">
    <target type="canonical-id" id="nbc.divB.part3.sect1.subsect4.art8"/>
    <replace preserve-references="true">
        <new-content source="bc">
            <article xml:id="nbc.divB.part3.sect1.subsect4.art8" number="8">
                <title>Exterior Cladding</title>
                <sentence xml:id="nbc.divB.part3.sect1.subsect4.art8.sent1" number="1">
                    <text>Except as provided in
                        <ref type="internal" target="nbc.divB.part3.sect1.subsect4.art8.sent2"
                             display-type="short"/>, cladding on an exterior wall assembly...</text>
                    <clause xml:id="nbc.divB.part3.sect1.subsect4.art8.sent1.clause1" letter="a">
                        <text><ref type="term" target="ncmbtbl">noncombustible</ref> cladding, or</text>
                    </clause>
                    <clause xml:id="nbc.divB.part3.sect1.subsect4.art8.sent1.clause2" letter="b">
                        <text>a wall assembly that satisfies the criteria...</text>
                    </clause>
                </sentence>
                <sentence xml:id="nbc.divB.part3.sect1.subsect4.art8.sent2" number="2">
                    <text>For buildings described in Sentence (1)...</text>
                </sentence>
                <!-- More sentences... -->
            </article>
        </new-content>
    </replace>
</amendment>
```

**Why this approach:**
- `preserve-references="true"` because internal references to this article should continue to work
- Complete article structure with title, sentences, and clauses

---

## 2. Insert Operations

### Example 2.1: Insert New Sentence After Existing

**Source:** `json-generation-pipeline/source/bc-amendments/xml/NBC2020p1 Division B Part 3.FIN_1.xml`
**Amendment ID:** `bc-014`
**Description:** Add new sentence with clause structure

```xml
<amendment id="bc-014" sequence="3"
           description="Add new sentence 2 for care facilities">
    <target type="position"
            parent-id="nbc.divB.part3.sect1.subsect2.art5"
            position="after"
            reference-id="nbc.divB.part3.sect1.subsect2.art5.sent1"/>
    <insert>
        <new-content source="bc">
            <sentence xml:id="nbc.divB.part3.sect1.subsect2.art5.sent2" number="2">
                <text>A care facility accepted for residential use pursuant to
                    provincial legislation is permitted to be classified as a
                    <ref type="term" target="rdntl-cc">residential occupancy</ref>, provided</text>
                <clause xml:id="nbc.divB.part3.sect1.subsect2.art5.sent2.clause1" letter="a">
                    <text>occupants live as a single housekeeping unit in a
                        <ref type="term" target="dwllng-n">dwelling unit</ref>
                        with sleeping accommodation for not more than 10 persons,</text>
                </clause>
                <clause xml:id="nbc.divB.part3.sect1.subsect2.art5.sent2.clause2" letter="b">
                    <text><ref type="term" target="mk-lrm">smoke alarms</ref> are installed
                        in conformance with
                        <ref type="internal" target="nbc.divB.part3.sect2.subsect4.art20"
                             display-type="long"/>,</text>
                </clause>
                <clause xml:id="nbc.divB.part3.sect1.subsect2.art5.sent2.clause3" letter="c">
                    <text>emergency lighting is provided in conformance with
                        <ref type="internal" target="nbc.divB.part3.sect2.subsect7"
                             display-type="long"/>, and</text>
                </clause>
                <clause xml:id="nbc.divB.part3.sect1.subsect2.art5.sent2.clause4" letter="d">
                    <text>the <ref type="term" target="bldng">building</ref> is
                        <ref type="term" target="prnklrd">sprinklered</ref> throughout.</text>
                </clause>
            </sentence>
        </new-content>
    </insert>
</amendment>
```

**Key points:**
- `position="after"` with `reference-id` specifies exact insertion point
- All IDs follow hierarchical pattern
- References use proper `<ref>` elements

---

### Example 2.2: Insert New Article (Chained Inserts)

**Source:** `json-generation-pipeline/source/bc-amendments/xml/NBC2020p1 Division B Part 3.FIN_1.xml`
**Amendment IDs:** `bc-015`, `bc-016`
**Description:** Insert two new articles in sequence

```xml
<!-- First: Insert Article 3.1.2.7 -->
<amendment id="bc-015" sequence="4"
           description="Add new Article 3.1.2.7. for Group A, Division 2 low occupant load">
    <target type="position"
            parent-id="nbc.divB.part3.sect1.subsect2"
            position="after"
            reference-id="nbc.divB.part3.sect1.subsect2.art6"/>
    <insert>
        <new-content source="bc">
            <article xml:id="nbc.divB.part3.sect1.subsect2.art7" number="7">
                <title>Group A, Division 2, Low Occupant Load</title>
                <sentence xml:id="nbc.divB.part3.sect1.subsect2.art7.sent1" number="1">
                    <text>A <ref type="term" target="t">suite</ref> of Group A, Division 2
                        <ref type="term" target="mbl-ccpn">assembly occupancy</ref>...</text>
                    <!-- Clauses... -->
                </sentence>
            </article>
        </new-content>
    </insert>
</amendment>

<!-- Second: Insert Article 3.1.2.8 after the newly created art7 -->
<amendment id="bc-016" sequence="5"
           description="Add new Article 3.1.2.8. for daycare facilities">
    <target type="position"
            parent-id="nbc.divB.part3.sect1.subsect2"
            position="after"
            reference-id="nbc.divB.part3.sect1.subsect2.art7"/>  <!-- References bc-015's output -->
    <insert>
        <new-content source="bc">
            <article xml:id="nbc.divB.part3.sect1.subsect2.art8" number="8">
                <title>Daycare Facilities for Children</title>
                <sentence xml:id="nbc.divB.part3.sect1.subsect2.art8.sent1" number="1">
                    <text>A daycare facility for children shall be classified as...</text>
                </sentence>
            </article>
        </new-content>
    </insert>
</amendment>
```

**Key point:** Amendment bc-016 (sequence 5) references the article created by bc-015 (sequence 4). The merge engine processes in sequence order.

---

## 3. Modify Operations - Text Change

### Example 3.1: Simple Word Change

**Source:** `json-generation-pipeline/source/bc-amendments/xml/NBC2020p1 Division B Part 3.FIN_1.xml`
**Amendment ID:** `bc-017`
**Description:** Change "required" to "permitted"

```xml
<amendment id="bc-017" sequence="6"
           description="Change 'required to be' to 'permitted to be'">
    <target type="canonical-id" id="nbc.divB.part3.sect1.subsect4.art2.sent2"/>
    <modify>
        <text-change xpath-within-target="text()">
            <find-replace>
                <find>required to be of</find>
                <replace>permitted to be of</replace>
            </find-replace>
        </text-change>
    </modify>
</amendment>
```

**When to use:** When the text to change is entirely within plain text nodes (no `<ref>` elements in the find string).

---

### Example 3.2: Change Title Text

**Source:** `json-generation-pipeline/source/bc-amendments/xml/NBC2020p1 Division B Part 3.FIN_1.xml`
**Amendment ID:** `bc-013`
**Description:** Update article title

```xml
<amendment id="bc-013" sequence="2"
           description="Update Article 3.1.2.5. title to include Residential Care Homes">
    <target type="canonical-id" id="nbc.divB.part3.sect1.subsect2.art5"/>
    <modify>
        <text-change xpath-within-target=".//title">
            <find-replace>
                <find>Convalescent and Children's Custodial Homes</find>
                <replace>Convalescent, Children's Custodial, and Residential Care Homes</replace>
            </find-replace>
        </text-change>
    </modify>
</amendment>
```

**Key point:** Uses `.//title` to target the title element within the article.

---

## 4. Modify Operations - Element Replace

### Example 4.1: Replace Text Element (with `<ref>` elements)

**Use case:** When the find text would span `<ref>` element boundaries

```xml
<amendment id="bc-048" sequence="48"
           description="Change 'each suite' to 'a suite'">
    <target type="canonical-id" id="nbc.divB.part3.sect3.subsect1.art1.sent1"/>
    <modify>
        <element-replace element="text" position="1">
            <new-content source="bc">
                <text>..., a <ref type="term" target="t">suite</ref> in other than
                    a <ref type="term" target="bldng">building</ref> described in
                    <ref type="internal" target="nbc.divB.part3.sect2.subsect2.art48"
                         display-type="long"/>...</text>
            </new-content>
        </element-replace>
    </modify>
</amendment>
```

**Why element-replace:** The word "suite" is inside a `<ref>` element, so `text-change` can't find "each suite" as a continuous string.

---

### Example 4.2: Replace Definition Element

```xml
<amendment id="bc-044" sequence="44"
           description="Replace definition element">
    <target type="canonical-id" id="nbc.divA.part1.sect4.subsect1.art2.term15"/>
    <modify>
        <element-replace element="definition" position="1">
            <new-content source="bc">
                <definition>
                    <paragraph>
                        <text>A building or part of a building used for the
                            housing of farm animals or the storage of farm produce.</text>
                    </paragraph>
                </definition>
            </new-content>
        </element-replace>
    </modify>
</amendment>
```

---

## 5. Delete Operations

### Example 5.1: Simple Delete

```xml
<amendment id="bc-099" sequence="99"
           description="Delete sentence 3">
    <target type="canonical-id" id="nbc.divB.part3.sect1.subsect2.art5.sent3"/>
    <delete/>
</amendment>
```

**Note:** For Phase 2 amendments where you need to track deletion history, use revision amendments with `deleted="yes"` instead.

---

## 6. Revision Amendments

### Example 6.1: Table Row Update with Revision History

**Source:** `json-generation-pipeline/source/bc-revisions/xml/Ministerial Order BA 2024 01.xml`
**Amendment ID:** `bc-mo-2024-01-001`

```xml
<amendment id="bc-mo-2024-01-001" sequence="1000"
           description="Add 3.1.6.6.(6)(c) to ASTM C840-18b Code Reference column">
    <target type="canonical-id" id="nbc.divB.part1.sect3.subsect1.art2.table1.row64"/>
    <replace preserve-references="true">
        <new-content source="bc">
            <row xml:id="nbc.divB.part1.sect3.subsect1.art2.table1.row64">
                <entry>ASTM</entry>
                <entry>C840-18b</entry>
                <entry>Standard Specification for Application and Finishing of Gypsum Board</entry>
                <entry revised="yes">
                    <revision-history>
                        <original effective-date="2020-12-01">
                            <!-- Merge engine auto-populates -->
                        </original>
                        <revision seq="1" type="amendment" effective-date="2024-04-05"
                                  id="bc-mo-2024-01-001" status="current">
                            <content>
                                <ref type="internal" target="nbc.divB.part3.sect1.subsect6.art6.sent2"
                                     display-type="number"/>
                                <ref type="internal" target="nbc.divB.part3.sect1.subsect6.art6.sent6.clause3"
                                     display-type="number"/>
                                <!-- More references... -->
                            </content>
                            <change-summary>Added 3.1.6.6.(6)(c) to Code Reference</change-summary>
                            <note>Ministerial Order BA 2024 01</note>
                        </revision>
                    </revision-history>
                </entry>
            </row>
        </new-content>
    </replace>
</amendment>
```

**Key points:**
- Only the entry that changes gets `revised="yes"` and `<revision-history>`
- `<original>` left empty for merge engine to populate
- `status="current"` marks this as the active revision

---

### Example 6.2: Clause Update with Revision History

**Source:** `json-generation-pipeline/source/bc-revisions/xml/Ministerial Order BA 2024 06.xml`
**Amendment ID:** `bc-mo-2024-06-002`

```xml
<amendment id="bc-mo-2024-06-002" sequence="4001"
           description="Amend Clause 1.1.1.1.(2)(a)">
    <target type="canonical-id" id="nbc.divA.part1.sect1.subsect1.art1.sent2.clause1"/>
    <replace preserve-references="false">
        <new-content source="bc">
            <clause xml:id="nbc.divA.part1.sect1.subsect1.art1.sent2.clause1"
                    letter="a" revised="yes">
                <revision-history>
                    <original effective-date="2020-12-01">
                        <!-- Merge engine will auto-populate -->
                    </original>
                    <revision seq="1" type="amendment" effective-date="2025-06-16"
                              id="bc-mo-2024-06-002" status="current">
                        <content>
                            <text><ref type="term" target="swg">sewage</ref>, water, electrical,
                                telephone, rail or similar public infrastructure systems...</text>
                        </content>
                        <change-summary>Amended by striking out "sewage" and substituting "sewage"</change-summary>
                        <note>Ministerial Order BA 2024 06</note>
                    </revision>
                </revision-history>
            </clause>
        </new-content>
    </replace>
</amendment>
```

---

## 7. Deletion Tracking

### Example 7.1: Delete Table Row with History

**Source:** `json-generation-pipeline/source/bc-revisions/xml/Ministerial Order BA 2024 06.xml`
**Amendment ID:** `bc-mo-2024-06-134`

```xml
<amendment id="bc-mo-2024-06-134" sequence="4104"
           description="Delete Table 9.38.1.1. row for Article 9.8.5.5.">
    <target type="canonical-id" id="nbc.divBV2.part9.sect38.subsect1.art1.table1.row393"/>
    <replace preserve-references="false">
        <new-content source="bc">
            <row xml:id="nbc.divBV2.part9.sect38.subsect1.art1.table1.row393"
                 revised="yes" deleted="yes">
                <revision-history>
                    <original effective-date="2020-12-01">
                        <!-- Merge engine will auto-populate original content -->
                    </original>
                    <revision seq="1" type="amendment" effective-date="2025-06-16"
                              id="bc-mo-2024-06-134" status="current">
                        <content>
                            <!-- Empty content indicates deletion -->
                        </content>
                        <change-summary>Row deleted - Article 9.8.5.5. entry removed from table</change-summary>
                        <note>Ministerial Order BA 2024 06</note>
                    </revision>
                </revision-history>
            </row>
        </new-content>
    </replace>
</amendment>
```

**Key points:**
- `deleted="yes"` on the element marks it as deleted
- `revised="yes"` indicates it has revision history
- `<content>` is empty (indicates deletion)
- Change summary explains why deleted

---

## 8. Special Targets

### Example 8.1: Child Element Target (Title)

**Source:** `Ministerial Order BA 2024 06.xml`
**Amendment ID:** `bc-mo-2024-06-007`
**Description:** Target title element without its own ID

```xml
<amendment id="bc-mo-2024-06-007" sequence="4006"
           description="Amend Subsection 1.1.3. title">
    <target type="child-element"
            parent-id="nbc.divA.part1.sect1.subsect3"
            element-name="title"
            position="1"/>
    <replace preserve-references="false">
        <new-content source="bc">
            <title revised="yes">
                <revision-history>
                    <original effective-date="2020-12-01">
                        <!-- Merge engine auto-populates original title -->
                    </original>
                    <revision seq="1" type="amendment" effective-date="2025-06-16"
                              id="bc-mo-2024-06-007" status="current">
                        <content>Notes</content>
                        <change-summary>Amended title by striking out "Appendices," and "and Annotations"</change-summary>
                        <note>Ministerial Order BA 2024 06</note>
                    </revision>
                </revision-history>
            </title>
        </new-content>
    </replace>
</amendment>
```

**Key points:**
- `type="child-element"` targets elements without their own IDs
- `parent-id` specifies the parent with an ID
- `element-name="title"` identifies the child element type
- `position="1"` targets the first occurrence

---

### Example 8.2: Table Row Insert

```xml
<amendment id="bc-060" sequence="60"
           description="Insert new row in Table 3.1.3.1">
    <target type="table-row-insert"
            table-id="nbc.divB.part3.sect1.subsect3.art1.table1"
            position="after"
            match-row-containing="Fire-Resistance Rating"/>
    <insert>
        <new-content source="bc">
            <row xml:id="nbc.divB.part3.sect1.subsect3.art1.table1.row_new">
                <entry align="center">New Category</entry>
                <entry align="center">1</entry>
                <entry align="center">2</entry>
                <!-- More entries... -->
            </row>
        </new-content>
    </insert>
</amendment>
```

**Key point:** `match-row-containing` finds the reference row by text content.

---

## Summary: Choosing the Right Pattern

| Need to... | Pattern | Example |
|------------|---------|---------|
| Replace entire element | Replace | 1.1, 1.2 |
| Add new content | Insert with position | 2.1, 2.2 |
| Change simple text | Modify text-change | 3.1, 3.2 |
| Change text with `<ref>` | Modify element-replace | 4.1, 4.2 |
| Remove element (Phase 1) | Delete | 5.1 |
| Track change history | Revision amendment | 6.1, 6.2 |
| Track deletion | Deletion with history | 7.1 |
| Target child without ID | child-element target | 8.1 |
| Insert table row | table-row-insert | 8.2 |
