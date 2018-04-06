#!/bin/bash

mapfile -t ipmi < ipmi.txt
mapfile -t command < command.txt

U=ADMIN
P=ADMIN
W="===================="
w="------------------------------"

# read the readme
echo "Please clear logs from previous tests in this folder first";
# Test Timer
s=5
while [ $s -gt 0 ]; do
	echo "Test start in $s";
	sleep 1;
	let s=s-1;
done

# Gathering info loop
for i in "${ipmi[@]}"; do
	D=$i.log;
	smc="./SMCIPMITool $i $U $P";
	echo "$W Test for system at IPMI IP address $i $W"  2>&1 | tee -a $D;
	date 2>&1 | tee -a $D;
	for j in "${command[@]}"; do
		echo -e "$W \nRunning '$j' command $W" 2>&1 | tee -a $D;
		echo -e "$w\n" 2>&1 | tee -a $D;
		$smc $j 2>&1 | tee -a $D;
	done
	echo -e "\n";
done

# Fan Speed Mode test
echo "Beginning Fan Speed test";
echo "edit fancmd.txt for system depending on which mode supported"

# Test Timer
s=10
while [ $s -gt 0 ]; do
    echo "Test start in $s";
    sleep 1;
    let s=s-1;
done
./fantest.sh

# Power Cycle test
echo "Beginning Power Cycle Test";
# Test Timer
s=10
while [ $s -gt 0 ]; do
    echo "Test start in $s";
    sleep 1;
    let s=s-1;
done
./bmcpowercycle.sh
