#!/bin/bash

mapfile -t command < sum_commands.txt

U=ADMIN
P=ADMIN
smc="./sum -l IP_ADDR_RANGE.txt -u $U -p $P -c"

echo "testing"
#./timer.sh
for j in "${command[@]}"; do
	echo -e "\e[44mRunning $j\e[0m" #2>&1 | tee -a $D;
	$smc $j #2>&1 | tee -a $D;
	echo -e "\n";
done

# dont' use this, built-in range thing creates logs automatically, can't organize it