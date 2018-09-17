#!/bin/bash
# check if argument supplied
if [[ $# -eq 0 ]] ; then
    echo "$0: No argument supplied!"
    exit 1
fi
# check if the supplied argument is a file
if [[ ! -f $1 ]] ; then
    echo "$0: Supplied argument is not a file !"
    exit 1
fi
# temporary directory
F_TMPDIR=$(mktemp -d) || { echo "$0: Failed to create temporary directory!"; exit 1; }
# count the columns
myNF=`head -1 ${1}|awk -F';' '{print NF ; exit ;}'`
# prepare for flip
sed -e 's/^# *//' -e 's/$/;/' ${1} | tr -d '\n' | sed -e 's/;/;\n/g' > "${F_TMPDIR}/flip.input"
# flip the lines
awk -v COL=${myNF} -v FDR="${F_TMPDIR}/flip" '{ printf "%s",$0 > FDR ( NR - 1 ) % COL ".tmp" } END { for (i=0;i<COL;i++) { printf "\n" >> FDR i ".tmp" } }' "${F_TMPDIR}/flip.input"
# concatenate the output
cat ${F_TMPDIR}/flip*.tmp | sed -e 's/;$//'
# clean-up temporary files
rm -rf "${F_TMPDIR}"
