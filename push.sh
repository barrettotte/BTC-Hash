#!/bin/bash
if [ $# -eq 0 ]; then
  echo "Enter the commit message!"
  exit
fi
python3 ibmi-pull.py
if [ $? -eq 0 ]; then
  git add . 
  git commit -m "${1}" 
  git push origin master
else
  echo "Something went wrong, no push"
fi
