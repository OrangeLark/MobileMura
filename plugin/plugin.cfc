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
			<cfset this.createMMValidationTable() />
			
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
		<cfset this.createMMValidationTable() />
		
		<!--- SETUP SITES --->
		<cfset this.setupSites(local.dsn) />
		
	</cffunction>
	
	<cffunction name="delete" returntype="void" access="public" output="true">

		<cfset var local = StructNew()/>
		
		<cfdump var="#variables.configBean.getDatasource()#" >
		<cfabort />

		<cfquery datasource="#variables.configBean.getDatasource()#" username="#variables.configBean.getDbUsername()#" password="#variables.configBean.getDbPassword()#">
			DROP TABLE mm_ua_settings
		</cfquery>

		<cfquery datasource="#variables.configBean.getDatasource()#" username="#variables.configBean.getDbUsername()#" password="#variables.configBean.getDbPassword()#">
			DROP TABLE mm_content
		</cfquery>

<!---
		<cfset this.deleteMMUASettings() />
		<cfset this.deleteMMContent() />
		<cfset this.deleteMMValidation() />
--->
		<cfset application.appInitialized = false/>
		
	</cffunction>
	
	<cffunction name="toBundle" returntype="void" access="public" output="false">

		<cfset var local = StructNew()/>

		<cfset $ = application.serviceFactory.getBean("muraScope")/>
		<cfset local.dsn = $.globalConfig().getDatasource() />
		
		<cfset local.dbBundle = $.getPlugin("MobileMura").GETFULLPATH() & "/plugin/dbBundle" />
		<cfif NOT directoryExists(local.dbBundle)>
			<cfset directoryCreate(local.dbBundle) />
		</cfif>
		
		<!--- BUNDLE TABLES --->
		<cfset this.bundleMMUASettings(local.dsn) />
		<cfset this.bundleMMContent(local.dsn) />
		<cfset this.bundleMMValidation(local.dsn) />
		
	</cffunction>
	
	<cffunction name="fromBundle" returntype="void" access="public" output="false">

		<cfset var local = StructNew()/>

		<cfset $ = application.serviceFactory.getBean("muraScope")/>
		<cfset local.dsn = $.globalConfig().getDatasource() />
		
		<cfset local.dbBundle = $.getPlugin("MobileMura").GETFULLPATH() & "/plugin/dbBundle" />
		<cfif NOT directoryExists(local.dbBundle)>
			<cfset directoryCreate(local.dbBundle) />
		</cfif>

		<!--- CREATE TABLES --->
		<cfset this.createMMUASettingsTable() />
		<cfset this.createMMContentTable() />
		<cfset this.createMMValidationTable() />
		
		<!--- RESTORE DATA --->
		<cfset this.restoreMMUASettings(local.dsn) />
		<cfset this.restoreMMContent(local.dsn) />
		<cfset this.restoreMMValidation(local.dsn) />

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

	<cffunction name="createMMValidationTable" access="private" returntype="void" output="false" >
		
		<cfset var local = StructNew()/>
		
		<cfset local.dbUtility = $.getBean("dbUtility") />
		
		<cfset local.table = local.dbUtility.setTable('mm_validation') />
		
		<cfset local.table.addColumn(column='site_id', datatype='varchar', length='25', nullable='false', default='') />
		<cfset local.table.addColumn(column='validation', datatype='varchar', length='50', nullable='false', default='') />
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
				FROM	mm_validation
				WHERE	site_id = '#local.installedSites.siteID#'
			</cfquery>
			
			<cfif NOT local.checkSiteSetup.recordCount>
				<cfquery name="insertMMValidation" datasource="#arguments.dsn#" >
					INSERT INTO mm_validation (site_id, validation, theme)
					VALUES
					('#local.installedSites.siteID#','1','')
				</cfquery>
			</cfif>
		
		</cfloop>
	</cffunction>

	<cffunction name="bundleMMUASettings" access="private" returntype="void" output="false" >
		<cfargument name="dsn" required="true" >
		<cfset var local = StructNew()/>
		
		<cfquery name="local.getMMUASettings" datasource="#arguments.dsn#" >
			SELECT	*
			FROM	mm_ua_settings
		</cfquery>
		
		<cfwddx action="cfml2wddx" input="#local.getMMUASettings#" output="local.temp">
		<cffile action="write" output="#local.temp#" file="dbBundle/wddx_mm_ua_settings.xml" charset="utf-8">
	</cffunction>

	<cffunction name="bundleMMContent" access="private" returntype="void" output="false" >
		<cfargument name="dsn" required="true" >
		<cfset var local = StructNew()/>
		
		<cfquery name="local.getMMContent" datasource="#arguments.dsn#" >
			SELECT	*
			FROM	mm_content
		</cfquery>
		
		<cfwddx action="cfml2wddx" input="#local.getMMContent#" output="local.temp">
		<cffile action="write" output="#local.temp#" file="dbBundle/wddx_mm_content.xml" charset="utf-8">
	</cffunction>

	<cffunction name="bundleMMValidation" access="private" returntype="void" output="false" >
		<cfargument name="dsn" required="true" >
		<cfset var local = StructNew()/>
		
		<cfquery name="local.getMMValidation" datasource="#arguments.dsn#" >
			SELECT	*
			FROM	mm_validation
		</cfquery>
		
		<cfwddx action="cfml2wddx" input="#local.getMMValidation#" output="local.temp">
		<cffile action="write" output="#local.temp#" file="dbBundle/wddx_mm_validation.xml" charset="utf-8">
	</cffunction>

	<cffunction name="restoreMMUASettings" access="private" returntype="void" output="false" >
		<cfargument name="dsn" required="true" >
		<cfset var local = StructNew()/>
		
		<cfquery datasource="#arguments.dsn#" name="truncateMMUASettings">
			TRUNCATE TABLE mm_ua_settings
		</cfquery>
		
		<cffile action="read" file="dbBundle/wddx_mm_ua_settings.xml" variable="local.importWDDX" charset="utf-8">
		<cfwddx action="wddx2cfml" input=#local.importWDDX# output="importValue">
		
		<cfif importValue.recordcount>
			<cfquery name="insertMMUASettings" datasource="#arguments.dsn#" >
				INSERT INTO mm_ua_settings (mm_ua_settings_id, site_id, name, ua_string, theme)
				VALUES
				<cfloop query="importValue" >
				<cfif importValue.CurrentRow NEQ 1>,</cfif>
				('#importValue.mm_ua_settings_id#','#importValue.site_id#','#importValue.name#','#importValue.ua_string#','#importValue.theme#')
				</cfloop>
			</cfquery>
		</cfif>
	</cffunction>

	<cffunction name="restoreMMContent" access="private" returntype="void" output="false" >
		<cfargument name="dsn" required="true" >
		<cfset var local = StructNew()/>
		
		<cfquery datasource="#arguments.dsn#" name="truncateMMContent">
			TRUNCATE TABLE mm_content
		</cfquery>
		
		<cffile action="read" file="dbBundle/wddx_mm_content.xml" variable="local.importWDDX" charset="utf-8">
		<cfwddx action="wddx2cfml" input=#local.importWDDX# output="importValue">
		
		<cfif importValue.recordcount>
			<cfquery name="insertMMContent" datasource="#arguments.dsn#" >
				INSERT INTO mm_content_id (mm_content_id, site_id, mm_ua_settings_id, content_id, template)
				VALUES
				<cfloop query="importValue" >
				<cfif importValue.CurrentRow NEQ 1>,</cfif>
				('#importValue.mm_content_id#','#importValue.site_id#','#importValue.mm_ua_settings_id#','#importValue.content_id#','#importValue.template#')
				</cfloop>
			</cfquery>
		</cfif>
	</cffunction>

	<cffunction name="restoreMMValidation" access="private" returntype="void" output="false" >
		<cfargument name="dsn" required="true" >
		<cfset var local = StructNew()/>
		
		<cfquery datasource="#arguments.dsn#" name="truncateMMValidation">
			TRUNCATE TABLE mm_validation
		</cfquery>
		
		<cffile action="read" file="dbBundle/wddx_mm_validation.xml" variable="local.importWDDX" charset="utf-8">
		<cfwddx action="wddx2cfml" input=#local.importWDDX# output="importValue">
		
		<cfif importValue.recordcount>
			<cfquery name="insertMMValidation" datasource="#arguments.dsn#" >
				INSERT INTO mm_validation (site_id, validation, theme)
				VALUES
				<cfloop query="importValue" >
				<cfif importValue.CurrentRow NEQ 1>,</cfif>
				('#importValue.site_id#','#importValue.validation#','#importValue.theme#')
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
	
	<cffunction name="deleteMMValidation" access="private" returntype="void" output="false" >

		<cfset var local = StructNew()/>
		
		<cfset local.dbUtility = $.getBean("dbUtility") />
		
		<cfset local.dbUtility.dropTable('mm_validation') />

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