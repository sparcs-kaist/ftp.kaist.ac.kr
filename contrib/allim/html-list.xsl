<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="rss rdf dc"
    xmlns:rss="http://purl.org/rss/1.0/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="xml" media-type="text/html" encoding="UTF-8"
        omit-xml-declaration="yes"/>

    <xsl:template match="/rdf:RDF">
        <xsl:if test="count(rss:item) &gt; 0">
            <ul class="rss-items"><xsl:apply-templates select="rss:item"/></ul>
        </xsl:if>
    </xsl:template>

    <xsl:template match="rss:item">
        <li class="rss-item">
            <b class="rss-item-title"><a href="{rss:link}"><xsl:value-of
                        select="rss:title"/></a></b><br/>
            <xsl:if test="dc:date">
                <small class="rss-item-date"><xsl:value-of
                        select="dc:date"/></small><br/>
            </xsl:if>
            <p class="rss-item-description"><xsl:value-of
                    select="rss:description"/></p>
        </li>
    </xsl:template>

</xsl:stylesheet>
