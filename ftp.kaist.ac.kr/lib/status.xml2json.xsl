<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="text"/>

    <xsl:template match="/packages">
{ "timestamp": "<xsl:value-of select="@timestamp"/>"
, "package":
  {<xsl:for-each select="package"><xsl:if test="position() &gt; 1">,</xsl:if
    >"<xsl:value-of select="@id"/>": { "id": "<xsl:value-of select="@id"/>"
    , "name": "<xsl:value-of select="@name"/>"
    , "hidden": <xsl:call-template name="boolean"><xsl:with-param name="v" select="@hidden"/></xsl:call-template>
    , "link":
      [<xsl:for-each select="link"><xsl:if test="position() &gt; 1">,</xsl:if
        > { "rel":"<xsl:value-of select="@rel"/>", "href":"<xsl:value-of select="@href"/>" }
      </xsl:for-each>]
    <xsl:if test="sync">
    , "sync":
      { "source":"<xsl:value-of select="sync/@source"/>"
      <xsl:if test="sync/@frequency">, "frequency":"<xsl:value-of select="sync/@frequency"/>"</xsl:if>
      }
    </xsl:if>
    <xsl:if test="status">
    , "status":
      { "updated": <xsl:call-template name="status"><xsl:with-param name="v" select="status/updated"/></xsl:call-template>
      , "updating": <xsl:call-template name="status"><xsl:with-param name="v" select="status/updating"/></xsl:call-template>
      , "failed": <xsl:call-template name="status"><xsl:with-param name="v" select="status/failed"/></xsl:call-template>
      , "usage": null
      , "size": null
      }
    </xsl:if>
    }
  </xsl:for-each>}
}
    </xsl:template>

    <xsl:template name="boolean">
        <xsl:param name="v"/>
        <xsl:choose>
            <xsl:when test="$v = 'true'">"true"</xsl:when>
            <xsl:when test="$v = 'false'">"false"</xsl:when>
            <xsl:otherwise>null</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="status">
        <xsl:param name="v"/>
        <xsl:choose>
            <xsl:when test="$v">
                { "href":"<xsl:value-of select="$v/@href"/>"
                <xsl:if test="$v/@timestamp">, "timestamp":"<xsl:value-of select="$v/@timestamp"/>"</xsl:if>
                <xsl:if test="$v/@count">, "count":"<xsl:value-of select="$v/@count"/>"</xsl:if>
                }</xsl:when>
            <xsl:otherwise>null</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
