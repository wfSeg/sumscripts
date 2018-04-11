#!/bin/bash

mapfile -t ipmi < haslicense.temp
mapfile -t command < sum_commands.txt

U=ADMIN
P=ADMIN

echo "testing"
#./timer.sh
#check for license
#./keycheck.sh

echo -e "\e[32m\e[7mTesting only system/nodes with license activated.\e[0m"
echo -e "\e[32mPlease see nolicense.temp for systems that needs license.\e[0m"
for i in "${ipmi[@]}"; do
	#D=$i.log;
	smc="./sum -i $i -u $U -p $P -c";
	echo -e "\e[32mTest for system at IPMI IP address\e[0m $i"  #2>&1 | tee -a $D;
	#date 2>&1 | tee -a $D;
	for j in "${command[@]}"; do
		echo -e "\e[1;4mRunning $j\e[0m" #2>&1 | tee -a $D;
		$smc $j #2>&1 | tee -a $D;
		echo -e "\n";
	done
done