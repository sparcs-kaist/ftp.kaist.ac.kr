<xsl:stylesheet version="1.0"
    exclude-result-prefixes="exsl"
    xmlns:exsl="http://exslt.org/common"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!-- 
  XSLT for creating HTML package index for Geoul
  Author:  Jaeho Shin <netj@sparcs.org>
  Refined: 2006-04-09
  Created: 2003/02/03
-->

<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

<xsl:variable name="packages-per-row" select="5"/>
<xsl:variable name="_msgs">
<labels lang="ko">
    <label name="status">상태</label>
    <label name="status_sync">받는 중</label>
    <label name="status_good">좋음</label>
    <label name="status_ok">괜찮음</label>
    <label name="status_old">오래됨</label>
    <label name="status_bad">나쁨</label>
    <label name="status_dead">죽었음</label>
    <label name="status_down">멈춤</label>
    <label name="status_unknown">알 수 없음</label>
    <label name="unknown">알 수 없음</label>
    <label name="timeelapsed">흐른 시간</label>
    <label name="failures">번 실패</label>
    <label name="lastupdated">새로고침</label>
    <label name="source">원본</label>
    <label name="frequency">갱신주기</label>
    <label name="links">빨리가기</label>
    <label name="refresh">새로고침</label>
    <label name="refreshnow">지금</label>
    <label name="refresh1min">매 1분마다</label>
    <label name="refresh5mins">매 5분마다</label>
    <label name="refresh20mins">매 20분마다</label>
    <label name="refreshhourly">한 시간마다</label>
    <label name="size">크기변화</label>
</labels>
<labels lang="en">
    <label name="status">Status</label>
    <label name="status_sync">Updating</label>
    <label name="status_good">Good</label>
    <label name="status_ok">OK</label>
    <label name="status_old">Old</label>
    <label name="status_bad">Bad</label>
    <label name="status_dead">Dead</label>
    <label name="status_down">Down</label>
    <label name="status_unknown">Unknown</label>
    <label name="unknown">Unknown</label>
    <label name="timeelapsed">Time Elapsed</label>
    <label name="failures"> Failures</label>
    <label name="lastupdated">Last Updated</label>
    <label name="source">Source</label>
    <label name="frequency">Frequency</label>
    <label name="links">Links</label>
    <label name="refresh">Refresh</label>
    <label name="refreshnow">Now</label>
    <label name="refresh1min">Every minute</label>
    <label name="refresh5mins">Every 5 minutes</label>
    <label name="refresh20mins">Every 20 minutes</label>
    <label name="refreshhourly">Every hour</label>
    <label name="size">Change in size</label>
</labels>
</xsl:variable>
<xsl:variable name="labels" select="exsl:node-set($_msgs)/labels"/>

<xsl:param name="lang" select="$labels[1]/@lang"/>
<xsl:variable name="labs" select="$labels[@lang=$lang]/label"/>

<xsl:template match="packages[package]">
    <script type="text/javascript" src="/include/mozxpath.js">;</script>
    <script type="text/javascript" src="/locale.js.{$lang}">;</script>
    <script type="text/javascript" src="/status.js">;</script>
    <div id="pkgs">
        <div id="pkgstool">
            <a href="/pkgs/news.feed"><img alt="[feed]"
                    src="feed-icon-24x24.png"
                    style="border:none; vertical-align:middle;"/></a>
            <select onchange="refreshRegularly(this.value);">
                <option     value=""><xsl:value-of select="$labs[@name='refreshnow']"/></option>
                <option   value="60"><xsl:value-of select="$labs[@name='refresh1min']"/></option>
                <option  value="300"><xsl:value-of select="$labs[@name='refresh5mins']"/></option>
                <option value="1200"><xsl:value-of select="$labs[@name='refresh20mins']"/></option>
                <option value="3600"><xsl:value-of select="$labs[@name='refreshhourly']"/></option>
            </select>
            <button accesskey="r" onclick="refresh();"><xsl:value-of
                    select="$labs[@name='refresh']"/><sub
                    style="text-decoration:underline;">r</sub></button>
        </div>
        <div id="pkgsidx">
            <xsl:apply-templates select="package" mode="index">
                <xsl:sort select="translate(name, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
            </xsl:apply-templates>
        </div>
        <div id="pkgsinfo">
            <xsl:apply-templates select="package">
                <xsl:sort select="translate(name, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
            </xsl:apply-templates>
        </div>
    </div>
</xsl:template>

<xsl:template match="package" mode="index">
    <a class="pkglink {status}" href="#pkg-{@id}"
        onclick="toggle('pkg-{@id}');"><xsl:value-of select="name"/></a>
</xsl:template>

<xsl:template match="package">
    <div id="pkg-{@id}" class="pkg {status}">
        <h3 class="pkgname"><xsl:value-of select="name"/>
            <xsl:text> </xsl:text>
            <a href="/pkgs/{@id}/news.feed"><img alt="[feed]"
                    src="feed-icon-12x12.png"
                    style="border:none; vertical-align:top;"/></a></h3>
        <ul>
            <xsl:if test="status != 'original'">
                <li><xsl:value-of select="$labs[@name='status']"/>:
                    <!-- show update status -->
                    <a class="pkgstatus" href="{status/@ref}">
                        <xsl:call-template name="fallback-to-unknown">
                            <xsl:with-param name="v"
                                select="$labs[@name=concat('status_',
                                current()/status)]"/>
                        </xsl:call-template>
                    </a>
                    <xsl:text> </xsl:text>
                    <!-- show synchronizing status -->
                    <span class="pkgsync">
                        <a href="{sync/@ref}" class="pkgsyncref"><xsl:value-of
                                select="$labs[@name='status_sync']"/></a>
                        <xsl:text> </xsl:text>
                        <span class="pkgsyncage"
                            title="{$labs[@name='timeelapsed']}">&#160;</span>
                    </span>
                    <xsl:text> </xsl:text>
                    <a href="{fail/@ref}" class="pkgsyncfailures"
                        style="display:none;">(<span
                            class="pkgsyncfailed"><xsl:value-of
                                select="fail"/></span><xsl:value-of
                            select="$labs[@name='failures']"/>)</a>
                    <xsl:text> </xsl:text>
                    <!-- show elapsed time in such state -->
                    <span class="pkgage"
                        title="{$labs[@name='timeelapsed']}">&#160;</span>
                </li>
                <li><xsl:value-of select="$labs[@name='lastupdated']"/>:
                    <span class="pkglastupdated"><xsl:value-of
                            select="status/@lastupdated"/></span>
                </li>

                <!-- show locations -->
                <li><xsl:value-of select="$labs[@name='source']"/>:
                    <span class="pkgsource"><xsl:value-of select="sync"/></span>
                </li>
                <li><xsl:value-of select="$labs[@name='frequency']"/>:
                    <span class="pkgfrequency"><xsl:value-of select="sync/@frequency"/></span>
                </li>
            </xsl:if>

            <xsl:if test="link">
                <li><xsl:value-of select="$labs[@name='links']"/>:
                    <ul class="pkglinks">
                        <xsl:for-each select="link">
                            <li><xsl:value-of select="@rel"/>: 
                                <a href="{@href}" title="{@href}"><xsl:value-of
                                        select="@href"/></a></li>
                        </xsl:for-each>
                    </ul>
                </li>
            </xsl:if>

            <xsl:if test="size">
                <li>
                    <img class="pkgsizegraph" src="/pkgs/{@id}/du.png"
                        alt="{$labs[@name='size']} ({name})"/>
                </li>
            </xsl:if>
        </ul>
    </div>
</xsl:template>


<!-- fallback to unknown -->
<xsl:template name="fallback-to-unknown">
    <xsl:param name="v"/>
    <xsl:choose>
        <xsl:when test="$v"><xsl:value-of select="$v"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="$labs[@name='unknown']"/></xsl:otherwise>
    </xsl:choose>
</xsl:template>



<!-- abbreviate bytes -->
<xsl:template name="abbreviate-bytes">
    <xsl:param name="value"/>
    <xsl:choose>
        <xsl:when test="$value >= 1099511627776">
            <xsl:value-of select="format-number($value div 1099511627776, '#,###.00TB')"/>
        </xsl:when>
        <xsl:when test="$value >= 1073741824">
            <xsl:value-of select="format-number($value div 1073741824, '#.00GB')"/>
        </xsl:when>
        <xsl:when test="$value >= 1048576">
            <xsl:value-of select="format-number($value div 1048576, '#.00MB')"/>
        </xsl:when>
        <xsl:when test="$value >= 1024">
            <xsl:value-of select="format-number($value div 1024, '#.00KB')"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="format-number($value, '#B')"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
