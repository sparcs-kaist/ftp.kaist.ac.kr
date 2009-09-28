<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns="http://purl.org/rss/1.0/"
    exclude-result-prefixes="rss date"
    xmlns:rss="http://purl.org/rss/1.0/"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:template match="/rdf:RDF">
        <xsl:apply-templates select="rss:item"/>
    </xsl:template>

    <xsl:template match="rss:item"><xsl:text>= </xsl:text><xsl:value-of
            select="rss:title"/><xsl:text> =
</xsl:text><xsl:value-of select="rss:link"/><xsl:text>
</xsl:text><xsl:value-of select="dc:date"/><xsl:text>
-------------------------------------------------------------------------------
</xsl:text><xsl:value-of select="rss:description"/><xsl:text>

</xsl:text></xsl:template>

</xsl:stylesheet>
