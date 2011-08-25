<!---

MobileMura/public/controllers/main.cfc

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

<cfcomponent extends="mura.cfobject" output="false">

	<cfscript>
		variables.fw = '';

		function init ( fw ) {
			variables.fw = arguments.fw;
		};

		function before ( rc ) {
			var $ = StructNew();
			if ( StructKeyExists(rc, '$') ) {
				$ = rc.$;
			};
			
			if ( not rc.isFrontEndRequest ) {
				fw.redirect(action='admin:main.default');
			};
		};
	</cfscript>

	<!--- ********************************* PAGES ******************************************* --->

	<cffunction name="default" output="false" returntype="any">
		<cfargument name="rc" required="true" />
	</cffunction>

	<cffunction name="mobileSwitcher" output="false" returntype="any">
		<cfargument name="rc" required="true" />
	</cffunction>

</cfcomponent>