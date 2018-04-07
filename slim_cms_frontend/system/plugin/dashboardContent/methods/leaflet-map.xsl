<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">

	<xsl:template match="leaflet-map" mode="html">
		<xsl:param name="id" select="@id" />

		<xsl:variable name="plugin_method_call_id">
			<xsl:choose>
				<xsl:when test="$id != ''">
					<xsl:value-of select="/config/plugin[@plugin='dashboardContent'][@method='leafletMap'][@id=$id]/@plugin_method_call_id" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="/config/plugin[@plugin='dashboardContent'][@method='leafletMap']/@plugin_method_call_id" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="height">
			<xsl:choose>
				<xsl:when test="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/@height">
					<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/@height" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>500px</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="element-id">
			<xsl:choose>
				<xsl:when test="$id != ''">
					<xsl:text>leaflet-map-</xsl:text><xsl:value-of select="$id" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>leaflet-map</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<div style="display:block">
			<div>

				<!-- //Standard Attributes -->
				<xsl:attribute name="id"><xsl:value-of select="$element-id" /></xsl:attribute>
				<xsl:attribute name="class"><xsl:value-of select="'dashboard leaflet-map'" /></xsl:attribute>
				<xsl:attribute name="style">height:<xsl:value-of select="$height" />;width:100%;max-height:100%;</xsl:attribute>
				<xsl:attribute name="data-key">
					<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/@key" />
				</xsl:attribute>
				<xsl:attribute name="data-timestamp">
					<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/@timestamp" />
				</xsl:attribute>
				<xsl:attribute name="data-hash">
					<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/@hash" />
				</xsl:attribute>

				<!-- //Optional Attributes -->
				<xsl:if test="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/@center-lat">
					<xsl:attribute name="data-center-lat">
						<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/@center-lat" />
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/@center-lng">
					<xsl:attribute name="data-center-lng">
						<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/@center-lng" />
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/@zoom">
					<xsl:attribute name="data-zoom">
						<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/@zoom" />
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/@max-zoom">
					<xsl:attribute name="data-max-zoom">
						<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/@max-zoom" />
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/@min-zoom">
					<xsl:attribute name="data-min-zoom">
						<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/@min-zoom" />
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/@map-type">
					<xsl:attribute name="data-map-type">
						<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/@map-type" />
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/@layers">
					<xsl:attribute name="data-map-layers">
						<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/@layers" />
					</xsl:attribute>
				</xsl:if>
				<xsl:attribute name="data-map-data">
					<xsl:value-of select="/config/plugin[@plugin_method_call_id = $plugin_method_call_id]/clientCoordinates/@data" />
				</xsl:attribute>
			</div>
		</div>

	</xsl:template>

</xsl:stylesheet>