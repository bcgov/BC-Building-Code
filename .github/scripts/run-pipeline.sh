#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
AMENDMENTS_FILE="$ROOT/json-generation-pipeline/output/bc-amendments-combined.xml"
REVISIONS_FILE="$ROOT/json-generation-pipeline/output/bc-revisions-combined.xml"


java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/nbc-to-canonical.xsl \
  -s:json-generation-pipeline/source/nbc-2020-xml/nbc2020.xml \
  -o:json-generation-pipeline/output/nbc-canonical.xml


java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/combine-amendments.xsl \
  -s:json-generation-pipeline/source/bc-amendments/amendment-list.xml \
  -o:json-generation-pipeline/output/bc-amendments-combined.xml


java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/merge-engine-v3.xsl \
  -s:json-generation-pipeline/output/nbc-canonical.xml \
  overlay-document="file://$AMENDMENTS_FILE" \
  -o:json-generation-pipeline/output/bc-building-code.xml


java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/combine-amendments.xsl \
  -s:json-generation-pipeline/source/bc-revisions/revision-list.xml \
  -o:json-generation-pipeline/output/bc-revisions-combined.xml


java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/merge-engine-v3.xsl \
  -s:json-generation-pipeline/output/bc-building-code.xml \
  overlay-document="file://$REVISIONS_FILE" \
  -o:json-generation-pipeline/output/bc-building-code-final.xml


java -jar json-generation-pipeline/tools/saxon.jar \
  -xsl:json-generation-pipeline/transformation-xslt/canonical-to-json.xsl \
  -s:json-generation-pipeline/output/bc-building-code-final.xml \
  -o:json-generation-pipeline/output/bcbc-2024.json