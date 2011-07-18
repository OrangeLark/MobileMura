<cfsilent>
<!---

This file is part of muraFW1
(c) Stephen J. Withington, Jr. | www.stephenwithington.com

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

		Document:	/admin/views/main/default.cfm
		Author:		Steve Withington | www.stephenwithington.com
		Modified:	2011.02.04

--->
</cfsilent>
<cfoutput>
	<h3>FAQ</h3>
	<h4>Why a different theme?</h4>
	<p>Good question! You can do a lot of mobile specific layouting in your css files, but you won't be able to do mobile specific rendering. With a different theme you can write mobile specific display objects, resource bundles, create an adapted contentRenderer and eventHandler, use multiple templates, etc.</p>
	<h4>I want to your the same theme for both desktop and mobile devices but different templates.</h4>
	<p>Select the desktop theme as the mobile theme in the mobileMura settings and choose a different template for mobile devices in the "mobileMura" tab located in the item details.</p>
</cfoutput>