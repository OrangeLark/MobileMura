<!---

MobileMura/event/pluginEventHandler.cfc

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

<cfcomponent extends="mura.plugin.pluginGenericEventHandler">

	<cfset variables.preserveKeyList = 'context,base,cfcbase,subsystem,subsystembase,section,item,services,action,controllerExecutionStarted' />
	<!--- Include FW/1 configuration that is shared between the Mura CMS and the FW/1 application. --->
	<cfset variables.framework = getFramework() />

	<!--- ********** Mura Specific Events ************* --->

	<cffunction name="onApplicationLoad" output="false">
		<cfargument name="$" required="true" hint="mura scope" />
		<cfset var state=preseveInternalState(request)>
		<cfinvoke component="#variables.pluginConfig.getPackage()#.Application" method="onApplicationStart" />
		<cfset restoreInternalState(request,state)>
		<cfset variables.pluginConfig.addEventHandler(this)>
	</cffunction>
	
	<cffunction name="onGlobalSessionStart" output="false">
		<cfargument name="$" required="true" hint="mura scope" />
		<cfset var state=preseveInternalState(request)>
		<cfinvoke component="#pluginConfig.getPackage()#.Application" method="onSessionStart" />
		<cfset restoreInternalState(request,state)>
	</cffunction>

	<cffunction name="onSiteRequestStart" output="false">
        <cfargument name="$" required="true" hint="mura scope" />
        <cfset $[variables.framework.applicationKey] = this />
	</cffunction>

	<cffunction name="onRenderStart" output="false" returntype="any">
		<cfargument name="$" />
		<cfscript>
			// this allows you to call methods here by accessing '$.mfw1.methodName(argumentCollection=args)'
			$.mfw1 = this;
		</cfscript>
	</cffunction>

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
		
		<cfquery name="local.getDetection" datasource="#local.dsn#" >
			SELECT	detection
			FROM	mm_detection
			WHERE	site_id = '#listGetAt(cgi.script_name,listLen(cgi.script_name,"/")-1,"/")#'
		</cfquery>
		
		<cfif local.getDetection.detection NEQ "1">

			<cfif NOT isdefined("cookie.mobileMuraFormat")>
				
				<cfquery name="local.getUASettings" datasource="#local.dsn#" >
					SELECT	ua_string, name
					FROM	mm_ua_settings
					WHERE	site_id = '#listGetAt(cgi.script_name,listLen(cgi.script_name,"/")-1,"/")#'
				</cfquery>
				
				<cfloop query="local.getUASettings" >
					<cfif reFindNoCase(local.getUASettings.ua_string,CGI.HTTP_USER_AGENT)>
						<cfcookie name="mobileFormat" value="true" />
						<cfset request.muraMobileRequest = true />
						<cfcookie name="mobileMuraFormat" value="#local.getUASettings.name#" />
						<cfset request.mobileMuraRequest = local.getUASettings.name />
						<cfbreak />
					<cfelse>
						<cfcookie name="mobileFormat" value="false" />
						<cfset request.muraMobileRequest = false />
						<cfcookie name="mobileMuraFormat" value="false" />
						<cfset request.mobileMuraRequest = false />
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

		<cfset local.MobileMura = createObject("component","#pluginConfig.getPackage()#.MobileMura") />
		
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
		<cfset local.dsn = $.globalConfig().getDatasource() />
		
		<cfset local.themes = $.siteConfig().getThemes() />
		
		<cfquery name="local.getDetection" datasource="#local.dsn#" >
			SELECT	detection, theme
			FROM	mm_detection
			WHERE	site_id = "#$.getSite().getSiteId()#"
		</cfquery>
		
		<cfquery name="local.getMMDetectionSettings" datasource="#local.dsn#">
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
		<cfloop query="local.getMMDetectionSettings" >
			<cfset local.MMDetectionSettings[local.getMMDetectionSettings.name] = local.getMMDetectionSettings.theme />
		</cfloop>
		</cfif>
		<cfif local.getDetection.detection EQ 3 >
			<cfquery name="local.MMCustomDetectionSettings" dbtype="query" >
				SELECT	*
				FROM	local.getMMDetectionSettings
				WHERE	1 = 1
			</cfquery>
		<cfelse>
			<cfquery name="local.MMCustomDetectionSettings" dbtype="query" >
				SELECT	*
				FROM	local.getMMDetectionSettings
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

	<!--- ********** display object/s ************ --->	

	<cffunction name="renderApp" output="false">
		<cfargument name="$" required="true" hint="mura scope" />
		<cfargument name="action" required="false" default="" 
			hint="if only rendering a 'widget', then pass in the action such as 'public:main.default' ... otherwise, just leave it blank!" />
		<cfreturn doEvent(arguments.$,arguments.action) />
	</cffunction>

	<!--- ********** FW/1 ************* --->

	<cffunction name="doEvent" output="false">
		<cfargument name="$" required="true" />
		<cfargument name="action" type="string" required="false" default="" 
					hint="Optional: If not passed it looks into the event for a defined action, else it uses the default" />
		<cfreturn doAction(arguments.$,arguments.action) />
	</cffunction>
	
	<cffunction name="doAction" output="false">
		<cfargument name="$" />
		<cfargument name="action" type="string" required="false" default="" 
					hint="Optional: If not passed it looks into the event for a defined action, else it uses the default" />
		<cfscript>
			var local = StructNew();
			var state = StructNew();
			var result = '';
			var savedEvent = '';
			var savedAction = '';
			var fw1 = CreateObject('component','#pluginConfig.getPackage()#.Application');

			// Put the event url struct, to be used by FW/1
			url.$ = arguments.$;
			if ( not len( arguments.action ) ) {
				if ( len(arguments.$.event(variables.framework.action)) ) {
					arguments.action = arguments.$.event(variables.framework.action);
				} else {
					arguments.action = variables.framework.home;
				};
			};
		
			// put the action passed into the url scope, saving any pre-existing value
			if ( StructKeyExists(request, variables.framework.action) ) {
				savedEvent = request[variables.framework.action];
			};

			if ( StructKeyExists(url,variables.framework.action) ) {
				savedAction = url[variables.framework.action];
			};

			url[variables.framework.action] = arguments.action;
			state = preseveInternalState(request);

			// call the frameworks onRequestStart
			fw1.onRequestStart(CGI.SCRIPT_NAME);
		</cfscript>

		<!--- call the frameworks onRequest --->
		<!--- we save the results via cfsavecontent so we can display it in mura --->
		<cfsavecontent variable="result">
			<cfset fw1.onRequest(CGI.SCRIPT_NAME) />
		</cfsavecontent>
		
		<cfscript>
			// restore the url scope
			if ( StructKeyExists(url,variables.framework.action) ) {
				StructDelete(url,variables.framework.action);
			};

			// if there was a passed in action via the url then restore it
			if ( Len(savedAction) ) {
				url[variables.framework.action] = savedAction;
			};

			// if there was a passed in request event then restore it
			if ( Len(savedEvent) ) {
				request[variables.framework.action] = savedEvent;
			};
			
			restoreInternalState(request,state);

			return result;
		</cfscript>
	</cffunction>

	<cffunction name="checkFrameworkConfig" output="false">
		<cfargument name="$" />
		<cfset var str="">
		<cfset var configPath="#expandPath('/plugins')#/#variables.pluginConfig.getDirectory()#/frameworkConfig.cfm">
		<cfset var lineBreak=chr(13) & chr(10)>
		<cfif variables.framework.applicationKey neq variables.pluginConfig.getPackage() & lineBreak>
			<cfset str='<cfset variables.framework=structNew()>' & lineBreak>
			<cfset str=str & '<cfset variables.framework.applicationKey="#variables.pluginConfig.getPackage()#">' & lineBreak>
			<cfset str=str & '<cfset variables.framework.base="/#variables.pluginConfig.getPackage()#">' & lineBreak>
			<cfset str=str & '<cfset variables.framework.usingsubsystems=false>' & lineBreak>
			<cfset str=str & '<cfset variables.framework.action="action">' & lineBreak>
			<cfset str=str & '<cfset variables.framework.home="main.default">' & lineBreak>
			<cfset str=str & '<cfset variables.framework.baseURL="useRequestURI">' & lineBreak>
			<cfset str=str & '<cfset variables.framework.SESOmitIndex="true">' & lineBreak>
			<cfset $.getBean('fileWriter').writeFile(file=configPath, output=str)>
			<cfinclude template="../fw1config.cfm">
		</cfif>
	</cffunction>
	
	<cffunction name="preseveInternalState" output="false">
		<cfargument name="state" />
		<cfset var preserveKeys=structNew()>
		<cfset var k="">

		<cfif StructKeyExists(request, 'controllers')>
			<cfset StructDelete(request, 'controllers') />
		</cfif>
		
		<cfloop list="#variables.preserveKeyList#" index="k">
			<cfif isDefined("arguments.state.#k#")>
				<cfset preserveKeys[k]=arguments.state[k]>
				<cfset structDelete(arguments.state,k)>
			</cfif>
		</cfloop>
		<cfset structDelete( arguments.state, "serviceExecutionComplete" )>
		<cfreturn preserveKeys>
	</cffunction>
	
	<cffunction name="restoreInternalState" output="false">
		<cfargument name="state" />
		<cfargument name="restore" />
		<cfloop list="#variables.preserveKeyList#" index="k">
			<cfset StructDelete(arguments.state,k)>
		</cfloop>
		<cfset StructAppend( state,restore, true )>
		<cfset StructDelete( state, "serviceExecutionComplete" )>
	</cffunction>

	<!--- apparently needed for CF8 (thanks Grant Shepert!) --->
	<cffunction name="getFramework" output="false" returntype="any">
		<cfset var framework = StructNew() />
		<cfinclude template="../fw1config.cfm" />
		<cfreturn framework />
	</cffunction>

</cfcomponent>