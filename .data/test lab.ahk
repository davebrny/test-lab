/*
[script info]
version     = 0.1
description = quick code testing using a single hotkey
author      = davebrny
source      = https://github.com/davebrny/test-lab
*/


run_lab:
global default_label, lab_number
lab_number := regExReplace(a_scriptName, "[^0-9]")
menu, tray, icon, % a_scriptDir "\.data\" lab_number ".ico"

lab_settings("settings")    ; global
lab_settings(lab_number)    ; individual lab

loop, parse, labs, `, , % a_space   ;# set hotkeys
    {
    if a_loopField is number
        {
        hotkey, % menu_modifier    . a_loopField, lab_show_menu
        hotkey, % default_modifier . a_loopField, run_default_label
        }
    }

loop, %0%    ;# get parameters passed to the script
    label_name .= (label_name ? a_space : "") . %a_index%
if isLabel(label_name)
    goSub % label_name

return ; end of auto-execute ---------------------------------------------------







lab_show_menu:
lab_details(lab_number, lab_file)
lab_labels(lab_labels, script_path)
if (lab_labels = "")
    {
    msg_tl("no labels found")
    return
    }
    ; main menu title
lab_name := "Lab " lab_number
if (default_label)
    {
    splitPath, script_path, filename
    lab_name .= "  (" filename ")"
    }
menu, lab_main, add, % lab_name, lab_menu_run
menu, lab_main, disable, % lab_name
menu, lab_main, add
    ; default menu title
if (default_label)
    menu, lab_default, add, Reset Default, lab_menu_reset
else
    {
    menu, lab_default, add,     Choose Default:, lab_menu_reset
    menu, lab_default, disable, Choose Default:
    }
menu, lab_default, add
    ; lab labels
loop, parse, lab_labels, `n
    {
    menu, lab_main,    add, % a_loopField, lab_menu_run
    menu, lab_default, add, % a_loopField, lab_menu_default
    if (a_loopField = default_label)
        {
        menu, lab_main,    default, % a_loopField
        menu, lab_default, default, % a_loopField
        }
    }

menu, lab_main, add
menu, lab_main, add, Settings, :lab_default
menu, lab_main,    show
menu, lab_main,    delete
menu, lab_default, delete
return


run_default_label:
lab_details(lab_number, lab_file)
if (save_before = "true")
    goSub, save_active_file
if (default_label)
    run, "%a_ahkPath%" "%lab_file%" %default_label%
else msg_tl("default label not set")
return


lab_menu_run:
setup_lab_data("#include, *i " . script_path)
if (save_before = "true")
    goSub, save_active_file
run, "%a_ahkPath%" "%lab_file%" %a_thisMenuItem%
return


lab_menu_default:
iniWrite, % " " a_thisMenuItem, % a_scriptDir "\settings.ini", % lab_number, default_label
setup_lab_data("#include, *i " . script_path)
msg_tl(a_thisMenuItem "`nset as default")
return


lab_menu_reset:
msg_tl("Lab " lab_number " reset")
lab_reset:
default_label := ""
iniWrite, % "", % a_scriptDir "\settings.ini", % lab_number, default_label
setup_lab_data("")    ; clear file
return


save_active_file:
fileRead, file_contents, % a_scriptDir "\.data\lab " . lab_number . " data.ahk"
if inStr(file_contents, active_file_tl())
    send ^{s}    ; save if file is active/focused
return


lab_settings(ini_section) {
    local section_text, ini_value, pos
    iniRead, section_text, % a_scriptDir "\settings.ini", % ini_section
    loop, parse, % section_text, `n, `r
        {
        stringGetPos, pos, a_loopField, =, L1
        stringMid, ini_key, a_loopField, pos, , L
        stringMid, ini_value, a_loopField, pos + 2
        %ini_key% := ini_value
        }
}


lab_details(byRef lab_number, byRef lab_file) {
    lab_number := regExReplace(a_thisHotkey, "[^0-9]")
    if (lab_number = "")
        lab_number := regExReplace(a_scriptName, "[^0-9]")
    splitPath, a_scriptFullPath, , dir, ext, name
    lab_file := dir "\lab " lab_number "." ext
    lab_settings(lab_number)
}


lab_labels(byRef lab_labels, byRef script_path) {
    lab_labels := ""
    script_path := lab_path()
    fileRead, file_contents, % script_path
    file_contents := strReplace(file_contents, "::")
    if inStr(file_contents, ":")   ; possible label name
        {
        strReplace(file_contents, ":", "", colon_count)
        loop, % colon_count
            {
            stringGetPos, pos, % file_contents, % ":", % "L" a_index
            stringMid, text_left, % file_contents, pos, , L
            stringGetPos, pos, % text_left, % "`n", R1
            stringMid, string, % text_left, pos + 2
            if !inStr(string, a_space) and !inStr(string, a_tab)
                and !inStr(string, ",") and !inStr(string, "``")
                lab_labels .= (lab_labels ? "`n" : "") . string
            }
        }
}


lab_path() {
    iniRead, default_label, % a_scriptDir "\settings.ini", % lab_number, default_label
    if (default_label = "")
        script_path := active_file_tl()
    else
        {
        fileRead, file_contents, % a_scriptDir "\.data\lab " . lab_number . " data.ahk"
        string := strReplace(file_contents, "#include, *i ", "")
        if fileExist(string)
            script_path := string
        else
            {
            goSub, lab_reset
            script_path := active_file_tl()  
            }
        }
    return script_path
}


setup_lab_data(new_contents="") {
    file := fileOpen(a_scriptDir "\.data\lab " . lab_number . " data.ahk", "r")
    if (new_contents != file.read())
        {
        file := fileOpen(a_scriptDir "\.data\lab " . lab_number . " data.ahk", "w")
        file.write(new_contents)
        file.close()
        }
}


active_file_tl() {
    winGet, process_name, processName, a
    splitPath, process_name, , , , process_name ; without .exe
    if isFunc(process_name "_active_file")
        return %process_name%_active_file()
}


msg_tl(msg) {
    toolTip, % msg
    setTimer, timer_tl, 2000
}
timer_tl(){
    setTimer, timer_tl, off
    toolTip,
}

; ==============================================================================


sublime_text_active_file() {
    winGetTitle, title, ahk_exe sublime_text.exe 
    splitPath, title, , file_dir, file_ext, name_no_ext
    split := strSplit(file_ext, a_space)    ; remove project name or • from an unsaved file
    if (split[1] = "ahk")
        return file_dir "\" name_no_ext "." split[1]
}