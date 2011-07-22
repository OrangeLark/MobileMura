<cfsilent>
<!---

MobileMura/admin/views/settings/settings.cfm

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
</cfsilent>

<cfoutput>
	<h3>Settings</h3>	
	<h4>Mobile Theme</h4>

	<cfif StructKeyExists(URL, "saved") AND URL.saved>
		<p color="red">Changes saved!</p>
	</cfif>
	
	<form method="POST" action="?action=admin:settings.saveSettings">
		<cfloop query="rc.assignedSites">
			<cfset siteStruct.siteID = rc.assignedSites.siteid />
			<cfset $.init(siteStruct) />
			<cfset themes = $.siteConfig().getThemes() />
			
			<div style="float:left; width: 150px;">
				#rc.assignedSites.siteid#
			</div>
			<div>
				<select name="mobileTheme#rc.assignedSites.siteid#">
					<option <cfif rc.mm.getMobileMuraData(rc.assignedSites.siteid).getMobileTheme() EQ "">selected="selected"</cfif>>No mobile theme selected</option>
					<cfloop query="themes">
						<option value="#themes.name#" <cfif rc.mm.getMobileMuraData(rc.assignedSites.siteid).getMobileTheme() EQ themes.name>selected="selected"</cfif>>#themes.name#</option>
					</cfloop>
				</select>
			</div>
			</hr>
		</cfloop>
		<div style="float:left; width: 150px;">&nbsp;</div>
		<div><input type="submit" value="Save Site Settings" /></div>
	</form>

</cfoutput>