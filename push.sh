#!/bin/bash
if [ $# -eq 0 ]; then
  echo "Enter the commit message!"
  exit
fi
python3 ibmi-pull.py 
git add . 
git commit -m "${1}" 
git push origin master
