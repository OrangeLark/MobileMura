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
		
		<!--- add logic --->
		
    </cffunction>

	<cffunction name="onRenderStart" output="false" returntype="any">
		<cfargument name="$" />
		<cfscript>
			// this allows you to call methods here by accessing '$.mfw1.methodName(argumentCollection=args)'
			$.mfw1 = this;
		</cfscript>
	</cffunction>

	<cffunction name="standardMobileHandler" output="false" returntype="any">
		<cfargument name="$" />

<!---		
		<cfset MobileMura = createObject("component","#pluginConfig.getPackage()#.MobileMura") />
		
		<cfset MobileMura.updateTemplate($.content()) />
		<cfset MobileMura.updateTheme($) />

		<cfset renderer.showAdminToolbar=false>
		<cfset renderer.showMemberToolbar=false>
		<cfset renderer.showEditableObjects=false>
--->
		<cfreturn />
	</cffunction>

	<cffunction name="onContentEdit" returntype="any" output="true">
		<cfargument name="$" />
		
		<cfinclude template="onContentEdit.cfm" />
		
		<cfreturn />
	</cffunction>

	<cffunction name="onAfterContentSave" returntype="any" output="true">
		<cfargument name="$" />
		
		<cfset var local = StructNew() />
		<cfset local.dsn = $.globalConfig().getDatasource() />
		
		<cfquery name="local.checkContent" datasource="#local.dsn#" >
			SELECT	*
			FROM	mm_content
			WHERE	content_id = '#$.content().getContentId()#'
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
				('#createUUID()#', '#$.content().getSiteId()#', '#$.content().getCOntentId()#', #$.event("mobiletemplate")#)
			</cfif>
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