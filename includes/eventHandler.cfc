<!---

MobileMura/plugin/config.xml

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

<cfcomponent persistent="false" accessors="true" output="false" extends="mura.plugin.pluginGenericEventHandler">

	<!--- framework variables --->
	<cfinclude template="fw1config.cfm" />

	<!--- ========================== MobileMura Specific Methods ============================== --->

	<cffunction name="onGlobalRequestStart" output="false" returntype="any">
		<cfargument name="$" />

		<cfif isDefined("form.mobileMuraFormat")>
			<cfcookie name="mobileMuraFormat" value="#form.mobileMuraFormat#" />
			<cfcookie name="mobileFormat" value="true" />
			<cfset request.muraMobileRequest = true />
		<cfelseif isDefined("url.mobileMuraFormat")>
			<cfcookie name="mobileMuraFormat" value="#url.mobileMuraFormat#" />
			<cfcookie name="mobileFormat" value="true" />
			<cfset request.muraMobileRequest = true />
		</cfif>

		<cfif isDefined('cookie.mobileMuraFormat')>
			<cfset request.mobileMuraRequest = cookie.mobileMuraFormat />
		<cfelse>
			<cfset request.mobileMuraRequest = false />
		</cfif>
		
	</cffunction>
	
	<cffunction name="onGlobalMobileDetection" output="false">
		<cfargument name="$" required="true" hint="mura scope" />

		<cfset var local = StructNew() />
		<cfset local.dsn = $.globalConfig().getDatasource() />
		
		<cfif listLen(cgi.script_name,"/") GT 1>
			<cfset local.site_id = listGetAt(cgi.script_name,listLen(cgi.script_name,"/")-1,"/") />
		<cfelse>
			<cfset local.site_id = listGetAt(cgi.script_name,listLen(cgi.script_name,"/"),"/") />
		</cfif>
		
		<cfquery name="local.getDetection" datasource="#local.dsn#" >
			SELECT	detection
			FROM	mm_detection
			WHERE	site_id = '#listGetAt(cgi.script_name,listLen(cgi.script_name,"/")-1,"/")#'
		</cfquery>
		
		<cfif local.getDetection.detection NEQ "1">

			<cfif NOT isdefined("cookie.mobileMuraFormat")>
				
				<!--- get the configured devices from the DB --->
				<cfquery name="local.getUASettings" datasource="#local.dsn#" >
					SELECT	ua_string, name
					FROM	mm_ua_settings
					WHERE	site_id = '#listGetAt(cgi.script_name,listLen(cgi.script_name,"/")-1,"/")#'
				</cfquery>
				
				<!--- loop over the devices --->
				<cfloop query="local.getUASettings" >
					<cfset local.thisDevice = false />
					
					<!--- loop over the different keywords --->
					<cfloop list="#local.getUASettings.ua_string#" index="i" >
						<cfif reFindNoCase(i,CGI.HTTP_USER_AGENT)>
							<!--- keyword found --->
							<!--- match still possible --->
							<cfset local.thisDevice = true />
						<cfelse>
							<!--- keyword not found --->
							<!--- match impossible --->
							<cfset local.thisDevice = false />
							<cfbreak />
						</cfif>
					</cfloop>
					
					<!--- if the devices matches --->
					<cfif local.thisDevice>
						<cfcookie name="mobileFormat" value="true" />
						<cfset request.muraMobileRequest = true />
						<cfcookie name="mobileMuraFormat" value="#local.getUASettings.name#" />
						<cfset request.mobileMuraRequest = local.getUASettings.name />
						<cfbreak />
					</cfif>
				</cfloop>
			<cfelse>
				<cfset request.muraMobileRequest = true />
				<cfset request.mobileMuraRequest = cookie.mobileMuraFormat />
			</cfif>
		</cfif>
		
		</cffunction>
	
	<cffunction name="standardMobileValidator" output="false" returnType="any">
		<cfargument name="event" required="true">
		<cfif request.muraMobileRequest and not len(arguments.event.getValue('altTheme'))>
			<cfset arguments.event.getHandler("standardMobile").handle(arguments.event)>
		</cfif>
	</cffunction>

	<cffunction name="standardMobileHandler" output="false" returntype="any">
		<cfargument name="$" />
		
		<cfset var local = StructNew() />
		<cfset local.dsn = $.globalConfig().getDatasource() />

		<cfset local.MobileMura = createObject("component","MobileMura") />
		
		<cfquery name="local.getDetection" datasource="#local.dsn#" >
			SELECT	detection
			FROM	mm_detection
			WHERE	site_id = '#$.getSite().getSiteId()#'
		</cfquery>
		
		<cfif local.getDetection.detection EQ "1">
			<cfset local.MobileMura.updateTemplate($) />
			<cfset local.MobileMura.updateTheme($) />
		<cfelse>
			<cfquery name="local.getUASettings" datasource="#local.dsn#" >
				SELECT	mm_ua_settings_id, name
				FROM	mm_ua_settings
				WHERE	site_id = '#$.getSite().getSiteId()#'
				AND		name = '#request.mobileMuraRequest#'
			</cfquery>

			<cfset local.MobileMura.MMupdateTemplate($, local.getUASettings.mm_ua_settings_id) />
			<cfset local.MobileMura.MMupdateTheme($) />
		</cfif>

		<cfset renderer.showAdminToolbar=false>
		<cfset renderer.showMemberToolbar=false>
		<cfset renderer.showEditableObjects=false>

		<cfreturn />
	</cffunction>

	<cffunction name="onContentEdit" returntype="any" output="true">
		<cfargument name="$" />
		
		<cfset var local = StructNew() />
		
		<cfset local.dsn = $.globalConfig().getDatasource() />
		
		<cfquery name="local.getDetection" datasource="#local.dsn#" >
			SELECT	detection, theme
			FROM	mm_detection
			WHERE	site_id = "#$.getSite().getSiteId()#"
		</cfquery>
		
		<cfif local.getDetection.detection EQ 1>
			<cfset local.mobileTheme = local.getDetection.theme />
			
			<cfif Len(local.mobileTheme)>
				<cfset local.mobileTemplatesUrl = Replace($.getSite().getTemplateIncludeDir(), $.getSite().getTheme(), local.mobileTheme) />
				<cfdirectory name="local.mobileTemplates" action="LIST" directory="#local.mobileTemplatesUrl#" filter="*.cfm" />
			<cfelse>
				<cfset local.mobileTemplates = queryNew("", "") />
			</cfif>
			
			<cfquery name="local.getTemplateSet" datasource="#local.dsn#" >
				SELECT	template
				FROM	mm_content
				WHERE	site_id = '#$.content().getSiteId()#'
				AND		content_id = '#$.content().getContentId()#'
			</cfquery>
		<cfelse>
			<cfquery name="local.UASettings" datasource="#local.dsn#" >
				SELECT	name, theme, mm_ua_settings_id
				FROM	mm_ua_settings
				WHERE	site_id = '#$.getSite().getSiteID()#'
			</cfquery>
			
			<cfquery name="local.getTemplateSet" datasource="#local.dsn#" >
				SELECT	mm_ua_settings_id, template
				FROM	mm_content
				WHERE	site_id = '#$.content().getSiteId()#'
				AND		content_id = '#$.content().getContentId()#'
			</cfquery>
		</cfif>
		
		<cfinclude template="onContentEdit.cfm" />
		
		<cfreturn />
	</cffunction>

	<cffunction name="onAfterContentSave" returntype="any" output="true">
		<cfargument name="$" />
		
		<cfset var local = StructNew() />
		<cfset local.dsn = $.globalConfig().getDatasource() />
		
		<cfquery name="local.getDetection" datasource="#local.dsn#" >
			SELECT	detection, theme
			FROM	mm_detection
			WHERE	site_id = "#$.getSite().getSiteId()#"
		</cfquery>
		
		<cfif local.getDetection.detection EQ "1">
			<cfquery name="local.checkContent" datasource="#local.dsn#" >
				SELECT	*
				FROM	mm_content
				WHERE	site_id = '#$.content().getSiteId()#'
				AND		content_id = '#$.content().getContentId()#'
			</cfquery>
			
			<cfquery name="insertUpdateContent" datasource="#local.dsn#">
				<cfif local.checkContent.recordCount>
					UPDATE	mm_content
					SET		template = '#$.event("mobiletemplate")#'
					WHERE	site_id = '#$.content().getSiteId()#'
					AND		content_id = '#$.content().getContentId()#'
				<cfelse>
					INSERT 	INTO mm_content
					(mm_content_id, site_id, content_id, template)
					VALUES
					('#createUUID()#', '#$.content().getSiteId()#', '#$.content().getContentId()#', '#$.event("mobiletemplate")#')
				</cfif>
			</cfquery>
		<cfelse>
			<cfquery name="local.getMMDetectionSettings" datasource="#local.dsn#">
				SELECT	*
				FROM	mm_ua_settings
				WHERE	site_id = '#$.getSite().getSiteId()#'
			</cfquery>
			
			<cfloop query="local.getMMDetectionSettings" >
				<cfset local.name = Replace(local.getMMDetectionSettings.name, ' ', '') />
				<cfquery name="local.checkContentSettings" datasource="#local.dsn#">
					SELECT	*
					FROM	mm_content
					WHERE	site_id = '#$.getSite().getSiteId()#'
					AND		content_id = '#$.content().getContentId()#'
					AND		mm_ua_settings_id = '#local.getMMDetectionSettings.mm_ua_settings_id#'
				</cfquery>
				
				<cfif local.checkContentSettings.RecordCount>
					<cfquery name="local.updateSettings" datasource="#local.dsn#">
						UPDATE	mm_content
						SET		template = '#$.event("MMmobileTemplate-#local.name#")#'
						WHERE	mm_content_id = '#local.checkContentSettings.mm_content_id#'
					</cfquery>
				<cfelse>
					<cfquery name="local.updateSettings" datasource="#local.dsn#">
						INSERT	INTO mm_content
						(mm_content_id, site_id, mm_ua_settings_id, content_id, template)
						VALUES
						('#createUUID()#', '#$.getSite().getSiteID()#', '#local.getMMDetectionSettings.mm_ua_settings_id#', '#$.content().getContentID()#', '#$.event("MMmobileTemplate-#local.name#")#')
					</cfquery>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn />
	</cffunction>

	<cffunction name="onAfterContentDelete" returntype="any" output="true" >
		<cfargument name="$" />
		
		<cfset var local = StructNew() />
		<cfset local.dsn = $.globalConfig().getDatasource() />
		
		<cfquery name="local.deleteContentTraces" datasource="#local.dsn#" >
			DELETE	
			FROM	mm_content
			WHERE	content_id = "#$.content().getContenId()#"
		</cfquery>
		
		<cfreturn />
	</cffunction>

	<cffunction name="onSiteEdit" returntype="any" output="true">
		<cfargument name="$" />
		
		<cfset var local = StructNew() />
		<cfset var getMMDetectionSettings = "" />
		
		<cfset local.dsn = $.globalConfig().getDatasource() />
		
		<cfset local.themes = $.siteConfig().getThemes() />
		
		<cfquery name="local.getDetection" datasource="#local.dsn#" >
			SELECT	detection, theme
			FROM	mm_detection
			WHERE	site_id = "#$.getSite().getSiteId()#"
		</cfquery>
		
		<cfquery name="getMMDetectionSettings" datasource="#local.dsn#">
			SELECT	*
			FROM	mm_ua_settings
			WHERE	site_id = "#$.getSite().getSiteId()#"
		</cfquery>
		
		<cfset local.MMDetectionSettings = StructNew() />
		<cfset local.MMDetectionSettings["iPod"] = "" />
		<cfset local.MMDetectionSettings["iPhone"] = "" />
		<cfset local.MMDetectionSettings["iPad"] = "" />
		<cfset local.MMDetectionSettings["Android Phone"] = "" />
		<cfset local.MMDetectionSettings["Android Tablet"] = "" />
		<cfset local.MMDetectionSettings["BlackBerry Phone"] = "" />
		<cfset local.MMDetectionSettings["BlackBerry Tablet"] = "" />
		<cfset local.MMDetectionSettings["Windows Mobile Phone"] = "" />
		
		<cfif local.getDetection.detection EQ 2>
		<cfloop query="getMMDetectionSettings" >
			<cfset local.MMDetectionSettings[getMMDetectionSettings.name] = getMMDetectionSettings.theme />
		</cfloop>
		</cfif>
		<cfif local.getDetection.detection EQ 3 >
			<cfquery name="local.MMCustomDetectionSettings" dbtype="query" >
				SELECT	*
				FROM	getMMDetectionSettings
				WHERE	1 = 1
			</cfquery>
		<cfelse>
			<cfquery name="local.MMCustomDetectionSettings" dbtype="query" >
				SELECT	*
				FROM	getMMDetectionSettings
				WHERE	1 = 0
			</cfquery>
		</cfif>
		
		<cfinclude template="onSiteEdit.cfm" />
		
		<cfreturn />
	</cffunction>

	<cffunction name="onAfterSiteSave" returntype="any" output="true">
		<cfargument name="$" />
		
		<cfset var local = StructNew() />
		<cfset local.dsn = $.globalConfig().getDatasource() />
		
		<cfswitch expression="#$.event("mm_detectionType")#" >
			<cfcase value="1" >
				<cfquery name="local.checkContent" datasource="#local.dsn#" >
					SELECT	*
					FROM	mm_detection
					WHERE	site_id = '#$.getSite().getSiteId()#'
				</cfquery>
				
				<cfquery name="insertUpdateContent" datasource="#local.dsn#">
					<cfif local.checkContent.recordCount>
						UPDATE	mm_detection
						SET		detection = '1',
								theme = '#$.event("mobileTheme")#'
						WHERE	site_id = '#$.getSite().getSiteId()#'
					<cfelse>
						INSERT 	INTO mm_detection
						(site_id, detection, theme)
						VALUES
						('#$.getSite().getSiteId()#', '1', '#$.event("mobileTheme")#')
					</cfif>
				</cfquery>

				<cfquery name="local.deleteOldSettings" datasource="#local.dsn#" >
					DELETE	
					FROM	mm_ua_settings
					WHERE	site_id = '#$.getSite().getSiteId()#'
				</cfquery>

				<cfquery name="local.deleteOldContentSettings" datasource="#local.dsn#" >
					DELETE	
					FROM	mm_content
					WHERE	site_id = '#$.getSite().getSiteId()#'
					AND		NOT mm_ua_settings_id IS NULL
				</cfquery>
			</cfcase>
			<cfcase value="2" >
				<cfquery name="local.checkContent" datasource="#local.dsn#" >
					SELECT	*
					FROM	mm_detection
					WHERE	site_id = '#$.getSite().getSiteId()#'
				</cfquery>
				
				<cfquery name="insertUpdateContent" datasource="#local.dsn#">
					<cfif local.checkContent.recordCount>
						UPDATE	mm_detection
						SET		detection = '2',
								theme = ''
						WHERE	site_id = '#$.getSite().getSiteId()#'
					<cfelse>
						INSERT 	INTO mm_detection
						(site_id, detection, theme)
						VALUES
						('#$.getSite().getSiteId()#', '2', '')
					</cfif>
				</cfquery>
				
				<cfquery name="local.checkSettings" datasource="#local.dsn#" >
					SELECT	*
					FROM	mm_ua_settings
					WHERE	site_id = '#$.getSite().getSiteId()#'
				</cfquery>
				
				<!--- iPod --->
				<cfquery name="local.checkSetting_iPod_mobileTheme" dbtype="query" >
					SELECT	*
					FROM	local.checkSettings
					WHERE	name = 'iPod'
				</cfquery>
				
				<cfquery name="insertUpdateSettings" datasource="#local.dsn#">
					<cfif local.checkSetting_iPod_mobileTheme.recordCount>
						UPDATE	mm_ua_settings
						SET		theme = '#$.event("iPod_mobileTheme")#'
						WHERE	site_id = '#$.getSite().getSiteId()#'
						AND		name = 'iPod'
					<cfelse>
						INSERT 	INTO mm_ua_settings
						(mm_ua_settings_id, site_id, name, ua_string, theme)
						VALUES
						('#createUUID()#', '#$.getSite().getSiteId()#', 'iPod', 'ipod', '#$.event("iPod_mobileTheme")#')
					</cfif>
				</cfquery>
				
				<!--- iPhone --->
				<cfquery name="local.checkSetting_iPhone_mobileTheme" dbtype="query" >
					SELECT	*
					FROM	local.checkSettings
					WHERE	name = 'iPhone'
				</cfquery>
				
				<cfquery name="insertUpdateSettings" datasource="#local.dsn#">
					<cfif local.checkSetting_iPhone_mobileTheme.recordCount>
						UPDATE	mm_ua_settings
						SET		theme = '#$.event("iPhone_mobileTheme")#'
						WHERE	site_id = '#$.getSite().getSiteId()#'
						AND		name = 'iPhone'
					<cfelse>
						INSERT 	INTO mm_ua_settings
						(mm_ua_settings_id, site_id, name, ua_string, theme)
						VALUES
						('#createUUID()#', '#$.getSite().getSiteId()#', 'iPhone', 'iphone', '#$.event("iPhone_mobileTheme")#')
					</cfif>
				</cfquery>
				
				<!--- iPad --->
				<cfquery name="local.checkSetting_iPad_mobileTheme" dbtype="query" >
					SELECT	*
					FROM	local.checkSettings
					WHERE	name = 'iPad'
				</cfquery>
				
				<cfquery name="insertUpdateSettings" datasource="#local.dsn#">
					<cfif local.checkSetting_iPad_mobileTheme.recordCount>
						UPDATE	mm_ua_settings
						SET		theme = '#$.event("iPad_mobileTheme")#'
						WHERE	site_id = '#$.getSite().getSiteId()#'
						AND		name = 'iPad'
					<cfelse>
						INSERT 	INTO mm_ua_settings
						(mm_ua_settings_id, site_id, name, ua_string, theme)
						VALUES
						('#createUUID()#', '#$.getSite().getSiteId()#', 'iPad', 'ipad', '#$.event("iPad_mobileTheme")#')
					</cfif>
				</cfquery>
				
				<!--- Android Phone --->
				<cfquery name="local.checkSetting_AndroidPhone_mobileTheme" dbtype="query" >
					SELECT	*
					FROM	local.checkSettings
					WHERE	name = 'Android Phone'
				</cfquery>
				
				<cfquery name="insertUpdateSettings" datasource="#local.dsn#">
					<cfif local.checkSetting_AndroidPhone_mobileTheme.recordCount>
						UPDATE	mm_ua_settings
						SET		theme = '#$.event("AndroidPhone_mobileTheme")#'
						WHERE	site_id = '#$.getSite().getSiteId()#'
						AND		name = 'Android Phone'
					<cfelse>
						INSERT 	INTO mm_ua_settings
						(mm_ua_settings_id, site_id, name, ua_string, theme)
						VALUES
						('#createUUID()#', '#$.getSite().getSiteId()#', 'Android Phone', 'android,mobile', '#$.event("AndroidPhone_mobileTheme")#')
					</cfif>
				</cfquery>
				
				<!--- Android Tablet --->
				<cfquery name="local.checkSetting_AndroidTablet_mobileTheme" dbtype="query" >
					SELECT	*
					FROM	local.checkSettings
					WHERE	name = 'Android Tablet'
				</cfquery>
				
				<cfquery name="insertUpdateSettings" datasource="#local.dsn#">
					<cfif local.checkSetting_AndroidTablet_mobileTheme.recordCount>
						UPDATE	mm_ua_settings
						SET		theme = '#$.event("AndroidTablet_mobileTheme")#'
						WHERE	site_id = '#$.getSite().getSiteId()#'
						AND		name = 'Android Tablet'
					<cfelse>
						INSERT 	INTO mm_ua_settings
						(mm_ua_settings_id, site_id, name, ua_string, theme)
						VALUES
						('#createUUID()#', '#$.getSite().getSiteId()#', 'Android Tablet', 'android', '#$.event("AndroidTablet_mobileTheme")#')
					</cfif>
				</cfquery>
				
				<!--- BlackBerry Phone --->
				<cfquery name="local.checkSetting_BlackBerryPhone_mobileTheme" dbtype="query" >
					SELECT	*
					FROM	local.checkSettings
					WHERE	name = 'BlackBerry Phone'
				</cfquery>
				
				<cfquery name="insertUpdateSettings" datasource="#local.dsn#">
					<cfif local.checkSetting_BlackBerryPhone_mobileTheme.recordCount>
						UPDATE	mm_ua_settings
						SET		theme = '#$.event("BlackBerryPhone_mobileTheme")#'
						WHERE	site_id = '#$.getSite().getSiteId()#'
						AND		name = 'BlackBerry Phone'
					<cfelse>
						INSERT 	INTO mm_ua_settings
						(mm_ua_settings_id, site_id, name, ua_string, theme)
						VALUES
						('#createUUID()#', '#$.getSite().getSiteId()#', 'BlackBerry Phone', 'blackberry', '#$.event("BlackBerryPhone_mobileTheme")#')
					</cfif>
				</cfquery>
				
				<!--- BlackBerry Tablet --->
				<cfquery name="local.checkSetting_BlackBerryTablet_mobileTheme" dbtype="query" >
					SELECT	*
					FROM	local.checkSettings
					WHERE	name = 'BlackBerry Tablet'
				</cfquery>
				
				<cfquery name="insertUpdateSettings" datasource="#local.dsn#">
					<cfif local.checkSetting_BlackBerryTablet_mobileTheme.recordCount>
						UPDATE	mm_ua_settings
						SET		theme = '#$.event("BlackBerryTablet_mobileTheme")#'
						WHERE	site_id = '#$.getSite().getSiteId()#'
						AND		name = 'BlackBerry Tablet'
					<cfelse>
						INSERT 	INTO mm_ua_settings
						(mm_ua_settings_id, site_id, name, ua_string, theme)
						VALUES
						('#createUUID()#', '#$.getSite().getSiteId()#', 'BlackBerry Tablet', 'rim tablet', '#$.event("BlackBerryTablet_mobileTheme")#')
					</cfif>
				</cfquery>
				
				<!--- Windows Mobile Phone --->
				<cfquery name="local.checkSetting_WindowsMobilePhone_mobileTheme" dbtype="query" >
					SELECT	*
					FROM	local.checkSettings
					WHERE	name = 'Windows Mobile Phone'
				</cfquery>
				
				<cfquery name="insertUpdateSettings" datasource="#local.dsn#">
					<cfif local.checkSetting_WindowsMobilePhone_mobileTheme.recordCount>
						UPDATE	mm_ua_settings
						SET		theme = '#$.event("WindowsMobilePhone_mobileTheme")#'
						WHERE	site_id = '#$.getSite().getSiteId()#'
						AND		name = 'Windows Mobile Phone'
					<cfelse>
						INSERT 	INTO mm_ua_settings
						(mm_ua_settings_id, site_id, name, ua_string, theme)
						VALUES
						('#createUUID()#', '#$.getSite().getSiteId()#', 'Windows Mobile Phone', 'windows phone os', '#$.event("WindowsMobilePhone_mobileTheme")#')
					</cfif>
				</cfquery>

				<cfset local.names = "iPod,iPhone,iPad,Android Phone,Android Tablet,BlackBerry Phone,BlackBerry Tablet,Windows Mobile Phone" />
				<cfquery name="local.deleteOldSettings" datasource="#local.dsn#" >
					DELETE	
					FROM	mm_ua_settings
					WHERE	site_id = '#$.getSite().getSiteId()#'
					AND		NOT name IN (<cfqueryparam value="#local.names#" cfsqltype="cf_sql_varchar" list="true" >)
				</cfquery>

				<cfquery name="local.deleteOldContentSettings" datasource="#local.dsn#" >
					DELETE	
					FROM	mm_content
					WHERE	site_id = '#$.getSite().getSiteId()#'
					AND		NOT mm_ua_settings_id IN (
							SELECT	mm_ua_settings_id
							FROM	mm_ua_settings
							WHERE	site_id = '#$.getSite().getSiteId()#'
					)
				</cfquery>
			</cfcase>
			<cfcase value="3" >
				<cfquery name="local.checkContent" datasource="#local.dsn#" >
					SELECT	*
					FROM	mm_detection
					WHERE	site_id = '#$.getSite().getSiteId()#'
				</cfquery>
				
				<cfquery name="insertUpdateContent" datasource="#local.dsn#">
					<cfif local.checkContent.recordCount>
						UPDATE	mm_detection
						SET		detection = '3',
								theme = ''
						WHERE	site_id = '#$.getSite().getSiteId()#'
					<cfelse>
						INSERT 	INTO mm_detection
						(site_id, detection, theme)
						VALUES
						('#$.getSite().getSiteId()#', '3', '')
					</cfif>
				</cfquery>
				
				<cfset local.names = "" />
				<cfloop index="i" from="1" to="#$.event("MMRowTotal")#" >
					<cfif Len($.event("MMCustomName-#i#"))>
						<cfquery name="local.checkCustomSettings" datasource="#local.dsn#" >
							SELECT	*
							FROM	mm_ua_settings
							WHERE	site_id = '#$.getSite().getSiteId()#'
							AND		name = '#$.event("MMCustomName-#i#")#'
						</cfquery>
						<cfquery name="insertUpdateCustomSettings" datasource="#local.dsn#">
							<cfif local.checkCustomSettings.recordCount>
								UPDATE	mm_ua_settings
								SET		ua_string = '#$.event("MMCustomUAString-#i#")#',
										theme = '#$.event("MMCustomTheme-#i#")#'
								WHERE	site_id = '#$.getSite().getSiteId()#'
								AND		name = '#$.event("MMCustomName-#i#")#'
							<cfelse>
								INSERT 	INTO mm_ua_settings
								(mm_ua_settings_id, site_id, name, ua_string, theme)
								VALUES
								('#createUUID()#', '#$.getSite().getSiteId()#', '#$.event("MMCustomName-#i#")#', '#$.event("MMCustomUAString-#i#")#', '#$.event("MMCustomTheme-#i#")#')
							</cfif>
						</cfquery>
						<cfset local.names = ListAppend(local.names, $.event("MMCustomName-#i#")) />
					</cfif>
				</cfloop>

				<cfquery name="local.deleteOldSettings" datasource="#local.dsn#" >
					DELETE	
					FROM	mm_ua_settings
					WHERE	site_id = '#$.getSite().getSiteId()#'
					AND		NOT name IN (<cfqueryparam value="#local.names#" cfsqltype="cf_sql_varchar" list="true" >)
				</cfquery>

				<cfquery name="local.deleteOldContentSettings" datasource="#local.dsn#" >
					DELETE	
					FROM	mm_content
					WHERE	site_id = '#$.getSite().getSiteId()#'
					AND		NOT mm_ua_settings_id IN (
							SELECT	mm_ua_settings_id
							FROM	mm_ua_settings
							WHERE	site_id = '#$.getSite().getSiteId()#'
					)
				</cfquery>
			</cfcase>
		</cfswitch>
		
		<cfreturn />
	</cffunction>

	<cffunction name="onAfterSiteDelete" returntype="any" output="true" >
		<cfargument name="$" />
		
		<cfset var local = StructNew() />
		<cfset local.dsn = $.globalConfig().getDatasource() />
		
		<cfquery name="local.deleteSiteTraces" datasource="#local.dsn#" >
			DELETE	
			FROM	mm_ua_settings
			WHERE	site_id = "#$.getSite().getSiteId()#"
		</cfquery>
		
		<cfquery name="local.deleteSiteTraces" datasource="#local.dsn#" >
			DELETE	
			FROM	mm_detection
			WHERE	site_id = "#$.getSite().getSiteId()#"
		</cfquery>
		
		<cfreturn />
	</cffunction>

	<!--- ========================== Mura CMS Specific Methods ============================== --->
	<!--- Add any other Mura CMS Specific methods you need here. --->

	<cfscript>
	public void function onApplicationLoad(required struct $) {
		// trigger MuraFW1 setupApplication()
		getApplication().setupApplication();
		// register this file as a Mura eventHandler
		variables.pluginConfig.addEventHandler(this);
	}
	
	public void function onSiteRequestStart(required struct $) {
		// make the methods in displayObjects.cfc accessible via $.packageName.methodName()
		arguments.$.setCustomMuraScopeKey(variables.framework.package, new displayObjects());
	}

	public any function onRenderStart(required struct $) {
		arguments.$.loadShadowboxJS();
	}
	</cfscript>

	<!--- ========================== Helper Methods ============================== --->

	<cfscript>
	private any function getApplication() {
		if( !StructKeyExists(request, '#variables.framework.applicationKey#Application') ) {
			request['#variables.framework.applicationKey#Application'] = new '#variables.framework.package#.Application'();
		};
		return request['#variables.framework.applicationKey#Application'];
	}
	</cfscript>

</cfcomponent>

