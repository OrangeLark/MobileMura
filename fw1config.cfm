<!---

MobileMura/fw1config.cfm

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

<cfscript>
	framework = StructNew();

	// !important: enter the plugin packageName here. must be the same as found in '/plugin/config.xml.cfm'
	framework.package = 'MobileMura';

	// less commonly modified
	framework.defaultSection = 'main';
	framework.defaultItem = 'default';
	framework.usingSubSystems = true;
	framework.defaultSubsystem = 'public';

	// ***** rarely modified *****
	framework.applicationKey = framework.package;
	framework.base = '/' & framework.package;
	framework.action = 'action';
	//framework.reload = 'reload';
	//framework.password = 'appreload';
	framework.reloadApplicationOnEveryRequest = true;
	framework.generateSES = false;
	framework.SESOmitIndex = true;
	framework.baseURL = 'useRequestURI';
	framework.suppressImplicitService = false;
	framework.unhandledExtensions = 'cfc';
	framework.unhandledPaths = '/flex2gateway';
	framework.preserveKeyURLKey = 'fw1pk';
	framework.maxNumContextsPreserved = 10;
	framework.cacheFileExists = false;

	if ( framework.usingSubSystems ) {
		framework.subsystemDelimiter = ':';
		framework.siteWideLayoutSubsystem = 'common';
		framework.home = framework.defaultSubsystem & framework.subsystemDelimiter & framework.defaultSection & '.' & framework.defaultItem;
		framework.error = framework.defaultSubsystem & framework.subsystemDelimiter & framework.defaultSection & '.error';
	} else {
		framework.home = framework.defaultSection & '.' & framework.defaultItem;
		framework.error = framework.defaultSection & '.error';
	};
</cfscript>