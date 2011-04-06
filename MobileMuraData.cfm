
<cffunction name="setMobileMuraData" access="public" output="false" returntype="any">
	<cfargument name="siteID" type="string" required="true">
	<cfargument name="MobileTheme" type="any" required="true">

	<cfset var myDataObject	= createObject("component","mura.extend.extendObject").init(Type="Custom",SubType="MobileMuraData",SiteID=arguments.siteID)>

	<cfset myDataObject.setID( siteID ) />
	<cfset myDataObject.setMobileTheme( arguments.MobileTheme ) />
	<cfset myDataObject.save() />

	<cfreturn myDataObject />
</cffunction>

<cffunction name="getMobileMuraData" access="public" output="false" returntype="any">
	<cfargument name="siteID" type="string" required="true">

	<cfset var myDataObject	= createObject("component","mura.extend.extendObject").init(Type="Custom",SubType="MobileMuraData",SiteID=arguments.siteID)>

	<cfset myDataObject.setID( siteID ) />

	<cfreturn myDataObject />
</cffunction>
