#!/bin/bash

# If day specified use that. If not use current.
SADFCPU="-d /var/log/sa/sa${1}"
SADFMEM="/var/log/sa/sa${1}"
if ! [ -e "${SADFMEM}" ]; then
  SADFCPU="-d"
  SADFMEM=""
fi

# Input data
# CPU
FILE_CPU="/sarmonit/example/cpu.txt"
FLIP_CPU="/tmp/cpu.flip"
sadf -h -t -P 1 ${SADFMEM} > ${FILE_CPU}
/sarmonit/flip.sh ${FILE_CPU} > ${FLIP_CPU}

# Memory
FILE_MEM="/sarmonit/example/mem.txt"
FLIP_MEM="/tmp/mem.flip"
sadf -t ${SADFCPU} -- -r > ${FILE_MEM}
/sarmonit/flip.sh ${FILE_MEM} > ${FLIP_MEM}

# Disk
FILE_DISK="/sarmonit/example/disk.txt"
FLIP_DISK="/tmp/disk.flip"
/sarmonit/flip.sh ${FILE_DISK} > ${FLIP_DISK}

# temperature
FILE_TEMP="/sarmonit/example/temp.txt"
FLIP_TEMP="/tmp/temp.flip"
/sarmonit/flip.sh ${FILE_TEMP} > ${FLIP_TEMP}

# control data
declare -A METRIC_FILE=( ["TEMPERATURE"]="${FLIP_TEMP}" ["CPU"]="${FLIP_CPU}" ["MEM"]="${FLIP_MEM}" ["DISK"]="${FLIP_DISK}" ["MEM2"]="${FLIP_MEM}" )
declare -A METRIC_DATA=( ["TEMPERATURE"]="Eureka Lincoln Newark" ["CPU"]="%user %nice %system %iowait %steal" ["MEM"]="%memused %commit" ["DISK"]="/boot /home /opt /tmp /var /var/log /var/log/audit" ["MEM2"]="kbmemused kbbuffers kbcached kbcommit" )

# html output
cat << 'EOF'
<head>
  <!-- Plotly.js -->
  <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
</head>

<body>
EOF

# generate the div
for tmpj in "${!METRIC_DATA[@]}"
do
  echo "<div id=\"${tmpj}Div\"><!-- Plotly chart will be drawn inside this DIV --></div>"
done

cat << 'EOF'
  <script>
EOF

for tmpj in "${!METRIC_FILE[@]}"
do
  for tmpi in ${METRIC_DATA[$tmpj]}
  do
    tmpk=`echo ${tmpi}|sed -e 's/ /,data/g' -e 's@[/%]@_@g' -e 's/^/data/'`
    echo "var ${tmpk} = {"
    grep "timestamp" ${METRIC_FILE[$tmpj]}|sed -e 's/^[^;]*;/x: ['\''/' -e 's/;/'\'','\''/g' -e 's/$/'\''],/'
    grep "^${tmpi}" ${METRIC_FILE[$tmpj]}|sed -e 's/^[^;]*;/y: [/' -e 's/;/,/g' -e 's/$/],/'
    echo "mode: 'lines+markers',"
    echo "name: '${tmpi}'"
    echo "};"
  done
done

for tmpj in "${!METRIC_FILE[@]}"
do
  tmpk=`echo ${METRIC_DATA[$tmpj]}|sed -e 's/ /,data/g' -e 's@[/%]@_@g' -e 's/^/data/'`
  echo "var ${tmpj}_data = [ ${tmpk} ];"
done
echo 

for tmpj in "${!METRIC_FILE[@]}"
do
  echo "var ${tmpj}_layout = {"
  echo "  title:'${tmpj}'"
  echo "};"
done

for tmpj in "${!METRIC_FILE[@]}"
do
  echo "Plotly.newPlot('${tmpj}Div', ${tmpj}_data, ${tmpj}_layout);"
done

cat << 'EOF'
  </script>
</body>
EOF
