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

    <xsl:param name="rss-url"/>
    <xsl:param name="title"/>
    <xsl:param name="link"/>
    <xsl:param name="description"/>
    <xsl:param name="img-url"/>
    <xsl:param name="date" select="date:date-time()"/>

    <xsl:output method="xml" encoding="UTF-8"/>

    <xsl:template match="rss:channel">
	<xsl:copy>
	    <xsl:attribute name="rdf:about">
		<xsl:value-of select="$rss-url"/>
	    </xsl:attribute>
	    <xsl:apply-templates select="@*"/>
	    <title><xsl:value-of select="$title"/></title>
	    <link><xsl:value-of select="$link"/></link>
            <description><xsl:element name="include" namespace="http://www.w3.org/2001/XInclude">
                    <xsl:attribute name="href"><xsl:value-of select="$description"/></xsl:attribute>
                    <xsl:attribute name="parse">text</xsl:attribute>
            </xsl:element></description>
	    <xsl:if test="$img-url"><image rdf:resource="{$img-url}"/></xsl:if>
	    <xsl:apply-templates select="node()"/>
	</xsl:copy>
    </xsl:template>

    <xsl:template match="rdf:RDF">
	<xsl:copy>
	    <xsl:apply-templates select="@*|node()"/>
	    <xsl:if test="$img-url">
		<image rdf:about="{$img-url}">
		    <title><xsl:value-of select="$title"/></title>
		    <url><xsl:value-of select="$img-url"/></url>
		    <link><xsl:value-of select="$link"/></link>
		</image>
	    </xsl:if>
	    <item rdf:about="{$link}">
		<title><xsl:value-of select="$title"/></title>
		<link><xsl:value-of select="$link"/></link>
		<description><xsl:value-of
			select="$description"/></description>
		<dc:date><xsl:value-of select="$date"/></dc:date>
	    </item>
	</xsl:copy>
    </xsl:template>

    <xsl:template match="rss:channel/rss:items/rdf:Seq">
	<xsl:copy>
	    <rdf:li resource="{$link}"/>
	    <xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
    </xsl:template>

</xsl:stylesheet>
