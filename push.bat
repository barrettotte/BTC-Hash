@ECHO OFF
IF [%1] == [] GOTO NOMSG
python3 ibmi-pull.py 
git add . 
git commit -m "${1}" 
git push origin master

:NOMSG
  ECHO "Enter the commit message!"
:END
PAUSE