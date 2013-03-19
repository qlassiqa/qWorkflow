(*
Name:				Workflow (*adapted from PHP code to AppleScript*)
Description:			This AppleScript class provides several useful functions for retrieving, parsing, 
					and formatting data to be used with Alfred 2 Workflow.
Author:				Ursan Razvan
Original Source:		https://github.com/jdfwarrior/Workflows  (written in PHP by David Ferguson)
Revised: 			18 March 2013
Version: 			0.2
*)

-- @description
-- Handler for creating new Workflow script objects (mimics classes and constructors from OOP)
--
-- @param none
-- @return a new Workflow script object
--
on new_workflow()
	return my new_workflow_with_bundle(missing value)
end new_workflow


-- @description
-- Handler for creating new Workflow script objects (mimics classes and constructors from OOP)
--
-- @param $bundleid - the name of the bundle
-- @return a new Workflow script object
--
on new_workflow_with_bundle(bundleid)
	# the actual script object (or class) to be created on calling the handler
	script Workflow
		# the class name for AppleScript's internal use
		property class : "workflow"
		
		# class properties
		property _cache : missing value
		property _data : missing value
		property _bundle : missing value
		property _path : missing value
		property _home : missing value
		property _results : missing value
		
		
		-- @description
		-- Script constructor function. Intializes all class properties. Accepts one parameter of
		-- the workflow bundle id in the case that you want to specify a different bundle id,
		-- or missing value (or even an empty string) if the bundle id should be automatically
		-- determined from the workflow's 'info.plist' configuration file. This would adjust 
		-- the output directories for storing data.
		--
		-- @param bundleid - optional bundle id if not found automatically
		-- @return none
		--
		on run {bundleid}
			# initialize the working folder
			set my _path to do shell script "pwd"
			if my _path does not end with "/" then set my _path to my _path & "/"
			
			# initialize the home folder
			set my _home to do shell script "printf $HOME"
			
			# create the path to the current Applescript's 'info.plist' file
			set _infoPlist to _path & "info.plist"
			
			# if the 'info.plist' file exists, start reading it
			if my q_file_exists(_infoPlist) then
				tell application "System Events"
					tell property list file _infoPlist
						# initialize the bundle with the id from the 'info.plist' file
						set my _bundle to value of property list item "bundleid" as text
					end tell
				end tell
			end if
			
			# if no bundle id could be found inside the 'info.plist' file, or 
			# the 'info.plist' file doesn't exist, set the bundle to the 
			# parameter passed to this handler
			if not my q_is_empty(bundleid) then
				set my _bundle to bundleid
			end if
			
			# initialize the Cache and Data folders
			set my _cache to (my _home) & "/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/" & (my _bundle) & "/"
			set my _data to (my _home) & "/Library/Application Support/Alfred 2/Workflow Data/" & (my _bundle) & "/"
			
			# create the Cache and Data folders if they don't exist
			if not my q_folder_exists(my _cache) then
				do shell script "mkdir '" & (my _cache) & "'"
			end if
			if not my q_folder_exists(my _data) then
				do shell script "mkdir '" & (my _data) & "'"
			end if
			
			# initialize the results list
			set my _results to {}
			
			# return this new script object
			return me
		end run
		
		
		-- @description
		-- Accepts no parameter and returns the value of the bundle id for the 
		-- current workflow. If no value is available, then missing value is returned.
		--
		-- @param none
		-- @return missing value if not available, bundle id value if available.
		--
		on get_bundle()
			if my q_is_empty(my _bundle) then return missing value
			
			return my _bundle
		end get_bundle
		
		
		-- @description
		-- Accepts no parameter and returns the value of the path to the cache directory 
		-- for your workflow if it is available. Returns missing value if the value isn't available.
		--
		-- @param none
		-- @return missing value if not available, path to the cache directory for your workflow if available.
		--
		on get_cache()
			if my q_is_empty(my _bundle) then return missing value
			if my q_is_empty(my _cache) then return missing value
			
			return my _cache
		end get_cache
		
		
		-- @description
		-- Accepts no parameter and returns the value of the path to the storage directory for your
		-- workflow if it is available. Returns missing value if the value isn't available.
		--
		-- @param none
		-- @return missing value if not available, path to the storage directory for your workflow if available.
		--
		on get_data()
			if my q_is_empty(my _bundle) then return missing value
			if my q_is_empty(my _data) then return missing value
			
			return my _data
		end get_data
		
		
		-- @description
		-- Accepts no parameter and returns the value of the path to the current directory for your
		-- workflow if it is available. Returns missing value if the value isn't available.
		--
		-- @param none
		-- @return missing value if not available, path to the current directory for your workflow if available.
		--
		on get_path()
			if my q_is_empty(my _path) then return missing value
			
			return my _path
		end get_path
		
		
		-- @description
		-- Accepts no parameter and returns the value of the home path for the current user
		-- Returns missing value if the value isn't available.
		--
		-- @param none
		-- @return missing value if not available, home path for the current user if available.
		--
		on get_home()
			if my q_is_empty(my _home) then return missing value
			
			return my _home
		end get_home
		
		
		-- @description
		-- Returns a list of available result items
		--
		-- @param none
		-- @return list - list of result items
		--
		on get_results()
			return my _results
		end get_results
		
		
		-- @description
		-- Convert a list of records into XML format
		--
		-- @param $a - a list of records to convert
		-- @return XML string representation of the list, or missing value on error
		--
		on to_xml(a)
			if (my q_is_empty(a)) and (not my q_is_empty(my _results)) then
				set a to my _results
			else if (my q_is_empty(a)) and (my q_is_empty(my _results)) then
				return missing value
			end if
			
			set tab2 to tab & tab
			
			set xml to "<?xml version=\"1.0\"?>" & return & "<items>" & return
			repeat with itemRef in a
				set r to contents of itemRef
				set xml to xml & tab & "<item"
				set xml to xml & " uid=\"" & my q_encode(theUid of r) & "\""
				set xml to xml & " arg=\"" & my q_encode(theArg of r) & "\""
				if isValid of r is false then
					set xml to xml & " valid=\"no\""
					if not my q_is_empty(theAutocomplete of r) then
						set xml to xml & " autocomplete=\"" & my q_encode(theAutocomplete of r) & "\""
					end if
				end if
				if not my q_is_empty(theType of r) then
					set xml to xml & " type=\"" & (theType of r) & "\""
				end if
				set xml to xml & ">" & return
				set xml to xml & tab2 & "<title>" & my q_encode(theTitle of r) & "</title>" & return
				set xml to xml & tab2 & "<subtitle>" & my q_encode(theSubtitle of r) & "</subtitle>" & return
				
				set ic to theIcon of r
				if not my q_is_empty(ic) then
					set xml to xml & tab2 & "<icon"
					if ic starts with "fileicon:" then
						set xml to xml & " type=\"fileicon\""
						set ic to (items 10 thru -1 of ic as text)
					else if ic starts with "filetype:" then
						set xml to xml & " type=\"filetype\""
						set ic to (items 10 thru -1 of ic as text)
					end if
					set xml to xml & ">" & my q_encode(ic) & "</icon>" & return
				end if
				set xml to xml & tab & "</item>" & return
			end repeat
			
			set xml to xml & "</items>"
			return xml
		end to_xml
		
		
		-- @description
		-- Save values to a specified plist. If the first parameter is a record list
		-- then the second parameter becomes the plist file to save to. If the
		-- first parameter is string, then it is assumed that the first parameter is
		-- the label, the second parameter is the value, and the third parameter is
		-- the plist file to save the data to.
		--
		-- @param $a - key name / or records list of values to save
		-- @param $b - key value / or the plist to save
		-- @param $c - empty string, missing value / or the plist to save the values into
		-- @return string - execution output
		--
		-- @observations:
		-- Due to AppleScript's limited support for records, all records in the "a" list
		-- must have the following structure in order for this to work:
		-- {theKey: "someKey", theValue: anyValue}
		--
		on set_value(a, b, c)
			tell application "System Events"
				# if first argument is a list, then "b" is the file to save to
				if class of a is list then
					set lst to my q_clean_list(a)
					# get the full path location to the passed name or path
					# and obtain a reference to the actual plist file, and if
					# there isn't one then create it
					set b to property list file (_get_location of me at b with plist)
					
					# iterate through all records of the list a
					repeat with recordRef in lst
						set r to contents of recordRef
						
						# and create (or change) the required entry with the class type
						# of the key value, the name of the key and its value
						make new property list item at end of property list items of contents of b ¬
							with properties {kind:(class of (theValue of r)), name:(theKey of r), value:(theValue of r)}
					end repeat
				else
					# get the full path location to the passed name or path
					# and obtain a reference to the actual plist file, and if
					# there isn't one then create it
					set c to property list file (_get_location of me at c with plist)
					
					# and create (or change) the required entry with the class type
					# of b, the key name a, and the value of b
					if class of b is list then
						set x to my q_clean_list(b)
					else
						set x to b
					end if
					make new property list item at end of property list items of contents of c ¬
						with properties {kind:(class of x), name:a, value:x}
				end if
			end tell
		end set_value
		
		-- @description
		-- Similar to set_value, but is used for saving lists of values at once
		--
		-- @param $a - records list of values to save
		-- @param $b - the plist to save the values into
		--
		-- @return string - execution output
		--
		-- @observations:
		-- Due to AppleScript's limited support for records, all records in the "a" list
		-- must have the following structure in order for this to work:
		-- {theKey: "someKey", theValue: anyValue}
		--
		on set_values(a, b)
			return my set_value(a, b, "")
		end set_values
		
		
		-- @description
		-- Read a value from the specified plist
		--
		-- @param $a - the value to read
		-- @param $b - plist to read the values from
		-- @return missing value if not found, string if found
		--
		on get_value(a, b)
			tell application "System Events"
				set b to property list file (_get_location of me at b with plist)
				try
					return value of property list item a of contents of b
				end try
			end tell
			return missing value
		end get_value
		
		
		-- @description:
		-- Read data from a remote file/url, essentially a shortcut for curl
		--
		-- @param $website - website URL to request
		-- @return result from curl, or missing value on error
		--
		on request(website)
			### agent to mimic browser instead of software crawler to avoid blocking our request
			set agent to "Mozilla/5.0 (compatible; MSIE 7.01; Windows NT 5.0)"
			
			try
				# try fetching the website's content
				set theContent to do shell script "curl --silent --show-error --max-redirs 5 --connect-timeout 10 --max-time 10 -L -A '" & agent & "' '" & website & "'"
				return theContent
			end try
			# return nothing by default
			return missing value
		end request
		
		
		-- @description:
		-- Allows searching the local hard drive using mdfind
		--
		-- @param $query - search string
		-- @return list - list of search result paths
		--
		on mdfind(query)
			set output to do shell script "mdfind \"" & query & "\""
			return my q_split(output, return)
		end mdfind
		
		
		-- @description:
		-- Accepts data and a string file name to store data to local file as cache
		--
		-- @param $a - list of data to save to file, or text
		-- @param $b - filename to write the cache data to
		-- @return true or false, depending on success
		--
		-- @observations:
		-- Due to AppleScript's non-existant JSON support, this method can write to file
		-- only a string, a value that can be converted to string, or a list that doesn't
		-- contain sublists or records
		--
		on write_file(a, b)
			# determine location or create a new file if
			# no file can be found at any predefined locations
			set b to _get_location of me at b without plist
			
			# make sure that "a" is either a plain list or it
			# can be converted into a string (if not one)
			if class of a is list then
				# try to convert the list into lines of text
				try
					set a to my q_join(a, return)
				on error
					return false
				end try
			else
				# try to convert the non-list value of a to text
				try
					set a to a as text
				on error
					return false
				end try
			end if
			
			# try writing the contents of a to file
			try
				set f to open for access b with write permission
				set eof f to 0
				write a to f as «class utf8»
				close access b
				return true
			on error
				close access b
				return false
			end try
		end write_file
		
		
		-- @description:
		-- Returns data from a local cache file
		--
		-- @param file - filename to read the cache data from
		-- @return missing value if the file cannot be found or is empty, 
		-- 			and the file data if found and not empty
		--
		on read_file(a)
			# determine location or create a new file if
			# no file can be found at any predefined locations
			set a to _get_location of me at a without plist
			
			try
				# try opening the file
				set f to open for access a
				
				# get its size in bytes and close it
				set sz to get eof f
				close access a
				
				# if file is empty then remove it and return missing value
				if sz = 0 then
					tell application "System Events" to delete file a
					return missing value
				else
					# otherwise return the file data
					return read a
				end if
			on error
				close access a
				return missing value
			end try
		end read_file
		
		
		-- @description
		-- Helper function that just makes it easier to pass values into a function
		-- and create an array result to be passed back to Alfred
		--
		-- @param $theUid - the uid of the result, should be unique
		-- @param $theArg - the argument that will be passed on
		-- @param $theTitle - The title of the result item
		-- @param $theSubtitle - The subtitle text for the result item
		-- @param $theIcon - the icon to use for the result item
		-- @param $isValid - sets whether the result item can be actioned
		-- @param $theAutocomplete - the autocomplete value for the result item
		-- @return list items to be passed back to Alfred
		--
		on get_result given theUid:_uid, theArg:_arg, theTitle:_title, theSubtitle:_sub, theIcon:_icon, theAutocomplete:_auto, theType:_type, isValid:_valid
			if _uid is missing value then set _uid to ""
			if _arg is missing value then set _arg to ""
			if _title is missing value then set _title to ""
			if _sub is missing value then set _sub to ""
			if _icon is missing value then set _icon to ""
			if _auto is missing value then set _auto to ""
			if _type is missing value then set _type to ""
			if _valid is missing value then set _valid to "yes"
			
			set temp to {theUid:_uid, theArg:_arg, theTitle:_title, theSubtitle:_sub, theIcon:_icon, isValid:_valid, theAutocomplete:_auto, theType:_type}
			if my q_is_empty(_type) then
				set temp's theType to missing value
			end if
			
			set end of (my _results) to temp
			return temp
		end get_result
		
		
		-- @description:
		-- Helper function that creates a new empty plist file at a given path
		--
		-- @param $plistPath - the path to the new plist file
		-- @return a reference to the plist file
		--
		on _make_plist(plistPath)
			tell application "System Events"
				set parentElement to make new property list item with properties {kind:record}
				set plistFile to ¬
					make new property list file with properties {contents:parentElement, name:plistPath}
			end tell
			return plistFile
		end _make_plist
		
		
		-- @description
		-- Helper function that converts a file name or a file path into a full file path 
		-- and makes sure that the file exists (by creating one if it doesn't exist)
		--
		-- @param $pathOrName - either a file name or a file path
		-- @param $plist - boolean indicating whether it should create a new plist file or a plain file
		--
		on _get_location at pathOrName given plist:isPlist
			# if no path or name was provided, then use a default "settings.plist" file
			if pathOrName is missing value or my q_is_empty(pathOrName) then set pathOrName to "settings.plist"
			
			if my q_file_exists(pathOrName) then
				# pathOrName is a complete file path value, so nothing to do here,
				# otherwise assume it's a file name and not a path
				# and check it against the important folders for Alfred
			else if my q_file_exists(my _path & pathOrName) then
				# file exists in the current folder
				set location to my _path & pathOrName
			else if my q_file_exists(my _data & pathOrName) then
				# file exists in the data folder
				set location to my _data & pathOrName
			else if my q_file_exists(my _cache & pathOrName) then
				# file exists in the cache folder
				set location to my _cache & pathOrName
			else
				# file doesn't exist, so create a fresh one in the data path
				set location to my _data & pathOrName
				
				if isPlist then
					# if it needs to be a plist, create one
					my _make_plist(location)
				else
					# otherwise create a plain empty file
					try
						set f to open for access location with write permission
						set eof of f to 0
						close access location
					on error
						do shell script "touch " & location
					end try
				end if
			end if
			return location
		end _get_location
	end script
	
	# run the 'constructor' and return the new Workflow script object
	return run script Workflow with parameters {bundleid}
end new_workflow_with_bundle

### join text
on q_join(l, delim)
	if class of l is not list or l is missing value then return ""
	
	repeat with i from 1 to length of l
		if item i of l is missing value then
			set item i of l to ""
		end if
	end repeat
	
	set oldDelims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delim
	set output to l as text
	set AppleScript's text item delimiters to oldDelims
	return output
end q_join

### split text
on q_split(s, delim)
	set oldDelims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delim
	set output to text items of s
	set AppleScript's text item delimiters to oldDelims
	return output
end q_split

### handler to check if a file exists
on q_file_exists(theFile)
	if my q_path_exists(theFile) then
		tell application "System Events"
			return (class of (disk item theFile) is file)
		end tell
	end if
	return false
end q_file_exists

### handler to check if a folder exists
on q_folder_exists(theFolder)
	if my q_path_exists(theFolder) then
		tell application "System Events"
			return (class of (disk item theFolder) is folder)
		end tell
	end if
	return false
end q_folder_exists

### handler to check if a path exists
on q_path_exists(thePath)
	if thePath is missing value or my q_is_empty(thePath) then return false
	
	try
		if class of thePath is alias then return true
		if thePath contains ":" then
			alias thePath
			return true
		else if thePath contains "/" then
			POSIX file thePath as alias
			return true
		else
			return false
		end if
	on error msg
		return false
	end try
end q_path_exists

### checks if a value is empty
on q_is_empty(str)
	if str is missing value then return true
	return length of (my q_trim(str)) is 0
end q_is_empty

### removes white space surrounding a string
on q_trim(str)
	if class of str is not text or class of str is not string or str is missing value then return str
	if str is "" then return str
	
	repeat while str begins with " "
		try
			set str to items 2 thru -1 of str as text
		on error msg
			return ""
		end try
	end repeat
	repeat while str ends with " "
		try
			set str to items 1 thru -2 of str as text
		on error
			return ""
		end try
	end repeat
	
	return str
end q_trim

### filters "missing value" from a list
on q_clean_list(lst)
	if lst is missing value or class of lst is not list then return lst
	set l to {}
	repeat with lRef in lst
		set i to contents of lRef
		if i is not missing value then
			if class of i is not list then
				set end of l to i
			else if class of i is list then
				set end of l to my q_clean_list(i)
			end if
		end if
	end repeat
	return l
end q_clean_list

### encodes invalid XML characters
on q_encode(str)
	if class of str is not text or my q_is_empty(str) then return str
	set s to ""
	repeat with sRef in str
		set c to contents of sRef
		if c is in {"&", "'", "\"", "<", ">"} then
			if c is "&" then
				set s to s & "&amp;"
			else if c is "'" then
				set s to s & "&apos;"
			else if c is "\"" then
				set s to s & "&quot;"
			else if c is "<" then
				set s to s & "&lt;"
			else if c is ">" then
				set s to s & "&gt;"
			end if
		else
			set s to s & c
		end if
	end repeat
	return s
end q_encode