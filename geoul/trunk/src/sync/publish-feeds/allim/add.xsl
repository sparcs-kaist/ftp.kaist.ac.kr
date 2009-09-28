<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns="http://purl.org/rss/1.0/"
    exclude-result-prefixes="rss date"
    xmlns:rss="http://purl.org/rss/1.0/"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="expire.xsl"/>

    <xsl:param name="title"/>
    <xsl:param name="link"/>
    <xsl:param name="description"/>
    <xsl:param name="date" select="date:date-time()"/>

    <xsl:output method="xml" encoding="UTF-8"/>

    <xsl:template match="/rdf:RDF/rss:channel/rss:items/rdf:Seq">
	<xsl:copy>
	    <rdf:li resource="{$link}"/>
	    <xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
    </xsl:template>

    <xsl:template match="/rdf:RDF/rss:item[1]">
	<item rdf:about="{$link}">
	    <title><xsl:value-of select="$title"/></title>
	    <link><xsl:value-of select="$link"/></link>
	    <description><xsl:value-of select="$description"/></description>
	    <dc:date><xsl:value-of select="$date"/></dc:date>
	</item>
	<xsl:apply-imports/>
    </xsl:template>

</xsl:stylesheet>
