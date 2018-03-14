<!--#include virtual="/app/initialize.asp"-->
<!--#include virtual="/lib/axe/classes/Parsers/json2.asp"-->
<!--#include virtual="/lib/axe/classes/Parsers/mustache.asp"-->
<!--#include virtual="/lib/axe/classes/Utilities/es5shim.asp"-->
<!--#include virtual="/lib/axe/classes/Parsers/gfm.asp"-->
<!--#include virtual="/app/helpers.asp"-->
<%

dim author, post_id, filespec
author   = Session("author")
post_id  = Session("post_id")
filespec = Session("datasource")

dim masterpage, partials, ds

' alloc
set partials = JSON.parse("{}")
set ds = JSON.parse("{ ""data"": {}, ""metadata"": {} }")

' populate data source
with ds.data
	.set "article", get_article( author, post_id, filespec )
end with
with ds.metadata
	.set "title", []( "{0} @ {1} daily blog", array( ds.data.article.title, author ) )
	.set "description", ds.data.article.description
	.set "canonical", ds.data.article.canonical
end with
push_next_prev ds.metadata, author, post_id

' load templates
masterpage = loadTextFile( cascade( getref( "cascade_fileExists" ), array( _
	Server.mapPath( []( "/{0}/TMaster.mustache", author ) ), _
	Server.mapPath( "/app/TMaster.mustache" ) _
) ) )

partials.set "content", loadTextFile( cascade( getref( "cascade_fileExists" ), array( _
	Server.mapPath( []( "/{0}/TArticle.mustache", author ) ), _
	Server.mapPath( "/app/TArticle.mustache" ) _
) ) )

' render
Response.write Mustache.render( masterpage, ds, partials )

' free
set ds = nothing
set partials = nothing

%>
<!--#include virtual="/app/finalize.asp"-->