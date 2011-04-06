
<!---

MobileMura/plugin/config.cfm

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

<cfsilent>
	<cfif not isDefined("pluginConfig")>
		<cfset pluginID=listLast(listGetat(getDirectoryFromPath(getCurrentTemplatePath()),listLen(getDirectoryFromPath(getCurrentTemplatePath()),application.configBean.getFileDelim())-1,application.configBean.getFileDelim()),"_")>
		<cfset pluginConfig=application.pluginManager.getConfig(pluginID)>
		<cfset hasPluginConfig=false>
	<cfelse>
		<cfset hasPluginConfig=true>
	</cfif>
	<cfif not hasPluginConfig and not isUserInRole('S2')>
		<cfif not structKeyExists(session,"siteID") or not application.permUtility.getModulePerm(pluginConfig.getValue('moduleID'),session.siteID)>
			<cflocation url="#application.configBean.getContext()#/admin/" addtoken="false">
		</cfif>
	</cfif>
	<cfif not isDefined("$")>
		<cfset $=application.serviceFactory.getBean("muraScope").init(session.siteid)>
	</cfif>
</cfsilent>