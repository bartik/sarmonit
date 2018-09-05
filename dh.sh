#!/bin/bash
df -Ph | awk -F' ' 'BEGIN { ORS=";" ; print "hostname;date" } /^\// { print $6 }' | sed -e 's/\%//g' -e 's/;$//'
echo
