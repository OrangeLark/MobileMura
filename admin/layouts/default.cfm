<cfsilent>
<!---

MobileMura/admin/layouts/default.cfm

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

<cfsavecontent variable="local.newBody">
	<cfoutput>
		<div class="mfw1adminblock">
			<div id="pageTitle"><h2>#rc.pc.getPackage()#</h2></div>
			<div class="navTask">
				<ul>
					<li class="first<cfif rc.action eq 'admin:main.default'> active</cfif>"><a href="#buildURL('admin:main')#">Main</a></li>
					<li<cfif rc.action eq 'admin:settings.settings'> class="active"</cfif>><a href="#buildURL('admin:settings.settings')#">Settings</a></li>
					<li class="last"><a href="#buildURL('admin:main.faq')#">FAQ</a></li>
				</ul>
			</div>
		</div>

		<cfif StructKeyExists(rc, 'errors') and IsArray(rc.errors) and ArrayLen(rc.errors)>
			<div class="mfw1adminblock">
				<h4 class="red">Please note the following message<cfif ArrayLen(rc.errors) gt 1>s</cfif>:</h4>
				<ul>
					<cfloop from="1" to="#ArrayLen(rc.errors)#" index="local.e">
						<li>#rc.errors[local.e]#</li>
					</cfloop>
				</ul>
			</div>
		</cfif>

		<div class="mfw1adminblock">
			#body#
		</div>
	</cfoutput>
</cfsavecontent>
<cfoutput>#application.pluginManager.renderAdminTemplate(body=local.newBody,pageTitle=rc.pc.getName())#</cfoutput>