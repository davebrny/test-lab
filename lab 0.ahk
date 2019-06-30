#hotkeyInterval 99000000
#keyHistory 0
#maxHotkeysPerInterval 99000000
#noEnv
#singleInstance, force
listLines, off
process, priority, , a
sendMode, input
setBatchLines, -1
setControlDelay, -1
setDefaultMouseSpeed, 0
setKeyDelay, -1, -1
setMouseDelay, -1
setWinDelay, -1
setWorkingDir, % a_scriptDir

goSub, run_lab

return ; end of auto-execute ---------------------------------------------------



#include, %a_scriptDir%\.data\lab 0 data.ahk
#include, %a_scriptDir%\.data\test lab.ahk