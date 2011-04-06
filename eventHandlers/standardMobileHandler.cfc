
<!---

MobileMura/eventHandlers/onRenderStart.cfc

Copyright 2010 Guust Nieuwenhuis 

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

	<cffunction name="standardMobileHandler" output="false" returntype="any">
		<cfargument name="event" />
		
		<cfset updateTemplate($.content()) />
		<cfset updateTheme($) />

		<cfset renderer.showAdminToolbar=false>
		<cfset renderer.showMemberToolbar=false>
		<cfset renderer.showEditableObjects=false>
		
		<cfreturn />
	</cffunction>
	
	<cffunction name="updateTemplate" output="false" returntype="any" access="public" >
		<cfargument name="contentBean" />
		
		<cfset var $ = application.serviceFactory.getBean("muraScope").init(session.siteID) />

		<cfset var c = arguments.contentBean />
		<cfset var p = arguments.contentBean />
		
		<cfset var mobileTemplate = "" />
		
		<!--- check if a template is set --->
		<!--- inherit from parent == empty string --->
		<!--- if the template is an empty string: look for the parents template --->
		<cfloop condition="NOT Len(c.getTemplate())" >
			<!--- get the template --->
			<cfset c = c.getParent() />
		</cfloop>
		
		<!--- the 'mobiletemplate' is set --->
		<cfif Len(arguments.contentBean.getValue("mobiletemplate"))>
			
			<!--- Inherit From Parent --->
			<cfif arguments.contentBean.getValue("mobiletemplate") EQ "-1">
				<cfset i = true />
				<cfloop condition="i" >
					<cfif p.hasParent()>
						<cfset p = p.getParent() />

						<cfif Len(p.getExtendedAttribute("mobiletemplate"))>
							<cfif p.getExtendedAttribute("mobiletemplate") EQ "-1">
								
							<cfelseif p.getExtendedAttribute("mobiletemplate") EQ "0">
								<cfset mobileTemplate = p.getTemplate() />
								<cfset i = false />
							<cfelse>
								<cfset mobileTemplate = p.getExtendedAttribute("mobiletemplate") />
								<cfset i = false />
							</cfif>
						</cfif>
					<cfelse>
						<cfset mobileTemplate = p.getTemplate() />
						<cfset i = false />
					</cfif>
				</cfloop>
			
			<!--- Desktop Template --->
			<cfelseif arguments.contentBean.getValue("mobiletemplate") EQ "-2">
				<cfset mobileTemplate = "" />
			<cfelse>
				<cfset mobileTemplate = arguments.contentBean.getValue("mobiletemplate") />
			</cfif>
			
		<!--- the 'mobiletemplate' isn't set --->
		<cfelse>
			<cfset mobileTemplate = "" />
		</cfif>
		
		<!--- if a mobiletemplate is set and if the file exists --->
		<cfif Len(mobileTemplate) AND FileExists($.siteConfig().getTemplateIncludeDir() & "/" & mobileTemplate)>
			<!--- change the template --->
			<cfset arguments.contentBean.setTemplate(mobileTemplate) />
		</cfif>

		<cfreturn />
	</cffunction>
	
	<cffunction name="updateTheme" output="false" returntype="any">
		<cfargument name="MuraScope" type="Any" required="true">

		<cflog log="MobileMura" type="information" text="MobileTheme: #getMobileMuraData(session.siteid).getMobileTheme()#" />

		<cfif Len(getMobileMuraData(session.siteid).getMobileTheme())>
			<cflog log="MobileMura" type="information" text="entered cfif" />
			<cfset MuraScope.event("altTheme",getMobileMuraData(session.siteid).getMobileTheme()) />
			<cflog log="MobileMura" type="information" text="altTheme: #MuraScope.event('altTheme')#" />
		</cfif>
		
		<cfreturn />
	</cffunction>
	
	<cffunction name="getMobileMuraData" output="false" returntype="any">
		<cfargument name="siteID" type="Any" required="true">
	
		<cfset var myDataObject	= createObject("component","mura.extend.extendObject").init(Type="Custom",SubType="MobileMuraData",SiteID=arguments.siteID)>
	
		<cfset myDataObject.setID( siteID ) />
	
		<cfreturn myDataObject />
	</cffunction>

</cfcomponent>