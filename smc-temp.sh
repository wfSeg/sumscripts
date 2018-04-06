#!/bin/bash

mapfile -t command < /usr/local/sbin/command.txt

# this grabs the IPMI IP address of the system
# ipmitool lan print | grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sed 's/[^0-9,.]*//g' > /usr/local/sbin/ipmi.txt
ipmitool lan print | egrep -i IP\ Address | sed 's/[^0-9,.]*//g' | tr -d "\n" > /usr/local/sbin/ipmi.txt
mapfile -t ipmi < /usr/local/sbin/ipmi.txt

U=ADMIN
P=ADMIN
W="===================="
w="------------------------------"

# Drink the purple drink
echo "Wakanda Forever.";

# Get Log directory

cat /root/stage2.conf | grep "SYS_DIR" > /root/flasher_config.sh
source /root/flasher_config.sh

RDIR="${SYS_DIR}"

# Gathering info loop
for i in "${ipmi[@]}"; do
	smc="/usr/local/sbin/smctools/SMCIPMITool $i $U $P";
	echo "$W Test for system at IPMI IP address $i $W"  2>&1 | tee -a ${SYS_DIR}/$i.log;
	date 2>&1 | tee -a ${SYS_DIR}/$i.log;
	for j in "${command[@]}"; do
		echo -e "\nRunning '$j' command" 2>&1 | tee -a ${SYS_DIR}/$i.log;
		echo -e "$w\n" 2>&1 | tee -a ${SYS_DIR}/$i.log;
		$smc $j 2>&1 | tee -a ${SYS_DIR}/$i.log;
	done
	echo -e "\n";
done