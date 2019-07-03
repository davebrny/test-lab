# test lab

the idea behind test lab is to take some of the friction out of writing [AutoHotkey](https://www.autohotkey.com) scripts by letting you use a single hotkey to quickly test out your changes. normally this process requires 3 hotkeys: 

1: <kbd>ctrl</kbd> + <kbd>s</kbd> to save your changes  
2: a hotkey to reload the script  
3: another hotkey to run your code  

these arent exactly a lot of effort on their own, but when you are making lots of changes it can start to get tedious after a while, so this script lets you avoid that by doing it all in one go

&nbsp;

## usage

- run any one of the lab files  (i will use `lab 3.ahk` as an example here)  
- focus on an .ahk script in your editor  (see supported editors below)  
- press <kbd>alt</kbd> + <kbd>3</kbd> to see a list of labels you can run  
- <kbd>ctrl</kbd> + <kbd>3</kbd> will run the default label

once a label is set as default, the script will be tied to that lab number and both hotkeys can be used even when the script youre working on isnt focused anymore  

if the script you are running labels from is the one that is focused in the editor, then <kbd>ctrl</kbd> + <kbd>s</kbd> will be sent before the label is run  

to make it even easier to get new ideas started, there is a gui for creating new test files that can be run from the `options` sub-menu or from a hotkey

&nbsp;  

## limitations

\-  for test lab to work at all you need to be able to get the script path from your editor's title bar or by some other method

\- this does not run whole files, only code that is under a label  

\- since each lab script is restarted when a label is run, this means there is a slight delay from when you press the hotkey to the code executing  

&nbsp;

## supported editors

- atom  
- __*__ notepad
- notepad++
- sublime text  

> editors with a * at the start only show the filename in the titlebar and not the full path, so in these cases it will only work if a [folder](https://github.com/davebrny/test-lab#settingsini) has been added and the file can be found in the root of that folder   


#### adding support  
support for other editors can be added to the end of `\.data\test lab.ahk`.   the function should use the editor's process name (without .exe) at the start and `_active_file_tl()` after it:    
```
atom_active_file_tl()
```

&nbsp;

## [settings.ini](https://github.com/davebrny/test-lab/blob/master/settings.ini)

> if youre changing any of these settings while others labs are running then select "reload all labs" in the options menu so the settings get applied to all of them  

#### save before  

set this to `false` if you dont want the script you are working on to be saved when a label is run

#### new test file hotkey

the hotkey that will be used to open the file creation gui, e.g. `^!n`  

> you can also launch the gui by using the menu shortcuts: press the letter <kbd>O</kbd> when the menu is open, then the letter <kbd>N</kbd>

#### test folder

the folder where new test files will be created

#### editor path

if you want the new test file to be opened after its created then add the path to your editor, otherwise leave this empty 