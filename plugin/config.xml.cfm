<?xml version="1.0" encoding="UTF-8"?>
<!---

MobileMura/plugin/config.xml.cfm

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
<plugin>
	<name>MobileMura</name>
	<package>MobileMura</package>
	<directoryFormat>packageOnly</directoryFormat>
	<loadPriority>5</loadPriority>
	<version>2.0</version>
	<provider>Guust Nieuwenhuis</provider>
	<providerURL>http://www.lagaffe.be</providerURL>
	<category>Application</category>
	<settings />
	<EventHandlers>
		<eventHandler event="onApplicationLoad" component="includes.eventHandler" persist="true" />
		<eventHandler event="onSiteEdit" component="includes.eventHandler" persist="true" />
<!---
		<eventHandler event="onSiteRequestStart" component="includes.eventHandler" persist="true" />
		<eventHandler event="onGlobalRequestStart" component="includes.eventHandler" persist="true" />
		<eventHandler event="standardMobileHandler" component="includes.eventHandler" persist="true" />
		<eventHandler event="standardMobileValidator" component="includes.eventHandler" persist="true" />
		<eventHandler event="onGlobalMobileDetection" component="includes.eventHandler" persist="true" />
		<eventHandler event="onContentEdit" component="includes.eventHandler" persist="true" />
		<eventHandler event="onAfterContentSave" component="includes.eventHandler" persist="true" />
		<eventHandler event="onAfterContentDelete" component="includes.eventHandler" persist="true" />
		<eventHandler event="onAfterSiteSave" component="includes.eventHandler" persist="true" />
		<eventHandler event="onAfterSiteDelete" component="includes.eventHandler" persist="true" />
--->
	</EventHandlers>
	<DisplayObjects location="global">
		<DisplayObject name="MobileSwitcher" component="includes.displayObjects" displaymethod="dspMobileSwitcher" persist="false" />
	</DisplayObjects>
</plugin>