#!/bin/bash

# This starts the whole test.
# Wrapper for logging
# Get Log directory
cat /root/stage2.conf | grep "SYS_DIR" > /root/flasher_config.sh;
source /root/flasher_config.sh;
RDIR="${SYS_DIR}";
#RDIR=/usr/local/sbin

# Get IPMI IP address
ipmitool lan print | egrep -i IP\ Address | sed 's/[^0-9,.]*//g' | tr -d "\n" > /usr/local/sbin/ipmi.txt;
mapfile -t ipmi < /usr/local/sbin/ipmi.txt;
IPMI=${ipmi[0]};

# Drink the purple power drink
sh /usr/local/sbin/hi.sh;
echo "Wakanda Forever.";

# Run script and log it
echo -e "Test on $IPMI started on:" 2>&1 | tee -a $RDIR/$IPMI.log;
date 2>&1 | tee -a $RDIR/$IPMI.log;
sh /usr/local/sbin/smc-temp.sh 2>&1 | tee -a $RDIR/$IPMI-$(date +%Y-%m-%d).log;
echo -e "Test done, please see Logs at $RDIR/$IPMI.log";