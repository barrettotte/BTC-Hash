@ECHO OFF
IF [%1] == [] GOTO NOMSG
python ibmi-pull.py && git add . && git commit -m "%~1" && git push origin master
GOTO END
:NOMSG
  ECHO "Enter the commit message!"
:END
PAUSE