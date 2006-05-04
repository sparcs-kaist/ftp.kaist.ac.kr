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

<xsl:variable name="packages-per-row" select="4"/>
<xsl:variable name="_msgs">
<labels lang="ko">
    <label name="title">복사본 현황</label>
    <label name="name">이름</label>
    <label name="url">URL</label>
    <label name="timeelapsed">흐른 시간</label>
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
    <label name="source">원본 위치</label>
    <label name="frequency">자동 갱신 주기</label>
    <label name="failures">번 실패</label>
    <label name="hours">시간</label>
    <label name="lastupdated">마지막 동기 시각</label>
    <label name="statistics">통계 자료</label>
    <label name="sizechanges">크기 변화</label>
    <label name="sizehistory">모든 기록</label>
    <label name="currentsize">현재 크기</label>
    <label name="size">크기</label>
    <label name="files">파일 수</label>
    <label name="dirs">디렉토리 수</label>
    <label name="sizecounted">계산된 때</label>
    <label name="refresh">새로고침</label>
    <label name="refreshnow">지금</label>
    <label name="refresh1min">매 1분마다</label>
    <label name="refresh5mins">매 5분마다</label>
    <label name="refresh20mins">매 20분마다</label>
    <label name="refreshhourly">한 시간마다</label>
</labels>
<labels lang="en">
    <label name="title">Status of mirrors</label>
    <label name="name">Name</label>
    <label name="url">URL</label>
    <label name="timeelapsed">Time Elapsed</label>
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
    <label name="source">Source</label>
    <label name="frequency">Frequency</label>
    <label name="failures"> Failures</label>
    <label name="hours">hours</label>
    <label name="lastupdated">Last Updated</label>
    <label name="statistics">Statistics Data</label>
    <label name="sizechanges">Size Changes</label>
    <label name="sizehistory">All History</label>
    <label name="wwwstats">WWW Usages</label>
    <label name="currentsize">Current Size</label>
    <label name="size">Size</label>
    <label name="files">Files</label>
    <label name="dirs">Directories</label>
    <label name="sizecounted">Calculated</label>
    <label name="refresh">Refresh</label>
    <label name="refreshnow">Now</label>
    <label name="refresh1min">Every minute</label>
    <label name="refresh5mins">Every 5 minutes</label>
    <label name="refresh20mins">Every 20 minutes</label>
    <label name="refreshhourly">Every hour</label>
</labels>
</xsl:variable>
<xsl:variable name="labels" select="exsl:node-set($_msgs)/labels"/>

<xsl:param name="lang" select="$labels[1]/@lang"/>
<xsl:variable name="labs" select="$labels[@lang=$lang]/label"/>

<xsl:template match="/">
    <xsl:comment>#set var="id" value="status" </xsl:comment>
    <xsl:comment>#set var="title" value="<xsl:value-of select="$labs[@name='title']"/>" </xsl:comment>
    <xsl:comment>#include virtual="/include/head.shtml" </xsl:comment>
    <xsl:apply-templates/>
    <xsl:comment>#include virtual="/include/foot.shtml" </xsl:comment>
</xsl:template>

<xsl:template match="packages[package]">
    <script type="text/javascript" src="/include/mozxpath.js">;</script>
    <script type="text/javascript" src="/locale.js.{$lang}">;</script>
    <script type="text/javascript" src="/status.js">;</script>
    <table id="pkgs">
        <thead>
            <tr><td colspan="{$packages-per-row}">
                    <select onchange="refreshRegularly(this.value);">
                        <option     value=""><xsl:value-of select="$labs[@name='refreshnow']"/></option>
                        <option   value="60"><xsl:value-of select="$labs[@name='refresh1min']"/></option>
                        <option  value="300"><xsl:value-of select="$labs[@name='refresh5mins']"/></option>
                        <option value="1200"><xsl:value-of select="$labs[@name='refresh20mins']"/></option>
                        <option value="3600"><xsl:value-of select="$labs[@name='refreshhourly']"/></option>
                    </select>
                    <a accesskey="r" href="javascript:void(refresh());"><xsl:value-of
                            select="$labs[@name='refresh']"/><sub style="text-decoration:underline;">r</sub></a>
            </td></tr>
        </thead>
        <tbody>
            <xsl:for-each select="package[
                position() mod $packages-per-row = 1]">
                <tr>
                    <xsl:apply-templates mode="row" select="."/>
                </tr>
            </xsl:for-each>
        </tbody>
    </table>
</xsl:template>
<xsl:template mode="row" match="package">
    <xsl:param name="remaining" select="$packages-per-row"/>
    <td><xsl:apply-templates select="."/></td>
    <xsl:if test="$remaining &gt; 1">
        <xsl:apply-templates mode="row"
            select="following-sibling::package[1]">
            <xsl:with-param name="remaining" select="$remaining - 1"/>
        </xsl:apply-templates>
    </xsl:if>
</xsl:template>


<xsl:template match="package">
    <xsl:variable name="pkg" select="."/>
    <div id="pkg-{@id}" class="pkg {status}">
        <h3 class="pkgname"><xsl:value-of select="name"/></h3>
        <div class="pkglinks">
            <xsl:for-each select="link">
                <a href="{@href}" title="{@href}">
                    [<xsl:value-of select="@rel"/>]</a>
            </xsl:for-each>
        </div>
        <div class="pkglastupdated">
            <xsl:value-of select="status/@lastupdated"/>
        </div>
        <div>
            <!-- show update status -->
            <span class="pkgstatus">
                <a href="/pkgs/{@id}/log.0">
                    <xsl:call-template name="fallback-to-unknown">
                        <xsl:with-param name="v"
                            select="$labs[@name=concat('status_',$pkg/status)]"/>
                    </xsl:call-template>
                </a>
            </span>
            <!-- show elapsed time in such state -->
            <span class="pkgage">&#160;</span>
        </div>
        <!-- show synchronizing status -->
        <div>
            <span class="pkgsync">
                <a href="/pkgs/{@id}/log"><xsl:value-of
                        select="$labs[@name='status_sync']"/></a>
                <span class="pkgsyncage">&#160;</span>
            </span>
            <a href="/pkgs/{@id}/fail.log.0" class="pkgsyncfailures" style="display:none;">
                (<span class="pkgsyncfailed"><xsl:choose>
                        <xsl:when test="sync/@failed"><xsl:value-of
                                select="sync/@failed"/></xsl:when>
                        <xsl:otherwise>0</xsl:otherwise>
                    </xsl:choose></span><xsl:value-of
                    select="$labs[@name='failures']"/>)
            </a>
        </div>
        <!-- verbose information -->
        <ul class="pkginfo">
            <li><xsl:value-of select="$labs[@name='source']"/>: <span class="pkgsource"><xsl:value-of select="sync"/></span></li>
            <li><xsl:value-of select="$labs[@name='frequency']"/>: <span class="pkgfrequency"><xsl:value-of select="sync/@frequency"/></span></li>
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
