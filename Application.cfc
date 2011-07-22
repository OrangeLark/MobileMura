<!---

MobileMura/Application.cfc

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

<cfcomponent extends="fw1">

	<cfinclude template="../../config/applicationSettings.cfm" />
	<cfinclude template="../../config/mappings.cfm" />
	<cfinclude template="../mappings.cfm" />
	<cfset variables.framework = getFramework() />

	<!--- ********************** fw/1-specific *************************** --->
	<cffunction name="setupApplication" output="false">
		<cfscript>
			var local = StructNew();
		</cfscript>
		<cflock type="exclusive" timeout="50">
			<cfscript>
				// THIS IS CRITICIAL!! This is what gives this FW/1 app access to it's own pluginConfig within Mura CMS
				// in the setupRequest() it is also assigned to request.context to allow you to access the pluginConfig with 'rc.pc' OR 'rc.pluginConfig'
				application[variables.framework.applicationKey].pluginConfig = application.pluginManager.getConfig(ID=variables.framework.applicationKey);
				local.pc = application[variables.framework.applicationKey].pluginConfig;
				setBeanFactory(local.pc.getApplication(purge=false));
			</cfscript>
		</cflock>
	</cffunction>

	<cffunction name="setupRequest">
		<cfscript>
			var local = StructNew();

			secureRequest();
			request.context.isAdminRequest = isAdminRequest();
			request.context.isFrontEndRequest = isFrontEndRequest();
			
			if ( StructKeyExists(url, application.configBean.getAppReloadKey()) ) { 
				setupApplication();
			};

			// rc.$
			if ( not StructKeyExists(request.context, '$') and StructKeyExists(session, 'siteid') ) {
				request.context.$ = getBeanFactory().getBean('muraScope').init(session.siteid);
			};

			// rc.pc and rc.pluginConfig
			request.context.pc = application[variables.framework.applicationKey].pluginConfig;
			request.context.pluginConfig = application[variables.framework.applicationKey].pluginConfig;
			
			// rc.mm
			request.context.mm = createObject("component","MobileMura");
		</cfscript>
	</cffunction>

	<cffunction name="onMissingView" output="true">
		<cfargument name="rc" />
		<cfscript>
			var local = StructNew();			
			local.eMessage = "The page you're looking for ";
			// rc.action SHOULD always be there, but just in case...
			if ( StructKeyExists(arguments.rc, 'action') ) {
				local.eMessage = local.eMessage & '<em>' & rc.action & '</em> ';
			};
			local.eMessage = local.eMessage & " doesn't exist.";
			
			rc.errors = ArrayNew(1);
			ArrayAppend(rc.errors, local.eMessage);
			
			// forward to appropriate error screen
			if ( isFrontEndRequest() ) {
				redirect(action='public:main.error',preserve='errors');
			} else {
				redirect(action='admin:main.error',preserve='errors');
			};
		</cfscript>
	</cffunction>

	<!--- ********************** HELPERS / Mura-specific *************************** --->
	<cffunction name="secureRequest" output="false">
		<cfif isAdminRequest() and not IsUserInRole('S2')>
			<cfif not StructKeyExists(session,'siteID') or not application.permUtility.getModulePerm(getBeanFactory('pluginConfig').getValue('moduleID'),session.siteid)>
				<cflocation url="#application.configBean.getContext()#/admin/" addtoken="false" />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="isAdminRequest" output="false" returntype="boolean">
		<cfscript>
			if ( StructKeyExists(request, 'action') and ListFirst(request.action, ':') eq 'admin' ) {
				return true;
			} else {
				return false;
			};
		</cfscript>
	</cffunction>

	<cffunction name="isFrontEndRequest" output="false" returntype="boolean">
		<cfreturn StructKeyExists(request, 'murascope') />
	</cffunction>

	<!--- apparently needed for CF8 (thanks Grant Shepert!) --->
	<cffunction name="getFramework" output="false" returntype="any">
		<cfset var framework = StructNew() />
		<cfinclude template="fw1config.cfm" />
		<cfreturn framework />
	</cffunction>

</cfcomponent>