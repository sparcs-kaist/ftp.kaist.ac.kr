<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:al="http://netj.org/2006/allim"
    xmlns="http://purl.org/rss/1.0/"
    exclude-result-prefixes="rss date"
    xmlns:rss="http://purl.org/rss/1.0/"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="id.xsl"/>

    <xsl:param name="duration" select="/rdf:RDF/rss:channel/@al:keep"/>
    <xsl:param name="now" select="date:date-time()"/>

    <xsl:output method="xml" encoding="UTF-8"/>

    <xsl:variable name="secs" select="date:seconds($duration)"/>


    <!-- record al:keep -->
    <xsl:template match="/rdf:RDF/rss:channel">
	<xsl:copy>
	    <xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
    </xsl:template>
    <xsl:template match="@al:keep">
        <xsl:attribute name="al:keep">
            <xsl:value-of select="$duration"/>
        </xsl:attribute>
    </xsl:template>

    <!-- expire rdf:li -->
    <xsl:key name="item" match="/rdf:RDF/rss:item" use="@rdf:about"/>
    <xsl:template match="/rdf:RDF/rss:channel/rss:items/rdf:Seq/rdf:li">
	<xsl:if test="date:seconds(date:difference(
	    key('item', @resource)/dc:date, $now)) &lt; $secs">
	    <xsl:apply-imports/>
	</xsl:if>
    </xsl:template>

    <!-- expire rss:item -->
    <xsl:template match="/rdf:RDF/rss:item">
	<xsl:if test="date:seconds(date:difference(dc:date, $now)) &lt; $secs">
	    <xsl:apply-imports/>
	</xsl:if>
    </xsl:template>

</xsl:stylesheet>
