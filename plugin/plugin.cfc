<!---

MobileMura/plugin/plugin.cfc

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

<cfcomponent output="false" extends="mura.plugin.plugincfc">

	<cfset variables.config = '' />

	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="config"  type="any" default="" />
		<cfscript>
			variables.config = arguments.config;
		</cfscript>
	</cffunction>
	
	<cffunction name="install" returntype="void" access="public" output="false">

		<cfset var local = StructNew()/>
	
		<!--- need to check and see if this is already installed ... if so, then abort! --->
		<cfset local.moduleid = variables.config.getModuleID()/>
	
		<!--- comment this out if you want to allow more than 1 installation of this plugin per Mura CMS 
		install. --->
		<cfif (val(getInstallationCount()) neq 1)>
			<cfset variables.config.getPluginManager().deletePlugin(local.moduleid)/>
		<cfelse>
			
			<cfset $ = application.serviceFactory.getBean("muraScope")/>
			<cfset local.dsn = $.globalConfig().getDatasource() />

			<!--- CREATE TABLES --->
			<cfset this.createMMUASettingsTable() />
			<cfset this.createMMContentTable() />
			<cfset this.createMMDetectionTable() />
			
			<!--- SETUP SITES --->
			<cfset this.setupSites(local.dsn) />
			
		</cfif>
		<cfset application.appInitialized = false/>

	</cffunction>
	
	<cffunction name="update" returntype="void" access="public" output="false">		

		<cfset var local = StructNew()/>
	
		<cfscript>
			// this will be executed by the pluginManager when the plugin is updated.
			application.appInitialized = false;
		</cfscript>

		<cfset $ = application.serviceFactory.getBean("muraScope")/>
		<cfset local.dsn = $.globalConfig().getDatasource() />

		<!--- CREATE TABLES --->
		<cfset this.createMMUASettingsTable() />
		<cfset this.createMMContentTable() />
		<cfset this.createMMDetectionTable() />
		
		<!--- SETUP SITES --->
		<cfset this.setupSites(local.dsn) />
		
	</cffunction>
	
	<cffunction name="delete" returntype="void" access="public" output="true">

		<cfset var local = StructNew()/>
		
		<cfdump var="#variables.configBean.getDatasource()#" >
		<cfabort />

		<cfset this.deleteMMUASettings() />
		<cfset this.deleteMMContent() />
		<cfset this.deleteMMDetection() />

		<cfset application.appInitialized = false/>
		
	</cffunction>
	
	<cffunction name="toBundle" returntype="void" access="public" output="false">
		<cfargument name="pluginConfig" type="any" default="" >
		<cfargument name="bundle" type="any" default="" >

		<cfset var local = StructNew()/>

		<cfset $ = application.serviceFactory.getBean("muraScope")/>
		<cfset local.dsn = $.globalConfig().getDatasource() />
		
		<!--- BUNDLE TABLES --->
		<cfset arguments.bundle.setValue('mm_MMUASettings', this.bundleMMUASettings(local.dsn)) />
		<cfset arguments.bundle.setValue('mm_MMContent', this.bundleMMContent(local.dsn)) />
		<cfset arguments.bundle.setValue('mm_MMDetection', this.bundleMMDetection(local.dsn)) />
		
	</cffunction>
	
	<cffunction name="fromBundle" returntype="void" access="public" output="false">
		<cfargument name="pluginConfig" type="any" default="" >
		<cfargument name="bundle" type="any" default="" >

		<cfset var local = StructNew()/>

		<cfset $ = application.serviceFactory.getBean("muraScope")/>
		<cfset local.dsn = $.globalConfig().getDatasource() />

		<!--- CREATE TABLES --->
		<cfset this.createMMUASettingsTable() />
		<cfset this.createMMContentTable() />
		<cfset this.createMMDetectionTable() />
		
		<!--- RESTORE DATA --->
		<cfset this.restoreMMUASettings(local.dsn, arguments.bundle.getValue('mm_MMUASettings')) />
		<cfset this.restoreMMContent(local.dsn, arguments.bundle.getValue('mm_MMContent')) />
		<cfset this.restoreMMDetection(local.dsn, arguments.bundle.getValue('mm_MMDetection')) />

	</cffunction>

	<!--- *******************************    private    ******************************** --->
	<cffunction name="createMMUASettingsTable" access="private" returntype="void" output="false" >
		
		<cfset var local = StructNew()/>
		
		<cfset local.dbUtility = $.getBean("dbUtility") />
		
		<cfset local.table = local.dbUtility.setTable('mm_ua_settings') />
		
		<cfset local.table.addColumn(column='mm_ua_settings_id', datatype='char', length='35', nullable='false', default='') />
		<cfset local.table.addColumn(column='site_id', datatype='varchar', length='25', nullable='false', default='') />
		<cfset local.table.addColumn(column='name', datatype='varchar', length='50', nullable='false', default='') />
		<cfset local.table.addColumn(column='ua_string', datatype='varchar', length='50', nullable='true', default='') />
		<cfset local.table.addColumn(column='theme', datatype='varchar', length='50', nullable='false', default='') />
		
		<cfset local.table.addPrimaryKey(column='mm_ua_settings_id') />
	</cffunction>
	
	<cffunction name="createMMContentTable" access="private" returntype="void" output="false" >
		<cfset var local = StructNew()/>
		
		<cfset local.dbUtility = $.getBean("dbUtility") />
		
		<cfset local.table = local.dbUtility.setTable('mm_content') />
		
		<cfset local.table.addColumn(column='mm_content_id', datatype='char', length='35', nullable='false', default='') />
		<cfset local.table.addColumn(column='site_id', datatype='varchar', length='25', nullable='false', default='') />
		<cfset local.table.addColumn(column='mm_ua_settings_id', datatype='char', length='35', nullable='false', default='') />
		<cfset local.table.addColumn(column='content_id', datatype='char', length='35', nullable='false', default='') />
		<cfset local.table.addColumn(column='template', datatype='varchar', length='50', nullable='false', default='') />
		
		<cfset local.table.addPrimaryKey(column='mm_content_id') />
	</cffunction>

	<cffunction name="createMMDetectionTable" access="private" returntype="void" output="false" >
		
		<cfset var local = StructNew()/>
		
		<cfset local.dbUtility = $.getBean("dbUtility") />
		
		<cfset local.table = local.dbUtility.setTable('mm_detection') />
		
		<cfset local.table.addColumn(column='site_id', datatype='varchar', length='25', nullable='false', default='') />
		<cfset local.table.addColumn(column='detection', datatype='varchar', length='50', nullable='false', default='') />
		<cfset local.table.addColumn(column='theme', datatype='varchar', length='50', nullable='false', default='') />
		
		<cfset local.table.addPrimaryKey(column='site_id') />
	</cffunction>

	<cffunction name="setupSites" access="private" returntype="void" output="false" >
		<cfargument name="dsn" required="true" >
		<cfset var local = StructNew()/>
		
		<cfset local.installedSites = variables.config.getAssignedSites() />
		
		<cfloop query="local.installedSites" >

			<cfquery datasource="#arguments.dsn#" name="local.checkSiteSetup">
				SELECT	*
				FROM	mm_detection
				WHERE	site_id = '#local.installedSites.siteID#'
			</cfquery>
			
			<cfif NOT local.checkSiteSetup.recordCount>
				<cfquery name="insertMMDetection" datasource="#arguments.dsn#" >
					INSERT INTO mm_detection (site_id, detection, theme)
					VALUES
					('#local.installedSites.siteID#','1','')
				</cfquery>
			</cfif>
		
		</cfloop>
	</cffunction>

	<cffunction name="bundleMMUASettings" access="private" returntype="any" output="false" >
		<cfargument name="dsn" required="true" >

		<cfset var local = StructNew()/>
		
		<cfquery name="local.getMMUASettings" datasource="#arguments.dsn#" >
			SELECT	*
			FROM	mm_ua_settings
		</cfquery>
		
		<cfreturn local.getMMUASettings />
	</cffunction>

	<cffunction name="bundleMMContent" access="private" returntype="any" output="false" >
		<cfargument name="dsn" required="true" >

		<cfset var local = StructNew()/>
		
		<cfquery name="local.getMMContent" datasource="#arguments.dsn#" >
			SELECT	*
			FROM	mm_content
		</cfquery>
		
		<cfreturn local.getMMContent />
	</cffunction>

	<cffunction name="bundleMMDetection" access="private" returntype="any" output="false" >
		<cfargument name="dsn" required="true" >

		<cfset var local = StructNew()/>
		
		<cfquery name="local.getMMDetection" datasource="#arguments.dsn#" >
			SELECT	*
			FROM	mm_detection
		</cfquery>
		
		<cfreturn local.getMMDetection />
	</cffunction>

	<cffunction name="restoreMMUASettings" access="private" returntype="void" output="false" >
		<cfargument name="dsn" required="true" >
		<cfargument name="settings" required="true" >

		<cfset var local = StructNew()/>
		
		<cfquery datasource="#arguments.dsn#" name="truncateMMUASettings">
			TRUNCATE TABLE mm_ua_settings
		</cfquery>
		
		<cfif arguments.settings.recordcount>
			<cfquery name="insertMMUASettings" datasource="#arguments.dsn#" >
				INSERT INTO mm_ua_settings (mm_ua_settings_id, site_id, name, ua_string, theme)
				VALUES
				<cfloop query="arguments.settings" >
				<cfif arguments.settings.CurrentRow NEQ 1>,</cfif>
				('#arguments.settings.mm_ua_settings_id#','#arguments.settings.site_id#','#arguments.settings.name#','#arguments.settings.ua_string#','#arguments.settings.theme#')
				</cfloop>
			</cfquery>
		</cfif>
	</cffunction>

	<cffunction name="restoreMMContent" access="private" returntype="void" output="false" >
		<cfargument name="dsn" required="true" >
		<cfargument name="content" required="true" >

		<cfset var local = StructNew()/>
		
		<cfquery datasource="#arguments.dsn#" name="truncateMMContent">
			TRUNCATE TABLE mm_content
		</cfquery>
		
		<cfif arguments.content.recordcount>
			<cfquery name="insertMMContent" datasource="#arguments.dsn#" >
				INSERT INTO mm_content_id (mm_content_id, site_id, mm_ua_settings_id, content_id, template)
				VALUES
				<cfloop query="arguments.content" >
				<cfif arguments.content.CurrentRow NEQ 1>,</cfif>
				('#arguments.content.mm_content_id#','#arguments.content.site_id#','#arguments.content.mm_ua_settings_id#','#arguments.content.content_id#','#arguments.content.template#')
				</cfloop>
			</cfquery>
		</cfif>
	</cffunction>

	<cffunction name="restoreMMDetection" access="private" returntype="void" output="false" >
		<cfargument name="dsn" required="true" >
		<cfargument name="detection" required="true" >

		<cfset var local = StructNew()/>
		
		<cfquery datasource="#arguments.dsn#" name="truncateMMDetection">
			TRUNCATE TABLE mm_detection
		</cfquery>
		
		<cfif arguments.detection.recordcount>
			<cfquery name="insertMMDetection" datasource="#arguments.dsn#" >
				INSERT INTO mm_detection (site_id, detection, theme)
				VALUES
				<cfloop query="arguments.detection" >
				<cfif arguments.detection.CurrentRow NEQ 1>,</cfif>
				('#arguments.detection.site_id#','#arguments.detection.detection#','#arguments.detection.theme#')
				</cfloop>
			</cfquery>
		</cfif>
	</cffunction>
	
	<cffunction name="deleteMMUASettings" access="private" returntype="void" output="false" >

		<cfset var local = StructNew()/>
		
		<cfset local.dbUtility = $.getBean("dbUtility") />
		
		<cfset local.dbUtility.dropTable('mm_ua_settings') />

	</cffunction>
	
	<cffunction name="deleteMMContent" access="private" returntype="void" output="false" >

		<cfset var local = StructNew()/>
		
		<cfset local.dbUtility = $.getBean("dbUtility") />
		
		<cfset local.dbUtility.dropTable('mm_content') />

	</cffunction>
	
	<cffunction name="deleteMMDetection" access="private" returntype="void" output="false" >

		<cfset var local = StructNew()/>
		
		<cfset local.dbUtility = $.getBean("dbUtility") />
		
		<cfset local.dbUtility.dropTable('mm_detection') />

	</cffunction>
	
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