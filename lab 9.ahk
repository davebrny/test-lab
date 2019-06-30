#noEnv
#singleInstance, force
sendMode input
setWorkingDir, % a_scriptDir

goSub, run_lab

return ; end of auto-execute ---------------------------------------------------



#include, %a_scriptDir%\.data\lab 9 data.ahk
#include, %a_scriptDir%\.data\test lab.ahk