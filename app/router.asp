<!--#include virtual="/app/initialize.asp"-->
<%

sub main()
	' force https only. comment to disable
	if cint( Request.ServerVariables("SERVER_PORT_SECURE") ) = 0 then _
		Response.redirect []("https://{0}{1}", array( Request.ServerVariables("HTTP_HOST"), replace( Request.ServerVariables("URL"), "Default.asp", "" ) ) )

	dim path, a, author, post_id

	path = get_requested_path()
	a    = split( path, "/" )

	select case ubound(a)
		case 2
			if a(2) = "" then
				render_author a(1)
			else
				render_author_article a(1), a(2)
			end if

		case else
			Err.raise 5, "`router` runtime error"
	end select
end sub : main

function get_requested_path()
	if len( trim( Request.ServerVariables("QUERY_STRING") ) ) > 0 then
		get_requested_path = path_from_404()
	else
		get_requested_path = path_from_endpoint()
	end if
end function

function path_from_endpoint()
	path_from_endpoint = replace( Request.ServerVariables("URL"), "Default.asp", "" )
end function

function path_from_404()
	dim host, port, p

	host = Request.ServerVariables("SERVER_NAME")
	port = Request.ServerVariables("SERVER_PORT")

	p = len("http://") + 1' mid is an one-based function
	if cint( Request.ServerVariables("SERVER_PORT_SECURE") ) = 1 then _
		p = p + 1
	p = p + len( host & ":" & port )
	path_from_404 = mid( split( Request.ServerVariables("QUERY_STRING"), ";" )(1), p )
end function

function find_post(byVal author, byVal post_id)
	dim filespec
	filespec = Server.mapPath( []( "/{0}/posts/{1}.md", array( author, post_id ) ) )
	if fileExists(filespec) then
		find_post = filespec
	else
		find_post = "NOT_FOUND"
	end if
end function

sub render_author(byVal author)
	Session("author") = author

	Server.Transfer replace( replace( cascade( getref( "cascade_fileExists" ), array( _
		Server.mapPath( []( "/{0}/collection.asp", author ) ), _
		Server.mapPath( "/app/collection.asp" ) _
	) ), Request.ServerVariables("APPL_PHYSICAL_PATH"), "\" ), "\", "/" )
end sub

sub render_author_article(byVal author, byVal post_id)
	dim path
	path = find_post(author, post_id)
	if path = "NOT_FOUND" then
		render_not_found author
	else
		render_entry author, post_id, path
	end if
end sub

sub render_not_found(byVal author)
	Server.Transfer replace( replace( cascade( getref( "cascade_fileExists" ), array( _
		Server.mapPath( []( "/{0}/404.html", author ) ), _
		Server.mapPath( "/app/404.html" ) _
	) ), Request.ServerVariables("APPL_PHYSICAL_PATH"), "\" ), "\", "/" )
end sub

sub render_entry(byVal author, byVal post_id, byVal path)
	Session("author")     = author
	Session("post_id")    = post_id
	Session("datasource") = path

	Server.Transfer replace( replace( cascade( getref( "cascade_fileExists" ), array( _
		Server.mapPath( []( "/{0}/entry.asp", author ) ), _
		Server.mapPath( "/app/entry.asp" ) _
	) ), Request.ServerVariables("APPL_PHYSICAL_PATH"), "\" ), "\", "/" )
end sub

%>