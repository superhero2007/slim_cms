<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math">

	<xsl:template match="JVMClientMap" mode="html">
		<xsl:call-template name="jvmClientMap" />
	</xsl:template>

	<xsl:template name="jvmClientMap">
		<!-- //Get the client map element -->
		<xsl:param name="settings" select="@settings" />
		<xsl:param name="data" select="/config/plugin[@plugin = 'dashboardContent'][@method = 'getJVMClientMap']/clientCoordinates/@data" />

		<xsl:param name="height" select="@height" />
		<xsl:param name="mapElement" select="@mapElement" />
		<xsl:param name="map" select="@map" />

		<div style="display:block">
			<div id="{$mapElement}" style="height:{$height}; width:100%; max-height:100%;" data-map-markers="{$data}" data-map-settings="{$settings}"></div>
		</div>
		<script type="text/javascript">
			$(document).ready(function() {
				var data = $('#<xsl:value-of select="$mapElement" />').data('map-markers');
				var mapSettings = $('#<xsl:value-of select="$mapElement" />').data('map-settings');
				console.log(data);
				console.log(mapSettings);

				if(mapSettings[0].demo === 'true') {
				    $('#<xsl:value-of select="$mapElement" />').vectorMap({
				        map: '<xsl:value-of select="$map" />',
				        normalizeFunction: 'linear',
				        backgroundColor: 'transparent',
				        regionStyle: {
				          initial: {
				            fill: '#f5f7fa',
				            stroke: '#cfdbe2',
				            "stroke-width": 0.5,
				            "stroke-opacity": 0.8
				          }
				        },
				        markers: data,
				        series: {
						    regions: [{
					            scale: {
					              Notice: '#008000',
					              Warning: '#FFA500',
					              Danger: '#FF0000'
					            },
					            attribute: 'fill',
					            values: {
					              "BR": 'Notice',
					              "ET": 'Notice',
					              "SO": 'Danger',
					              "SS": 'Warning',
					              "RU": 'Danger',
					              "CN": 'Warning',
					              "IR": 'Warning',
					              "IQ": 'Warning',
					              "SY": 'Danger',
					              "AU-WA": 'Warning',
					              "AU-NT": 'Danger'
					            },
					            legend: {
					              vertical: true,
					              title: 'Alert Level'
					            }
					          }]
				        },
				        onMarkerTipShow: function(event, label, index){
				        	switch(data[index].markertype) {
				        		case 'gdacs':
									label.html(
										'<div class="jvectormap-marker-label">' +
										'<p class="label-name gdacs">' + data[index].name + '</p>' +
										'<p class="label-content gdacs">' + data[index].description + '</p>' +
										((typeof data[index].link != 'undefined' <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> data[index].link != '') ? '<p class="label-content gdacs">Click for more details.</p>' : '') +
										'</div>'
									);
								break;

				        		case 'client':
									label.html(
										'<div class="jvectormap-marker-label">' +
										'<p class="label-name client">' + data[index].name + '</p>' +
										'<p class="label-content client">' + data[index].address + '</p>' +
										((typeof data[index].link != 'undefined' <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> data[index].link != '') ? '<p class="label-content gdacs">Click for more details.</p>' : '') +
										'</div>'
									);
								break;
							}
							console.log(data[index]);
						},
						onMarkerClick: function(event, index) {
				        	switch(data[index].markertype) {
				        		case 'gdacs':
									if(typeof data[index].link != 'undefined' <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> data[index].link != '') {
										console.log(data[index].link);
			                  			window.open(data[index].link, "_blank");
			                  		}
								break;

				        		case 'client':
									if(typeof mapSettings[0].clientUrl != 'undefined' <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> mapSettings[0].clientUrl != '') {
										console.log(mapSettings[0].clientUrl + data[index].client_id);
			                  			window.open(mapSettings[0].clientUrl + data[index].client_id, mapSettings[0].targetUrl);
			                  		}
								break;
							}
							console.log(data[index]);
	                  	}
				    });
				} else {
				    $('#<xsl:value-of select="$mapElement" />').vectorMap({
				        map: '<xsl:value-of select="$map" />',
				        normalizeFunction: 'linear',
				        backgroundColor: 'transparent',
				        regionStyle: {
				          initial: {
				            fill: '#f5f7fa',
				            stroke: '#cfdbe2',
				            "stroke-width": 0.5,
				            "stroke-opacity": 0.8
				          }
				        },
				        markers: data,
				        onMarkerTipShow: function(event, label, index){
				        	switch(data[index].markertype) {
				        		case 'gdacs':
									label.html(
										'<div class="jvectormap-marker-label">' +
										'<p class="label-name gdacs">' + data[index].name + '</p>' +
										'<p class="label-content gdacs">' + data[index].description + '</p>' +
										((typeof data[index].link != 'undefined' <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> data[index].link != '') ? '<p class="label-content gdacs">Click for more details.</p>' : '') +
										'</div>'
									);
								break;

				        		case 'client':
									label.html(
										'<div class="jvectormap-marker-label">' +
										'<p class="label-name client">' + data[index].name + '</p>' +
										'<p class="label-content client">' + data[index].address + '</p>' +
										((typeof data[index].link != 'undefined' <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> data[index].link != '') ? '<p class="label-content gdacs">Click for more details.</p>' : '') +
										'</div>'
									);
								break;
							}
							console.log(data[index]);
						},
						onMarkerClick: function(event, index) {
				        	switch(data[index].markertype) {
				        		case 'gdacs':
									if(typeof data[index].link != 'undefined' <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> data[index].link != '') {
										console.log(data[index].link);
			                  			window.open(data[index].link, "_blank");
			                  		}
								break;

				        		case 'client':
									if(typeof mapSettings[0].clientUrl != 'undefined' <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> mapSettings[0].clientUrl != '') {
										console.log(mapSettings[0].clientUrl + data[index].client_id);
			                  			window.open(mapSettings[0].clientUrl + data[index].client_id, mapSettings[0].targetUrl);
			                  		}
								break;
							}
							console.log(data[index]);
	                  	}
				    });
				}
			});
		</script>	

	</xsl:template>

	<xsl:template match="clientMap" mode="html">
		<xsl:call-template name="clientMap" />
	</xsl:template>
	
	<xsl:template name="clientMap">
		<!-- //Get the client map element -->
		<xsl:param name="settings" select="@settings" />
		<xsl:param name="data" select="/config/plugin[@plugin = 'dashboardContent'][@method = 'getClientMap']/clientCoordinates/@data" />

		<xsl:param name="height" select="@height" />

		<div style="display:block">
			<div id="data-vector-map" style="height:{$height}; width:100%; max-height:100%;" data-map-markers="{$data}" data-map-settings="{$settings}"></div>
		</div>

	</xsl:template>

</xsl:stylesheet>