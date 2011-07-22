<!---

MobileMura/public/views/main/mobileSwitcher.cfm

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
	<div id="svMobileSwitcher">
		<cfif cookie.mobileFormat>
			<a href="#$.content().getUrl('mobileFormat=false', false, '0')#">#$.rbKey("mobile.fullversion")#<!---Go to desktop website---></a>
		<cfelse>
			<a href="#$.content().getUrl('mobileFormat=true', false, '0')#">#$.rbKey("mobile.mobileversion")#<!---Go to mobile website---></a>
		</cfif>
	</div>
</cfoutput>
