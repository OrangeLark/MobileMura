<!---

This file is part of muraFW1
(c) Stephen J. Withington, Jr. | www.stephenwithington.com

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

		Document:	plugin/plugin.cfc
		Author:		Steve Withington | www.stephenwithington.com
		Modified:	2011.02.04

--->
<cfcomponent output="false" extends="mura.plugin.plugincfc">

	<cfset variables.config = '' />

	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="config"  type="any" default="" />
		<cfscript>
			variables.config = arguments.config;
		</cfscript>
	</cffunction>
	
	<cffunction name="install" returntype="void" access="public" output="false">
		<cfset updateSiteExtensions("Page") />
		<cfset updateSiteExtensions("Portal") />
		<cfset updateSiteExtensions("Calendar") />
		<cfset updateSiteExtensions("Gallery") />
		<cfset updateDataSiteExtensions("Custom") />
		<cfset super.install() />
	</cffunction>
	
	<cffunction name="update" returntype="void" access="public" output="false">		
		<cfset updateSiteExtensions("Page") />
		<cfset updateSiteExtensions("Portal") />
		<cfset updateSiteExtensions("Calendar") />
		<cfset updateSiteExtensions("Gallery") />
		<cfset updateDataSiteExtensions("Custom") />
		<cfset super.update() />
	</cffunction>
	
	<cffunction name="delete" returntype="void" access="public" output="false">
		<cfset deleteSiteExtensions("Page") />
		<cfset deleteSiteExtensions("Portal") />
		<cfset deleteSiteExtensions("Calendar") />
		<cfset deleteSiteExtensions("Gallery") />
		<cfset deleteDataSiteExtensions("Custom") />
		<cfset super.delete() />
	</cffunction>

	<cffunction name="updateSiteExtensions" returntype="void" access="private" output="false">
		<cfargument name="useType" type="string" required="true">

		<cfset var siteStruct = getBean("settingsManager").getSites()>
		<cfset var siteID = "">

		<cfloop collection="#siteStruct#" item="siteID">
			<cfset checkExtension(siteID,arguments.useType)>
		</cfloop>
	</cffunction>

	<cffunction name="deleteSiteExtensions" returntype="void" access="private" output="false">
		<cfargument name="useType" type="string" required="true">

		<cfset var siteStruct = getBean("settingsManager").getSites()>
		<cfset var siteID = "">

		<cfloop collection="#siteStruct#" item="siteID">
			<cfset deleteExtension(siteID,arguments.useType)>
		</cfloop>
	</cffunction>

	<cffunction name="checkExtension" returntype="void" access="private" output="false">
		<cfargument name="siteID" type="string" required="true">
		<cfargument name="useType" type="string" required="true">

		<cfset var qExtensions = application.classExtensionManager.getSubTypes(arguments.siteID)>
		<cfset var sExtension = application.classExtensionManager.getSubTypeByName(arguments.useType,"Default",arguments.siteID)>
		<cfset var qExtendSets = sExtension.getSetsQuery()>

		<cfif not qExtensions.recordCount>
			<cfset addExtension(arguments.siteID,arguments.useType)>
			<cfreturn>
		</cfif>

		<cfquery dbtype="query" name="selectDefaultExtensionType">
			SELECT
				subTypeID
			FROM
				qExtensions
			WHERE
				type = '#arguments.useType#'
		</cfquery>

		<cfif not selectDefaultExtensionType.recordCount>
			<cfset addExtension(arguments.siteID,arguments.useType)>
			<cfreturn>
		</cfif>

		<cfquery dbtype="query" name="selectGSMExtendSet">
			SELECT
				extendSetID
			FROM
				qExtendSets
			WHERE
				name = 'MobileMura'
		</cfquery>
		
		<cfif not selectGSMExtendSet.recordCount>
			<cfset addExtendSet(arguments.siteID,selectDefaultExtensionType.subTypeID)>
			<cfreturn>
		</cfif>
		
		<cfset checkAttributes(arguments.siteID,selectDefaultExtensionType.subTypeID,selectGSMExtendSet.extendSetID)>
	</cffunction>

	<cffunction name="deleteExtension" returntype="void" access="private" output="false">
		<cfargument name="siteID" type="string" required="true">
		<cfargument name="useType" type="string" required="true">

		<cfset var sExtension = application.classExtensionManager.getSubTypeByName(arguments.useType,"Default",arguments.siteID)>
		<cfset var sExtendSet = application.classExtensionManager.getSubTypeBean().getExtendSetBean()>
		<cfset var qExtendSets = sExtension.getSetsQuery()>

		<cfquery dbtype="query" name="selectGSMExtendSetForDelete">
			SELECT
				extendSetID
			FROM
				qExtendSets
			WHERE
				name = 'MobileMura'
		</cfquery>

		<cfoutput query="selectGSMExtendSetForDelete">
			<cfset sExtendSet = sExtension.loadSet( extendSetID ) />
			<cfset sExtendSet.delete()>
		</cfoutput>
	</cffunction>

	<cffunction name="addExtension" returntype="void" access="private" output="false">
		<cfargument name="siteID" type="string" required="true">
		<cfargument name="useType" type="string" required="true">
		<cfargument name="subTypeID" type="string" required="false" default="#createUUID()#">

		<cfset var newExtensionID = createUUID()>
		<cfset var sExtension = application.classExtensionManager.getSubTypeByID(arguments.subTypeID)>

		<cfset sExtension.setType(arguments.useType)>
		<cfset sExtension.setSubType("Default")>
		<cfset sExtension.setIsActive(1)>
		<cfset sExtension.setBaseKeyField("contentHistID")>
		<cfset sExtension.setBaseTable("tcontent")>
		<cfset sExtension.setDataTable("tclassextenddata")>
		<cfset sExtension.setSiteID(arguments.siteID)>
		<cfset sExtension.save()>

		<cfset addExtendSet(arguments.siteID,arguments.subTypeID)>
	</cffunction>

	<cffunction name="addExtendSet" returntype="void" access="private" output="false">
		<cfargument name="siteID" type="string" required="true">
		<cfargument name="subTypeID" required="false" type="string" default="#createUUID()#">

		<cfset var newExtendSetID = createUUID()>
		<cfset var sExtendSet = application.classExtensionManager.getSubTypeBean().getExtendSetBean()>
		<cfset var attName = "">

		<cfset sExtendSet.setSubTypeID(arguments.subTypeID)>
		<cfset sExtendSet.setExtendSetID(newExtendSetID)>
		<cfset sExtendSet.setName("MobileMura")>
		<cfset sExtendSet.setOrderNo(0)>
		<cfset sExtendSet.setIsActive(1)>
		<cfset sExtendSet.setSiteID(arguments.siteID)>
		<cfset sExtendSet.setContainer("Custom")>
		<cfset sExtendSet.save()>

		<cfset checkAttributes(arguments.siteID,arguments.subTypeID,newExtendSetID)>
	</cffunction>

	<cffunction name="checkAttributes" returntype="void" access="private" output="false">
		<cfargument name="siteID" type="string" required="true">
		<cfargument name="subTypeID" type="string" required="true">
		<cfargument name="extendSetID" type="string" required="true">

		<cfset var sExtension = application.classExtensionManager.getSubTypeByID(arguments.subTypeID)>
		<cfset var sExtendSet = sExtension.loadSet( arguments.extendSetID ) />
		<cfset var qExtendAtts = sExtendSet.getAttributesQuery() />
		
		<cfloop list="mobiletemplate" index="attName">
			<cfquery dbtype="query" name="selectGSMExtendSetAttributes">
				SELECT
					attributeID
				FROM
					qExtendAtts
				WHERE
					name = '#attName#'
			</cfquery>

			<cfif not selectGSMExtendSetAttributes.recordCount>
				<cfset addAttribute( arguments.siteID,attName,arguments.extendSetID )>
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="addAttribute" returntype="void" access="private" output="false">
		<cfargument name="siteID" type="string" required="true">
		<cfargument name="useName" type="string" required="true">
		<cfargument name="extendSetID" required="true">

		<cfset var sAttribute = application.classExtensionManager.getSubTypeBean().getExtendSetBean().getattributeBean()>
		<cfset var templateslist = "" />

		<cfset sAttribute.setExtendSetID(arguments.extendSetID)>
		<cfset sAttribute.setSiteID(arguments.siteID)>

		<cfswitch expression="#arguments.useName#">
			<cfcase value="mobiletemplate">
				<cfset sAttribute.setName("mobiletemplate")>
				<cfset sAttribute.setLabel("Mobile layout template")>
				<cfset sAttribute.setHint("Set the mobile layout template")>
				<cfset sAttribute.setType("SelectBox")>
				<cfset sAttribute.setDefaultValue("")>
				<cfset sAttribute.setOptionList("")>
				<cfset sAttribute.setOptionLabelList("")>
				<cfset sAttribute.setOrderNo(1)>
			</cfcase>
		</cfswitch>
		<cfset sAttribute.save()>
	</cffunction>

	<!--- Data --->
	<cffunction name="updateDataSiteExtensions" returntype="void" access="private" output="false">
		<cfargument name="useType" type="string" required="true">

		<cfset var siteStruct = getBean("settingsManager").getSites()>
		<cfset var siteID = "">

		<cfloop collection="#siteStruct#" item="siteID">
			<cfset checkDataExtension(siteID,arguments.useType)>
		</cfloop>
	</cffunction>

	<cffunction name="deleteDataSiteExtensions" returntype="void" access="private" output="false">
		<cfargument name="useType" type="string" required="true">

		<cfset var siteStruct = getBean("settingsManager").getSites()>
		<cfset var siteID = "">

		<cfloop collection="#siteStruct#" item="siteID">
			<cfset deleteDataExtension(siteID,arguments.useType)>
		</cfloop>
	</cffunction>

	<cffunction name="checkDataExtension" returntype="void" access="private" output="false">
		<cfargument name="siteID" type="string" required="true">
		<cfargument name="useType" type="string" required="true">

		<cfset var qExtensions = application.classExtensionManager.getSubTypes(arguments.siteID)>
		<cfset var sExtension = application.classExtensionManager.getSubTypeByName(arguments.useType,"MobileMuraData",arguments.siteID)>
		<cfset var qExtendSets = sExtension.getSetsQuery()>

		<cfif not qExtensions.recordCount>
			<cfset addDataExtension(arguments.siteID,arguments.useType)>
			<cfreturn>
		</cfif>

		<cfquery dbtype="query" name="selectDefaultExtensionType">
			SELECT
				subTypeID
			FROM
				qExtensions
			WHERE
				type = '#arguments.useType#'
		</cfquery>

		<cfif not selectDefaultExtensionType.recordCount>
			<cfset addDataExtension(arguments.siteID,arguments.useType)>
			<cfreturn>
		</cfif>

		<cfquery dbtype="query" name="selectGSMExtendSet">
			SELECT
				extendSetID
			FROM
				qExtendSets
			WHERE
				name = 'MobileMuraData'
		</cfquery>
		
		<cfif not selectGSMExtendSet.recordCount>
			<cfset addDataExtendSet(arguments.siteID,selectDefaultExtensionType.subTypeID)>
			<cfreturn>
		</cfif>
		
		<cfset checkDataAttributes(arguments.siteID,selectDefaultExtensionType.subTypeID,selectGSMExtendSet.extendSetID)>
	</cffunction>

	<cffunction name="deleteDataExtension" returntype="void" access="private" output="false">
		<cfargument name="siteID" type="string" required="true">
		<cfargument name="useType" type="string" required="true">

		<cfset var sExtension = application.classExtensionManager.getSubTypeByName(arguments.useType,"MobileMuraData",arguments.siteID)>
		<cfset var sExtendSet = application.classExtensionManager.getSubTypeBean().getExtendSetBean()>
		<cfset var qExtendSets = sExtension.getSetsQuery()>

		<cfquery dbtype="query" name="selectGSMExtendSetForDelete">
			SELECT
				extendSetID
			FROM
				qExtendSets
			WHERE
				name = 'MobileMuraData'
		</cfquery>

		<cfoutput query="selectGSMExtendSetForDelete">
			<cfset sExtendSet = sExtension.loadSet( extendSetID ) />
			<cfset sExtendSet.delete()>
		</cfoutput>
	</cffunction>

	<cffunction name="addDataExtension" returntype="void" access="private" output="false">
		<cfargument name="siteID" type="string" required="true">
		<cfargument name="useType" type="string" required="true">
		<cfargument name="subTypeID" type="string" required="false" default="#createUUID()#">

		<cfset var newExtensionID = createUUID()>
		<cfset var sExtension = application.classExtensionManager.getSubTypeByID(arguments.subTypeID)>

		<cfset sExtension.setType(arguments.useType)>
		<cfset sExtension.setSubType("MobileMuraData")>
		<cfset sExtension.setIsActive(1)>
		<cfset sExtension.setBaseKeyField("contentHistID")>
		<cfset sExtension.setBaseTable("custom")>
		<cfset sExtension.setDataTable("custom")>
		<cfset sExtension.setSiteID(arguments.siteID)>
		<cfset sExtension.save()>

		<cfset addDataExtendSet(arguments.siteID,arguments.subTypeID)>
	</cffunction>

	<cffunction name="addDataExtendSet" returntype="void" access="private" output="false">
		<cfargument name="siteID" type="string" required="true">
		<cfargument name="subTypeID" required="false" type="string" default="#createUUID()#">

		<cfset var newExtendSetID = createUUID()>
		<cfset var sExtendSet = application.classExtensionManager.getSubTypeBean().getExtendSetBean()>
		<cfset var attName = "">

		<cfset sExtendSet.setSubTypeID(arguments.subTypeID)>
		<cfset sExtendSet.setExtendSetID(newExtendSetID)>
		<cfset sExtendSet.setName("MobileMuraData")>
		<cfset sExtendSet.setOrderNo(0)>
		<cfset sExtendSet.setIsActive(1)>
		<cfset sExtendSet.setSiteID(arguments.siteID)>
		<cfset sExtendSet.setContainer("MobileMuraData")>
		<cfset sExtendSet.save()>

		<cfset checkDataAttributes(arguments.siteID,arguments.subTypeID,newExtendSetID)>
	</cffunction>

	<cffunction name="checkDataAttributes" returntype="void" access="private" output="false">
		<cfargument name="siteID" type="string" required="true">
		<cfargument name="subTypeID" type="string" required="true">
		<cfargument name="extendSetID" type="string" required="true">

		<cfset var sExtension = application.classExtensionManager.getSubTypeByID(arguments.subTypeID)>
		<cfset var sExtendSet = sExtension.loadSet( arguments.extendSetID ) />
		<cfset var qExtendAtts = sExtendSet.getAttributesQuery() />
		
		<cfloop list="mobiletemplate" index="attName">
			<cfquery dbtype="query" name="selectGSMExtendSetAttributes">
				SELECT
					attributeID
				FROM
					qExtendAtts
				WHERE
					name = '#attName#'
			</cfquery>

			<cfif not selectGSMExtendSetAttributes.recordCount>
				<cfset addDataAttribute( arguments.siteID,attName,arguments.extendSetID )>
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="addDataAttribute" returntype="void" access="private" output="false">
		<cfargument name="siteID" type="string" required="true">
		<cfargument name="useName" type="string" required="true">
		<cfargument name="extendSetID" required="true">

		<cfset var sAttribute = application.classExtensionManager.getSubTypeBean().getExtendSetBean().getattributeBean()>
		<cfset var templateslist = "" />

		<cfset sAttribute.setExtendSetID(arguments.extendSetID)>
		<cfset sAttribute.setSiteID(arguments.siteID)>

		<cfswitch expression="#arguments.useName#">
			<cfcase value="mobiletemplate">
				<cfset sAttribute.setName("MobileTheme")>
				<cfset sAttribute.setLabel("Mobile theme")>
				<cfset sAttribute.setHint("Set the mobile theme")>
				<cfset sAttribute.setType("SelectBox")>
				<cfset sAttribute.setDefaultValue("")>
				<cfset sAttribute.setOptionList("")>
				<cfset sAttribute.setOptionLabelList("")>
				<cfset sAttribute.setOrderNo(1)>
			</cfcase>
		</cfswitch>
		<cfset sAttribute.save()>
	</cffunction>

	<!--- *******************************    private    ******************************** --->
	<cffunction name="getInstallationCount" access="private" returntype="any" output="false">
		<cfscript>
			var qoq = '';
			var rs = variables.config.getConfigBean().getPluginManager().getAllPlugins();
		</cfscript>
		<cfquery name="qoq" dbtype="query">
			SELECT *
			FROM rs
			WHERE package = <cfqueryparam value="#variables.config.getPackage()#" cfsqltype="cf_sql_varchar" maxlength="100" />
		</cfquery>
		<cfreturn val(qoq.recordcount) />
	</cffunction>

</cfcomponent>