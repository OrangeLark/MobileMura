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
	// FW1 Configuration
	variables.framework = {};

	// TEMPORARY : feature will be deprecated in 3.0 ...  need to update plugin soon
	variables.framework.suppressServiceQueue = false;

	// !important: enter the plugin packageName here. must be the same as found in '{context}/plugin/config.xml.cfm'
	variables.framework.package = 'MobileMura';
	variables.framework.packageVersion = '2.0';

	// If true, then additional information is returned by the Application.onError() method
	// and FW1 will 'reloadApplicationOnEveryRequest' (unless explicitly set otherwise below).
	variables.framework.debugMode = true;
	
	// change to TRUE if you're developing the plugin so you can see changes in your controllers, etc.
	variables.framework.reloadApplicationOnEveryRequest = variables.framework.debugMode ? true : false;

	// the 'action' defaults to your packageNameAction, (e.g., 'MuraFW1action') you may want to update this to something else.
	// please try to avoid using simply 'action' so as not to conflict with other FW1 plugins
	variables.framework.action = variables.framework.package & 'action';

	// less commonly modified
	variables.framework.defaultSection = 'main';
	variables.framework.defaultItem = 'default';
	variables.framework.usingSubsystems = true;
	variables.framework.defaultSubsystem = 'public';

	// by default, fw1 uses 'fw1pk' ... however, to allow for plugin-specific keys, this plugin will use your packageName + 'pk'
	variables.framework.preserveKeyURLKey = variables.framework.package & 'pk';

	// reload application keys
	variables.framework.reload = 'reload';
	variables.framework.password = 'appreload'; // IF you're NOT using the default reload key of 'appreload', then you'll need to update this to match the setting found in /config/settings.ini.cfm!

	// ***** rarely modified *****
	variables.framework.applicationKey = variables.framework.package;
	variables.framework.base = '/' & variables.framework.package;
	variables.framework.generateSES = false;
	variables.framework.SESOmitIndex = true;
	variables.framework.baseURL = 'useRequestURI';
	variables.framework.suppressImplicitService = false; //true to suppress fw/1 from storing service calls results in rc.data
	variables.framework.unhandledExtensions = 'cfc';
	variables.framework.unhandledPaths = '/flex2gateway';
	variables.framework.maxNumContextsPreserved = 10;
	variables.framework.cacheFileExists = false;

	if ( variables.framework.usingSubSystems ) {
		variables.framework.subsystemDelimiter = ':';
		variables.framework.siteWideLayoutSubsystem = 'common';
		variables.framework.home = variables.framework.defaultSubsystem & variables.framework.subsystemDelimiter & variables.framework.defaultSection & '.' & variables.framework.defaultItem;
		variables.framework.error = variables.framework.defaultSubsystem & variables.framework.subsystemDelimiter & variables.framework.defaultSection & '.error';
	} else {
		variables.framework.home = variables.framework.defaultSection & '.' & variables.framework.defaultItem;
		variables.framework.error = variables.framework.defaultSection & '.error';
	};
</cfscript>