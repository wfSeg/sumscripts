#!/bin/bash

# This starts the whole test.
# Wrapper for logging
# Get Log directory
cat /root/stage2.conf | grep "SYS_DIR" > /root/flasher_config.sh;
source /root/flasher_config.sh;
RDIR="${SYS_DIR}";
#RDIR=/usr/local/sbin
U=ADMIN
P=ADMIN
DIR="${DIR}"
q="=============================="
smc="${DIR}/smctools/SMCIPMITool ${ipmi[0]} $U $P";
sumtool="${DIR}/smctools/sum -i ${ipmi[0]} -u $U -p $P -c"

# Get IPMI IP address
ipmitool lan print | egrep -i IP\ Address | sed 's/[^0-9,.]*//g' | tr -d "\n" > /usr/local/sbin/ipmi.txt;
mapfile -t ipmi < /usr/local/sbin/ipmi.txt;
IPMI=${ipmi[0]};

# Drink the purple power drink
sh /usr/local/sbin/hi.sh;
echo "Wakanda Forever.";

# Add in IPMI IP network connection check
# Add in sum Product key check for OOB/DCMS
ipmi_detect="$smc ipmi ver"
key_detect="$sumtool queryproduct key"
if [ "$ipmi_detect" == "Can't connect to ${IPMI}" ];then
	echo -e "$q$q\nIPMI LAN interface is not working, please check BMC\n$q$q";
elif [[ "$key_detect" ]]; then
	echo -e "$q$q\nDCMS/OOB key not detected, please activate with cburn KDCMS\n$q$q";
else
	echo -e "Test on $IPMI started on:" 2>&1 | tee -a $RDIR/$IPMI.log;
	date 2>&1 | tee -a $RDIR/$IPMI.log;
	sh /usr/local/sbin/smc-temp.sh 2>&1 | tee -a $RDIR/$IPMI-$(date +%Y-%m-%d).log;
	echo -e "Test done, please see Logs at $RDIR/$IPMI-$(date +%Y-%m-%d).log";
fi