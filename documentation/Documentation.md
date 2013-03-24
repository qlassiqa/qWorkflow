#qWorkflow Library

##A. Introduction
This is an AppleScript library for creating workflows with Alfred 2. This library provides an object-oriented class with functions for working with plist settings files, reading and writing data to files, generating Alfred feedback results, requesting remote data, and more.

It was originally created by [David Ferguson using PHP](https://github.com/jdfwarrior/Workflows), and was entirely rewritten by me using AppleScript to provide the same functionality to all my fellow AppleScript lovers.

So you may be asking yourself: 

* ***why on Earth would I use AppleScript when I already have PHP, Python, Ruby, Bash, etc.?*** - yes, it's true, Alfred can be scripted using all those languages, but ask yourself this: **are you able to control MacOS and its Apps using those languages?** I'm afraid not, and this is where AppleScript comes to help. 

* ***but isn't it simpler to use my PHP / Python / etc. skills and combine them with AppleScript inside Alfred?*** Actually no, it isn't simpler - I've tried it, and it becomes really messy, not to mention that Alfred's workflow system doesn't allow that much mixing.

**NOTE:** the `compiled source` folder contains the ready-to-use library script (the files inside this folder should be put inside your Alfred workflow's folder); the `uncompiled source` folder contains the plain .applescript file that you can view online, and it contains fully commented code to better understand what I did there.

##B. Features
There are a lot of things you can do with this library to make your life a lot easier when creating & programming your Alfred Workflows, so here's a list of the most important features (the list will grow while I improve the library):

* **object-oriented approach** to write less & more readable code
* internal **workflow introspection** (finding the bundle ID, cache & storage paths)
* generate Alfred-compatible **XML feedback** with ease
* saving & retrieving **workflow-related settings**
* **remote data requests**, as well as **JSON support** (thanks to David @[Mousedown Software](http://www.mousedown.net/mouseware/index.html))
* **sending notifications** through the Notification Center (thanks to [Daji-Djan](https://github.com/Daij-Djan/DDMountainNotifier))
* various **internal utilities that improve AppleScript** (string and date manipulation, file system utilities)

##C. Known Limitations
Now, because AppleScript is a bit limited in terms of capabilities, some functionality isn't available right now, but I will try to improve this library further.

* **no JSONP support <u>yet</u>** - AppleScript doesn't know anything about JSON or JSONP, so I had to get help from [Mousedown Software](http://www.mousedown.net/mouseware/index.html), and they provided me with a fully functional and really fast JSON helper for which I've made a wrapper to embed it inside my library, and hopefully they will add JSONP support in the near feature; but until then you will have to make sure you're only working with JSON data

* **strict syntax for accessing JSON properties** - the [JSON Helper](http://www.mousedown.net/mouseware/JSONHelper.html) that I'm using to add JSON capabilities to this library parses JSON data and converts it to native AppleScript lists and records, and it's obvious that some JSON properties will have the same name as AppleScript's reserved keywords, so to avoid any syntax issues it's highly recommended that you enclose all JSON property names in vertical bar characters, like so: `|text| of |result| of item 1 of json`  (both `text` and `result` are reserved keywords in the AppleScript language, and not using the vertical bars would trigger errors in your code)

* **bigger file size** - since AppleScript requires extra coding for text manipulation and object handling, the file size is a bit large compared to the PHP equivalent, and it will probably increase as I add new features to it (features that are totally worth the size increase)

* **strict syntax for plist records** - it's known that AppleScript's records are a bit clumsy since they lack so many features, that's why when saving a list of records as a PList settings file you should adhere to the following strict record notation:
 
  ```
	{ 
	  {theKey:"someKeyName", theValue: "textValue"}, 
	  {theKey:"mynum", theValue: 2},
	  {theKey: "booltest", theValue: false},
	  {theKey:"na", theValue: missing value} 
	}
	```

##D. Initialization
Before you write any code, it's imperative that you copy the `q_workflow.scpt` library file. 

<font color="#ff0000">**NOTE:** If you plan to use the NotificationCenter methods to trigger notifications or if you plan on using the JSON capabilities of this library, then it's vital that you also copy the `bin` folder to your Workflow folder "as is" since it contains the helper utilities that provide these extra features. Note that trying to send notifications or read JSON without having the bin folder in your Workflow folder will produce no result (and yes, the utilities have to stay inside the bin folder at all time with the current filenames for this to work).</font>

```
set workflowFolder to do shell script "pwd"
set wlib to load script POSIX file (workflowFolder & "/q_workflow.scpt")
set wf to wlib's new_workflow()
```

or by specifying a bundle name:

```
...
set wf to wlib's new_workflow_with_bundle("com.mycompany.mybundlename")
```

**Explanations:**
* the first line determines the Alfred workflow's bundle path because this is where the "q_workflow.scpt" library should be placed in order to work

* the second line loads the library from the bundle's path assuming that you already placed it there

* the last line creates a new script object (the equivalent of a class in other languages) with all the required functionality

* since AppleScript doesn't support optional parameters, there are 2 constructors: `new_workflow()` with no parameters, which creates a new class that automatically fetches the bundle name from Alfred, and `new_workflow_with_bundle(<name>)`, which takes 1 parameter with the desired bundle name if none was specified in Alfred.

##E. Methods
This library provides 2 categories of methods, namely **workflow methods** and **utility methods**. Workflow methods can be used only after creating a new workflow class (these are also known as instance methods), and provide basic handlers to deal with Alfred Workflows. Utility methods, on the other hand, contain handlers that are used internally by the workflow methods, as well as useful handlers for regular use that enhance AppleScript's capabilities (these include string and date manipulation, file system checks, sending notification, etc.)

### Workflow Methods
####1. get\_bundle()
Takes no parameter and returns the value of the bundle id for the current workflow. If no value is available, then `missing value` is returned.

*Example:*
```
wf's get_bundle()
```

output: 
```
com.qlassiqa.iTunesRatings
```

####2. get\_data()
Takes no parameter and returns the value of the path to the storage directory for your workflow if it is available. Returns missing value if the value isn't available.

*Example:*
```
wf's get_data()
```

output:
```
/Users/qlassiqa/Library/Application Support/Alfred 2/Workflow Data/com.qlassiqa.iTunesRatings/
```

####3. get\_cache()
Takes no parameter and returns the value of the path to the cache directory for your workflow if it is available. Returns missing value if the value isn't available.

*Example:*
```
wf's get_cache()
```

output:
```
/Users/qlassiq/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/com.qlassiqa.iTunesRatings/
```

####4. get\_path()
Takes no parameter and returns the value of the path to the current folder for your workflow if it is available. Returns missing value if the value isn't available.

*Example:*
```
wf's get_path()
```

output:
```
/Users/qlassiqa/Dropbox/Public/Alfred2/Alfred.alfredpreferences/workflows/user.workflow.3BA9A8FC-75DB-494F-926A-CE19221E1211/
```

####5. get\_home()
Takes no parameter and returns the value of the home path for the current user. Returns missing value if the value isn't available.

*Example:*
```
wf's get_path()
```

output:
```
/Users/qlassiqa
```

####6. set\_value(key, value, plistfile)
Save values to a specified plist. If the plist file doesn't exist, it will be created in the workflow's data folder, and if the plistfile parameter is `missing value` or an empty string, a default "settings.plist" file will be created.

If the first parameter is a record list then the second parameter becomes the plist file to save to. Or you could just ignore this and use the `set_values` method that takes only 2 parameters for this scenario (presented next).

If the first parameter is text, then it is assumed that the first parameter is the key, the second parameter is the value, and the third parameter is the plist file to save the data to.

*Example:*
```
# add a username key with a text value to a default "settings.plist" file
1. wf's set_value("username", "mike", "")

# add a key with a boolean value
2. wf's set_value("default", true, "")

# add a key with a number value to a specific plist file
3. wf's set_value("age", 23, "settings.plist")

# add a key with a real number value
4. wf's set_value("weight", 65.3, "settings.plist")

# doesn't add anything since missing value was passed
5. wf's set_value("none", missing value, "settings.plist")

# add a list with mixed values
6. wf's set_value("my first list", {1, 2, 3, "bob"}, "settings.plist")

# add a list with values and a sublist
7. wf's set_value("my second list", {1, 2, 3, {"bob", "anne"}}, "settings.plist")

# replace previously created key
8. wf's set_value("username", "john", "settings.plist")
```

output:
```
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>age</key>
	<integer>23</integer>
	<key>default</key>
	<true/>
	<key>my first list</key>
	<array>
		<integer>1</integer>
		<integer>2</integer>
		<integer>3</integer>
		<string>bob</string>
	</array>
	<key>my second list</key>
	<array>
		<integer>1</integer>
		<integer>2</integer>
		<integer>3</integer>
		<array>
			<string>bob</string>
			<string>anne</string>
		</array>
	</array>
	<key>username</key>
	<string>john</string>
	<key>weight</key>
	<real>65.299999999999997</real>
</dict>
</plist>
```

####7. set\_values(listofrecords, plistfile)
Save a list of records to a specified plist. If the plist file doesn't exist, it will be created in the workflow's data folder, and if the plistfile parameter is `missing value` or an empty string, a default "settings.plist" file will be created.

Each record must adhere to the following notation:

```{theKey: "somekeyname", theValue: 13}```

*Example:*
```
set theList to {{theKey:"favcolor", theValue:"red"}, {theKey:"hobbies", theValue:{"sports", "music"}}}
wf's set_values(theList, "settings.plist")
```

output:
```
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>favcolor</key>
	<string>red</string>
	<key>hobbies</key>
	<array>
		<string>sports</string>
		<string>music</string>
	</array>
</dict>
</plist>
```

####8. get\_value(key, plistfile)
Read a value from the specified plist. Note that if the plist file cannot be located, the script will automatically create an empty plist file in the data folder of the workflow. Also, if the plistfile parameter is `missing value` or an empty string, a default "settings.plist" file will be created.

*Example:*
```
# get a simple value from the default "settings.plist" file
1. wf's get_value("username", "")

# get a simple list (see example plist on method [5])
2. wf's get_value("my first list", "settings.plist")

# get a list containing a sublist (see example plist on method [5])
3. wf's get_value("my second list", "settings.plist")
```

output:
```
1. mike
2. {1,2,3,"bob"}
3. {1,2,3,{"bob","anne"}}
```

####9. request(url)
Read data from a remote file/url, essentially a shortcut for curl

*Example:*
```
# get a json file from twitter
1. wf's request("http://mysite.com/search.json?q=json&rpp=5")

# get the contents of a website
2. wf's request("http://www.adobe.com/")
```

output:
```
1. "{
	"name": "JSON.sh",
	"version": "0.1.4",
	"description": "JSON parser written in bash",
	"homepage": "http://github.com/dominictarr/JSON.sh",
	"repository": {
  		"type": "git",
  		"url": "https://github.com/dominictarr/JSON.sh.git"
  	},
  	"bin": {
   		"JSON": "./JSON.sh"
  	},
  	"dependencies": {},
  	"devDependencies": {},
  	"author": "Dominic Tarr",
  	"scripts": { "test": "./all-tests.sh" }
}"

2. the raw html contents of Adobe's website
```

####10. request\_json(url)
Read & parse raw JSON data from a remote file/url, and converts it to native AppleScript records and lists (or missing value if an invalid JSON or URL). Note that this will \*NOT\* work with JSONP data, but only with JSON.

*Example:*
```
1. set json to wf's request_json("http://mysite.com/search.json?q=json&rpp=5")
```

output:
```
{
	name: "JSON.sh",
	version: "0.1.4",
	description: "JSON parser written in bash",
	homepage: "http://github.com/dominictarr/JSON.sh",
	repository: {
  		type: "git",
  		url: "https://github.com/dominictarr/JSON.sh.git"
  	},
  	bin: {
   		JSON: "./JSON.sh"
  	},
  	dependencies: {},
  	devDependencies: {},
  	author: "Dominic Tarr",
  	scripts: { 
		test: "./all-tests.sh"
	}
}
```

accessing individual JSON data:
```
1. |name| of json
2. count of |repository| of json
3. |JSON| of |bin| of json
```

####11. mdfind(query)
Allows searching the local hard drive using mdfind, and returns a list of all found paths.

*Example:*
```
wf's mdfind("php.ini")
```

output:
```
{
	"/private/etc/php.ini.default",
	"/usr/local/php/lib/php.ini",
	...
}
```

####12. write\_file(textorlist, cachefile)
Accepts data and a string file name to store data to local file. Each call to this method will overwrite the file if it already exists.

**Note:** due to AppleScript's lack of JSON support, this method can write to file only a piece of text, a value that can be converted to text, or a list that doesn't contain sublists or records.

*Example:*
```
1. wf's write_file("testing" & return & "string", "test.dat")
2. wf's write_file(12.5, "test.dat")
```

output:
```
1. testing
string

2. 12.5
```

####13. read\_file(cachefile)
Returns data from a local cache file, or missing value if the file doesn't exist. Note that if the file exists but is empty, it will be automatically deleted to clean up the workflow folder.

*Example:*
```
wf's write_file(12.5, "test.dat")
wf's read_file("test.dat")
```

output:
```
"12.5"
```

####14. add\_result with(out) isValid given theUid, theArg, theTitle, theSubtitle, theAutocomplete, theIcon, theType
Creates a new result item that is cached within the class object. This set of results is available via the get_results() functions, or, can be formatted and returned as XML via the to_xml() function.

**Note:** this method uses the labeled parameter syntax in AppleScript (see example), and takes the following 'camelCase' parameters:

* **theUid**: the uid attribute is a value that is used to help Alfred learn about your results. You know that Alfred learns based on the items you use the most. That same mechanism can be used in feedback results. Give your results a unique identifier and Alfred will learn which ones you use the most and prioritize them by moving them up in the result list

* **theArg**: the arg attribute is the value that is passed to the next portion of the workflow when the result item is selected in the Alfred results list. So if you pressed enter on a result, the arg value would be passed to a shell script, applescript, or any of the other Action items

* **theTitle**: the title element is the value that is shown in large text as the title for the result item. This is the main text/title shown in the results list

* **theSubtitle**: the subtitle element is the value shown under the title in the results list. When performing normal searches within Alfred, this is the area where you would normally see the file path

* **theAutocomplete**: the autocomplete attribute is only used when the valid attribute has been set to `false`. When attempting to action an item that has the valid attribute set to 'no' and an autocomplete value is specified, the autocomplete value is inserted into the Alfred window. When using this attribute, the arg attribute is ignored

* **theType**: the type attribute allows you to specify what type of result you are generating. Currently, the only value available for this attribute is "file". This will allow you to specify that the feedback item is a file and allows you to use Result Actions on the feedback item

* **theIcon**: the icon element allows you to specify the icon to use for your result item. This can be a file located in your workflow directory, an icon of a file type on your local machine, or the icon of a specific file on your system. To use the icons of a specific file type you use this syntax `"filetype:public.folder"`. To use the icons of another folder/file you use this syntax `"fileicon:/Applications"`. To use an icon inside a subfolder located within the workflow you use this syntax `"subfolder/icon.png"`.

*Example:* (the following code was separated on different lines for easier reading, but should be written on a single line or separated using the "¬" AppleScript reserverd character.
```
1. add_result of wf without isValid given 
	theUid:"alfred", 
	theArg:"alfredapp", 
	theTitle:"Alfred", 
	theAutocomplete:"Alfred", 
	theSubtitle:"/Applications/Alfred.app", 
	theIcon:"fileicon:/Applications/Alfred 2.app", 
	theType:"Alfredapp"

2. add_result of wf with isValid given
	theUid:"r9996",
	theArg:5,
	theTitle:"Alfred",
	theSubtitle:"",
	theAutocomplete:missing value,
	theIcon:"icon.png",
	theType:missing value
```

output:
```
1. {theUid:"alfred", theArg:"alfredapp", theTitle:"Alfred", theSubtitle:"/Applications/Alfred.app", theIcon:"fileicon:/Applications/Alfred 2.app", isValid:false, theAutocomplete:"Alfred", theType:"Alfredapp"}

2. {theUid:"r9996", theArg:5, theTitle:"Alfred", theSubtitle:"", theIcon:"icon.png", isValid:true, theAutocomplete:"", theType:missing value}
```

**Note:** any of the above parameters can accept empty strings or missing values.

####15. get\_results()
Returns a list of available result items from the class' internal cache.

*Example:*
```
add_result of wf without isValid given theUid:"alfred", theArg:"alfredapp", theTitle:"Alfred", theAutocomplete:"Alfred", theSubtitle:"/Applications/Alfred.app", theIcon:"fileicon:/Applications/Alfred 2.app", theType:"Alfredapp"

add_result of wf with isValid given theUid:"r9996", theArg:5, theTitle:"Alfred", theSubtitle:"", theAutocomplete:missing value, theIcon:"icon.png", theType:missing value

wf's get_results()
```

output:
```
{
	{theUid:"alfred", theArg:"alfredapp", theTitle:"Alfred", theSubtitle:"/Applications/Alfred.app", theIcon:"fileicon:/Applications/Alfred 2.app", isValid:false, theAutocomplete:"Alfred", theType:"Alfredapp"}, 
	{theUid:"r9996", theArg:5, theTitle:"Alfred", theSubtitle:"", theIcon:"icon.png", isValid:true, theAutocomplete:"", theType:missing value}
}
```

####16. to\_xml(listofrecords)
Convert a list of records into XML format. Passing an empty string or `missing value` as the parameter will make the method use the class' internal cache results as the list of records (this is built using the `add_result` method).

*Example:*
```
add_result of wf without isValid given theUid:"alfred", theArg:"alfredapp", theTitle:"Alfred", theAutocomplete:"Alfred", theSubtitle:"/Applications/Alfred.app", theIcon:"fileicon:/Applications/Alfred 2.app", theType:"Alfredapp"

add_result of wf with isValid given theUid:"r9996", theArg:5, theTitle:"Alfred", theSubtitle:"", theAutocomplete:missing value, theIcon:"icon.png", theType:missing value

wf's to_xml("")
```

output:
```
<?xml version="1.0"?>
<items>
	<item uid="alfred" arg="alfredapp" valid="no" autocomplete="Alfred" type="Alfredapp">
		<title>Alfred</title>
		<subtitle>/Applications/Alfred.app</subtitle>
		<icon type="fileicon">/Applications/Alfred 2.app</icon>
	</item>
	<item uid="r9996" arg="5">
		<title>Alfred</title>
		<subtitle></subtitle>
		<icon>icon.png</icon>
	</item>
</items>
```

### Utility Methods
####1. q\_trim(text)
Removes any whitespace characters from the start and end of a given text.

*Example:*
```
wlib's q_trim("   abc  " & return & "  def")
```

output: 
```
abc
def
```

####2. q\_join(list, delimiter or string of delimiters)
Takes the elements of a list and returns a text with the joined elements using the specified delimiter or string of delimiters.

*Example:*
```
1. q_join({"Test", "me", "now"}, ".")
2. q_join({"Test", "me", "now"}, ". ")
```

output:
```
1. Test.me.now
2. Test. me. now
```

####3. q\_split(text, delimiter or string of delimiters or list of delimiters)
Takes a piece of text and splits it into smaller pieces based on specific delimiters that will be ignored. The resulting pieces are put in a list.

*Example:*
```
1. q_split("Test. Me. Now", ".")
2. q_split("Test. Me, now", {". ", ","})
```

output:
```
1. {"Test", " Me", " Now"}
2. {"Test", "Me", " now"}
```

####4. q\_is\_empty(string or list)
Takes a text or list and checks if it's empty. An empty text is one that, when trimmed at both ends, has a length of 0. A list is empty when it has no elements. Also, `missing value` is also considered an empty value, so it will return true.

*Example:*
```
1. q_is_empty("")
2. q_is_empty("    ")
3. q_is_empty("  a  ")
4. q_is_empty({})
5. q_is_empty({"a"})
```

output:
```
1. true
2. true
3. false
4. true
5. false
```

####5/6/7. q\_file\_exists, q\_folder\_exists, q\_path\_exists
All methods are used to check if a given file or folder exists. The `q_file_exists` checks if a file path exists, the `q_folder_exists` checks if a folder or volume path exists, while the `q_path_exists` checks if a file/folder/volume path exists.

All three methods work with both HFS and Unix path styles, but none of them expand the tilde character (~).

*Example:*
```
1. q_file_exists("MacHD:Users:mike:Desktop:test.txt")
2. q_file_exists("MacHD:Users:mike:")
3. q_folder_exists("MacHD:Users:mike:")
4. q_folder_exists("MacHD:Users:mike")
5. q_folder_exists("Users/mike")
6. q_folder_exists("/Users/mike")
7. q_folder_exists("MacHD")
8. q_folder_exists("MacHD:")
9. q_path_exists("MacHD:Users:mike:Desktop:test.txt")
10. q_path_exists("MacHD:")
```

output:
```
1. true
2. false
3. true
4. true
5. true
6. true
7. false
8. true
9. true
10. true
```

####8. q\_clean\_list(list)
Takes a list and removes all `missing value` elements from it and its sublists, if any (recursively)

*Example:*
```
1. q_clean_list({1, missing value, 2})
2. q_clean_list({1, missing value, {2, missing value}})
```

output:
```
1. {1, 2}
2. {1, {2}}
```

####9. q\_encode(text)
Encodes a given text to valid XML text.

*Example:*
```
q_encode("testing \" and &")
```

output:
```
testing &quot; and &amp;
```

####10. q\_date\_to\_unixdate(date)
Takes a native AppleScript date value and converts it to a Unix formatted date.

*Example:*
```
q_date_to_unixdate(current date)
```

output:
```
03/22/2013 11:47:33 PM
```

####11. q\_unixdate\_to\_date(text)
Takes a Unix formatted date and converts it to a native AppleScript date value.

*Example:*
```
q_unixdate_to_date("03/22/2013 11:47:33 PM")
```

output:
```
date "Friday, March 22, 2013 11:47:33 PM"
```

####12. q\_date\_to\_timestamp(date)
Takes a native AppleScript date value and converts it to an epoch timestamp.

*Example:*
```
q_date_to_timestamp(current date)
```

output:
```
1363988971
```

####13. q\_timestamp\_to\_date(text)
Takes an epoch timestamp and converts it to a native AppleScript date value.

*Example:*
```
1. q_timestamp_to_date("1363988971")
2. q_timestamp_to_date("1363988971000")
```

output:
```
1. date "Friday, March 22, 2013 11:49:31 PM"
2. date "Friday, March 22, 2013 11:49:31 PM"
```

####14. q\_send\_notification(message, details, extra)
Displays a notification through MacOS's Notification Center system. A notification is made out of 3 parts: the top message text which appears in bold, the middle detailed information text, and the bottom extra information text - a notification must have at least a message or an extra text.

####15. q\_notify()
Takes no parameters and displays a generic notification through MacOS's Notification Center system.

####16. q\_encode\_url(str)
Encodes a string for passing it to a URL without breaking the URL. 

*Example:*
```
q_encode_url("search=a&b=c")
```

output:
```
search%3Da%26b%3Dc
```

####17. q\_decode\_url(str)
Decodes a URL formatted string into a regular text.

*Example:*
```
q_decode_url("search%3Da%26b%3Dc")
```

output:
```
search=a&b=c
```

##F. Licensing
This library is free to use, copy and modify, and is provided "AS IS", without warranty of any kind. However, I will greatly appreciate it if you'd give me credit and mention me in your works or anywhere you use this library.

The use of the helper utilities shipped with this library is subject to each author's license, which can be read at the links provided in [section B].