<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:template match="/config/plugin[@plugin = 'checklist'][@method = 'loadCertificate']">
		<div id="certificate">
			<div class="inner">
				<div class="frame-top"><div></div></div>
				<div class="frame">
					<div>
						<!--<p class="logo"><img src="/_images/certificate/logo.gif" alt="GreenBizCheck" /></p>-->
                        <p class="logo"><img src="/stamp/?cclid={report/@client_checklist_id}&amp;w=125" width="125" height="125" alt="Certification Stamp" class="stamp" /></p>
						<p>This is to certify</p>
						<p class="company"><xsl:value-of select="report/@company_name" disable-output-escaping="yes" /></p>
						<p>
							<xsl:text>Has Achieved GreenBizCheck Certification</xsl:text>
							<br />
							<xsl:text>on </xsl:text>
							<xsl:value-of select="report/@certified_date_long" />
						</p>
						<img src="/_images/certificate/signature-tony.gif" alt="Tony Hall's Signature" class="tony" />
						<img src="/_images/certificate/signature-nicholas.gif" alt="Nicholas Bernhardt's Signature" class="nicholas" />
                        <img src="/_images/certificate/arf.gif" alt="Australian Rainforest Foundation" class="stamp" />
                        <p class="footer-text"><xsl:text>Certificate and frame carbon compensated via the Australian Rainforest Foundation</xsl:text></p>
					</div>
				</div>
				<div class="frame-bottom"><div></div></div>
			</div>
		</div>
		<div id="certificate-caption"><a href="/certificate-pdf/{report/@client_checklist_id_md5}">Printable Assessment Certificate</a></div>
	</xsl:template>
	
</xsl:stylesheet>