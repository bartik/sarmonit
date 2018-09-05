#!/bin/bash

# If day specified use that. If not use current.
SADFCPU="-d /var/log/sa/sa${1}"
SADFMEM="/var/log/sa/sa${1}"
if ! [ -e "${SADFMEM}" ]; then
  SADFCPU="-d"
  SADFMEM=""
fi

# Input data files
FILE_CPU="/tmp/cpu.txt"
FILE_MEM="/tmp/mem.txt"
sadf -t ${SADFCPU} -- -r > ${FILE_MEM}
sadf -h -t -P 1 ${SADFMEM} > ${FILE_CPU}

# Interim data files
FILE_CPU_DATE="/tmp/cpu_date.txt"
FILE_CPU_USER="/tmp/cpu_user.txt"
FILE_CPU_SYST="/tmp/cpu_syst.txt"
awk -F';' 'BEGIN { ORS="" ; print "x: [" ; ORS="," ; } /^[^#]/ { print "'\''" $3 "'\''" ; } END { print "]" ; } ' ${FILE_CPU} | sed -e 's/,\]/\]/' > ${FILE_CPU_DATE}
awk -F';' 'BEGIN { ORS="" ; print "y: [" ; ORS="," ; } /^[^#]/ { print  $5 ; } END { print "]" ; } ' ${FILE_CPU} | sed -e 's/,\]/\]/' > ${FILE_CPU_USER}
awk -F';' 'BEGIN { ORS="" ; print "y: [" ; ORS="," ; } /^[^#]/ { print  $7 ; } END { print "]" ; } ' ${FILE_CPU} | sed -e 's/,\]/\]/' > ${FILE_CPU_SYST}

FILE_MEM_DATE="/tmp/mem_date.txt"
FILE_MEM_FREE="/tmp/mem_free.txt"
FILE_MEM_USED="/tmp/mem_used.txt"
awk -F';' 'BEGIN { ORS="" ; print "x: [" ; ORS="," ; } /^[^#]/ { print "'\''" $3 "'\''" ; } END { print "]" ; } ' ${FILE_MEM} | sed -e 's/,\]/\]/' > ${FILE_MEM_DATE}
awk -F';' 'BEGIN { ORS="" ; print "y: [" ; ORS="," ; } /^[^#]/ { print $4+$7+$8 ; } END { print "]" ; } ' ${FILE_MEM} | sed -e 's/,\]/\]/' > ${FILE_MEM_FREE}
awk -F';' 'BEGIN { ORS="" ; print "y: [" ; ORS="," ; } /^[^#]/ { print $9 ; } END { print "]" ; } ' ${FILE_MEM} | sed -e 's/,\]/\]/' > ${FILE_MEM_USED}

# html output
cat << 'EOF'
<head>
  <!-- Plotly.js -->
  <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
</head>

<body>
  <div id="CpuDiv"><!-- Plotly chart will be drawn inside this DIV --></div>
  <div id="MemDiv"><!-- Plotly chart will be drawn inside this DIV --></div>
  <script>
var user = {
EOF
cat ${FILE_CPU_DATE}
echo
cat ${FILE_CPU_USER}
echo
cat << 'EOF'
  mode: 'lines+markers',
  name: 'user'
};

var system = {
EOF
cat ${FILE_CPU_DATE}
echo
cat ${FILE_CPU_SYST}
echo
cat << 'EOF'
  mode: 'lines+markers',
  name: 'system'
};

var free = {
EOF
cat ${FILE_MEM_DATE}
echo
cat ${FILE_MEM_FREE}
echo
cat << 'EOF'
  mode: 'lines+markers',
  name: 'free'
};

var used = {
EOF
cat ${FILE_MEM_DATE}
echo
cat ${FILE_MEM_USED}
echo
cat << 'EOF'
  mode: 'lines+markers',
  name: 'overall used'
};

var cpu_data = [ user, system ];
var mem_data = [ free ];

var cpu_layout = {
  title:'CPU'
};

var mem_layout = {
  title:'MEM'
};

Plotly.newPlot('CpuDiv', cpu_data, cpu_layout);
Plotly.newPlot('MemDiv', mem_data, mem_layout);
  </script>
</body>
EOF
