<cfsilent>
<!---

This file is part of muraFW1
(c) Stephen J. Withington, Jr. | www.stephenwithington.com

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

		Document:	/admin/views/main/default.cfm
		Author:		Steve Withington | www.stephenwithington.com
		Modified:	2011.02.04

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