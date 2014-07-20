/*

MobileMura/includes/configurators/Application.cfc

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

*/

component output=false {
	depth = 4;

	include '#repeatString('../',depth)#config/applicationSettings.cfm';
	include '#repeatString('../',depth)#config/mappings.cfm';
	include '#repeatString('../',depth)#plugins/mappings.cfm';
	include '#repeatString('../',depth)#config/appcfc/onApplicationStart_method.cfm';

	public any function onRequestStart() {
		// NOTE: If you need to allow direct access to a file located 
		// under your site/theme (e.g., a remote web service, etc.),
		// just add the file name to the list of files below.
		var safeFilesList = 'configurator.cfm';

		if ( !ListFindNoCase(safeFilesList, ListLast(cgi.SCRIPT_NAME, '/')) ) {
			WriteOutput('Access Restricted.');
			abort;
		}

		include '#repeatString('../',depth)#config/appcfc/onRequestStart_include.cfm';
		include '#repeatString('../',depth)#config/appcfc/scriptProtect_include.cfm';
		return true;
	}

	include '#repeatString('../',depth)#config/appcfc/onSessionStart_method.cfm';
	include '#repeatString('../',depth)#config/appcfc/onSessionEnd_method.cfm';
	include '#repeatString('../',depth)#config/appcfc/onError_method.cfm';
	include '#repeatString('../',depth)#config/appcfc/onMissingTemplate_method.cfm';
}