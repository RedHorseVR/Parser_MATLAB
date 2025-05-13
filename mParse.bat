echo off
PROMPT VFC:$G
ECHO
echo Processing files...

for %%F in (%*) do (
    echo Processing: %%F
	echo ---------------------------------------------------
	echo MatlabParser.pl %%F
	MatlabParser.pl %%F
	echo vfc2000 "%%F.vfc" -Reload    
	start vfc2000 "%%F.vfc" -Reload    
	
	REM Add your processing commands here, such as:
    REM some_command "%%F"
)




pause