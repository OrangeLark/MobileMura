
<!---

MobileMura/index.cfm

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

<cfinclude template="plugin/config.cfm" />

<cfset assignedSites = variables.pluginConfig.getAssignedSites() />

<cfset mobileThemeStruct = StructNew() />

<cfif StructKeyExists(URL, "processForm") AND URL.processForm>
	<cfloop query="assignedSites">
		<cfset mobileThemeStruct["#assignedSites.siteid#"] = evaluate("FORM.mobileTheme" & assignedSites.siteid) />
	</cfloop>
	<cfwddx action="cfml2wddx" input="#mobileThemeStruct#" output="mobileThemeWDDX" />
	<cffile action="write" file="#getDirectoryFromPath(getCurrentTemplatePath())#plugin/settings.data" output="#mobileThemeWDDX#" />
<cfelseif Len(Trim(pluginConfig.getSetting("mobileThemes")))>
	<cffile action="read" file="#getDirectoryFromPath(getCurrentTemplatePath())#plugin/settings.data" variable="mobileThemeWDDX" />
	<cfwddx action="wddx2cfml" input="#mobileThemeWDDX#" output="mobileThemeStruct" />
<cfelse>
	<cfloop query="assignedSites">
		<cfset mobileThemeStruct["#assignedSites.siteid#"] = "" />
	</cfloop>
</cfif>

<cfsavecontent variable="body">
	<cfoutput>
		<h2>#pluginConfig.getName()#</h2>
<!---
		<p>#pluginConfig.getName()# allows you to display your content different for 'mobile' devices.</p>
		<h3>How to use it</h3>
		<p>When a user visits your website from a 'mobile' device #pluginConfig.getName()# will detect this and will change the template used for rendering the requested page.</p>
		<p>By default #pluginConfig.getName()# will look for the '[regular template name]Mobile.cfm' template.</p>
		<p>Customizing the 'mobile template' is possible in the '#pluginConfig.getName()#' tab shown when editing the page.</p>
		<p>Like with the regular template setting, the default setting will be to inherit from the parent content node.</p>
		<h3>Mobile Switcher</h3>
		<p>Give your 'mobile' visitors the option to switch between the mobile layout/content and the regular layout/content by adding the 'Mobile Switcher' display object to your page.</p>
		<h3>Custom Plugin Settings</h3>
		<h4>Enabled devices</h4>
		<p>Select for witch devices you want to enable #pluginConfig.getName()#.</p>
--->
		<h4>Mobile Theme</h4>
		<form method="POST" action="?processForm=true">
			<cfloop query="assignedSites">
				<cfset siteStruct.siteID = assignedSites.siteid />
				<cfset $.init(siteStruct) />
				<cfset themes = $.siteConfig().getThemes() />
				
				<div style="float:left; width: 150px;">
					#assignedSites.siteid#
				</div>
				<div>
					<select name="mobileTheme#assignedSites.siteid#">
						<option <cfif evaluate('mobileThemeStruct.' & assignedSites.siteid) EQ "">selected="selected"</cfif>></option>
						<cfloop query="themes">
							<option value="#themes.name#" <cfif evaluate('mobileThemeStruct.' & assignedSites.siteid) EQ themes.name>selected="selected"</cfif>>#themes.name#</option>
						</cfloop>
					</select>
				</div>
				</hr>
			</cfloop>
			<div style="float:left; width: 150px;">&nbsp;</div>
			<div><input type="submit" value="Save Site Settings" /></div>
		</form>
	</cfoutput>
</cfsavecontent>

<cfoutput>
#application.pluginManager.renderAdminTemplate(body=body,pageTitle=pluginConfig.getName())#
</cfoutput>
