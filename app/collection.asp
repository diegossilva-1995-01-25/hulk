<!--#include virtual="/app/initialize.asp"-->
<!--#include virtual="/lib/axe/classes/Parsers/json2.asp"-->
<!--#include virtual="/lib/axe/classes/Parsers/mustache.asp"-->
<!--#include virtual="/lib/axe/classes/Utilities/es5shim.asp"-->
<!--#include virtual="/lib/axe/classes/Parsers/gfm.asp"-->
<!--#include virtual="/app/helpers.asp"-->
<%

dim author
author = Session("author")

dim masterpage, partials, ds

' alloc
set partials = JSON.parse("{}")
set ds = JSON.parse("{ ""data"": {}, ""metadata"": {} }")

' populate data source
with ds.data
	.set "abstracts", get_abstracts( author, date_desc )
end with
with ds.metadata
	.set "title"      , []( "{0} daily blog", author )
	.set "description", loadTextFile( Server.mapPath( []( "/{0}/description.txt", author ) ) )
	.set "canonical"  , []( "https://{0}/{1}/", array( Request.ServerVariables("HTTP_HOST"), author ) )
end with

' load templates
masterpage = loadTextFile( cascade( getref( "cascade_fileExists" ), array( _
	Server.mapPath( []( "/{0}/TMaster.mustache", author ) ), _
	Server.mapPath( "/app/TMaster.mustache" ) _
) ) )

partials.set "content", loadTextFile( cascade( getref( "cascade_fileExists" ), array( _
	Server.mapPath( []( "/{0}/TAbstracts.mustache", author ) ), _
	Server.mapPath( "/app/TAbstracts.mustache" ) _
) ) )

partials.set "abstract", loadTextFile( cascade( getref( "cascade_fileExists" ), array( _
	Server.mapPath( []( "/{0}/TAbstract.mustache", author ) ), _
	Server.mapPath( "/app/TAbstract.mustache" ) _
) ) )

' render
Response.write Mustache.render( masterpage, ds, partials )

' free
set ds = nothing
set partials = nothing

%>
<!--#include virtual="/app/finalize.asp"-->