#!/bin/bash
df -Ph | awk -F' ' -v HS=`hostname` -v DT="`date "+%F %T"`" 'BEGIN { ORS=";" ; print HS ";" DT } /^\// { print $5 }' | sed -e 's/\%//g' -e 's/;$//'
echo
