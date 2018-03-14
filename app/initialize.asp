<%@
language = "VBScript"
codepage = 65001
lcid     = 1033
%><%

option explicit
Response.buffer = true
Response.charset = "UTF-8"

function [](byVal template, byVal replacements)
	if not isArray(replacements) then replacements = array(replacements)

	dim str, i
	str = template
	for i = 0 to ubound(replacements)
		if( not isNull( replacements(i) ) ) then
			str = replace(str, "{" & i & "}", replacements(i))
		end if
	next

	[] = str
end function

function cascade(byRef fn, byRef args)
	dim a, i
	for i = 0 to ubound(args)
		a = fn( args(i) )
		if( a(0) ) then
			cascade = a(1)
			exit function
		end if
	next
	Err.raise 5, "`cascade` runtime error"
end function

function cascade_fileExists(byVal filespec)
	dim a(1)
	a(0) = fileExists(filespec)
	a(1) = ""
	if a(0) then _
		a(1) = filespec
	cascade_fileExists = a
end function

function fileExists(byVal filespec)
	with Server.createObject("Scripting.FileSystemObject") 
		fileExists = .fileExists(filespec)
	end with
end function

function loadTextFile(byVal uncpath)
	if not fileExists(uncpath) then _
		Err.raise 53, "`loadTextFile` runtime error", []("File not found. <{0}>", uncpath)
	with ( Server.createObject("ADODB.Stream") )
		.type = adTypeText
		.mode = adModeReadWrite
		.charset = "UTF-8"
		.open()
		.loadFromFile(uncpath)
		loadTextFile = .readText()
		.close()
	end with
end function

%>