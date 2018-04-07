<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:output
		method="xml"
		version="1.0"
		encoding="UTF-8"
		omit-xml-declaration="yes"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
		indent="yes"
		media-type="text/html" />
		
	<xsl:template match="/subject">2015 Social Enterprise Awards Entry Confirmation</xsl:template>
	
	<xsl:param name="client_checklist_id" />
		
	<xsl:template match="/config">
		<html>
			<body>	
				<p>Thank you for your entry to the 2015 Social Enterprise Awards.</p>
				<p>You can download a copy of your application <a href="http://socialenterpriseawards.greenbizcheck.com/members/report-pdf/{$client_checklist_id}?report_type=full">here</a>.</p>
				<p>Shortlisting of finalists will take place in April, with winners announced at an Awards ceremony in early June.</p> 
				<p>In the meantime, stay up to date with the latest Awards news at <a href="www.socialenterpriseawards.com.au">www.socialenterpriseawards.com.au</a>.</p>
			</body>
		</html>
	</xsl:template>
	
</xsl:stylesheet>
