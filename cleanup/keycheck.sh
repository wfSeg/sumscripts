#!/bin/bash

# check for DCMS key, if no key, list IP in nolicense.temp

mapfile -t ipmi < ipmi_ip_addresses.txt
U=ADMIN
P=ADMIN

# cleanup temp files from other runs
echo -n "" > haslicense.temp
echo -n "" > nolicense.temp

for i in "${ipmi[@]}"; do
	echo -e "\e[32mCheck for key at IPMI IP:\e[0m $i"
	declare -a KEY
	KEY=( $(./sum -i $i -u $U -p $P -c QueryProductKey | grep -i SFT-DCMS-Single) )
	echo ${KEY[1]}
	if [[	${KEY[1]} =~ SFT-DCMS-Single/*	]]; then
		echo -e "\e[34mSystem\e[0m $i \e[34mhas license\e[0m"
		echo -e "$i" >> haslicense.temp
	else
		echo -e "\e[31mSystem\e[0m $i \e[31mdoes not have license\e[0m"
		echo -e "$i" >> nolicense.temp
	fi
done
