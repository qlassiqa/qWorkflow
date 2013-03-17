#Workflow Library

###Introduction
This is an AppleScript library for creating workflows with Alfred 2. This library provides an object-oriented class with functions for working with plist settings files, reading and writing data to files, generating Alfred feedback results, requesting remote data, and more.

It was originally created by [David Ferguson using PHP](https://github.com/jdfwarrior/Workflows), and was rewritten by me in AppleScript to provide the same functionality to all my fellow AppleScript lovers.

So you may be asking yourself: 

* ***why on Earth would I use AppleScript when I already have PHP, Python, Ruby, Bash, etc.?*** - yes, it's true, Alfred can be scripted using all those languages, but ask yourself this: **are you able to control MacOS and its Apps using those languages?** I'm afraid not, and this is where AppleScript comes to help. 

* ***but isn't it simpler to use my PHP / Python / etc. skills and combine them with AppleScript inside Alfred?*** Actually no, it isn't simpler - I've tried it, and it becomes really messy, not to mention that Alfred's workflow system doesn't allow that much mixing.

**NOTE:** the `compiled source` folder contains the ready-to-use library script (the file inside this folder should be put inside your Alfred workflow's folder); the `uncompiled source` folder contains the plain .applescript file that you can view online, and it contains fully commented code to better understand what I did there.

###Known Limitations
Now, because AppleScript is a bit limited in terms of capabilities, some functionality isn't available right now, but I will try to improve this library further.

* **no JSON support <u>yet</u>** - AppleScript doesn't know anything about JSON, but I'm already planning a JSON parser for AppleScript

* **bigger file size** - since AppleScript requires extra coding for text manipulation and object handling, the file size is a bit large compared to the PHP equivalent; right now the size of this library is ~87kb, but will probably increase as I add new features to it

* **strict syntax for plist records** - it's known that AppleScript's records are a bit clumsy since they lack so many features, that's why when saving a list of records as a PList settings file you should adhere to the following strict record notation: 

  ```
	{ 
	  {theKey:"someKeyName", theValue: "textValue"}, 
	  {theKey:"mynum", theValue: 2},
	  {theKey: "booltest", theValue: false},
	  {theKey:"na", theValue: missing value} 
	}
	```


###Initialization

```
set workflowFolder to do shell script "pwd"
set wf to load script POSIX file (workflowFolder & "/workflow.scpt")
set wf to wf's new_workflow()
```

or by specifying a bundle name:

```
...
set wf to wf's new_workflow_with_bundle("com.mycompany.mybundlename")
```

**Explanations:**
* the first line determines the Alfred workflow's bundle path because this is where the "workflow.scpt" library should be placed in order to work

* the second line loads the library from the bundle's path assuming that you already placed it there

* the last line creates a new script object (the equivalent of a class in other languages) with all the required functionality

* since AppleScript doesn't support optional parameters, there are 2 constructors: `new_workflow()` with no parameters, which creates a new class that automatically fetches the bundle name from Alfred, and `new_workflow_with_bundle(<name>)`, which takes 1 parameter with the desired bundle name if none was specified in Alfred.

###Methods
For more info, tips and examples on how to use the following methods, please consult the accompanying documentation (it is vital that you read the [DOCUMENTATION](https://github.com/qlassiqa/alfred-workflow/blob/master/documentation/Documentation.md) to get a grip on how to properly use this library).

1. get_bundle()
2. get_data()
3. get_cache()
4. get_path()
5. get_home()
6. set_value(key, value, plistfile)
7. set_values(listofrecords, plistfile)
8. get_value(key, plistfile)
9. request(url)
10. mdfind(query)
11. write_file(textorlist, cachefile)
12. read_file(cachefile)
13. get_result
14. get_results()
15. to_xml(listofrecords)
