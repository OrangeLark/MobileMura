﻿<!---

MobileMura/admin/views/onContentEdit/onContentEdit.cfm

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

<cfoutput>
<cfif local.getDetection.detection EQ 1>
	<div class="control-group">
		<label class="control-label">
			<a href="##" rel="tooltip" data-original-title="Select the mobile layout file for the page that you are working on.">
			    Mobile Template <i class="icon-info-sign"></i>
			</a>
		</label>
		<div class="controls">
			<select id="mobiletemplate" name="mobiletemplate" class="dropdown" >
				<option selected="selected" value="-1">Inherit From Parent</option>
				<option value="-2">Desktop Template</option>
				<cfloop query="local.mobileTemplates">
				<option value="#local.mobileTemplates.name#" <!---<cfif local.mobileTemplates.name EQ $.content("mobiletemplate") >selected="true"</cfif>--->>
					#local.mobileTemplates.name#
				</option>
				</cfloop>
			</select>
		</div>
	</div>
<cfelse>
	<table class="table table-bordered table-condensed table-bordered">
		<tr>
			<th>Device</th>
			<th>Template</th>
		</tr>
		<cfloop query="local.UASettings">

			<cfif Len(local.UASettings.theme)>
				<cfset local.mobileTemplatesUrl = Replace($.getSite().getConfigBean().getTemplateIncludeDir(), $.getSite().getConfigBean().getTheme(), local.UASettings.theme) />
				<cfdirectory name="local.mobileTemplates" action="LIST" directory="#local.mobileTemplatesUrl#" filter="*.cfm" />
			<cfelse>
				<cfset local.mobileTemplates = queryNew("", "") />
			</cfif>
	
			<tr>
				<td>#local.UASettings.name#</td>
				<td>
					<select id="mobiletemplate" name="mobiletemplate" class="dropdown" >
						<option selected="selected" value="-1">Inherit From Parent</option>
						<option value="-2">Desktop Template</option>
						<cfloop query="local.mobileTemplates">
						<option value="#local.mobileTemplates.name#" <!---<cfif local.mobileTemplates.name EQ $.content("mobiletemplate") >selected="true"</cfif>--->>
							#local.mobileTemplates.name#
						</option>
						</cfloop>
					</select>
				</td>
			</tr>
		</cfloop>
	</table>
</cfif>
</cfoutput>
