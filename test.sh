#!/bin/bash

mapfile -t ipmi < ipmi.txt
mapfile -t command < fancmd.txt

U=ADMIN
P=ADMIN
W="===================="
w="------------------------------"

# read the readme
echo "edit fancmd.txt for system depending on which mode supported"
# Test Timer
s=3
while [ $s -gt 0 ]; do
     echo "Test start in $s";
     sleep 1;
     let s=s-1;
done

# Gathering info loop
for i in "${ipmi[@]}"; do
	D=$i-fanmodes.log;
	smc="./SMCIPMITool $i $U $P";
	echo "$W Fan speed for system at IPMI IP address $i $W"  2>&1 | tee -a $D;
	date 2>&1 | tee -a $D;
	for j in "${command[@]}"; do
		$smc ipmi fan | grep Current 2>&1 | tee -a $D;
		echo -e "\nRunning '$j' command" 2>&1 | tee -a $D;
		echo -e "$w\n" 2>&1 | tee -a $D;
		$smc $j 2>&1 | tee -a $D;
		sleep 30;
		done
	done
	echo -e "\n";
done
