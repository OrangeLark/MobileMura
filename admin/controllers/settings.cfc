<!---

MobileMura/admin/controllers/settings.cfc

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

<cfcomponent extends="mura.cfobject" output="false">

	<cfscript>
		variables.fw = '';

		function init ( fw ) {
			variables.fw = arguments.fw;
		};

		function before ( rc ) {
			var $ = StructNew();
			if ( StructKeyExists(rc, '$') ) {
				$ = rc.$;
			};

			if ( rc.isFrontEndRequest ) {
				fw.redirect(action='public:main.default');
			};
			
		};
	</cfscript>

	<!--- ************ pages *************** --->
	<cffunction name="default" output="false" returntype="any">
		<cfargument name="rc" />
	</cffunction>

	<cffunction name="settings" output="false" returntype="any">
		<cfargument name="rc" />
		
		<cfset rc.msgSave = "" />
		
		<cfset rc.assignedSites = rc.pluginConfig.getAssignedSites() />
	</cffunction>


	<cffunction name="saveSettings" output="false" returntype="any">
		<cfargument name="rc" />
		
		<cfset rc.assignedSites = rc.pluginConfig.getAssignedSites() />
		
		<cfloop query="rc.assignedSites">
			<cfset setMobileMuraData(rc.assignedSites.siteid, evaluate("mobileTheme" & rc.assignedSites.siteid)) />
		</cfloop>
		
		<cfset variables.fw.redirect("admin:settings.settings&saved=true") />
	</cffunction>

	<!--- supporting functions --->
	<cffunction name="setMobileMuraData" access="public" output="false" returntype="any">
		<cfargument name="siteID" type="string" required="true">
		<cfargument name="MobileTheme" type="any" required="true">
	
		<cfset var myDataObject	= createObject("component","mura.extend.extendObject").init(Type="Custom",SubType="MobileMuraData",SiteID=arguments.siteID)>
	
		<cfset myDataObject.setID( siteID ) />
		<cfset myDataObject.setMobileTheme( arguments.MobileTheme ) />
		<cfset myDataObject.save() />
	
		<cfreturn myDataObject />
	</cffunction>
	
	<cffunction name="getMobileMuraData" access="public" output="false" returntype="any">
		<cfargument name="siteID" type="string" required="true">
	
		<cfset var myDataObject	= createObject("component","mura.extend.extendObject").init(Type="Custom",SubType="MobileMuraData",SiteID=arguments.siteID)>
	
		<cfset myDataObject.setID( siteID ) />
	
		<cfreturn myDataObject />
	</cffunction>

</cfcomponent>