/*
[script info]
version     = 0.5.2
description = quick code testing using a single hotkey
author      = davebrny
source      = https://github.com/davebrny/test-lab
*/


run_lab:
global default_label_tl, lab_number_tl, test_folder_tl
lab_number_tl := regExReplace(a_scriptName, "[^0-9]")
menu, tray, icon, % a_scriptDir "\.data\" lab_number_tl ".ico"

settings_tl("user", "settings")
settings_tl("lab", lab_number_tl)

hotkey, % menu_modifier_tl    . lab_number_tl, show_menu_tl
hotkey, % default_modifier_tl . lab_number_tl, run_default_tl

if (new_file_hotkey_tl)
    hotkey, % new_file_hotkey_tl, gui_new_file_tl

loop, %0%    ;# get parameters passed to the script
    label_name_tl .= (label_name_tl ? a_space : "") . %a_index%
if isLabel(label_name_tl)
    goSub % label_name_tl

return ; end of auto-execute ---------------------------------------------------







show_menu_tl:
lab_details_tl(lab_number_tl, lab_file_tl)
lab_labels_tl(lab_labels_tl, script_path_tl)
if (lab_labels_tl = "")
    {
    msg_tl("no labels found")
    return
    }
    ; main menu
lab_name_tl := "Lab " lab_number_tl
if (default_label_tl)
    {
    splitPath, script_path_tl, filename_tl
    lab_name_tl .= "  (" filename_tl ")"
    }
menu, main_menu_tl, add, % lab_name_tl, run_menu_tl
menu, main_menu_tl, disable, % lab_name_tl
menu, main_menu_tl, add
    ; lab labels
loop, parse, lab_labels_tl, `n
    {
    menu, main_menu_tl,    add, % a_loopField, run_menu_tl
    menu, main_menu_tl,   icon, % a_loopField, % a_scriptDir "\.data\" lab_number_tl ".ico"
    menu, default_menu_tl, add, % a_loopField, set_default_tl
    if (a_loopField = default_label_tl)
        {
        menu, main_menu_tl,    default, % a_loopField
        menu, default_menu_tl, default, % a_loopField
        }
    }
menu, main_menu_tl, add
    ; reset or choose default
if (default_label_tl)
     menu, main_menu_tl, add, Reset Default,  menu_reset_tl
else menu, main_menu_tl, add, Choose default, :default_menu_tl
    ; options sub-menu
menu, options_menu_tl, add, New Test File, gui_new_file_tl
menu, options_menu_tl, add
loop, 10
    {
    index_tl := a_index - 1
    if (index_tl = lab_number_tl)
        continue
    menu, options_menu_tl, add,  Start Lab %index_tl%, start_lab_tl
    menu, options_menu_tl, icon, Start Lab %index_tl%, % a_scriptDir "\.data\" index_tl ".ico"
    }
menu, main_menu_tl, add, &Options, :options_menu_tl

menu, main_menu_tl, show
menu, main_menu_tl, delete
menu, default_menu_tl, delete
menu, options_menu_tl, delete
return


run_default_tl:
lab_details_tl(lab_number_tl, lab_file_tl)
if (save_before_tl = "true")
    goSub, save_active_file_tl
if (default_label_tl)
    run, "%a_ahkPath%" "%lab_file_tl%" %default_label_tl%
else msg_tl("default label not set")
return


run_menu_tl:
setup_lab_data_tl("#include, *i " . script_path_tl)
if (save_before_tl = "true")
    goSub, save_active_file_tl
run, "%a_ahkPath%" "%lab_file_tl%" %a_thisMenuItem%
return


set_default_tl:
iniWrite, % " " a_thisMenuItem, % a_scriptDir "\.data\lab settings.ini", % lab_number_tl, default_label
setup_lab_data_tl("#include, *i " . script_path_tl)
msg_tl(a_thisMenuItem "`nset as default")
return


menu_reset_tl:
msg_tl("Lab " lab_number_tl " reset")
reset_tl:
default_label_tl := ""
iniWrite, % "", % a_scriptDir "\.data\lab settings.ini", % lab_number_tl, default_label
setup_lab_data_tl("")    ; clear file
return


start_lab_tl:
start_num_tl := regExReplace(a_thisMenuItem, "[^0-9]")
run, "%a_ahkPath%" "%a_scriptDir%\lab %start_num_tl%.ahk"
msg_tl("lab " start_num_tl " started")
return


save_active_file_tl:
fileRead, output_tl, % a_scriptDir "\.data\lab " . lab_number_tl . " data.ahk"
if inStr(output_tl, active_file_tl())
    send ^{s}    ; save if file is active/focused
return


settings_tl(type, ini_section_tl) {
    local section_text_tl, ini_value_tl, pos
    if (type = "user")
         iniRead, section_text_tl, % a_scriptDir "\settings.ini", % ini_section_tl
    else iniRead, section_text_tl, % a_scriptDir "\.data\lab settings.ini", % ini_section_tl
    loop, parse, % section_text_tl, `n, `r
        {
        stringGetPos, pos, a_loopField, =, L1
        stringMid, ini_key_tl, a_loopField, pos, , L
        stringMid, ini_value_tl, a_loopField, pos + 2
        %ini_key_tl%_tl := ini_value_tl
        }
}


lab_details_tl(byRef lab_number_tl, byRef lab_file_tl) {
    lab_number_tl := regExReplace(a_thisHotkey, "[^0-9]")
    if (lab_number_tl = "")
        lab_number_tl := regExReplace(a_scriptName, "[^0-9]")
    splitPath, a_scriptFullPath, , dir, ext, name
    lab_file_tl := dir "\lab " lab_number_tl "." ext
    settings_tl("lab", lab_number_tl)
}


lab_labels_tl(byRef lab_labels_tl, byRef script_path_tl) {
    lab_labels_tl := ""
    script_path_tl := lab_path_tl()
    fileRead, output, % script_path_tl
    if inStr(output, "/*") or inStr(output, ";")
        output := strip_comments_tl(output)
    output := strReplace(output, ":" ":")    ; remove hotkey symbol 
    if inStr(output, ":")   ; possible label name
        {
        strReplace(output, ":", "", colon_count)
        loop, % colon_count
            {
            stringGetPos, pos, % output, % ":", % "L" a_index
            stringMid, text_left, % output, pos, , L
            stringGetPos, pos, % text_left, % "`n", R1
            stringMid, string, % text_left, pos + 2
            if !inStr(string, a_space) and !inStr(string, a_tab)
                and !inStr(string, ",") and !inStr(string, "``")
                lab_labels_tl .= (lab_labels_tl ? "`n" : "") . string
            }
        }
}


lab_path_tl() {
    iniRead, default_label_tl, % a_scriptDir "\.data\lab settings.ini", % lab_number_tl, default_label
    if (default_label_tl = "")
        script_path := active_file_tl()
    else
        {
        fileRead, output, % a_scriptDir "\.data\lab " . lab_number_tl . " data.ahk"
        string := strReplace(output, "#include, *i ", "")
        if fileExist(string)
            script_path := string
        else
            {
            goSub, reset_tl
            script_path := active_file_tl()  
            }
        }
    return script_path
}


setup_lab_data_tl(new_contents="") {
    file := fileOpen(a_scriptDir "\.data\lab " . lab_number_tl . " data.ahk", "r")
    if (new_contents != file.read())
        {
        file := fileOpen(a_scriptDir "\.data\lab " . lab_number_tl . " data.ahk", "w")
        file.write(new_contents)
        file.close()
        }
}


strip_comments_tl(string) {
        ; #strip comment blocks
    if inStr(string, "/*")
        {
        original_string := string
        if inStr(string, "`r`n")
            stringReplace, string, string, `r`n, `n, all

        if (subStr(string, 1, 2) = "/*")               ; if at very first line
            stringReplace, string, string, % "/*", % "`n/*"
        strReplace(string, "`n/*", "", block_start)    ; get number of blocks
        strReplace(string, "`n*/", "", block_end)
        block_count := (block_start > block_end) ? (block_end) : (block_start)
        loop, % block_count
            {
            if (a_index = 1)                 ; get text before 1st block
                {
                stringGetPos, block_start, string, % "`n/*", L1
                stringMid, first_section, string, block_start, , L
                new_string .= first_section "`n"
                }
            else                             ; every other loop (text between blocks)
                {
                stringGetPos, block_start, string, % "`n/*", L%a_index%
                stringMid, middle_sections, string, block_start, , L
                stringGetPos, block_end, middle_sections, % "`n*/", R1,
                stringMid, middle_sections, middle_sections, block_end + 5
                new_string .= middle_sections "`n"
                }
            }                                ; text after last block 
        stringGetPos, block_end, string, % "`n*/", R1
        stringMid, end_section, string, block_end + 5
        new_string .= end_section

        if inStr(original_string, "`r`n")
            stringReplace, new_string, new_string, `n, `r`n, all
        string := new_string
        }

        ; #strip line comments
    if inStr(string, ";")
        {
        loop, parse, string, `n, `r
            {
            if (inStr(Ltrim(a_loopField), ";") = 1)
                continue    ; skip line comments
            new_lines .= (new_lines = "" ? "":"`r`n") . a_loopField
            }
        string := new_lines
        }
    return string
}


active_file_tl() {
    winGet, process_name, processName, a
    splitPath, process_name, , , , process_name ; without .exe
    process_name := convert_symbols_tl(process_name)
    if isFunc(process_name "_active_file_tl")
        return %process_name%_active_file_tl()
}


msg_tl(msg) {
    toolTip, % msg
    setTimer, timer_tl, 2000
}
timer_tl(){
    setTimer, timer_tl, off
    toolTip,
}


gui_new_file_tl:
if (test_folder_tl = "")
    {
    fileSelectFolder, output_tl, , , Choose a folder for new test files
    if (errorLevel != 1) ; if folder was chosen
        {
        iniWrite, % output_tl, % a_scriptDir "\settings.ini", settings, test_folder
        test_folder_tl := output_tl
        }
    else return
    }
gui add, edit, x10 y5 w160 h20 vedit_box, file name
gui add, text, x175 y8 w120 h23, .ahk
gui add, button, x10 y40 w75 h30 ggui_close_tl, Cancel
gui add, button, x95 y40 w75 h30 ggui_create_file_tl, Create
gui show, w210 h80, Test Lab
return

gui_close_tl:
gui destroy
return

gui_create_file_tl:
guiControlGet, edit_text_tl, , edit_box
if regExMatch(edit_text_tl, "[\Q\\/:*?""<>|\E]")
    msgbox, A file name can't contain any of the following characters \/:*?"<>|
else if fileExist(test_folder_tl "\" edit_text_tl ".ahk")
    msgbox, "%edit_text_tl%.ahk" already exists
else    ; create file
    {
    gui destroy
    filename_tl := test_folder_tl "\" edit_text_tl ".ahk"
    fileRead, output_tl, % a_scriptDir "\.data\template.ahk"
    output_tl := strReplace(output_tl, "`%test_lab_label_name`%", edit_text_tl)
    output_tl := strReplace(output_tl, a_space, "_")
    fileAppend, % output_tl, % filename_tl
    if (editor_path_tl)
        run, "%editor_path_tl%" "%filename_tl%"
    else msg_tl(edit_text_tl ".ahk created")
    }
return

; ==============================================================================


atom_active_file_tl() {
    winGetTitle, title, ahk_exe atom.exe
    split := strSplit(title, chr(8212), a_space)  ; split at — (em dash) 
    file_path := split[2] "\" split[1]
    splitPath, % file_path, , , file_ext
    if fileExist(file_path) and (file_ext = "ahk")
        return file_path
}


notepad_active_file_tl() {
    if (test_folder_tl)
        {
        winGetTitle, title, ahk_exe notepad.exe
        title := strReplace(title, " - Notepad", "")
        splitPath, title, filename_tl, , file_ext
        if fileExist(test_folder_tl "\" filename_tl) and (file_ext = "ahk")
            return test_folder_tl "\" filename_tl
        }
}


notepadplusplus_active_file_tl() {
    winGetTitle, title, ahk_exe notepad++.exe
    splitPath, title, , file_dir, file_ext, name_no_ext
    split := strSplit(file_ext, "-", a_space)
    file_path := file_dir "\" name_no_ext "." split[1]
    if inStr(file_path, "*", , 1)    ;if unsaved file
        stringTrimLeft, file_path, file_path, 1
    if fileExist(file_path) and (split[1] = "ahk")
        return file_path
}


sublime_text_active_file_tl() {
    winGetTitle, title, ahk_exe sublime_text.exe 
    splitPath, title, , file_dir, file_ext, name_no_ext
    split := strSplit(file_ext, a_space)    ; remove project name or • from an unsaved file
    if (split[1] = "ahk")
        return file_dir "\" name_no_ext "." split[1]
}


convert_symbols_tl(string) {    ; (for process names that contains symbols that cant be used in a function name)
    for this, that in {"++":"plusplus", "@":"at"}
        stringReplace, string, string, % this, % that, all
    return string
}