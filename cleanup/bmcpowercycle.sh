#!/bin/bash
mapfile -t ipmi < ipmi.txt
U=ADMIN
P=ADMIN

# BMC Power Cycle test
PL=$(date +%Y-%m-%d)_powercycle.log
delay=9
cycles=200
for ((j=1;j<=cycles;j++)); do
    echo -e "\n$WPower Cycle #$j $W" 2>&1 | tee -a $PL;
    date 2>&1 | tee -a $PL;
	for i in "${ipmi[@]}"; do
		echo "$i Power Status" 2>&1 | tee -a $PL;
		pow="./SMCIPMITool $i $U $P ipmi power";
		$pow status 2>&1 | tee -a $PL;
	done
	for i in "${ipmi[@]}"; do
		echo "$i Power Down" 2>&1 | tee -a $PL;
		pow="./SMCIPMITool $i $U $P ipmi power";
		$pow down 2>&1 | tee -a $PL;
	done
	sleep $delay;
	for i in "${ipmi[@]}"; do
		echo "$i Power Status" 2>&1 | tee -a $PL;
		pow="./SMCIPMITool $i $U $P ipmi power";
		$pow status 2>&1 | tee -a $PL;
	done
	for i in "${ipmi[@]}"; do
		echo "$i Power Up" 2>&1 | tee -a $PL;
		pow="./SMCIPMITool $i $U $P ipmi power";
		$pow up 2>&1 | tee -a $PL;
	done
	sleep $delay;
done
