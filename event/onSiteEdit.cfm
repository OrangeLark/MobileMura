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
<div class="fieldset">
	<div class="control-group">
	    <label class="control-label" for="mm_detectionType">Mobile detection</label>
		<div class="controls">
			<label class="radio">
				<input type="radio" name="mm_detectionType" id="mm_detectionType1" value="1" <cfif local.getDetection.detection EQ 1>checked</cfif>>
				Mura detection
			</label>
			<div id="mm_detectionType1_settings" class="well">
				<div class="control-group">
				    <label class="control-label" for="mm_detectionType">Mobile Theme</label>
					<div class="controls">
						<select name="mobileTheme">
							<option value="-1" <cfif local.getDetection.theme EQ "-1">selected="selected"</cfif>>No mobile theme selected</option>
							<cfloop query="local.themes">
								<option value="#local.themes.name#" <cfif local.getDetection.theme EQ local.themes.name>selected="selected"</cfif>>#local.themes.name#</option>
							</cfloop>
						</select>
					</div>
				</div>
			</div>
			<label class="radio">
				<input type="radio" name="mm_detectionType" id="mm_detectionType2" value="2" <cfif local.getDetection.detection EQ 2>checked</cfif>>
				MobileMura detection
			</label>
			<div id="mm_detectionType2_settings" class="well">
				<h4>iOS</h4>
				<table class="table table-bordered table-condensed table-bordered">
					<tr>
						<th>Device</th>
						<th>User Agent String</th>
						<th>Theme</th>
					</tr>
					<tr>
						<td class="input-large">iPod</td>
						<td><span class="input-large uneditable-input">ipod</span></td>
						<td>
							<select name="iPod_mobileTheme">
								<option value="-1" <cfif local.MMDetectionSettings["iPod"] EQ "-1">selected="selected"</cfif>>No mobile theme selected</option>
								<cfloop query="local.themes">
									<option value="#local.themes.name#" <cfif local.MMDetectionSettings["iPod"] EQ local.themes.name>selected="selected"</cfif>>#local.themes.name#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td class="input-large">iPhone</td>
						<td><span class="input-large uneditable-input">iphone</span></td>
						<td>
							<select name="iPhone_mobileTheme">
								<option value="-1" <cfif local.MMDetectionSettings["iPhone"] EQ "-1">selected="selected"</cfif>>No mobile theme selected</option>
								<cfloop query="local.themes">
									<option value="#local.themes.name#" <cfif local.MMDetectionSettings["iPhone"] EQ local.themes.name>selected="selected"</cfif>>#local.themes.name#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td class="input-large">iPad</td>
						<td><span class="input-large uneditable-input">ipad</span></td>
						<td>
							<select name="iPad_mobileTheme">
								<option value="-1" <cfif local.MMDetectionSettings["iPad"] EQ "-1">selected="selected"</cfif>>No mobile theme selected</option>
								<cfloop query="local.themes">
									<option value="#local.themes.name#" <cfif local.MMDetectionSettings["iPad"] EQ local.themes.name>selected="selected"</cfif>>#local.themes.name#</option>
								</cfloop>
							</select>
						</td>
					</tr>
				</table>
				<h4>Android</h4>
				<table class="table table-bordered table-condensed table-bordered">
					<tr>
						<th>Device</th>
						<th>User Agent String</th>
						<th>Theme</th>
					</tr>
					<tr>
						<td class="input-large">Phone</td>
						<td><span class="input-large uneditable-input">android,mobile</span></td>
						<td>
							<select name="AndroidPhone_mobileTheme">
								<option value="-1" <cfif local.MMDetectionSettings["Android Phone"] EQ "-1">selected="selected"</cfif>>No mobile theme selected</option>
								<cfloop query="local.themes">
									<option value="#local.themes.name#" <cfif local.MMDetectionSettings["Android Phone"] EQ local.themes.name>selected="selected"</cfif>>#local.themes.name#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td class="input-large">Tablet</td>
						<td><span class="input-large uneditable-input">android</span></td>
						<td>
							<select name="AndroidTablet_mobileTheme">
								<option value="-1" <cfif local.MMDetectionSettings["Android Tablet"] EQ "-1">selected="selected"</cfif>>No mobile theme selected</option>
								<cfloop query="local.themes">
									<option value="#local.themes.name#" <cfif local.MMDetectionSettings["Android Tablet"] EQ local.themes.name>selected="selected"</cfif>>#local.themes.name#</option>
								</cfloop>
							</select>
						</td>
					</tr>
				</table>
				<h4>BlackBerry</h4>
				<table class="table table-bordered table-condensed table-bordered">
					<tr>
						<th>Device</th>
						<th>User Agent String</th>
						<th>Theme</th>
					</tr>
					<tr>
						<td class="input-large">Phone</td>
						<td><span class="input-large uneditable-input">blackberry</span></td>
						<td>
							<select name="BlackBerryPhone_mobileTheme">
								<option value="-1" <cfif local.MMDetectionSettings["BlackBerry Phone"] EQ "-1">selected="selected"</cfif>>No mobile theme selected</option>
								<cfloop query="local.themes">
									<option value="#local.themes.name#" <cfif local.MMDetectionSettings["BlackBerry Phone"] EQ local.themes.name>selected="selected"</cfif>>#local.themes.name#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td class="input-large">Tablet</td>
						<td><span class="input-large uneditable-input">rim tablet</span></td>
						<td>
							<select name="BlackBerryTablet_mobileTheme">
								<option value="-1" <cfif local.MMDetectionSettings["BlackBerry Tablet"] EQ "-1">selected="selected"</cfif>>No mobile theme selected</option>
								<cfloop query="local.themes">
									<option value="#local.themes.name#" <cfif local.MMDetectionSettings["BlackBerry Tablet"] EQ local.themes.name>selected="selected"</cfif>>#local.themes.name#</option>
								</cfloop>
							</select>
						</td>
					</tr>
				</table>
				<h4>Windows Mobile</h4>
				<table class="table table-bordered table-condensed table-bordered">
					<tr>
						<th>Device</th>
						<th>User Agent String</th>
						<th>Theme</th>
					</tr>
					<tr>
						<td class="input-large">Phone</td>
						<td><span class="input-large uneditable-input">windows phone os</span></td>
						<td>
							<select name="WindowsMobilePhone_mobileTheme">
								<option value="-1" <cfif local.MMDetectionSettings["Windows Mobile Phone"] EQ "-1">selected="selected"</cfif>>No mobile theme selected</option>
								<cfloop query="local.themes">
									<option value="#local.themes.name#" <cfif local.MMDetectionSettings["Windows Mobile Phone"] EQ local.themes.name>selected="selected"</cfif>>#local.themes.name#</option>
								</cfloop>
							</select>
						</td>
					</tr>
				</table>
			</div>
			<label class="radio">
				<input type="radio" name="mm_detectionType" id="mm_detectionType3" value="3" <cfif local.getDetection.detection EQ 3>checked</cfif>>
				Custom detection
			</label>
			<div id="mm_detectionType3_settings" class="well">
				<table id="MMCustomSettingsTable" class="table table-bordered table-condensed table-bordered">
					<tr>
						<th>Name</th>
						<th>User Agent String</th>
						<th>Theme</th>
						<th></th>
					</tr>
					<cfset i = 0 />
					<cfloop query="local.MMCustomDetectionSettings" >
						<cfset i = i + 1 />
					<tr id="customSettingRow-#i#">
						<td>
							<input id="MMCustomName-#i#" name="MMCustomName-#i#" type="text" value="#local.MMCustomDetectionSettings.name#" />
						</td>
						<td>
							<input id="MMCustomUAString-#i#" name="MMCustomUAString-#i#" type="text" value="#local.MMCustomDetectionSettings.ua_string#" />
						</td>
						<td>
							<select name="MMCustomTheme-#i#">
								<option value="-1" <cfif local.MMCustomDetectionSettings.theme EQ "-1">selected="selected"</cfif>>No mobile theme selected</option>
								<cfloop query="local.themes">
									<option value="#local.themes.name#" <cfif local.MMCustomDetectionSettings.theme EQ local.themes.name>selected="selected"</cfif>>#local.themes.name#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<a class="btn" href="##" onclick="removeRow(#i#);"><i class="icon-remove"></i></a>
						</td>
					</tr>
					</cfloop>
				</table>
				<a id="btnAddRow" class="btn" href="##"><i class="icon-plus"></i></a>
			</div>
		</div>
	</div>
	<input id="MMRowTotal" name="MMRowTotal" value="#i#" type="hidden" />
</div>

<script>

$(document).ready(function() {
	
	<cfif local.getDetection.detection NEQ 1>
	$('##mm_detectionType1_settings').hide();
	</cfif>
	<cfif local.getDetection.detection NEQ 2>
	$('##mm_detectionType2_settings').hide();
	</cfif>
	<cfif local.getDetection.detection NEQ 3>
	$('##mm_detectionType3_settings').hide();
	</cfif>
	
	$('input[name=mm_detectionType]').click(function() {
		if($('##mm_detectionType1_settings').is(":visible")) {
			$('##mm_detectionType1_settings').hide('blind');
		};

		if($('##mm_detectionType2_settings').is(":visible")) {
			$('##mm_detectionType2_settings').hide('blind');
		};

		if($('##mm_detectionType3_settings').is(":visible")) {
			$('##mm_detectionType3_settings').hide('blind');
		};

		switch($(this).val()) {
			case "1": $('##mm_detectionType1_settings').show('blind');
				break;
			case "2": $('##mm_detectionType2_settings').show('blind');
				break;
			case "3": $('##mm_detectionType3_settings').show('blind');
				break;
		}
	});
	
	$('##btnAddRow').click(function() {
		row_id = parseInt($('##MMRowTotal').val()) + 1;
		
		$('##MMCustomSettingsTable tr:last').after('<tr id="customSettingRow-' + row_id + '"><td><input id="MMCustomName-' + row_id + '" name="MMCustomName-' + row_id + '" type="text"></td><td><input id="MMCustomUAString-' + row_id + '" name="MMCustomUAString-' + row_id + '" type="text"></td><td><select name="MMCustomTheme-' + row_id + '"><option value="-1">No mobile theme selected</option><cfloop query="local.themes"><option value="#local.themes.name#">' + '#local.themes.name#' + '</option></cfloop></select></td><td><a class="btn" href="##" onclick="removeRow(' + row_id + ');"><i class="icon-remove"></i></a></td></tr>');
		
		$('##MMRowTotal').val(row_id);
	});
	
});

function removeRow(id) {
	$('##customSettingRow-' + id).remove();
}

</script>

</cfoutput>