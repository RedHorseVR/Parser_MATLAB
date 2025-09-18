echo off
PROMPT VFC:$G

setlocal enabledelayedexpansion
echo Processing files...

for %%F in (%*) do (
    	echo Processing: %%F
	echo ---------------------------------------------------
    	set filename=%%~nxF
    	echo root: !filename!
    	echo Folder: %%~dpF
    	echo -----------------------
    
    	copy %%F %%~dpF\_!filename!

	perl %CD%/MatlabParser.pl %%F
  
	start vfc2000 "%%F.vfc" -Reload    
	
	REM Add your processing commands here, such as:
    REM some_command "%%F"
)

pause