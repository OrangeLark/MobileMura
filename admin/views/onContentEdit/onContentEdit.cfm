<!---

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

<cfset $ = application.serviceFactory.getBean("muraScope") />

<cfset contentBean = getBean("contentBean") />
<cfset site = application.serviceFactory.getBean("muraScope") />
<cfset site.init(session.siteID) />

<cfset subTypeBean = application.classExtensionManager.getSubTypeByName(contentBean.getType(),"Default",session.siteID) />
<cfset extendSetBean = subTypeBean.getExtendSetByName("MobileMura") />
<cfset attributeBean = extendSetBean.getAttributeByName("mobiletemplate") />

<cfset style = extendSetBean.getStyle() />

<cfset MobileMuraData = createObject("component","mura.extend.extendObject").init(Type="Custom",SubType="MobileMuraData",SiteID=session.siteID)>
<cfset MobileMuraData.setID( siteID ) />
<cfset mobileTheme = MobileMuraData.getMobileTheme() />

<cfif Len(mobileTheme)>
	<cfset mobileTemplatesUrl = Replace(site.siteConfig().getTemplateIncludeDir(), site.siteConfig().getTheme(), mobileTheme) />
	
	<cfdirectory name="mobileTemplates" action="LIST" directory="#mobileTemplatesUrl#" filter="*.cfm" />
<cfelse>
	<cfset mobileTemplates = queryNew("", "") />
</cfif>

<cfoutput>
<dl class="oneColumn" id="extendDL">
	<span class="extendset" extendsetid="#extendSetBean.getExtendSetID()#" categoryid="#extendSetBean.getCategoryID()#" #style#>
	<input name="extendSetID" type="hidden" value="#extendSetBean.getExtendSetID()#"/>
	<dt class="first">#extendSetBean.getName()#</dt>
	<cfsilent>
	</cfsilent>
	<dd><dl>
		<dt>
		<cfif len(attributeBean.getHint())>
		<a href="##" class="tooltip">#attributeBean.getLabel()# <span>#attributeBean.gethint()#</span></a>
		<cfelse>
		#attributeBean.getLabel()#
		</cfif>
		</dt>
		<dd>
			<select id="#attributeBean.getName()#" required="#attributeBean.getRequired()#" label="#attributeBean.getLabel()#" name="#attributeBean.getName()#">
				<option selected="selected" value="-1">Inherit From Parent</option>
				<option value="-2">Desktop Template</option>
				<cfloop query="mobileTemplates">
					<option value="#mobileTemplates.name#" <cfif mobileTemplates.name EQ $.content("mobiletemplate") >selected="true"</cfif>>#mobileTemplates.name#</option>
				</cfloop>
			</select>
		</dd>
	</dl></dd>
	</span>
</dl>
</cfoutput>
