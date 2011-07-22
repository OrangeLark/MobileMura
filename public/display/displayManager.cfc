<!---

MobileMura/public/display/displayManager.cfc

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

<cfcomponent name="displayManager" output="false" extends="mura.plugin.pluginGenericEventHandler">

	<cfinclude template="../../fw1config.cfm">
	
	<cffunction name="doEvent">
		<cfargument name="$">
		<cfargument name="action" type="string" required="false" default="" hint="Optional: If not passed it looks into the event for a defined action, else it uses the default"/>
		
		<cfparam name="params" default="" />
		
		<cfset var result = "" />
		<cfset var savedEvent = "" />
		<cfset var savedAction = "" />
		<cfset var fw1 = createObject("component","#pluginConfig.getPackage()#.Application") />
		<cfif isJSON( $.event().getValue("params") )>
			<cfset request.context.params = deserializeJSON( $.event().getValue("params") ) />
		</cfif>

		<!--- remember to name the subsystem ... less expensive than parsing out on every request --->
		<cfset variables.subsystem = "public:" />

		<cfif not isStruct(params)>
			<cfset params = StructNew() />
		</cfif>
			
		<cfset url.$ = $ />

		<cfif StructKeyExists(params,"action")>
			<cfset arguments.action = variables.subsystem & params.action />
		<cfelseif not len( arguments.action )>
			<cfif len(arguments.$.event(variables.framework.action))>
				<cfset arguments.action = variables.subsystem & arguments.$.event(variables.framework.action)>
			<cfelse>
				<cfset arguments.action = variables.subsystem & variables.framework.home>
			</cfif>
		<cfelse>
			<cfset arguments.action = variables.subsystem & arguments.action>
		</cfif>

		<!--- put the action passed into the url scope, saving any pre-existing value --->
		<cfif StructKeyExists(request, variables.framework.action)>
			<cfset savedEvent = request[variables.framework.action] />
		</cfif>
		<cfif StructKeyExists(url,variables.framework.action)>
			<cfset savedAction = url[variables.framework.action] />
		</cfif>
		
		<cfset url[variables.framework.action] = arguments.action />
		
		<!--- call the frameworks onRequestStart --->
		<cfset fw1.onRequestStart(CGI.SCRIPT_NAME) />

		<cfset request.context.params = params />
		
		<!--- call the frameworks onRequest --->
		<!--- we save the results via cfsavecontent so we can display it in mura --->
		<cfsavecontent variable="result">
			<cfset fw1.onRequest(CGI.SCRIPT_NAME) />
		</cfsavecontent>
		
		<!--- restore the url scope --->
		<cfif structKeyExists(url,variables.framework.action)>
			<cfset structDelete(url,variables.framework.action) />
		</cfif>
		<!--- if there was a passed in action via the url then restore it --->
		<cfif Len(savedAction)>
			<cfset url[variables.framework.action] = savedAction />
		</cfif>
		<!--- if there was a passed in request event then restore it --->
		<cfif Len(savedEvent)>
			<cfset request[variables.framework.action] = savedEvent />
		</cfif>

		<!--- remove the content from the request scope --->
		<cfset structDelete( request, "context" )>
		<cfset structDelete( request, "serviceExecutionComplete" )>
		<cfset structDelete( request, "controllerExecutionStarted" )>

		<!--- return the result --->
		<cfreturn result>
	</cffunction>

	<!--- ADD CUSTOMIZATIONS BELOW --->

	<cffunction name="mobileSwitcher" output="false" returntype="String" >
		<cfargument name="$">

		<cfreturn doEvent(arguments.$,"main.mobileSwitcher")>
	</cffunction>

</cfcomponent>