# test lab

the idea behind test lab is to remove some of the friction of writing new scripts by letting you use a single hotkey to quickly test out the changes you make. normally this requires you to use 3 hotkeys: 

1: <kbd>ctrl</kbd> + <kbd>s</kbd> to save your changes  
2: a hotkey to reload the script  
3: another hotkey to run your code  

these arent exactly a lot of effort on their own, but when you are making lots of changes it can start to get tedious after a while, so this script lets you avoid that by doing it all in one go

&nbsp;

## usage

- run any one of the lab files.  (i will use `lab 3.ahk` as an example here)  
- focus on an .ahk script in your editor (see supported editors below)  
- press <kbd>alt</kbd> + <kbd>3</kbd> to see a list of labels you can run  
- <kbd>ctrl</kbd> + <kbd>3</kbd> will run the default label, which can be set in the `settings` sub-menu  

once a label is set as default, the script will be tied to that lab number and both hotkeys can be used even when the script youre working on isnt focused anymore.  if you want to remove the default at some point and choose another script the select "reset default" in the sub-menu  

if the script you are running labels from is the one that is focused in the editor, then <kbd>ctrl</kbd> + <kbd>s</kbd> will be sent before the label is run  

&nbsp;  

## limitations

\- this does not run whole files, only code that is under a label  

\- since each lab script is restarted when a label is run, this means there is a slight delay from when you press the hotkey to the code executing  

\-  for test lab to work at all you need to be able to get the script path from your editor's title bar or by some other method

&nbsp;

## suported editors

- sublime text  
&nbsp;

support for other editors can be added to the end of `\.data\script lab.ahk`.   the function should use the editor's process name (without .exe) at the start and `_active_file()` after it:    
```
sublime_text_active_file()
```

&nbsp;

## settings

#### labs 

only the numbers that are stated in the ini settings file will used as labs  

> each lab sets the all the same hotkeys so you only need to have one lab script added to the startup folder and then you can start the other labs from that one  

#### save before  

set `save_before` to `false` if you dont want the script you are working on to be saved before a label is run