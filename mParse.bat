echo off
prompt :
echo Processing files...

for %%F in (%*) do (
    echo Processing: %%F
	echo ---------------------------------------------------
	start perl C:\Users\lopezl10\AppData\Local\RedHorseVR\VFC_Matlab\MatlabParser.pl %%F
	start vfc2000 %%F.vfc -Reload    
	
	REM Add your processing commands here, such as:
    REM some_command "%%F"
)




pause