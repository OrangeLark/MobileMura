<!---

MobileMura/MobileMura.cfc

Copyright 2011 Guust Nieuwenhuis 

Licensed under the Apache License, Version 2.0 (the "License"); 
you may not use this file except in compliance with the License. 
You may obtain a copy of the License at 

http://www.apache.org/licenses/LICENSE-2.0 

Unless required by applicable law or agreed to in writing, software 
distributed under the License is distributed on an "AS IS" BASIS, 
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
See the License for the specific language governing permissions and 
limitations under the License. 

--->

<cfcomponent>
	
	<cffunction name="updateTemplate" output="false" returntype="any" access="public" >
		<cfargument name="$" type="Any" required="true">
		
		<cfset var local = StructNew() />
		<cfset local.dsn = $.globalConfig().getDatasource() />

		<cfset local.c = $.content() />
		<cfset local.p = $.content() />
		
		<cfset local.mobileTemplate = "" />
		
		<!--- check if a template is set --->
		<!--- inherit from parent == empty string --->
		<!--- if the template is an empty string: look for the parents template --->
		<cfquery name="local.searchTemplate" datasource="#local.dsn#" >
			SELECT	*
			FROM	mm_content
			WHERE	site_id = '#$.getSite().getSiteID()#'
			AND		content_id = '#local.c.getContentID()#'
		</cfquery>
		<cfset local.template = local.searchTemplate.template />
		<cfloop condition="NOT Len(local.template)" >
			<!--- get the template --->
			<cfif local.c.hasParent()>
				<cfset local.c = local.c.getParent() />
				<cfquery name="local.searchParentTemplate" datasource="#local.dsn#" >
					SELECT	*
					FROM	mm_content
					WHERE	site_id = '#$.getSite().getSiteID()#'
					AND		content_id = '#local.c.getContentID()#'
				</cfquery>
				<cfset local.template = local.searchParentTemplate.template />
			<cfelse>
				<cfset local.template = local.c.getTemplate() />
			</cfif>
		</cfloop>
		
		<!--- the 'mobiletemplate' is set --->
		<cfif Len(local.searchTemplate.template)>
			
			<!--- Inherit From Parent --->
			<cfif local.searchTemplate.template EQ "-1">
				<cfset local.i = true />
				<cfloop condition="local.i" >
					<cfif local.p.hasParent()>
						<cfset local.p = local.p.getParent() />
						
						<cfquery name="local.searchPTemplate" datasource="#local.dsn#" >
							SELECT	*
							FROM	mm_content
							WHERE	site_id = '#$.getSite().getSiteID()#'
							AND		content_id = '#local.p.getContentID()#'
						</cfquery>
						<cfset local.ptemplate = local.searchPTemplate.template />
						
						<cfif Len(local.ptemplate)>
							<cfif local.ptemplate EQ "-1">
								
							<cfelseif local.ptemplate EQ "-2">
								<cfset local.mobileTemplate = local.p.getTemplate() />
								<cfset local.i = false />
							<cfelse>
								<cfset local.mobileTemplate = local.ptemplate />
								<cfset local.i = false />
							</cfif>
						</cfif>
					<cfelse>
						<cfset local.mobileTemplate = local.p.getTemplate() />
						<cfset local.i = false />
					</cfif>
				</cfloop>
			
			<!--- Desktop Template --->
			<cfelseif local.searchTemplate.template EQ "-2">
				<cfset local.mobileTemplate = "" />
			<cfelse>
				<cfset local.mobileTemplate = local.searchTemplate.template />
			</cfif>
			
		<!--- the 'mobiletemplate' isn't set --->
		<cfelse>
			<cfset local.mobileTemplate = "" />
		</cfif>
		
		<!--- if a mobiletemplate is set and if the file exists --->
		<cfif Len(local.mobileTemplate) AND FileExists($.getSite().getTemplateIncludeDir() & "/" & local.mobileTemplate)>
			<!--- change the template --->
			<cfset $.content().setTemplate(mobileTemplate) />
		</cfif>

		<cfreturn />
	</cffunction>
	
	<cffunction name="updateTheme" output="false" returntype="any">
		<cfargument name="$" type="Any" required="true">
		
		<cfset var local = StructNew() />
		<cfset local.dsn = $.globalConfig().getDatasource() />
		
		<cfquery name="local.searchTheme" datasource="#local.dsn#" >
			SELECT	*
			FROM	mm_detection
			WHERE	site_id = '#$.getSite().getSiteID()#'
		</cfquery>
		<cfset local.theme = local.searchTheme.theme />

		<cfif local.searchTheme.recordCount AND local.theme NEQ "-1">
			<cfset $.event("altTheme",local.theme) />
			<cfif fileExists(expandPath($.siteConfig('themeIncludePath')) & "/contentRenderer.cfc" )>
				<cfset local.themeRenderer=createObject("component","#$.siteConfig('themeAssetMap')#.contentRenderer").init()>
				<cfset local.themeRenderer.injectMethod("mura",$)>
				<cfset local.themeRenderer.injectMethod("$",$)>
				<cfset local.themeRenderer.injectMethod("event",$.event())>
				<cfset $.event("themeRenderer",themeRenderer)>
			</cfif>
		</cfif>
		<cfreturn />
	</cffunction>
	
	<cffunction name="MMupdateTemplate" output="false" returntype="any" access="public" >
		<cfargument name="$" type="Any" required="true">
		<cfargument name="mm_ua_settings_id" type="Any" required="true">
		
		<cfset var local = StructNew() />
		<cfset local.dsn = $.globalConfig().getDatasource() />

		<cfset local.c = $.content() />
		<cfset local.p = $.content() />
		
		<cfset local.mobileTemplate = "" />
		
		<!--- check if a template is set --->
		<!--- inherit from parent == empty string --->
		<!--- if the template is an empty string: look for the parents template --->
		<cfquery name="local.searchTemplate" datasource="#local.dsn#" >
			SELECT	*
			FROM	mm_content
			WHERE	site_id = '#$.getSite().getSiteID()#'
			AND		content_id = '#local.c.getContentID()#'
			AND		mm_ua_settings_id = '#arguments.mm_ua_settings_id#'
		</cfquery>
		<cfset local.template = local.searchTemplate.template />
		<cfloop condition="NOT Len(local.template)" >
			<!--- get the template --->
			<cfset local.c = local.c.getParent() />
			<cfquery name="local.searchParentTemplate" datasource="#local.dsn#" >
				SELECT	*
				FROM	mm_content
				WHERE	site_id = '#$.getSite().getSiteID()#'
				AND		content_id = '#local.c.getContentID()#'
				AND		mm_ua_settings_id = '#arguments.mm_ua_settings_id#'
			</cfquery>
			<cfset local.template = local.searchParentTemplate.template />
		</cfloop>
		
		<!--- the 'mobiletemplate' is set --->
		<cfif Len(local.searchTemplate.template)>
			
			<!--- Inherit From Parent --->
			<cfif local.searchTemplate.template EQ "-1">
				<cfset local.i = true />
				<cfloop condition="local.i" >
					<cfif local.p.hasParent()>
						<cfset local.p = local.p.getParent() />
						
						<cfquery name="local.searchPTemplate" datasource="#local.dsn#" >
							SELECT	*
							FROM	mm_content
							WHERE	site_id = '#$.getSite().getSiteID()#'
							AND		content_id = '#local.c.getContentID()#'
							AND		mm_ua_settings_id = '#arguments.mm_ua_settings_id#'
						</cfquery>
						<cfset local.ptemplate = local.searchPTemplate.template />
						
						<cfif Len(local.ptemplate)>
							<cfif local.ptemplate EQ "-1">
								
							<cfelseif local.ptemplate EQ "-2">
								<cfset local.mobileTemplate = local.p.getTemplate() />
								<cfset local.i = false />
							<cfelse>
								<cfset local.mobileTemplate = local.ptemplate />
								<cfset local.i = false />
							</cfif>
						</cfif>
					<cfelse>
						<cfset local.mobileTemplate = local.p.getTemplate() />
						<cfset local.i = false />
					</cfif>
				</cfloop>
			
			<!--- Desktop Template --->
			<cfelseif local.searchTemplate.template EQ "-2">
				<cfset local.mobileTemplate = "" />
			<cfelse>
				<cfset local.mobileTemplate = local.searchTemplate.template />
			</cfif>
			
		<!--- the 'mobiletemplate' isn't set --->
		<cfelse>
			<cfset local.mobileTemplate = "" />
		</cfif>
		
		<!--- if a mobiletemplate is set and if the file exists --->
		<cfif Len(local.mobileTemplate) AND FileExists($.getSite().getTemplateIncludeDir() & "/" & local.mobileTemplate)>
			<!--- change the template --->
			<cfset $.content().setTemplate(mobileTemplate) />
		</cfif>

		<cfreturn />
	</cffunction>
	
	<cffunction name="MMupdateTheme" output="false" returntype="any">
		<cfargument name="$" type="Any" required="true">
		
		<cfset var local = StructNew() />
		<cfset local.dsn = $.globalConfig().getDatasource() />
		
		<cfquery name="local.searchTheme" datasource="#local.dsn#" >
			SELECT	*
			FROM	mm_ua_settings
			WHERE	site_id = '#$.getSite().getSiteID()#'
			AND		name = '#request.mobileMuraRequest#'
		</cfquery>
		<cfset local.theme = local.searchTheme.theme />

		<cfif local.searchTheme.recordCount AND local.theme NEQ "-1">
			<cfset $.event("altTheme",local.theme) />
			<cfif fileExists(expandPath($.siteConfig('themeIncludePath')) & "/contentRenderer.cfc" )>
				<cfset local.themeRenderer=createObject("component","#$.siteConfig('themeAssetMap')#.contentRenderer").init()>
				<cfset local.themeRenderer.injectMethod("mura",$)>
				<cfset local.themeRenderer.injectMethod("$",$)>
				<cfset local.themeRenderer.injectMethod("event",$.event())>
				<cfset $.event("themeRenderer",themeRenderer)>
			</cfif>
		</cfif>
		<cfreturn />
	</cffunction>

</cfcomponent>