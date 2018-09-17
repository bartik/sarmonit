#!/bin/bash
# $1 - source file
TMP1=/tmp/flip.001
TMP2=/tmp/flip.002
# count the columns
myNF=`head -1 ${1}|awk -F';' '{print NF ; exit ;}'`
# reset temporary file
cat /dev/null > ${TMP2}
# prepare for flip
sed -e 's/$/;/' ${1} | tr -d '\n' | sed -e 's/;/;\n/g' > ${TMP1}
# flip the lines
awk -v COL=${myNF} '{ printf "%s",$0 > "/tmp/flip" ( NR - 1 ) % COL ".tmp" } END { for (i=0;i<COL;i++) { printf "\n" } > "/tmp/flip" i ".tmp" }'
cat /tmp/flip*.tmp | sed -e 's/;$//'
