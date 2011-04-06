
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

<cfinclude template="MobileMuraData.cfm" />

<cfset assignedSites = variables.pluginConfig.getAssignedSites() />

<cfset msgSave = "" />

<cfif StructKeyExists(URL, "processForm") AND URL.processForm>
	
	<cfloop query="assignedSites">
		<cfset setMobileMuraData(assignedSites.siteid, evaluate("mobileTheme" & assignedSites.siteid)) />
	</cfloop>
	
	<cfset msgSave = "Changes saved!" />
</cfif>

<cfsavecontent variable="body">
	<cfoutput>
		<cfif Len(msgSave)>
			<p color="red">#msgSave#</p>
		</cfif>
		<h2>#pluginConfig.getName()#</h2>
		<h3>Settings</h3>
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
						<option <cfif getMobileMuraData(assignedSites.siteid).getMobileTheme() EQ "">selected="selected"</cfif>>No mobile theme selected</option>
						<cfloop query="themes">
							<option value="#themes.name#" <cfif getMobileMuraData(assignedSites.siteid).getMobileTheme() EQ themes.name>selected="selected"</cfif>>#themes.name#</option>
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
