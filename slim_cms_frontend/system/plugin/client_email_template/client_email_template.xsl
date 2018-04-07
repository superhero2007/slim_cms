<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings">
    
    <xsl:template match="/config/plugin[@plugin = 'client_email_template'][@method = 'renderClientTemplates']">
    <xsl:variable name="template" select="/config/plugin[@plugin = 'client_email_template']/@template" />
			<xsl:choose>
				<xsl:when test="$template = 'body-corporate-aircon-email'">
					<xsl:call-template name="body_corporate_aircon_email" />
				</xsl:when>
				<xsl:when test="$template = 'body-corporate-email'">
					<xsl:call-template name="body_corporate_email" />
				</xsl:when>
				<xsl:when test="$template = 'body-corporate-recycle-bin-email'">
					<xsl:call-template name="body_corporate_recycle_bin_email" />
				</xsl:when>
				<xsl:when test="$template = 'start-client-supply-chain-email'">
					<xsl:call-template name="start_client_supply_chain_email" />
				</xsl:when>
				<xsl:when test="$template = 'bronze-client-supply-chain-email'">
					<xsl:call-template name="bronze_client_supply_chain_email" />
				</xsl:when>
				<xsl:when test="$template = 'silver-client-supply-chain-email'">
					<xsl:call-template name="silver_client_supply_chain_email" />
				</xsl:when>
				<xsl:when test="$template = 'gold-client-supply-chain-email'">
					<xsl:call-template name="gold_client_supply_chain_email" />
				</xsl:when>
				<xsl:when test="$template = 'intro-staff-email'">
					<xsl:call-template name="intro_staff_email" />
				</xsl:when>
				<xsl:when test="$template = 'bronze-staff-email'">
					<xsl:call-template name="bronze_staff_email" />
				</xsl:when>
				<xsl:when test="$template = 'silver-staff-email'">
					<xsl:call-template name="silver_staff_email" />
				</xsl:when>
				<xsl:when test="$template = 'gold-staff-email'">
					<xsl:call-template name="gold_staff_email" />
				</xsl:when>
				<xsl:when test="$template = 'e-newsletter-email'">
					<xsl:call-template name="e_newsletter_email" />
				</xsl:when>
				<xsl:when test="$template = 'start-press-release-email'">
					<xsl:call-template name="start_press_release_email" />
				</xsl:when>
				<xsl:when test="$template = 'bronze-press-release-email'">
					<xsl:call-template name="bronze_press_release_email" />
				</xsl:when>
				<xsl:when test="$template = 'silver-press-release-email'">
					<xsl:call-template name="silver_press_release_email" />
				</xsl:when>
				<xsl:when test="$template = 'gold-press-release-email'">
					<xsl:call-template name="gold_press_release_email" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="listAvailableTemplates" />
				</xsl:otherwise>
			</xsl:choose>
    </xsl:template>
    
    <xsl:template name="listAvailableTemplates">
    </xsl:template>
    
    <xsl:include href="template/body_corporate_aircon_email.xsl" />
    <xsl:include href="template/body_corporate_email.xsl" />
    <xsl:include href="template/body_corporate_recycle_bin_email.xsl" />
    <xsl:include href="template/start_client_supply_chain_email.xsl" />
    <xsl:include href="template/bronze_client_supply_chain_email.xsl" />
    <xsl:include href="template/silver_client_supply_chain_email.xsl" />
    <xsl:include href="template/gold_client_supply_chain_email.xsl" />
    <xsl:include href="template/intro_staff_email.xsl" />
    <xsl:include href="template/bronze_staff_email.xsl" />
    <xsl:include href="template/silver_staff_email.xsl" />
    <xsl:include href="template/gold_staff_email.xsl" />
	<xsl:include href="template/e_newsletter_email.xsl" />
    <xsl:include href="template/start_press_release_email.xsl" />
    <xsl:include href="template/bronze_press_release_email.xsl" />
    <xsl:include href="template/silver_press_release_email.xsl" />
    <xsl:include href="template/gold_press_release_email.xsl" />
</xsl:stylesheet>