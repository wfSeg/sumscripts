#!/bin/bash

mapfile -t ipmi < ipmi.txt
mapfile -t command < fancmd.txt

U=ADMIN
P=ADMIN
W="===================="
w="------------------------------"

# Gathering info loop
for i in "${ipmi[@]}"; do
	D=$i-fanmodes.log;
	smc="./SMCIPMITool $i $U $P";
	echo "$W Fan speed for system at IPMI IP address $i $W"  2>&1 | tee -a $D;
	date 2>&1 | tee -a $D;
	for j in "${command[@]}"; do
		$smc ipmi fan | grep Current 2>&1 | tee -a $D;
		echo -e "\nRunning '$j' command" 2>&1 | tee -a $D;
		$smc $j 2>&1 | tee -a $D;
		sleep 10;
		$smc ipmi fan | grep Current 2>&1 | tee -a $D;
		sleep 30;
		$smc ipmi sensor | grep FAN 2>&1 | tee -a $D;
	done
	echo -e "\n";
done
