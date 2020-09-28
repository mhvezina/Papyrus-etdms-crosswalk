<?xml version="1.0" encoding="UTF-8" ?>
<!-- 
https://raw.githubusercontent.com/gcwa/dspace-etdms11/master/dspace/config/crosswalks/oai/metadataFormats/etdms11.xsl
 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://www.lyncode.com/xoai" version="1.0">
	<xsl:output omit-xml-declaration="yes" method="xml" indent="yes"/>

<!-- Prefixe UdeM : elements maison -->
	<xsl:variable name="UdeM" select="doc:metadata/doc:element[@name = 'UdeM']"/>
	
	<xsl:variable name="dc" select="doc:metadata/doc:element[@name = 'dc']"/>
	<xsl:variable name="dcterms" select="doc:metadata/doc:element[@name = 'dcterms']"/>
	<xsl:variable name="thesis" select="doc:metadata/doc:element[@name = 'etd']"/>
	<xsl:variable name="bundles" select="doc:metadata/doc:element[@name = 'bundles']"/>

<!-- VARIABLES -->
<!-- variable est-ce une these ou un memoire electronique (i.e. "TME" = "EDT") -->
	<xsl:variable name="TME">
		<xsl:for-each select="$dc/doc:element[@name = 'type']/doc:element/doc:field[@name = 'value']" >
			<xsl:if test="contains(normalize-space(.), 'Thesis or Dissertation')">
				<xsl:value-of select="'true'"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>

<!-- MHV. Pour la grande majorité des theses, on a un dc.date.submitted et un dc.date.issued; pour l'instant (oct. 2016) on veut mettre ds l'element "date"
de etdms, la valeur de dc.date.submitted. Mais si on n'en a pas (de dc.date.submitted), on va mettre la valeur de dc.date.issued (en principe tjrs present).
Par ex. ceci est le cas des theses des collections retrospectives -->

	<xsl:variable name="dateSoumission"
		select="$dc/doc:element[@name = 'date']/doc:element[@name = 'submitted']/doc:element/doc:field[@name = 'value' and position() = 1]"/>
	<xsl:variable name="datePublication"
		select="$dc/doc:element[@name = 'date']/doc:element[@name = 'issued']/doc:element/doc:field[@name = 'value' and position() = 1]"/>	

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

<!-- MHV fevrier 2017 : cas special integration orcid id pour les auteurs; il y a toujours et seulement un seul auteur de theses ou memoire, donc je peux inférer que le ORCID s'applique à l'auteur -->
	<xsl:variable name="ORCIDAuteurThese" select="$UdeM/doc:element[@name = 'ORCIDAuteurThese']/doc:element/doc:field[@name = 'value' and position() = 1]"/>



<!-- MHV Fevrier 2020 : À la demande de BAC-LAC :Je change la localisation des schemas de "http://www.ndltd.org/standards/metadata/etdms/1-1/etdms11.xsd" à "http://www.ndltd.org/standards/metadata/etdms/1.1/etdms11.xsd" 
  Ceci causera une erreur de validation à coup sûr mais accomodera BAC-LAC. Voir ce fil de discussion au besoin : https://www.google.com/search?q=ndltd+1.1+1-1+problem&rlz=1C1GCEU_frCA880CA880&oq=ndltd+1.1+1-1+problem+&aqs=chrome..69i57j33.11767j0j7&sourceid=chrome&ie=UTF-8 -->

	<xsl:template match="/">
		<thesis xmlns="http://www.ndltd.org/standards/metadata/etdms/1.1/"
				xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xmlns:dc="http://purl.org/dc/elements/1.1/"
			xmlns:dcterms="http://purl.org/dc/terms/"
			xsi:schemaLocation="http://www.ndltd.org/standards/metadata/etdms/1.1/
			http://www.ndltd.org/standards/metadata/etdms/1.1/etdms11.xsd
			http://purl.org/dc/elements/1.1/
			http://www.ndltd.org/standards/metadata/etdms/1.1/etdmsdc.xsd
			http://purl.org/dc/terms/
			http://www.ndltd.org/standards/metadata/etdms/1.1/etdmsdcterms.xsd"
		>


			<xsl:for-each
				select="$dc/doc:element[@name = 'title']/doc:element/doc:field[@name = 'value']">
				<dc:title>
					<xsl:value-of select="."/>
				</dc:title>
			</xsl:for-each>


<!-- title alternative : pas  dans bordereau theses et mémoires (attention ça serait un dcterms:alternatif le cas echeant et non un dc-->

<!-- MHV fevrier 2017 : cas special integration orcid id pour les auteurs de TME; j'ajoute l'URI dans un attribut "resource" comme le dit le schéma etdms 1.1 -->
			<xsl:for-each
				select="$dc/doc:element[@name = 'contributor']/doc:element[@name = 'author']/doc:element/doc:field[@name = 'value']">
				<dc:creator>
				<xsl:if test="$ORCIDAuteurThese">
					<xsl:attribute name="resource">
						<xsl:value-of select="concat('https://orcid.org/', $ORCIDAuteurThese)"/>
					</xsl:attribute>
				</xsl:if>
					<xsl:value-of select="."/>
				</dc:creator>
			</xsl:for-each>

			<xsl:for-each
				select="$dc/doc:element[@name = 'subject']/doc:element/doc:field[@name = 'value']">
				<dc:subject>
					<xsl:value-of select="."/>
				</dc:subject>
			</xsl:for-each>


			<xsl:for-each
				select="$dc/doc:element[@name = 'subject']/doc:element[@name = 'other']/doc:element/doc:field[@name = 'value']">
				<dc:subject>
					<xsl:attribute name="scheme">
						<xsl:value-of select="'UMI (Proquest) Subject Codes'"/>
					</xsl:attribute>
					<xsl:value-of select="."/>
				</dc:subject>
			</xsl:for-each>


			<xsl:for-each
				select="$dcterms/doc:element[@name = 'abstract']/doc:element/doc:field[@name = 'value']">
				<dc:description>
					<xsl:attribute name="role">
						<xsl:text>abstract</xsl:text>
					</xsl:attribute>
					<xsl:value-of select="."/>
				</dc:description>
			</xsl:for-each>

			<xsl:for-each
				select="$dcterms/doc:element[@name = 'description']/doc:element/doc:field[@name = 'value']">
				<dc:description>
					<xsl:attribute name="role">
						<xsl:text>note</xsl:text>
					</xsl:attribute>
					<xsl:value-of select="."/>
				</dc:description>
			</xsl:for-each>

<!-- Nouveauté 2019-2020 : BAC-LAC demande une chaine de caractères standardisées pour l'élément publisher. Je crois deviner
que ceci remplace le Theses Canada Number de la forme TC-QMU-.... Donc plutôt que de prendre la valeur de l'élément degree.grantor, qui porte parfois la nom de l'université suivi de celui de la faculté,
je (MHV) vais standardiser une valeur -->

<!--
			<dc:publisher country="Canada">
				<xsl:value-of select="$thesis/doc:element[@name = 'degree']/doc:element[@name = 'grantor']/doc:element/doc:field[@name = 'value']"/>
			</dc:publisher>
-->
			
			<dc:publisher country="Canada">Université de Montréal</dc:publisher>			
			
			<xsl:for-each
				select="$dc/doc:element[@name = 'contributor']/doc:element[@name = 'advisor']/doc:element/doc:field[@name = 'value']">
				<dc:contributor>
					<xsl:attribute name="role">
						<xsl:text>directeur(trice) de recherche/advisor</xsl:text>
					</xsl:attribute>
					<xsl:value-of select="."/>
				</dc:contributor>
			</xsl:for-each>
<!-- MHV Feb 2020 : changement suite au retrait de dc.contributor.editor 
			<xsl:for-each
				select="$dc/doc:element[@name = 'contributor']/doc:element[@name != 'author' and @name != 'advisor']/doc:element/doc:field[@name = 'value']">
				<dc:contributor>
					<xsl:attribute name="role">
						<xsl:value-of select="../../@name"/>
					</xsl:attribute>
					<xsl:value-of select="."/>
				</dc:contributor>
			</xsl:for-each>
			
			-->

			<xsl:for-each
				select="$dc/doc:element[@name = 'contributor']/doc:element[@name != 'author' and @name != 'advisor']/doc:element/doc:field[@name = 'value']">
				<dc:contributor>
					<xsl:value-of select="."/>
				</dc:contributor>
			</xsl:for-each>



			<dc:date>
  			<xsl:value-of select="$laDate"/>
			</dc:date>


<!-- tiré de la norme etdms 1.1 : This field is used to distinguish the resource from works in other genres and to identify the types of content included in
the resource. The string "Electronic Thesis or Dissertation" is recommended as one of the repeatable values for this element. -->
			<xsl:for-each
				select="$dc/doc:element[@name = 'type']/doc:element/doc:field[@name = 'value']">
				<dc:type>
					<xsl:attribute name="xml:lang">
						<xsl:value-of select="'fr'"/>
					</xsl:attribute>
					<xsl:choose>
					<xsl:when test="$TME = 'true'">
						<xsl:value-of select="'Thèse ou mémoire numérique'"	/>
					</xsl:when>
					<xsl:otherwise>

												<xsl:choose>
												<xsl:when
													test="contains('/', $dc/doc:element[@name = 'type']/doc:element/doc:field[@name = 'value']/text())">
													<xsl:value-of
														select="normalize-space(substring-before($dc/doc:element[@name = 'type']/doc:element/doc:field[@name = 'value']/text(), '/'))"
													/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of
														select="normalize-space($dc/doc:element[@name = 'type']/doc:element/doc:field[@name = 'value']/text())"
													/>
												</xsl:otherwise>
												</xsl:choose>

					</xsl:otherwise>
					</xsl:choose>
				</dc:type>

				<dc:type>
					<xsl:attribute name="xml:lang">
						<xsl:value-of select="'en'"/>
					</xsl:attribute>
					<xsl:choose>
					<xsl:when test="$TME = 'true'">
						<xsl:value-of select="'Electronic Thesis or Dissertation'"	/>
					</xsl:when>
					<xsl:otherwise>

												<xsl:choose>
												<xsl:when
													test="contains('/', $dc/doc:element[@name = 'type']/doc:element/doc:field[@name = 'value']/text())">
													<xsl:value-of
														select="normalize-space(substring-after($dc/doc:element[@name = 'type']/doc:element/doc:field[@name = 'value']/text(), '/'))"
													/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of
														select="normalize-space($dc/doc:element[@name = 'type']/doc:element/doc:field[@name = 'value']/text())"
													/>
												</xsl:otherwise>
												</xsl:choose>


					</xsl:otherwise>
					</xsl:choose>
				</dc:type>
			</xsl:for-each>

			<!-- Nouveauté 2019-2020 : Nouvelle exigence de BAC-LAC : l'élément identifier doit comporter l’URL
				des versions intégrales des documents dans le dépôt et, facultativement, de la notice du dépôt.
				Aucune espace n’est autorisée dans les URL. Les autres types d’identificateur ne seront pas téléchargés -->

			<xsl:for-each
				select="$dc/doc:element[@name = 'identifier']/doc:element/doc:element/doc:field[@name = 'value']">
				<dc:identifier>
					<xsl:value-of select="."/>
				</dc:identifier>
			</xsl:for-each>

			<xsl:if test="$TME = 'true'">
			<xsl:for-each select="$bundles/doc:element[@name = 'bundle' and doc:field = 'ORIGINAL']/doc:element[@name = 'bitstreams']/doc:element[@name = 'bitstream']/doc:field[@name = 'url']">
				<!-- url du bitstream dans papyrus ; encore demandé par BAC-LAC. Nouveauté 2019-2020 : BAC-LAC va maintenant récolter tous les fichiers de la thèse -->
				<dc:identifier>
					<xsl:value-of select="."/>
				</dc:identifier>
			</xsl:for-each>
			
		<!-- Nouveauté 2019-2020 : BAC-LAC ne semble plus exiger cet élément donc je (MHV) le retire -->
		   <!-- Ça va être toujours la chaîne à partir de la position 27, : http://hdl.handle.net/1973/10165 -->
		   <!-- <dc:identifier scheme="Theses Canada Number">TC-QMU-<xsl:value-of select="substring($dc/doc:element[@name = 'identifier']/doc:element/doc:element/doc:field[@name = 'value' and contains(., 'hdl.handle.net')], 28)"/></dc:identifier> -->

			</xsl:if>


	<!-- Nouveauté 2019-2020 : BAC-LAC ne demande plus cet élément mais je le conserve pour compatibilité ETDMS -->
		<!-- nombre de formats contenu ds ORIGINAL -->
		<xsl:variable name="nombreFormats"
			select="count($bundles/doc:element[@name = 'bundle']/doc:field[@name = 'name' and text() = 'ORIGINAL']/./../doc:element[@name = 'bitstreams']/doc:element[@name = 'bitstream' and doc:field[@name = 'format']])"/>


		<xsl:choose>
			<xsl:when test="($nombreFormats and $nombreFormats > 1)">
				<dc:format>
				<xsl:for-each
									select="$bundles/doc:element[@name = 'bundle']/doc:field[@name = 'name' and text() = 'ORIGINAL']">
									<xsl:for-each
										select="./../doc:element[@name = 'bitstreams']/doc:element[@name = 'bitstream' and doc:field[@name = 'format']]">
										<xsl:value-of
											select="./doc:field[@name = 'format']"/>
										<xsl:choose>
											<xsl:when test="position() = last() - 1"> et </xsl:when>
											<xsl:when test="position() != last()">, </xsl:when>
										</xsl:choose>
									</xsl:for-each>
								</xsl:for-each>
				</dc:format>
			</xsl:when>
			<xsl:otherwise> </xsl:otherwise>
		</xsl:choose>


			<xsl:for-each select="$dcterms/doc:element[@name = 'language']/doc:element/doc:field[@name = 'value']">
	<dc:language>
					<xsl:attribute name="xsi:type">
						<xsl:value-of select="'dcterms:ISO639-3'"/>
					</xsl:attribute>
					<xsl:value-of select="."/>
</dc:language>
			</xsl:for-each>






<xsl:if test="$TME = 'true'">

<!-- 
			<xsl:if test="$TME = 'true'">
			<xsl:for-each select="$bundles/doc:element[@name = 'bundle' and doc:field = 'ORIGINAL']/doc:element[@name = 'bitstreams']/doc:element[@name = 'bitstream']/doc:field[@name = 'format']"
					/>
				<dc:format>
					<xsl:value-of select="."/>
				</dc:format>
			</xsl:for-each>
-->


<!-- Nouveauté 2019-2020 : La norme ETDMS 1.1 indique une valeur numérique pour l'accès au document mais BAC-LAC donne encore
		la définition de dc.rights de ETDMS 1.0 pour ses nouvelles exigences. Je vais donc ajuster en conséquence et mettre une mention de droits a l'auteur.e -->
	<!-- etdms 1.1 : Information about rights
            held in and over the resource. Typically, this
            describes the conditions under which the work may be
            distributed, reproduced, etc., how these conditions may
            change over time, and whom to contact regarding the
            copyright of the work.<br><br><strong>Three levels are valid:<br><br></strong>
           <ul><li>0 Not publicly accessible</li><li>1 Limited public access</li><li>2 Publicly accessible</li></ul> -->
	<!-- <dc:rights>2</dc:rights> -->

	<dc:rights>
			<xsl:variable name="auteur">
				<xsl:call-template name="obtenirNomAuteur">
					<xsl:with-param name="auteur"
						select="$dc/doc:element[@name = 'contributor']/doc:element[@name = 'author']/doc:element/doc:field[@name = 'value']"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="annee"
						select="substring($laDate, 0, 5)"/>
				<xsl:value-of select="concat('© ', $auteur, ', ', $annee)"/>
	</dc:rights>





			<degree>
				<xsl:for-each
					select="$thesis/doc:element[@name = 'degree']/doc:element[@name = 'name']/doc:element/doc:field[@name = 'value']">
					<name><xsl:value-of select="."/></name>
				</xsl:for-each>

<!-- etdms 1.1 : Level of education
            associated with the document.<br><br><strong>Three levels are valid:</strong><br><br>
<ul><li>0 Undergraduate (pre-masters)</li><li>1 Masters (pre-doctoral)</li><li>2 Doctoral (includes post-doctoral)<br></li></ul> -->




									
								<xsl:variable name="level"
				select="$thesis/doc:element[@name = 'degree']/doc:element[@name = 'level']/doc:element/doc:field[@name = 'value' and descendant::text()[normalize-space()]]"/>
											<xsl:choose>
												<xsl:when test="contains( $level,'Maîtrise')">
													<level><xsl:value-of select="'1'"/></level>
												</xsl:when>
												<xsl:when
													test="contains( $level, 'Doctorat')">
													<level><xsl:value-of select="'2'"/></level>
												</xsl:when>
												<xsl:otherwise>
												</xsl:otherwise>
											</xsl:choose>
									
<!--
				<xsl:for-each
					select="$thesis/doc:element[@name = 'degree']/doc:element[@name = 'level']/doc:element/doc:field[@name = 'value']">
				<level>
					<xsl:attribute name="xml:lang">
						<xsl:value-of select="'fr'"/>
					</xsl:attribute>
						<xsl:value-of select="normalize-space(substring-before($thesis/doc:element[@name = 'degree']/doc:element[@name = 'level']/doc:element/doc:field[@name = 'value']/text(), '/'))"	/>
				</level>

				<level>
					<xsl:attribute name="xml:lang">
						<xsl:value-of select="'en'"/>
					</xsl:attribute>
						<xsl:value-of select="normalize-space(substring-after($thesis/doc:element[@name = 'degree']/doc:element[@name = 'level']/doc:element/doc:field[@name = 'value']/text(), '/'))"	/>
				</level>
				</xsl:for-each>
-->



				<xsl:for-each
					select="$thesis/doc:element[@name = 'degree']/doc:element[@name = 'discipline']/doc:element/doc:field[@name = 'value']">
					<discipline>
					 <xsl:attribute name="xml:lang">
						<xsl:value-of select="'fr'"/>
					</xsl:attribute>
					<xsl:value-of select="."/></discipline>
				</xsl:for-each>
				
				<xsl:for-each
					select="$thesis/doc:element[@name = 'degree']/doc:element[@name = 'grantor']/doc:element/doc:field[@name = 'value']">
					<grantor>
					<xsl:attribute name="xml:lang">
						<xsl:value-of select="'fr'"/>
					</xsl:attribute>
						<xsl:value-of select="."/></grantor>
				</xsl:for-each>
			</degree>

</xsl:if>




		</thesis>
	</xsl:template>
	

	
	<xsl:template name="obtenirNomAuteur">
		<xsl:param name="auteur"/>
		<xsl:variable name="nomFamille" select="substring-before($auteur, ',')"/>
		<xsl:variable name="prenom" select="substring-after($auteur, ', ')"/>
		<xsl:value-of select="concat($prenom, ' ', $nomFamille)"/>
	</xsl:template>
</xsl:stylesheet>
