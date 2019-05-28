<?xml version="1.0" encoding="UTF-8" ?>
<!-- 


    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/
	Developed by DSpace @ Lyncode <dspace@lyncode.com>

 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://www.lyncode.com/xoai" version="1.0">
	<xsl:output omit-xml-declaration="yes" method="xml" indent="yes"/>

	<xsl:variable name="UdeM" select="doc:metadata/doc:element[@name = 'UdeM']"/>
	<xsl:variable name="dc" select="doc:metadata/doc:element[@name = 'dc']"/>
	<xsl:variable name="etdms"
		select="doc:metadata/doc:element[@name = 'etd']/doc:element[@name = 'degree']"/>
	<xsl:variable name="bundles" select="doc:metadata/doc:element[@name = 'bundles']"/>
	<xsl:variable name="formatETD">
		<xsl:for-each select="$dc/doc:element[@name = 'type']/doc:element/doc:field[@name = 'value']" >
			<xsl:if test="contains(normalize-space(.), 'Thesis or Dissertation')">
				<xsl:value-of select="'true'"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>

	<xsl:variable name="dateSoumission"
		select="$dc/doc:element[@name = 'date']/doc:element[@name = 'submitted']/doc:element/doc:field[@name = 'value' and position() = 1]"/>
	<xsl:variable name="datePublication"
		select="$dc/doc:element[@name = 'date']/doc:element[@name = 'issued']/doc:element/doc:field[@name = 'value' and position() = 1]"/>	

<!-- MHV Pour la grande majorité des theses, on a un dc.date.submitted et un dc.date.issued; pour l'instant (oct. 2016) on veut mettre ds l'element "date"
de etdms, la valeur de dc.date.submitted. Mais si on n'en a pas (de dc.date.submitted), on va mettre la valeur de dc.date.issued (en principe tjrs present). Par ex. ceci est le cas des 
theses des coll retrospectives -->

	<xsl:variable name="laDate">
			<xsl:choose>
				<xsl:when test="$dateSoumission and string-length($dateSoumission) > 0">
					<xsl:value-of select="substring($dateSoumission,0, 11)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="string-length($datePublication) > 0 and string-length($dateSoumission) = 0">
							<xsl:value-of select="substring($datePublication, 1, 4)"
							/></xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
	</xsl:variable>

<!-- MHV fevrier 2017 : cas special integration orcid id pour les auteurs; il y a toujours et seuelemnt un seul auteur de theses ou memoire -->
	<xsl:variable name="ORCIDAuteurThese" select="$UdeM/doc:element[@name = 'ORCIDAuteurThese']/doc:element/doc:field[@name = 'value' and position() = 1]"/>





<!-- MHV 18 oct. 2016 - je change le Schema location de etdms de 
http://www.ndltd.org/standards/metadata/etdms/1.0/etdms.xsd
a
http://www.ndltd.org/standards/metadata/etdms/1-0/etdms.xsd -->
	<xsl:template match="/">
		<thesis xmlns="http://www.ndltd.org/standards/metadata/etdms/1.0/"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.ndltd.org/standards/metadata/etdms/1-0/ http://www.ndltd.org/standards/metadata/etdms/1-0/etdms.xsd">

<!--			<xsl:call-template name="debogage"/>
-->
			<xsl:for-each
				select="$dc/doc:element[@name = 'title']/doc:element/doc:field[@name = 'value']">
				<title>
					<xsl:value-of select="."/>
				</title>
			</xsl:for-each>


<!-- MHV fevrier 2017 : cas special integration orcid id pour les auteurs de TME; j'ajoute l'URI dans un attribut "resource" comme le dit le schéma etdms -->
			<xsl:for-each
				select="$dc/doc:element[@name = 'contributor']/doc:element[@name = 'author']/doc:element/doc:field[@name = 'value']">
				<creator>
				<xsl:if test="$ORCIDAuteurThese">
					<xsl:attribute name="resource">
						<xsl:value-of select="concat('https://orcid.org/', $ORCIDAuteurThese)"/>
					</xsl:attribute>
				</xsl:if>
					<xsl:value-of select="."/>
				</creator>
			</xsl:for-each>

			<xsl:for-each
				select="$dc/doc:element[@name = 'subject']//doc:element/doc:field[@name = 'value']">
				<subject>
					<xsl:value-of select="."/>
				</subject>
			</xsl:for-each>

			<xsl:for-each
				select="$dc/doc:element[@name = 'description']/doc:element[@name = 'abstract']/doc:element/doc:field[@name = 'value']">
				<description>
					<xsl:value-of select="."/>
				</description>
			</xsl:for-each>


			<xsl:for-each
				select="$dc/doc:element[@name = 'description']/doc:element/doc:field[@name = 'value']">
				<description>
					<xsl:attribute name="role">
						<xsl:text>note</xsl:text>
					</xsl:attribute>
					<xsl:value-of select="."/>
				</description>
			</xsl:for-each>





			<publisher>
				<xsl:value-of
					select="$etdms/doc:element[@name = 'grantor']/doc:element/doc:field[@name = 'value']"
				/>
			</publisher>

			<xsl:for-each
				select="$dc/doc:element[@name = 'contributor']/doc:element[@name = 'advisor']/doc:element/doc:field[@name = 'value']">
				<contributor>
					<xsl:attribute name="role">
						<xsl:text>Directeur(trice) de recherche/Advisor</xsl:text>
					</xsl:attribute>
					<xsl:value-of select="."/>
				</contributor>
			</xsl:for-each>

			<xsl:for-each
				select="$dc/doc:element[@name = 'contributor']/doc:element[@name != 'author' and @name != 'advisor']/doc:element/doc:field[@name = 'value']">
				<contributor>
					<xsl:attribute name="role">
						<xsl:value-of select="../../@name"/>
					</xsl:attribute>
					<xsl:value-of select="."/>
				</contributor>
			</xsl:for-each>
<!--
			<xsl:for-each
				select="$dc/doc:element[@name = 'date']/doc:element[@name = 'submitted']/doc:element/doc:field[@name = 'value']">
				<date>
					<xsl:value-of select="substring(., 0, 11)"/>
				</date>
			</xsl:for-each>
-->

			<date>
  			<xsl:value-of select="$laDate"/>
			</date>

			<xsl:for-each
				select="$dc/doc:element[@name = 'type']/doc:element/doc:field[@name = 'value']">
				<type>
					<xsl:value-of select="."/>
				</type>
			</xsl:for-each>

			<xsl:for-each
				select="$dc/doc:element[@name = 'identifier']/doc:element/doc:element/doc:field[@name = 'value']">
				<identifier>
					<xsl:value-of select="."/>
				</identifier>
			</xsl:for-each>

			<xsl:if test="$formatETD = 'true'">
				
				
				<!-- url du bitstream dans papyrus -->
				<identifier>
					<xsl:value-of
						select="$bundles/doc:element[@name = 'bundle' and doc:field = 'ORIGINAL']/doc:element[@name = 'bitstreams']/doc:element[@name = 'bitstream']/doc:field[@name = 'url']"
					/>
				</identifier>
				<format>application/pdf</format>
				<xsl:call-template name="getTCIdentifier">
					<xsl:with-param name="handleUri"
						select="$dc/doc:element[@name = 'identifier']/doc:element/doc:element/doc:field[@name = 'value' and contains(., 'hdl.handle.net')]"
					/>
				</xsl:call-template>
				<xsl:call-template name="getRights">
					<xsl:with-param name="dc" select="$dc"/>
				</xsl:call-template>

				<xsl:call-template name="getEtdmsData">
					<xsl:with-param name="etdms" select="$etdms"/>
				</xsl:call-template>
			</xsl:if>


			<xsl:call-template name="getLanguage">
				<xsl:with-param name="lang"
					select="$dc/doc:element[@name = 'language']/doc:element[@name = 'iso']/doc:element/doc:field[@name = 'value']"
				/>
			</xsl:call-template>

		</thesis>
	</xsl:template>

	<xsl:template name="debogage">
		<debogage>
			<formatETD>
				<xsl:value-of select="$formatETD"/>
			</formatETD>
			<xsl:copy-of select="@* | node()"> </xsl:copy-of>
		</debogage>

	</xsl:template>

	<xsl:template name="getTCIdentifier">
		<xsl:param name="handleUri"/>
		<!-- Ça va être toujours la chaîne à partir de la position 27, soit en dev, soit en prod.
			http://hdl.handle.net/1973/10165 -->
		<identifier xmlns="http://www.ndltd.org/standards/metadata/etdms/1.0/">TC-QMU-<xsl:value-of
				select="substring($handleUri, 28)"/></identifier>
	</xsl:template>

	<xsl:template name="getRights">
		<xsl:param name="dc"/>
		<xsl:variable name="auteur">
			<xsl:call-template name="getAuthorName">
				<xsl:with-param name="auteur"
					select="$dc/doc:element[@name = 'contributor']/doc:element[@name = 'author']/doc:element/doc:field[@name = 'value']"
				/>
			</xsl:call-template>
		</xsl:variable>
		
<!--		
		<xsl:variable name="annee"
			select="substring($dc/doc:element[@name = 'date']/doc:element[@name = 'submitted']/doc:element/doc:field[@name = 'value'], 0, 5)"/>
-->

			<xsl:variable name="annee"
					select="substring($laDate, 0, 5)"/>
			
		<rights xmlns="http://www.ndltd.org/standards/metadata/etdms/1.0/">
			<xsl:value-of select="concat('© ', $auteur, ', ', $annee)"/>
		</rights>
	</xsl:template>

	<xsl:template name="getAuthorName">
		<xsl:param name="auteur"/>
		<xsl:variable name="nomFamille" select="substring-before($auteur, ',')"/>
		<xsl:variable name="prenom" select="substring-after($auteur, ', ')"/>
		<xsl:value-of select="concat($prenom, ' ', $nomFamille)"/>
	</xsl:template>

	<xsl:template name="getLanguage">
		<xsl:param name="lang"/>
		<language xmlns="http://www.ndltd.org/standards/metadata/etdms/1.0/">
			<xsl:choose>
				<xsl:when test="$lang = 'fr'">fre</xsl:when>
				<xsl:when test="$lang = 'en'">eng</xsl:when>
				<xsl:when test="$lang = 'es'">spa</xsl:when>
				<xsl:when test="$lang = 'pt'">por</xsl:when>
				<xsl:when test="$lang = 'de'">ger</xsl:when>
				<xsl:when test="$lang = 'it'">ita</xsl:when>
				<xsl:when test="$lang = 'la'">lat</xsl:when>
				<xsl:when test="$lang = 'el'">gre</xsl:when>
				<xsl:when test="$lang = 'ar'">ara</xsl:when>
				<xsl:when test="$lang = 'zh'">chi</xsl:when>
				<xsl:when test="$lang = 'other'">mis</xsl:when>
				<xsl:when test="string-length($lang) > 1">mis</xsl:when>
				<xsl:otherwise>und</xsl:otherwise>
			</xsl:choose>
		</language>
	</xsl:template>

	<xsl:template name="getEtdmsData">
		<xsl:param name="etdms"/>
		<xsl:if test="$etdms">
			<degree xmlns="http://www.ndltd.org/standards/metadata/etdms/1.0/">
				<xsl:for-each
					select="$etdms/doc:element[@name = 'name']/doc:element/doc:field[@name = 'value']">
					<name>
						<xsl:value-of select="."/>
					</name>
				</xsl:for-each>
				<xsl:for-each
					select="$etdms/doc:element[@name = 'level']/doc:element/doc:field[@name = 'value']">
					<level>
						<xsl:value-of select="."/>
					</level>
				</xsl:for-each>
				<xsl:for-each
					select="$etdms/doc:element[@name = 'discipline']/doc:element/doc:field[@name = 'value']">
					<discipline>
						<xsl:value-of select="."/>
					</discipline>
				</xsl:for-each>
				<xsl:for-each
					select="$etdms/doc:element[@name = 'discipline']/doc:element/doc:element/doc:field[@name = 'value']">
					<discipline>
						<xsl:value-of select="."/>
					</discipline>
				</xsl:for-each>
				<xsl:for-each
					select="$etdms/doc:element[@name = 'grantor']/doc:element/doc:field[@name = 'value']">
					<grantor>
						<xsl:value-of select="."/>
					</grantor>
				</xsl:for-each>
			</degree>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
