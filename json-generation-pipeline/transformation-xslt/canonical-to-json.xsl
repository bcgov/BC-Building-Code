<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="fn">
    
    <!-- ================================================================== -->
    <!-- CANONICAL NBC TO JSON TRANSFORM                                    -->
    <!-- Converts merged canonical NBC+BC to structured JSON for AI systems -->
    <!-- ================================================================== -->
    
    <xsl:output method="text" encoding="UTF-8"/>
    
    <!-- Parameters -->
    <!-- include-metadata: Include document metadata and publication info (default: true) -->
    <!-- include-cross-references: Generate cross-reference index for navigation/analysis (default: false) -->
    <!--   Enable for: interactive web apps, reference analysis, standards indexing -->
    <!--   Disable for: smaller file size, AI/LLM systems that don't need the index -->
    <!-- include-bc-annotations: Include BC amendments and revision history (default: true) -->
    <!-- flatten-hierarchy: Flatten hierarchical structure - experimental (default: false) -->
    <xsl:param name="include-metadata" select="true()"/>
    <xsl:param name="include-cross-references" select="false()"/>
    <xsl:param name="include-bc-annotations" select="true()"/>
    <xsl:param name="flatten-hierarchy" select="false()"/>
    
    <!-- Root template -->
    <xsl:template match="/nbc">
        <xsl:variable name="json-structure">
            <fn:map>
                <fn:string key="document_type">bc_building_code</fn:string>
                <fn:string key="version"><xsl:value-of select="@version"/></fn:string>
                <fn:string key="canonical_version"><xsl:value-of select="@canonical-version"/></fn:string>
                <fn:string key="generated_timestamp"><xsl:value-of select="current-dateTime()"/></fn:string>
                
                <xsl:if test="$include-metadata">
                    <fn:map key="metadata">
                        <xsl:apply-templates select="metadata" mode="json"/>
                    </fn:map>
                </xsl:if>
                
                <!-- Front matter (preface, introduction, committees) -->
                <xsl:if test="front-matter">
                    <fn:map key="front_matter">
                        <xsl:apply-templates select="front-matter" mode="json"/>
                    </fn:map>
                </xsl:if>
                
                <!-- Document structure -->
                <fn:array key="divisions">
                    <xsl:apply-templates select="division" mode="json"/>
                </fn:array>
                
                <xsl:if test="$include-cross-references">
                    <fn:map key="cross_references">
                        <xsl:call-template name="build-reference-index"/>
                    </fn:map>
                </xsl:if>
                
                <xsl:if test="$include-bc-annotations">
                    <fn:array key="bc_amendments">
                        <xsl:call-template name="extract-bc-amendments"/>
                    </fn:array>
                </xsl:if>
                
                <!-- Glossary/definitions -->
                <fn:map key="glossary">
                    <xsl:call-template name="build-glossary"/>
                </fn:map>
                
                <!-- Statistics -->
                <fn:map key="statistics">
                    <fn:number key="total_divisions"><xsl:value-of select="count(division)"/></fn:number>
                    <fn:number key="total_parts"><xsl:value-of select="count(.//part)"/></fn:number>
                    <fn:number key="total_sections"><xsl:value-of select="count(.//section)"/></fn:number>
                    <fn:number key="total_articles"><xsl:value-of select="count(.//article)"/></fn:number>
                    <fn:number key="total_sentences"><xsl:value-of select="count(.//sentence)"/></fn:number>
                    <fn:number key="total_tables"><xsl:value-of select="count(.//table)"/></fn:number>
                    <fn:number key="total_figures"><xsl:value-of select="count(.//figure)"/></fn:number>
                    <fn:number key="total_spectables"><xsl:value-of select="count(.//spectables)"/></fn:number>
                    <fn:number key="total_application_notes"><xsl:value-of select="count(.//application-note)"/></fn:number>
                </fn:map>
            </fn:map>
        </xsl:variable>
        
        <xsl:value-of select="fn:xml-to-json($json-structure, map{'indent': true()})"/>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- METADATA PROCESSING                                                -->
    <!-- ================================================================== -->
    
    <xsl:template match="metadata" mode="json">
        <fn:string key="title"><xsl:value-of select="publication-info[1]/title"/></fn:string>
        <fn:string key="subtitle"><xsl:value-of select="publication-info[1]/subtitle"/></fn:string>
        <fn:string key="authority"><xsl:value-of select="publication-info[1]/authority"/></fn:string>
        <fn:string key="publication_date"><xsl:value-of select="publication-info[1]/publication-date"/></fn:string>
        <fn:string key="nrc_number"><xsl:value-of select="catalog-info/nrc-number"/></fn:string>
        <fn:string key="isbn"><xsl:value-of select="catalog-info/isbn"/></fn:string>
        <xsl:if test="count(publication-info) > 1">
            <fn:array key="volumes">
                <xsl:for-each select="publication-info">
                    <fn:map>
                        <fn:string key="volume"><xsl:value-of select="@volume"/></fn:string>
                        <fn:string key="title"><xsl:value-of select="title"/></fn:string>
                        <fn:string key="subtitle"><xsl:value-of select="subtitle"/></fn:string>
                    </fn:map>
                </xsl:for-each>
            </fn:array>
        </xsl:if>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- FRONT MATTER PROCESSING                                            -->
    <!-- ================================================================== -->
    
    <xsl:template match="front-matter" mode="json">
        <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
        
        <!-- Preface -->
        <xsl:if test="preface">
            <fn:map key="preface">
                <xsl:apply-templates select="preface" mode="json"/>
            </fn:map>
        </xsl:if>
        
        <!-- Introduction -->
        <xsl:if test="introduction">
            <fn:map key="introduction">
                <xsl:apply-templates select="introduction" mode="json"/>
            </fn:map>
        </xsl:if>
        
        <!-- Committees -->
        <xsl:if test="committees">
            <fn:map key="committees">
                <xsl:apply-templates select="committees" mode="json"/>
            </fn:map>
        </xsl:if>
    </xsl:template>
    
    <!-- Preface processing -->
    <xsl:template match="preface" mode="json">
        <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
        <fn:string key="type">preface</fn:string>
        
        <!-- Process all content in order -->
        <fn:array key="content">
            <xsl:apply-templates select="paragraph | title | table | figure | list" mode="front-matter-content"/>
        </fn:array>
    </xsl:template>
    
    <!-- Introduction processing -->
    <xsl:template match="introduction" mode="json">
        <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
        <fn:string key="type">introduction</fn:string>
        <xsl:if test="title">
            <fn:string key="title"><xsl:apply-templates select="title[1]" mode="text-only"/></fn:string>
        </xsl:if>
        
        <!-- Process all content in order -->
        <fn:array key="content">
            <xsl:apply-templates select="paragraph | title[position() > 1] | table | figure | list" mode="front-matter-content"/>
        </fn:array>
    </xsl:template>
    
    <!-- Committees processing -->
    <xsl:template match="committees" mode="json">
        <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
        <fn:string key="type">committees</fn:string>
        <xsl:if test="title">
            <fn:string key="title"><xsl:apply-templates select="title[1]" mode="text-only"/></fn:string>
        </xsl:if>
        
        <!-- Tables (committee member lists) -->
        <xsl:if test="table">
            <fn:array key="tables">
                <xsl:apply-templates select="table" mode="json"/>
            </fn:array>
        </xsl:if>
        
        <!-- Paragraphs (notes about committee members) -->
        <xsl:if test="paragraph">
            <fn:array key="notes">
                <xsl:for-each select="paragraph">
                    <fn:map>
                        <xsl:if test="@xml:id">
                            <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
                        </xsl:if>
                        <fn:string key="content"><xsl:apply-templates select="." mode="rich-text-json"/></fn:string>
                    </fn:map>
                </xsl:for-each>
            </fn:array>
        </xsl:if>
    </xsl:template>
    
    <!-- Front matter content items -->
    <xsl:template match="paragraph" mode="front-matter-content">
        <fn:map>
            <fn:string key="type">paragraph</fn:string>
            <xsl:if test="@xml:id">
                <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
            </xsl:if>
            <fn:string key="content"><xsl:apply-templates select="." mode="rich-text-json"/></fn:string>
        </fn:map>
    </xsl:template>
    
    <xsl:template match="title" mode="front-matter-content">
        <fn:map>
            <fn:string key="type">heading</fn:string>
            <xsl:if test="@xml:id">
                <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
            </xsl:if>
            <fn:string key="content"><xsl:apply-templates select="." mode="text-only"/></fn:string>
            <!-- Determine heading level based on ID structure -->
            <xsl:choose>
                <xsl:when test="contains(@xml:id, '.sub')">
                    <fn:number key="level">3</fn:number>
                </xsl:when>
                <xsl:when test="contains(@xml:id, '.div')">
                    <fn:number key="level">2</fn:number>
                </xsl:when>
                <xsl:otherwise>
                    <fn:number key="level">1</fn:number>
                </xsl:otherwise>
            </xsl:choose>
        </fn:map>
    </xsl:template>
    
    <xsl:template match="table" mode="front-matter-content">
        <fn:map>
            <fn:string key="type">table</fn:string>
            <xsl:if test="@xml:id">
                <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
            </xsl:if>
            <xsl:if test="title">
                <fn:string key="title"><xsl:apply-templates select="title" mode="rich-text-json"/></fn:string>
            </xsl:if>
            <fn:map key="structure">
                <xsl:choose>
                    <xsl:when test="tgroup/@cols and tgroup/@cols != ''">
                        <fn:number key="columns"><xsl:value-of select="tgroup/@cols"/></fn:number>
                    </xsl:when>
                    <xsl:otherwise>
                        <fn:null key="columns"/>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:if test="tgroup/thead">
                    <fn:array key="header_rows">
                        <xsl:apply-templates select="tgroup/thead/row" mode="json"/>
                    </fn:array>
                </xsl:if>
                
                <fn:array key="body_rows">
                    <xsl:apply-templates select="tgroup/tbody/row" mode="json"/>
                </fn:array>
            </fn:map>
        </fn:map>
    </xsl:template>
    
    <xsl:template match="figure" mode="front-matter-content">
        <fn:map>
            <fn:string key="type">figure</fn:string>
            <xsl:if test="@xml:id">
                <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
            </xsl:if>
            <xsl:if test="title">
                <fn:string key="title"><xsl:apply-templates select="title" mode="rich-text-json"/></fn:string>
            </xsl:if>
            <fn:map key="graphic">
                <fn:string key="src"><xsl:value-of select="graphic/@src"/></fn:string>
                <fn:string key="alt_text"><xsl:value-of select="graphic/@alt"/></fn:string>
            </fn:map>
        </fn:map>
    </xsl:template>
    
    <xsl:template match="list" mode="front-matter-content">
        <fn:map>
            <fn:string key="type">list</fn:string>
            <fn:string key="list_type"><xsl:value-of select="@type"/></fn:string>
            <fn:array key="items">
                <xsl:for-each select="item">
                    <fn:string><xsl:apply-templates select="." mode="rich-text-json"/></fn:string>
                </xsl:for-each>
            </fn:array>
        </fn:map>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- STRUCTURAL HIERARCHY PROCESSING                                    -->
    <!-- ================================================================== -->
    
    <xsl:template match="division" mode="json">
        <fn:map>
            <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
            <fn:string key="type">division</fn:string>
            <fn:string key="letter"><xsl:value-of select="@letter"/></fn:string>
            
            <!-- Add volume field -->
            <xsl:if test="@volume">
                <fn:number key="volume"><xsl:value-of select="@volume"/></fn:number>
            </xsl:if>
            
            <fn:string key="title"><xsl:apply-templates select="title" mode="text-only"/></fn:string>
            <fn:string key="number"><xsl:value-of select="number"/></fn:string>
            
            <xsl:if test="@source">
                <fn:string key="source"><xsl:value-of select="@source"/></fn:string>
            </xsl:if>
            
            <fn:array key="parts">
                <xsl:apply-templates select="part" mode="json"/>
            </fn:array>
        </fn:map>
    </xsl:template>
    
    <xsl:template match="part" mode="json">
        <fn:map>
            <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
            <fn:string key="type">part</fn:string>
            <xsl:choose>
                <xsl:when test="@number and @number != ''">
                    <fn:number key="number"><xsl:value-of select="@number"/></fn:number>
                </xsl:when>
                <xsl:otherwise>
                    <fn:null key="number"/>
                </xsl:otherwise>
            </xsl:choose>
            <fn:string key="title"><xsl:apply-templates select="title" mode="text-only"/></fn:string>
            
            <xsl:if test="@source">
                <fn:string key="source"><xsl:value-of select="@source"/></fn:string>
            </xsl:if>
            
            <xsl:if test="see-also">
                <fn:string key="see_also"><xsl:apply-templates select="see-also" mode="rich-text-json"/></fn:string>
            </xsl:if>
            
            <fn:array key="sections">
                <xsl:apply-templates select="section" mode="json"/>
            </fn:array>
            
            <!-- Special tables (Fire/Sound Resistance, Span Tables, etc.) -->
            <xsl:if test="spectables">
                <fn:array key="special_tables">
                    <xsl:apply-templates select="spectables" mode="json"/>
                </fn:array>
            </xsl:if>
            
            <!-- Part appendix (application notes) -->
            <xsl:if test="part-appendix">
                <fn:map key="appendix">
                    <xsl:apply-templates select="part-appendix" mode="json"/>
                </fn:map>
            </xsl:if>
        </fn:map>
    </xsl:template>
    
    <xsl:template match="section" mode="json">
        <fn:map>
            <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
            <fn:string key="type">section</fn:string>
            <xsl:choose>
                <xsl:when test="@number and @number != ''">
                    <fn:number key="number"><xsl:value-of select="@number"/></fn:number>
                </xsl:when>
                <xsl:otherwise>
                    <fn:null key="number"/>
                </xsl:otherwise>
            </xsl:choose>
            
            <!-- Deleted flag -->
            <xsl:if test="@deleted = 'yes'">
                <fn:boolean key="deleted">true</fn:boolean>
            </xsl:if>
            
            <xsl:if test="@source">
                <fn:string key="source"><xsl:value-of select="@source"/></fn:string>
            </xsl:if>
            
            <fn:string key="title"><xsl:apply-templates select="title" mode="text-only"/></fn:string>
            
            <fn:array key="subsections">
                <xsl:apply-templates select="subsection" mode="json"/>
            </fn:array>
        </fn:map>
    </xsl:template>
    
    <xsl:template match="subsection" mode="json">
        <fn:map>
            <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
            <fn:string key="type">subsection</fn:string>
            <xsl:choose>
                <xsl:when test="@number and @number != ''">
                    <fn:number key="number"><xsl:value-of select="@number"/></fn:number>
                </xsl:when>
                <xsl:otherwise>
                    <fn:null key="number"/>
                </xsl:otherwise>
            </xsl:choose>
            
            <!-- Deleted flag -->
            <xsl:if test="@deleted = 'yes'">
                <fn:boolean key="deleted">true</fn:boolean>
            </xsl:if>
            
            <xsl:if test="@source">
                <fn:string key="source"><xsl:value-of select="@source"/></fn:string>
            </xsl:if>
            
            <!-- Extract title and articles from revision-history if present, otherwise from direct children -->
            <xsl:choose>
                <xsl:when test="@revised='yes' and revision-history">
                    <xsl:variable name="current-revision" select="revision-history/revision[@status='current'][last()]"/>
                    <xsl:variable name="content-node" select="if ($current-revision/content) then $current-revision/content else revision-history/original"/>
                    
                    <fn:string key="title"><xsl:apply-templates select="$content-node/title" mode="text-only"/></fn:string>
                    
                    <xsl:if test="$content-node/see-also">
                        <fn:string key="see_also"><xsl:apply-templates select="$content-node/see-also" mode="rich-text-json"/></fn:string>
                    </xsl:if>
                    
                    <fn:array key="articles">
                        <xsl:apply-templates select="$content-node/article" mode="json"/>
                    </fn:array>
                </xsl:when>
                <xsl:otherwise>
                    <fn:string key="title"><xsl:apply-templates select="title" mode="text-only"/></fn:string>
                    
                    <xsl:if test="see-also">
                        <fn:string key="see_also"><xsl:apply-templates select="see-also" mode="rich-text-json"/></fn:string>
                    </xsl:if>
                    
                    <fn:array key="articles">
                        <xsl:apply-templates select="article" mode="json"/>
                    </fn:array>
                </xsl:otherwise>
            </xsl:choose>
            
            <!-- Revision history if present -->
            <xsl:if test="@revised = 'yes' and revision-history">
                <fn:array key="revisions">
                    <xsl:call-template name="build-subsection-revisions"/>
                </fn:array>
            </xsl:if>
        </fn:map>
    </xsl:template>
    
    <xsl:template match="article" mode="json">
        <fn:map>
            <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
            <fn:string key="type">article</fn:string>
            <xsl:choose>
                <xsl:when test="@number and @number != ''">
                    <fn:number key="number"><xsl:value-of select="@number"/></fn:number>
                </xsl:when>
                <xsl:otherwise>
                    <fn:null key="number"/>
                </xsl:otherwise>
            </xsl:choose>
            
            <!-- Deleted flag -->
            <xsl:if test="@deleted = 'yes'">
                <fn:boolean key="deleted">true</fn:boolean>
            </xsl:if>
            
            <xsl:if test="@source">
                <fn:string key="source"><xsl:value-of select="@source"/></fn:string>
            </xsl:if>
            
            <fn:string key="title"><xsl:apply-templates select="title" mode="text-only"/></fn:string>
            
            <xsl:if test="see-also">
                <fn:string key="see_also"><xsl:apply-templates select="see-also" mode="rich-text-json"/></fn:string>
            </xsl:if>
            
            <fn:array key="content">
                <xsl:apply-templates select="sentence | table | figure" mode="json"/>
            </fn:array>
            
            <!-- Revision history if present -->
            <xsl:if test="@revised = 'yes' and revision-history">
                <fn:array key="revisions">
                    <xsl:call-template name="build-article-revisions"/>
                </fn:array>
            </xsl:if>
        </fn:map>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- CONTENT PROCESSING                                                 -->
    <!-- ================================================================== -->
    
    <xsl:template match="sentence" mode="json">
        <fn:map>
            <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
            <fn:string key="type">sentence</fn:string>
            <xsl:choose>
                <xsl:when test="@number and @number != ''">
                    <fn:number key="number"><xsl:value-of select="@number"/></fn:number>
                </xsl:when>
                <xsl:otherwise>
                    <fn:null key="number"/>
                </xsl:otherwise>
            </xsl:choose>
            
            <!-- Deleted flag -->
            <xsl:if test="@deleted = 'yes'">
                <fn:boolean key="deleted">true</fn:boolean>
            </xsl:if>
            
            <xsl:if test="@source">
                <fn:string key="source"><xsl:value-of select="@source"/></fn:string>
            </xsl:if>
            
            <!-- Main text content with rich formatting preserved -->
            <fn:string key="text"><xsl:apply-templates select="text" mode="rich-text-json"/></fn:string>
            
            <!-- Extract equations from text element -->
            <xsl:if test="text//equation">
                <fn:array key="equations">
                    <xsl:apply-templates select="text//equation" mode="equation-json"/>
                </fn:array>
            </xsl:if>
            
            <!-- Intent reference if present -->
            <xsl:if test="intent-ref">
                <fn:string key="intent_reference"><xsl:value-of select="intent-ref/@target"/></fn:string>
            </xsl:if>
            
            <!-- Clauses -->
            <xsl:if test="clause">
                <fn:array key="clauses">
                    <xsl:apply-templates select="clause" mode="json"/>
                </fn:array>
            </xsl:if>
            
            <!-- See-also references -->
            <xsl:if test="see-also">
                <fn:array key="see_also">
                    <xsl:for-each select="see-also">
                        <fn:map>
                            <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
                            <fn:string key="content"><xsl:apply-templates select="." mode="rich-text-json"/></fn:string>
                        </fn:map>
                    </xsl:for-each>
                </fn:array>
            </xsl:if>
            
            <!-- Objectives and functional statements -->
            <xsl:if test="objectives">
                <fn:array key="objectives">
                    <xsl:apply-templates select="objectives/objective" mode="json"/>
                </fn:array>
            </xsl:if>
            
            <xsl:if test="functional-statements">
                <fn:array key="functional_statements">
                    <xsl:apply-templates select="functional-statements/functional-statement" mode="json"/>
                </fn:array>
            </xsl:if>
            
            <!-- BC annotations if present -->
            <xsl:if test="bc-annotation">
                <fn:array key="bc_annotations">
                    <xsl:apply-templates select="bc-annotation" mode="json"/>
                </fn:array>
            </xsl:if>
            
            <!-- Revision history if present -->
            <xsl:if test="@revised = 'yes' and revision-history">
                <fn:array key="revisions">
                    <xsl:call-template name="build-sentence-revisions"/>
                </fn:array>
            </xsl:if>
        </fn:map>
    </xsl:template>
    
    <xsl:template match="clause" mode="json">
        <fn:map>
            <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
            <fn:string key="type">clause</fn:string>
            <fn:string key="letter"><xsl:value-of select="@letter"/></fn:string>
            
            <!-- Deleted flag -->
            <xsl:if test="@deleted = 'yes'">
                <fn:boolean key="deleted">true</fn:boolean>
            </xsl:if>
            
            <xsl:if test="@source">
                <fn:string key="source"><xsl:value-of select="@source"/></fn:string>
            </xsl:if>
            
            <fn:string key="text"><xsl:apply-templates select="text" mode="rich-text-json"/></fn:string>
            
            <xsl:if test="see-also">
                <fn:array key="sue_also">
                    <xsl:for-each select="see-also">
                        <fn:map>
                            <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
                            <fn:string key="content"><xsl:apply-templates select="." mode="rich-text-json"/></fn:string>
                        </fn:map>
                    </xsl:for-each>
                </fn:array>
            </xsl:if>
            
            <xsl:if test="subclause">
                <fn:array key="subclauses">
                    <xsl:apply-templates select="subclause" mode="json"/>
                </fn:array>
            </xsl:if>
        </fn:map>
    </xsl:template>
    
    <xsl:template match="subclause" mode="json">
        <fn:map>
            <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
            <fn:string key="type">subclause</fn:string>
            <xsl:choose>
                <xsl:when test="@number and @number != ''">
                    <fn:number key="number"><xsl:value-of select="@number"/></fn:number>
                </xsl:when>
                <xsl:otherwise>
                    <fn:null key="number"/>
                </xsl:otherwise>
            </xsl:choose>
            
            <!-- Deleted flag -->
            <xsl:if test="@deleted = 'yes'">
                <fn:boolean key="deleted">true</fn:boolean>
            </xsl:if>
            
            <xsl:if test="@source">
                <fn:string key="source"><xsl:value-of select="@source"/></fn:string>
            </xsl:if>
            
            <fn:string key="text"><xsl:apply-templates select="text" mode="rich-text-json"/></fn:string>
        </fn:map>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- TABLE PROCESSING                                                   -->
    <!-- ================================================================== -->
    
    <xsl:template match="table" mode="json">
        <fn:map>
            <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
            <fn:string key="type">table</fn:string>
            
            <!-- Deleted flag -->
            <xsl:if test="@deleted = 'yes'">
                <fn:boolean key="deleted">true</fn:boolean>
            </xsl:if>
            
            <!-- Source attribute (bc or nbc) -->
            <xsl:if test="@source">
                <fn:string key="source"><xsl:value-of select="@source"/></fn:string>
            </xsl:if>
            
            <fn:string key="title"><xsl:apply-templates select="title" mode="rich-text-json"/></fn:string>
            
            <fn:map key="structure">
                <xsl:choose>
                    <xsl:when test="tgroup/@cols and tgroup/@cols != ''">
                        <fn:number key="columns"><xsl:value-of select="tgroup/@cols"/></fn:number>
                    </xsl:when>
                    <xsl:otherwise>
                        <fn:null key="columns"/>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:if test="tgroup/colspec">
                    <fn:array key="column_specs">
                        <xsl:for-each select="tgroup/colspec">
                            <fn:map>
                                <fn:string key="name"><xsl:value-of select="@colname"/></fn:string>
                                <fn:string key="width"><xsl:value-of select="@colwidth"/></fn:string>
                            </fn:map>
                        </xsl:for-each>
                    </fn:array>
                </xsl:if>
                
                <xsl:if test="tgroup/thead">
                    <fn:array key="header_rows">
                        <xsl:apply-templates select="tgroup/thead/row" mode="json"/>
                    </fn:array>
                </xsl:if>
                
                <fn:array key="body_rows">
                    <xsl:apply-templates select="tgroup/tbody/row" mode="json"/>
                </fn:array>
            </fn:map>
            
            <!-- Revision history if present -->
            <xsl:if test="@revised = 'yes' and revision-history">
                <fn:array key="revisions">
                    <xsl:call-template name="build-table-revisions"/>
                </fn:array>
            </xsl:if>
        </fn:map>
    </xsl:template>
    
    <xsl:template match="row" mode="json">
        <fn:array>
            <xsl:apply-templates select="entry" mode="json"/>
        </fn:array>
    </xsl:template>
    
    <xsl:template match="entry" mode="json">
        <fn:map>
            <fn:string key="content"><xsl:apply-templates select="." mode="rich-text-json"/></fn:string>
            <xsl:if test="@align">
                <fn:string key="align"><xsl:value-of select="@align"/></fn:string>
            </xsl:if>
            <xsl:if test="@rowspan and @rowspan != ''">
                <fn:number key="rowspan"><xsl:value-of select="@rowspan"/></fn:number>
            </xsl:if>
            <xsl:if test="@colspan and @colspan != ''">
                <fn:number key="colspan"><xsl:value-of select="@colspan"/></fn:number>
            </xsl:if>
            
            <!-- Revision history if present -->
            <xsl:if test="@revised = 'yes' and revision-history">
                <fn:array key="revisions">
                    <xsl:call-template name="build-entry-revisions"/>
                </fn:array>
            </xsl:if>
        </fn:map>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- FIGURE PROCESSING                                                  -->
    <!-- ================================================================== -->
    
    <xsl:template match="figure" mode="json">
        <fn:map>
            <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
            <fn:string key="type">figure</fn:string>
            
            <!-- Deleted flag -->
            <xsl:if test="@deleted = 'yes'">
                <fn:boolean key="deleted">true</fn:boolean>
            </xsl:if>
            
            <!-- Source attribute (bc or nbc) -->
            <xsl:if test="@source">
                <fn:string key="source"><xsl:value-of select="@source"/></fn:string>
            </xsl:if>
            
            <fn:string key="title"><xsl:apply-templates select="title" mode="rich-text-json"/></fn:string>
            
            <fn:map key="graphic">
                <fn:string key="src"><xsl:value-of select="graphic/@src"/></fn:string>
                <fn:string key="alt_text"><xsl:value-of select="graphic/@alt"/></fn:string>
                <xsl:if test="graphic/@width">
                    <fn:string key="width"><xsl:value-of select="graphic/@width"/></fn:string>
                </xsl:if>
                <xsl:if test="graphic/@height">
                    <fn:string key="height"><xsl:value-of select="graphic/@height"/></fn:string>
                </xsl:if>
            </fn:map>
            
            <xsl:if test="note">
                <fn:array key="notes">
                    <xsl:for-each select="note">
                        <fn:map>
                            <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
                            <fn:string key="content"><xsl:apply-templates select="." mode="rich-text-json"/></fn:string>
                        </fn:map>
                    </xsl:for-each>
                </fn:array>
            </xsl:if>
        </fn:map>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- SPECTABLES PROCESSING (Special Tables)                            -->
    <!-- ================================================================== -->
    
    <xsl:template match="spectables" mode="json">
        <fn:map>
            <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
            <fn:string key="type">spectables</fn:string>
            
            <!-- Source attribute (bc or nbc) -->
            <xsl:if test="@source">
                <fn:string key="source"><xsl:value-of select="@source"/></fn:string>
            </xsl:if>
            
            <fn:string key="title"><xsl:apply-templates select="title" mode="text-only"/></fn:string>
            <xsl:if test="@table-prefix">
                <fn:string key="table_prefix"><xsl:value-of select="@table-prefix"/></fn:string>
            </xsl:if>
            <xsl:if test="@toc-entry">
                <fn:string key="toc_entry"><xsl:value-of select="@toc-entry"/></fn:string>
            </xsl:if>
            
            <fn:array key="tables">
                <xsl:apply-templates select="table" mode="json"/>
            </fn:array>
        </fn:map>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- PART APPENDIX PROCESSING (Application Notes)                      -->
    <!-- ================================================================== -->
    
    <xsl:template match="part-appendix" mode="json">
        <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
        <fn:string key="type">part_appendix</fn:string>
        
        <xsl:if test="introduction">
            <fn:string key="introduction"><xsl:apply-templates select="introduction" mode="rich-text-json"/></fn:string>
        </xsl:if>
        
        <fn:array key="application_notes">
            <xsl:apply-templates select="application-note" mode="json"/>
        </fn:array>
    </xsl:template>
    
    <xsl:template match="application-note" mode="json">
        <fn:map>
            <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
            <fn:string key="type">application_note</fn:string>
            <fn:string key="number"><xsl:value-of select="number"/></fn:string>
            <fn:string key="title"><xsl:apply-templates select="title" mode="text-only"/></fn:string>
            <xsl:if test="@refs">
                <fn:string key="refs"><xsl:value-of select="@refs"/></fn:string>
            </xsl:if>
            
            <!-- Deleted flag -->
            <xsl:if test="@deleted = 'yes'">
                <fn:boolean key="deleted">true</fn:boolean>
            </xsl:if>
            
            <!-- Source attribute (bc or nbc) -->
            <xsl:if test="@source">
                <fn:string key="source"><xsl:value-of select="@source"/></fn:string>
            </xsl:if>
            
            <!-- Paragraphs -->
            <xsl:if test="paragraph">
                <fn:array key="paragraphs">
                    <xsl:for-each select="paragraph">
                        <fn:map>
                            <xsl:if test="@xml:id">
                                <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
                            </xsl:if>
                            <fn:string key="content"><xsl:apply-templates select="." mode="rich-text-json"/></fn:string>
                        </fn:map>
                    </xsl:for-each>
                </fn:array>
            </xsl:if>
            
            <!-- Note divisions (sub-sections within application notes) -->
            <xsl:if test="note-division">
                <fn:array key="divisions">
                    <xsl:apply-templates select="note-division" mode="json"/>
                </fn:array>
            </xsl:if>
            
            <!-- Tables within application notes -->
            <xsl:if test="table">
                <fn:array key="tables">
                    <xsl:apply-templates select="table" mode="json"/>
                </fn:array>
            </xsl:if>
            
            <!-- Figures within application notes -->
            <xsl:if test="figure">
                <fn:array key="figures">
                    <xsl:apply-templates select="figure" mode="json"/>
                </fn:array>
            </xsl:if>
            
            <!-- Revision history if present -->
            <xsl:if test="@revised = 'yes' and revision-history">
                <fn:array key="revisions">
                    <xsl:call-template name="build-appnote-revisions"/>
                </fn:array>
            </xsl:if>
        </fn:map>
    </xsl:template>
    
    <xsl:template match="note-division" mode="json">
        <fn:map>
            <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
            <fn:string key="type">note_division</fn:string>
            
            <!-- Source attribute (bc or nbc) -->
            <xsl:if test="@source">
                <fn:string key="source"><xsl:value-of select="@source"/></fn:string>
            </xsl:if>
            
            <fn:string key="title"><xsl:apply-templates select="title" mode="text-only"/></fn:string>
            
            <xsl:if test="paragraph">
                <fn:array key="paragraphs">
                    <xsl:for-each select="paragraph">
                        <fn:map>
                            <xsl:if test="@xml:id">
                                <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
                            </xsl:if>
                            <fn:string key="content"><xsl:apply-templates select="." mode="rich-text-json"/></fn:string>
                        </fn:map>
                    </xsl:for-each>
                </fn:array>
            </xsl:if>
            
            <!-- Tables within note divisions -->
            <xsl:if test="table">
                <fn:array key="tables">
                    <xsl:apply-templates select="table" mode="json"/>
                </fn:array>
            </xsl:if>
            
            <!-- Figures within note divisions -->
            <xsl:if test="figure">
                <fn:array key="figures">
                    <xsl:apply-templates select="figure" mode="json"/>
                </fn:array>
            </xsl:if>
        </fn:map>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- OBJECTIVES AND FUNCTIONAL STATEMENTS                              -->
    <!-- ================================================================== -->
    
    <xsl:template match="objective" mode="json">
        <fn:map>
            <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
            <fn:string key="key"><xsl:value-of select="@key"/></fn:string>
            <xsl:if test="@source">
                <fn:string key="source"><xsl:value-of select="fn:string(@source)"/></fn:string>
            </xsl:if>
            <fn:string key="title"><xsl:value-of select="title"/></fn:string>
            <fn:string key="definition"><xsl:apply-templates select="definition" mode="rich-text-json"/></fn:string>
            
            <xsl:if test="sub-objective">
                <fn:array key="sub_objectives">
                    <xsl:apply-templates select="sub-objective" mode="json"/>
                </fn:array>
            </xsl:if>
        </fn:map>
    </xsl:template>
    
    <xsl:template match="sub-objective" mode="json">
        <fn:map>
            <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
            <fn:string key="key"><xsl:value-of select="@key"/></fn:string>
            <xsl:if test="@source">
                <fn:string key="source"><xsl:value-of select="fn:string(@source)"/></fn:string>
            </xsl:if>
            <fn:string key="title"><xsl:value-of select="title"/></fn:string>
            <fn:string key="definition"><xsl:apply-templates select="definition" mode="rich-text-json"/></fn:string>
        </fn:map>
    </xsl:template>
    
    <xsl:template match="functional-statement" mode="json">
        <fn:map>
            <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
            <fn:string key="key"><xsl:value-of select="@key"/></fn:string>
            <xsl:if test="@source">
                <fn:string key="source"><xsl:value-of select="fn:string(@source)"/></fn:string>
            </xsl:if>
            <fn:string key="definition"><xsl:apply-templates select="definition" mode="rich-text-json"/></fn:string>
        </fn:map>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- BC ANNOTATIONS                                                     -->
    <!-- ================================================================== -->
    
    <xsl:template match="bc-annotation" mode="json">
        <fn:map>
            <fn:string key="type"><xsl:value-of select="@type"/></fn:string>
            <fn:string key="content"><xsl:apply-templates select="." mode="rich-text-json"/></fn:string>
        </fn:map>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- RICH TEXT PROCESSING                                               -->
    <!-- ================================================================== -->
    
    <xsl:template match="*" mode="rich-text-json">
        <xsl:apply-templates select="text() | *" mode="rich-text-json"/>
    </xsl:template>
    
    <xsl:template match="text()" mode="rich-text-json">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <xsl:template match="emphasis" mode="rich-text-json">
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="@style"/>
        <xsl:text>&gt;</xsl:text>
        <xsl:apply-templates select="node()" mode="rich-text-json"/>
        <xsl:text>&lt;/</xsl:text>
        <xsl:value-of select="@style"/>
        <xsl:text>&gt;</xsl:text>
    </xsl:template>
    
    <xsl:template match="super" mode="rich-text-json">
        <xsl:text>^{</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xsl:template match="sub" mode="rich-text-json">
        <xsl:text>_{</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xsl:template match="ref" mode="rich-text-json">
        <xsl:text>[REF:</xsl:text>
        <xsl:value-of select="@type"/>
        <xsl:text>:</xsl:text>
        <xsl:value-of select="@target"/>
        <xsl:if test="@display-type">
            <xsl:text>:</xsl:text>
            <xsl:value-of select="@display-type"/>
        </xsl:if>
        <xsl:text>]</xsl:text>
        <xsl:if test="text()">
            <xsl:value-of select="."/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="measurement" mode="rich-text-json">
        <xsl:value-of select="."/>
        <xsl:text> (</xsl:text>
        <xsl:value-of select="@units"/>
        <xsl:text>)</xsl:text>
    </xsl:template>
    
    <xsl:template match="equation" mode="rich-text-json">
        <!-- Insert placeholder in text that matches the pattern [EQ:type:id] -->
        <xsl:text>[EQ:</xsl:text>
        <xsl:value-of select="@type"/>
        <xsl:text>:</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>]</xsl:text>
    </xsl:template>
    
    <xsl:template match="change" mode="rich-text-json">
        <xsl:text>&lt;CHANGE:</xsl:text>
        <xsl:value-of select="@type"/>
        <xsl:text>&gt;</xsl:text>
        <xsl:apply-templates select="node()" mode="rich-text-json"/>
        <xsl:text>&lt;/CHANGE&gt;</xsl:text>
    </xsl:template>
    
    <xsl:template match="see-also" mode="rich-text-json">
        <xsl:apply-templates select="node()" mode="rich-text-json"/>
    </xsl:template>
    
    <!-- Revision history processing for JSON output (snapshot approach for date-based versioning) -->
    <!-- Display content comes from the latest revision (status="current") -->
    <xsl:template match="revision-history" mode="rich-text-json">
        <xsl:variable name="current-revision" select="revision[@status='current'][last()]"/>
        <xsl:choose>
            <xsl:when test="$current-revision/content">
                <xsl:apply-templates select="$current-revision/content/node()" mode="rich-text-json"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- Fallback to original if no current revision -->
                <xsl:apply-templates select="original/node()" mode="rich-text-json"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Handle elements with revision history - show current content in main text field -->
    <xsl:template match="*[@revised='yes']" mode="rich-text-json" priority="1">
        <xsl:choose>
            <xsl:when test="revision-history">
                <xsl:variable name="current-revision" select="revision-history/revision[@status='current'][last()]"/>
                <xsl:choose>
                    <xsl:when test="$current-revision/content">
                        <xsl:apply-templates select="$current-revision/content/node()" mode="rich-text-json"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Fallback to original if no current revision -->
                        <xsl:apply-templates select="revision-history/original/node()" mode="rich-text-json"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- No revision history, process normally -->
                <xsl:apply-templates select="text() | *[not(self::revision-history)]" mode="rich-text-json"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Handle text elements within revised elements -->
    <xsl:template match="text[parent::*[@revised='yes']]" mode="rich-text-json" priority="1">
        <xsl:variable name="parent" select="parent::*"/>
        <xsl:choose>
            <xsl:when test="$parent/revision-history">
                <xsl:variable name="current-revision" select="$parent/revision-history/revision[@status='current'][last()]"/>
                <xsl:choose>
                    <xsl:when test="$current-revision/content">
                        <xsl:apply-templates select="$current-revision/content/node()" mode="rich-text-json"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Fallback to original if no current revision -->
                        <xsl:apply-templates select="$parent/revision-history/original/node()" mode="rich-text-json"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- No revision history, process normally -->
                <xsl:apply-templates select="node()" mode="rich-text-json"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- EQUATION PROCESSING FOR JSON                                       -->
    <!-- ================================================================== -->
    
    <!-- Convert equation element to JSON object with multiple formats -->
    <xsl:template match="equation" mode="equation-json">
        <fn:map>
            <fn:string key="id"><xsl:value-of select="if (@xml:id) then @xml:id else if (@image) then @image else ''"/></fn:string>
            <fn:string key="type"><xsl:value-of select="@type"/></fn:string>
            
            <!-- LaTeX representation (converted from MathML) -->
            <fn:string key="latex"><xsl:apply-templates select="*[local-name()='math']" mode="mathml-to-latex"/></fn:string>
            
            <!-- Plain text representation -->
            <fn:string key="plainText"><xsl:apply-templates select="*[local-name()='math']" mode="mathml-to-plaintext"/></fn:string>
            
            <!-- MathML (optional - can be large) -->
            <fn:string key="mathml"><xsl:value-of select="fn:serialize(*[local-name()='math'])"/></fn:string>
            
            <!-- Image reference for fallback rendering -->
            <xsl:if test="@image">
                <fn:string key="image"><xsl:value-of select="@image"/></fn:string>
            </xsl:if>
            <xsl:if test="@image-src">
                <fn:string key="imageSrc"><xsl:value-of select="@image-src"/></fn:string>
            </xsl:if>
        </fn:map>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- MATHML TO LATEX CONVERSION                                         -->
    <!-- ================================================================== -->
    
    <!-- Match MathML math element (in MathML namespace) -->
    <xsl:template match="*[namespace-uri()='http://www.w3.org/1998/Math/MathML' and local-name()='math']" mode="mathml-to-latex">
        <xsl:apply-templates select="*" mode="mathml-to-latex"/>
    </xsl:template>
    
    <!-- Numbers (in no namespace due to xmlns="") -->
    <xsl:template match="*[local-name()='mn' and namespace-uri()='']" mode="mathml-to-latex">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <!-- Identifiers/variables (in no namespace) -->
    <xsl:template match="*[local-name()='mi' and namespace-uri()='']" mode="mathml-to-latex">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <!-- Operators (in no namespace) -->
    <xsl:template match="*[local-name()='mo' and namespace-uri()='']" mode="mathml-to-latex">
        <xsl:choose>
            <xsl:when test=". = '∑'">\\sum</xsl:when>
            <xsl:when test=". = '∫'">\\int</xsl:when>
            <xsl:when test=". = '≤'">\\leq</xsl:when>
            <xsl:when test=". = '≥'">\\geq</xsl:when>
            <xsl:when test=". = '±'">\\pm</xsl:when>
            <xsl:when test=". = '×'">\\times</xsl:when>
            <xsl:when test=". = '÷'">\\div</xsl:when>
            <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Text (in no namespace) -->
    <xsl:template match="*[local-name()='mtext' and namespace-uri()='']" mode="mathml-to-latex">
        <xsl:text>\text{</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <!-- Fractions (in no namespace) -->
    <xsl:template match="*[local-name()='mfrac' and namespace-uri()='']" mode="mathml-to-latex">
        <xsl:text>\frac{</xsl:text>
        <xsl:apply-templates select="*[1]" mode="mathml-to-latex"/>
        <xsl:text>}{</xsl:text>
        <xsl:apply-templates select="*[2]" mode="mathml-to-latex"/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <!-- Square root -->
    <xsl:template match="*:msqrt | msqrt | *[local-name()='msqrt']" mode="mathml-to-latex">
        <xsl:text>\sqrt{</xsl:text>
        <xsl:apply-templates select="*" mode="mathml-to-latex"/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <!-- Nth root -->
    <xsl:template match="*:mroot | mroot | *[local-name()='mroot']" mode="mathml-to-latex">
        <xsl:text>\sqrt[</xsl:text>
        <xsl:apply-templates select="*[2]" mode="mathml-to-latex"/>
        <xsl:text>]{</xsl:text>
        <xsl:apply-templates select="*[1]" mode="mathml-to-latex"/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <!-- Superscript -->
    <xsl:template match="*:msup | msup | *[local-name()='msup']" mode="mathml-to-latex">
        <xsl:apply-templates select="*[1]" mode="mathml-to-latex"/>
        <xsl:text>^{</xsl:text>
        <xsl:apply-templates select="*[2]" mode="mathml-to-latex"/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <!-- Subscript -->
    <xsl:template match="*:msub | msub | *[local-name()='msub']" mode="mathml-to-latex">
        <xsl:apply-templates select="*[1]" mode="mathml-to-latex"/>
        <xsl:text>_{</xsl:text>
        <xsl:apply-templates select="*[2]" mode="mathml-to-latex"/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <!-- Subsuperscript -->
    <xsl:template match="*:msubsup | msubsup | *[local-name()='msubsup']" mode="mathml-to-latex">
        <xsl:apply-templates select="*[1]" mode="mathml-to-latex"/>
        <xsl:text>_{</xsl:text>
        <xsl:apply-templates select="*[2]" mode="mathml-to-latex"/>
        <xsl:text>}^{</xsl:text>
        <xsl:apply-templates select="*[3]" mode="mathml-to-latex"/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <!-- Row (grouping) -->
    <xsl:template match="*:mrow | mrow | *[local-name()='mrow']" mode="mathml-to-latex">
        <xsl:apply-templates select="*" mode="mathml-to-latex"/>
    </xsl:template>
    
    <!-- Fenced (parentheses, brackets, etc.) -->
    <xsl:template match="*:mfenced | mfenced | *[local-name()='mfenced']" mode="mathml-to-latex">
        <xsl:text>\left(</xsl:text>
        <xsl:apply-templates select="*" mode="mathml-to-latex"/>
        <xsl:text>\right)</xsl:text>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- MATHML TO PLAIN TEXT CONVERSION                                    -->
    <!-- ================================================================== -->
    
    <!-- Match MathML elements with or without namespace -->
    <xsl:template match="*[namespace-uri()='http://www.w3.org/1998/Math/MathML'] | math | *[local-name()='math']" mode="mathml-to-plaintext">
        <xsl:apply-templates select="*" mode="mathml-to-plaintext"/>
    </xsl:template>
    
    <xsl:template match="*:mn | mn | *[local-name()='mn'] | *:mi | mi | *[local-name()='mi'] | *:mo | mo | *[local-name()='mo'] | *:mtext | mtext | *[local-name()='mtext']" mode="mathml-to-plaintext">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <xsl:template match="*:mfrac | mfrac | *[local-name()='mfrac']" mode="mathml-to-plaintext">
        <xsl:text>(</xsl:text>
        <xsl:apply-templates select="*[1]" mode="mathml-to-plaintext"/>
        <xsl:text>)/(</xsl:text>
        <xsl:apply-templates select="*[2]" mode="mathml-to-plaintext"/>
        <xsl:text>)</xsl:text>
    </xsl:template>
    
    <xsl:template match="*:msqrt | msqrt | *[local-name()='msqrt']" mode="mathml-to-plaintext">
        <xsl:text>√(</xsl:text>
        <xsl:apply-templates select="*" mode="mathml-to-plaintext"/>
        <xsl:text>)</xsl:text>
    </xsl:template>
    
    <xsl:template match="*:msup | msup | *[local-name()='msup']" mode="mathml-to-plaintext">
        <xsl:apply-templates select="*[1]" mode="mathml-to-plaintext"/>
        <xsl:text>^</xsl:text>
        <xsl:apply-templates select="*[2]" mode="mathml-to-plaintext"/>
    </xsl:template>
    
    <xsl:template match="*:msub | msub | *[local-name()='msub']" mode="mathml-to-plaintext">
        <xsl:apply-templates select="*[1]" mode="mathml-to-plaintext"/>
        <xsl:text>_</xsl:text>
        <xsl:apply-templates select="*[2]" mode="mathml-to-plaintext"/>
    </xsl:template>
    
    <xsl:template match="*:mrow | mrow | *[local-name()='mrow']" mode="mathml-to-plaintext">
        <xsl:apply-templates select="*" mode="mathml-to-plaintext"/>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- TEXT-ONLY MODE (for titles, etc.)                                  -->
    <!-- ================================================================== -->
    
    <xsl:template match="*" mode="text-only">
        <xsl:apply-templates select="text() | *" mode="text-only"/>
    </xsl:template>
    
    <xsl:template match="text()" mode="text-only">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <xsl:template match="emphasis | super | sub | ref | measurement" mode="text-only">
        <xsl:apply-templates select="text()" mode="text-only"/>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- CROSS-REFERENCE INDEX BUILDING                                     -->
    <!-- ================================================================== -->
    
    <xsl:template name="build-reference-index">
        <fn:array key="internal_references">
            <xsl:for-each select=".//ref[@type = 'internal']">
                <fn:map>
                    <fn:string key="source_id"><xsl:value-of select="ancestor::*[@xml:id][1]/@xml:id"/></fn:string>
                    <fn:string key="target_id"><xsl:value-of select="@target"/></fn:string>
                    <fn:string key="display_type"><xsl:value-of select="@display-type"/></fn:string>
                    <xsl:if test="@pretext">
                        <fn:string key="pretext"><xsl:value-of select="@pretext"/></fn:string>
                    </xsl:if>
                </fn:map>
            </xsl:for-each>
        </fn:array>
        
        <fn:array key="external_references">
            <xsl:for-each select=".//ref[@type = 'external']">
                <fn:map>
                    <fn:string key="source_id"><xsl:value-of select="ancestor::*[@xml:id][1]/@xml:id"/></fn:string>
                    <fn:string key="target"><xsl:value-of select="@target"/></fn:string>
                    <fn:string key="text"><xsl:value-of select="."/></fn:string>
                </fn:map>
            </xsl:for-each>
        </fn:array>
        
        <fn:array key="standard_references">
            <xsl:for-each select=".//ref[@type = 'standard']">
                <fn:map>
                    <fn:string key="source_id"><xsl:value-of select="ancestor::*[@xml:id][1]/@xml:id"/></fn:string>
                    <fn:string key="standard_id"><xsl:value-of select="@target"/></fn:string>
                    <fn:string key="text"><xsl:value-of select="."/></fn:string>
                </fn:map>
            </xsl:for-each>
        </fn:array>
        
        <fn:array key="term_references">
            <xsl:for-each select=".//ref[@type = 'term']">
                <fn:map>
                    <fn:string key="source_id"><xsl:value-of select="ancestor::*[@xml:id][1]/@xml:id"/></fn:string>
                    <fn:string key="term_id"><xsl:value-of select="@target"/></fn:string>
                    <fn:string key="text"><xsl:value-of select="."/></fn:string>
                </fn:map>
            </xsl:for-each>
        </fn:array>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- BC AMENDMENTS EXTRACTION                                           -->
    <!-- ================================================================== -->
    
    <xsl:template name="extract-bc-amendments">
        <!-- Extract change tracking elements -->
        <xsl:for-each select=".//change[@type != '']">
            <fn:map>
                <fn:string key="location_id"><xsl:value-of select="ancestor::*[@xml:id][1]/@xml:id"/></fn:string>
                <fn:string key="type"><xsl:value-of select="@type"/></fn:string>
                <xsl:if test="@amendment-id">
                    <fn:string key="amendment_id"><xsl:value-of select="@amendment-id"/></fn:string>
                </xsl:if>
                <xsl:if test="@effective-date">
                    <fn:string key="effective_date"><xsl:value-of select="@effective-date"/></fn:string>
                </xsl:if>
                <fn:string key="content"><xsl:apply-templates select="." mode="rich-text-json"/></fn:string>
            </fn:map>
        </xsl:for-each>
        
        <!-- Extract BC annotations -->
        <xsl:for-each select=".//bc-annotation">
            <fn:map>
                <fn:string key="location_id"><xsl:value-of select="ancestor::*[@xml:id][1]/@xml:id"/></fn:string>
                <fn:string key="type">annotation</fn:string>
                <fn:string key="annotation_type"><xsl:value-of select="@type"/></fn:string>
                <fn:string key="content"><xsl:apply-templates select="." mode="rich-text-json"/></fn:string>
            </fn:map>
        </xsl:for-each>
        
        <!-- Extract revision history entries (snapshot approach for date-based versioning) -->
        <xsl:for-each select=".//revision-history">
            <xsl:variable name="location-id" select="ancestor::*[@xml:id][1]/@xml:id"/>
            <!-- Output original baseline -->
            <fn:map>
                <fn:string key="location_id"><xsl:value-of select="$location-id"/></fn:string>
                <fn:string key="type">original</fn:string>
                <fn:string key="effective_date"><xsl:value-of select="original/@effective-date"/></fn:string>
                <fn:string key="content"><xsl:apply-templates select="original" mode="rich-text-json"/></fn:string>
            </fn:map>
            <!-- Output each revision snapshot -->
            <xsl:for-each select="revision">
                <fn:map>
                    <fn:string key="location_id"><xsl:value-of select="$location-id"/></fn:string>
                    <fn:string key="type">revision</fn:string>
                    <fn:string key="revision_type"><xsl:value-of select="@type"/></fn:string>
                    <fn:string key="revision_id"><xsl:value-of select="@id"/></fn:string>
                    <xsl:choose>
                        <xsl:when test="@seq and @seq != ''">
                            <fn:number key="sequence"><xsl:value-of select="@seq"/></fn:number>
                        </xsl:when>
                        <xsl:otherwise>
                            <fn:null key="sequence"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <fn:string key="effective_date"><xsl:value-of select="@effective-date"/></fn:string>
                    <fn:string key="status"><xsl:value-of select="@status"/></fn:string>
                    <fn:string key="content"><xsl:apply-templates select="content" mode="rich-text-json"/></fn:string>
                    <xsl:if test="change-summary">
                        <fn:string key="change_summary"><xsl:value-of select="change-summary"/></fn:string>
                    </xsl:if>
                    <xsl:if test="note">
                        <fn:string key="note"><xsl:value-of select="note"/></fn:string>
                    </xsl:if>
                </fn:map>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- GLOSSARY BUILDING                                                  -->
    <!-- ================================================================== -->
    
    <xsl:template name="build-glossary">
        <xsl:for-each select=".//list[@type = 'definition']/item[@xml:id]">
            <fn:map key="{@xml:id}">
                <fn:string key="term"><xsl:apply-templates select="term" mode="text-only"/></fn:string>
                <fn:string key="definition"><xsl:apply-templates select="definition" mode="rich-text-json"/></fn:string>
                <fn:string key="location_id"><xsl:value-of select="ancestor::*[@xml:id][1]/@xml:id"/></fn:string>
            </fn:map>
        </xsl:for-each>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- REVISION HISTORY BUILDING TEMPLATES                               -->
    <!-- ================================================================== -->
    
    <!-- Build sentence revisions with consistent structure -->
    <xsl:template name="build-sentence-revisions">
        <!-- Original baseline -->
        <fn:map>
            <fn:string key="type">original</fn:string>
            <fn:string key="effective_date"><xsl:value-of select="revision-history/original/@effective-date"/></fn:string>
            <fn:string key="text"><xsl:apply-templates select="revision-history/original" mode="rich-text-json"/></fn:string>
            <xsl:if test="revision-history/original/see-also">
                <fn:array key="see_also">
                    <xsl:for-each select="revision-history/original/see-also">
                        <fn:map>
                            <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
                            <fn:string key="content"><xsl:apply-templates select="." mode="rich-text-json"/></fn:string>
                        </fn:map>
                    </xsl:for-each>
                </fn:array>
            </xsl:if>
        </fn:map>
        
        <!-- Each revision -->
        <xsl:for-each select="revision-history/revision">
            <fn:map>
                <fn:string key="type">revision</fn:string>
                <fn:string key="revision_type"><xsl:value-of select="@type"/></fn:string>
                <fn:string key="revision_id"><xsl:value-of select="@id"/></fn:string>
                <xsl:choose>
                    <xsl:when test="@seq and @seq != ''">
                        <fn:number key="sequence"><xsl:value-of select="@seq"/></fn:number>
                    </xsl:when>
                    <xsl:otherwise>
                        <fn:null key="sequence"/>
                    </xsl:otherwise>
                </xsl:choose>
                <fn:string key="effective_date"><xsl:value-of select="@effective-date"/></fn:string>
                <fn:string key="status"><xsl:value-of select="@status"/></fn:string>
                
                <!-- Deleted flag for revision (check if content is empty indicating deletion) -->
                <xsl:choose>
                    <xsl:when test="not(content/node()) or normalize-space(content) = ''">
                        <fn:boolean key="deleted">true</fn:boolean>
                    </xsl:when>
                </xsl:choose>
                
                <fn:string key="text"><xsl:apply-templates select="content" mode="rich-text-json"/></fn:string>
                <xsl:if test="content/see-also">
                    <fn:array key="see_also">
                        <xsl:for-each select="content/see-also">
                            <fn:map>
                                <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
                                <fn:string key="content"><xsl:apply-templates select="." mode="rich-text-json"/></fn:string>
                            </fn:map>
                        </xsl:for-each>
                    </fn:array>
                </xsl:if>
                <xsl:if test="change-summary">
                    <fn:string key="change_summary"><xsl:value-of select="change-summary"/></fn:string>
                </xsl:if>
                <xsl:if test="note">
                    <fn:string key="note"><xsl:value-of select="note"/></fn:string>
                </xsl:if>
            </fn:map>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Build article revisions with consistent structure -->
    <xsl:template name="build-article-revisions">
        <!-- Original baseline -->
        <fn:map>
            <fn:string key="type">original</fn:string>
            <fn:string key="effective_date"><xsl:value-of select="revision-history/original/@effective-date"/></fn:string>
            <fn:string key="title"><xsl:apply-templates select="revision-history/original/title" mode="text-only"/></fn:string>
            <xsl:if test="revision-history/original/see-also">
                <fn:string key="see_also"><xsl:apply-templates select="revision-history/original/see-also" mode="rich-text-json"/></fn:string>
            </xsl:if>
            <fn:array key="content">
                <xsl:apply-templates select="revision-history/original/sentence | revision-history/original/table | revision-history/original/figure" mode="json"/>
            </fn:array>
        </fn:map>
        
        <!-- Each revision -->
        <xsl:for-each select="revision-history/revision">
            <fn:map>
                <fn:string key="type">revision</fn:string>
                <fn:string key="revision_type"><xsl:value-of select="@type"/></fn:string>
                <fn:string key="revision_id"><xsl:value-of select="@id"/></fn:string>
                <xsl:choose>
                    <xsl:when test="@seq and @seq != ''">
                        <fn:number key="sequence"><xsl:value-of select="@seq"/></fn:number>
                    </xsl:when>
                    <xsl:otherwise>
                        <fn:null key="sequence"/>
                    </xsl:otherwise>
                </xsl:choose>
                <fn:string key="effective_date"><xsl:value-of select="@effective-date"/></fn:string>
                <fn:string key="status"><xsl:value-of select="@status"/></fn:string>
                
                <!-- Deleted flag for revision (check if content is empty indicating deletion) -->
                <xsl:choose>
                    <xsl:when test="not(content/node()) or (not(content/sentence) and not(content/table) and not(content/figure) and normalize-space(content) = '')">
                        <fn:boolean key="deleted">true</fn:boolean>
                    </xsl:when>
                </xsl:choose>
                
                <fn:string key="title"><xsl:apply-templates select="content/title" mode="text-only"/></fn:string>
                <xsl:if test="content/see-also">
                    <fn:string key="see_also"><xsl:apply-templates select="content/see-also" mode="rich-text-json"/></fn:string>
                </xsl:if>
                <fn:array key="content">
                    <xsl:apply-templates select="content/sentence | content/table | content/figure" mode="json"/>
                </fn:array>
                <xsl:if test="change-summary">
                    <fn:string key="change_summary"><xsl:value-of select="change-summary"/></fn:string>
                </xsl:if>
                <xsl:if test="note">
                    <fn:string key="note"><xsl:value-of select="note"/></fn:string>
                </xsl:if>
            </fn:map>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Build table revisions with consistent structure -->
    <xsl:template name="build-table-revisions">
        <!-- Original baseline -->
        <fn:map>
            <fn:string key="type">original</fn:string>
            <fn:string key="effective_date"><xsl:value-of select="revision-history/original/@effective-date"/></fn:string>
            <fn:string key="title"><xsl:apply-templates select="revision-history/original/title" mode="rich-text-json"/></fn:string>
            <fn:map key="structure">
                <xsl:choose>
                    <xsl:when test="revision-history/original/tgroup/@cols and revision-history/original/tgroup/@cols != ''">
                        <fn:number key="columns"><xsl:value-of select="revision-history/original/tgroup/@cols"/></fn:number>
                    </xsl:when>
                    <xsl:otherwise>
                        <fn:null key="columns"/>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:if test="revision-history/original/tgroup/colspec">
                    <fn:array key="column_specs">
                        <xsl:for-each select="revision-history/original/tgroup/colspec">
                            <fn:map>
                                <fn:string key="name"><xsl:value-of select="@colname"/></fn:string>
                                <fn:string key="width"><xsl:value-of select="@colwidth"/></fn:string>
                            </fn:map>
                        </xsl:for-each>
                    </fn:array>
                </xsl:if>
                
                <xsl:if test="revision-history/original/tgroup/thead">
                    <fn:array key="header_rows">
                        <xsl:apply-templates select="revision-history/original/tgroup/thead/row" mode="json"/>
                    </fn:array>
                </xsl:if>
                
                <fn:array key="body_rows">
                    <xsl:apply-templates select="revision-history/original/tgroup/tbody/row" mode="json"/>
                </fn:array>
            </fn:map>
        </fn:map>
        
        <!-- Each revision -->
        <xsl:for-each select="revision-history/revision">
            <fn:map>
                <fn:string key="type">revision</fn:string>
                <fn:string key="revision_type"><xsl:value-of select="@type"/></fn:string>
                <fn:string key="revision_id"><xsl:value-of select="@id"/></fn:string>
                <xsl:choose>
                    <xsl:when test="@seq and @seq != ''">
                        <fn:number key="sequence"><xsl:value-of select="@seq"/></fn:number>
                    </xsl:when>
                    <xsl:otherwise>
                        <fn:null key="sequence"/>
                    </xsl:otherwise>
                </xsl:choose>
                <fn:string key="effective_date"><xsl:value-of select="@effective-date"/></fn:string>
                <fn:string key="status"><xsl:value-of select="@status"/></fn:string>
                
                <!-- Deleted flag for revision (check if content is empty indicating deletion) -->
                <xsl:choose>
                    <xsl:when test="not(content/node()) or (not(content/tgroup) and normalize-space(content) = '')">
                        <fn:boolean key="deleted">true</fn:boolean>
                    </xsl:when>
                </xsl:choose>
                
                <fn:string key="title"><xsl:apply-templates select="content/title" mode="rich-text-json"/></fn:string>
                <fn:map key="structure">
                    <xsl:choose>
                        <xsl:when test="content/tgroup/@cols and content/tgroup/@cols != ''">
                            <fn:number key="columns"><xsl:value-of select="content/tgroup/@cols"/></fn:number>
                        </xsl:when>
                        <xsl:otherwise>
                            <fn:null key="columns"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                    <xsl:if test="content/tgroup/colspec">
                        <fn:array key="column_specs">
                            <xsl:for-each select="content/tgroup/colspec">
                                <fn:map>
                                    <fn:string key="name"><xsl:value-of select="@colname"/></fn:string>
                                    <fn:string key="width"><xsl:value-of select="@colwidth"/></fn:string>
                                </fn:map>
                            </xsl:for-each>
                        </fn:array>
                    </xsl:if>
                    
                    <xsl:if test="content/tgroup/thead">
                        <fn:array key="header_rows">
                            <xsl:apply-templates select="content/tgroup/thead/row" mode="json"/>
                        </fn:array>
                    </xsl:if>
                    
                    <fn:array key="body_rows">
                        <xsl:apply-templates select="content/tgroup/tbody/row" mode="json"/>
                    </fn:array>
                </fn:map>
                <xsl:if test="change-summary">
                    <fn:string key="change_summary"><xsl:value-of select="change-summary"/></fn:string>
                </xsl:if>
                <xsl:if test="note">
                    <fn:string key="note"><xsl:value-of select="note"/></fn:string>
                </xsl:if>
            </fn:map>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Build entry revisions with consistent structure -->
    <xsl:template name="build-entry-revisions">
        <!-- Original baseline -->
        <fn:map>
            <fn:string key="type">original</fn:string>
            <fn:string key="effective_date"><xsl:value-of select="revision-history/original/@effective-date"/></fn:string>
            <fn:string key="content"><xsl:apply-templates select="revision-history/original" mode="rich-text-json"/></fn:string>
            <xsl:if test="revision-history/original/@align">
                <fn:string key="align"><xsl:value-of select="revision-history/original/@align"/></fn:string>
            </xsl:if>
            <xsl:if test="revision-history/original/@rowspan and revision-history/original/@rowspan != ''">
                <fn:number key="rowspan"><xsl:value-of select="revision-history/original/@rowspan"/></fn:number>
            </xsl:if>
            <xsl:if test="revision-history/original/@colspan and revision-history/original/@colspan != ''">
                <fn:number key="colspan"><xsl:value-of select="revision-history/original/@colspan"/></fn:number>
            </xsl:if>
        </fn:map>
        
        <!-- Each revision -->
        <xsl:for-each select="revision-history/revision">
            <fn:map>
                <fn:string key="type">revision</fn:string>
                <fn:string key="revision_type"><xsl:value-of select="@type"/></fn:string>
                <fn:string key="revision_id"><xsl:value-of select="@id"/></fn:string>
                <xsl:choose>
                    <xsl:when test="@seq and @seq != ''">
                        <fn:number key="sequence"><xsl:value-of select="@seq"/></fn:number>
                    </xsl:when>
                    <xsl:otherwise>
                        <fn:null key="sequence"/>
                    </xsl:otherwise>
                </xsl:choose>
                <fn:string key="effective_date"><xsl:value-of select="@effective-date"/></fn:string>
                <fn:string key="status"><xsl:value-of select="@status"/></fn:string>
                
                <!-- Deleted flag for revision (check if content is empty indicating deletion) -->
                <xsl:choose>
                    <xsl:when test="not(content/node()) or normalize-space(content) = ''">
                        <fn:boolean key="deleted">true</fn:boolean>
                    </xsl:when>
                </xsl:choose>
                
                <fn:string key="content"><xsl:apply-templates select="content" mode="rich-text-json"/></fn:string>
                <xsl:if test="content/@align">
                    <fn:string key="align"><xsl:value-of select="content/@align"/></fn:string>
                </xsl:if>
                <xsl:if test="content/@rowspan and content/@rowspan != ''">
                    <fn:number key="rowspan"><xsl:value-of select="content/@rowspan"/></fn:number>
                </xsl:if>
                <xsl:if test="content/@colspan and content/@colspan != ''">
                    <fn:number key="colspan"><xsl:value-of select="content/@colspan"/></fn:number>
                </xsl:if>
                <xsl:if test="change-summary">
                    <fn:string key="change_summary"><xsl:value-of select="change-summary"/></fn:string>
                </xsl:if>
                <xsl:if test="note">
                    <fn:string key="note"><xsl:value-of select="note"/></fn:string>
                </xsl:if>
            </fn:map>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Build application note revisions with consistent structure -->
    <xsl:template name="build-appnote-revisions">
        <!-- Original baseline -->
        <fn:map>
            <fn:string key="type">original</fn:string>
            <fn:string key="effective_date"><xsl:value-of select="revision-history/original/@effective-date"/></fn:string>
            <fn:string key="number"><xsl:value-of select="revision-history/original/number"/></fn:string>
            <fn:string key="title"><xsl:apply-templates select="revision-history/original/title" mode="text-only"/></fn:string>
            <xsl:if test="revision-history/original/paragraph">
                <fn:array key="paragraphs">
                    <xsl:for-each select="revision-history/original/paragraph">
                        <fn:map>
                            <xsl:if test="@xml:id">
                                <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
                            </xsl:if>
                            <fn:string key="content"><xsl:apply-templates select="." mode="rich-text-json"/></fn:string>
                        </fn:map>
                    </xsl:for-each>
                </fn:array>
            </xsl:if>
        </fn:map>
        
        <!-- Each revision -->
        <xsl:for-each select="revision-history/revision">
            <fn:map>
                <fn:string key="type">revision</fn:string>
                <fn:string key="revision_type"><xsl:value-of select="@type"/></fn:string>
                <fn:string key="revision_id"><xsl:value-of select="@id"/></fn:string>
                <xsl:choose>
                    <xsl:when test="@seq and @seq != ''">
                        <fn:number key="sequence"><xsl:value-of select="@seq"/></fn:number>
                    </xsl:when>
                    <xsl:otherwise>
                        <fn:null key="sequence"/>
                    </xsl:otherwise>
                </xsl:choose>
                <fn:string key="effective_date"><xsl:value-of select="@effective-date"/></fn:string>
                <fn:string key="status"><xsl:value-of select="@status"/></fn:string>
                
                <!-- Deleted flag for revision (check if content is empty indicating deletion) -->
                <xsl:choose>
                    <xsl:when test="not(content/node()) or (not(content/number) and not(content/title) and not(content/paragraph) and normalize-space(content) = '')">
                        <fn:boolean key="deleted">true</fn:boolean>
                    </xsl:when>
                </xsl:choose>
                
                <fn:string key="number"><xsl:value-of select="content/number"/></fn:string>
                <fn:string key="title"><xsl:apply-templates select="content/title" mode="text-only"/></fn:string>
                <xsl:if test="content/paragraph">
                    <fn:array key="paragraphs">
                        <xsl:for-each select="content/paragraph">
                            <fn:map>
                                <xsl:if test="@xml:id">
                                    <fn:string key="id"><xsl:value-of select="@xml:id"/></fn:string>
                                </xsl:if>
                                <fn:string key="content"><xsl:apply-templates select="." mode="rich-text-json"/></fn:string>
                            </fn:map>
                        </xsl:for-each>
                    </fn:array>
                </xsl:if>
                <xsl:if test="change-summary">
                    <fn:string key="change_summary"><xsl:value-of select="change-summary"/></fn:string>
                </xsl:if>
                <xsl:if test="note">
                    <fn:string key="note"><xsl:value-of select="note"/></fn:string>
                </xsl:if>
            </fn:map>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Build subsection revisions with consistent structure -->
    <xsl:template name="build-subsection-revisions">
        <!-- Original baseline -->
        <fn:map>
            <fn:string key="type">original</fn:string>
            <fn:string key="effective_date"><xsl:value-of select="revision-history/original/@effective-date"/></fn:string>
            <fn:string key="title"><xsl:apply-templates select="revision-history/original/title" mode="text-only"/></fn:string>
            <xsl:if test="revision-history/original/see-also">
                <fn:string key="see_also"><xsl:apply-templates select="revision-history/original/see-also" mode="rich-text-json"/></fn:string>
            </xsl:if>
            <fn:array key="articles">
                <xsl:apply-templates select="revision-history/original/article" mode="json"/>
            </fn:array>
        </fn:map>
        
        <!-- Each revision -->
        <xsl:for-each select="revision-history/revision">
            <fn:map>
                <fn:string key="type">revision</fn:string>
                <fn:string key="revision_type"><xsl:value-of select="@type"/></fn:string>
                <fn:string key="revision_id"><xsl:value-of select="@id"/></fn:string>
                <xsl:choose>
                    <xsl:when test="@seq and @seq != ''">
                        <fn:number key="sequence"><xsl:value-of select="@seq"/></fn:number>
                    </xsl:when>
                    <xsl:otherwise>
                        <fn:null key="sequence"/>
                    </xsl:otherwise>
                </xsl:choose>
                <fn:string key="effective_date"><xsl:value-of select="@effective-date"/></fn:string>
                <fn:string key="status"><xsl:value-of select="@status"/></fn:string>
                
                <!-- Deleted flag for revision (check if content is empty indicating deletion) -->
                <xsl:choose>
                    <xsl:when test="not(content/node()) or (not(content/title) and not(content/article) and normalize-space(content) = '')">
                        <fn:boolean key="deleted">true</fn:boolean>
                    </xsl:when>
                </xsl:choose>
                
                <fn:string key="title"><xsl:apply-templates select="content/title" mode="text-only"/></fn:string>
                <xsl:if test="content/see-also">
                    <fn:string key="see_also"><xsl:apply-templates select="content/see-also" mode="rich-text-json"/></fn:string>
                </xsl:if>
                <fn:array key="articles">
                    <xsl:apply-templates select="content/article" mode="json"/>
                </fn:array>
                <xsl:if test="change-summary">
                    <fn:string key="change_summary"><xsl:value-of select="change-summary"/></fn:string>
                </xsl:if>
                <xsl:if test="note">
                    <fn:string key="note"><xsl:value-of select="note"/></fn:string>
                </xsl:if>
            </fn:map>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>