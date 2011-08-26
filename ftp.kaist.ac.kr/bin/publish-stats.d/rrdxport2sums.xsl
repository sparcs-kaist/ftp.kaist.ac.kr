<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="text"/>

    <xsl:template match="/">
        <!-- for each pkg -->
        <xsl:for-each select="/xport/data/row[1]/v">
            <xsl:variable name="i" select="position()"/>
            <!-- show name and sum in each line -->
            <xsl:value-of select="/xport/meta/legend/entry[$i]"/>
            <xsl:text>&#9;</xsl:text>
            <xsl:value-of select="sum(/xport/data/row/v[$i]/text())"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
