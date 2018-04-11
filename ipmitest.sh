#!/bin/bash
# Author: Long Nguyen
# Copied the start.sh from brian, modified it so it will launch ipmitest.sh
# This script replaces tty2 (alt+f2) with a console 
# ipmitest.sh will launch getty-wakanda@service, the service will launch
# logger.sh. Logger.sh is basically a wrapper for the main program
# smc-temp.sh. The logger provides the log for the whole test, you can find the log in cburn directory
# smc-temp.sh contains all the tests. packy.tar is the tools package required
# for smc-temp.sh tests.
# 
# Requirements are:
# cburn, AutoPXE or OnOff Tracker
IP=172.16.113.224

echo " " |tee -a /dev/tty0

wget "http://${IP}/scripts/service/getty-wakanda@.service" -O "/lib/systemd/system/getty-wakanda@.service" &> /dev/null
if [ $? -ne 0 ]
 then
	echo "Failed to acquire getty service for ipmi tests.\nNo Vibranium here." | tee /dev/tty0
	return 1
	exit 1
fi
echo "Wakanda Service installed.\nWelcome to Wakanda." | tee /dev/tty0
############################################################################################################################
/usr/bin/systemctl daemon-reload
if [ $? -ne 0 ]
 then
	echo "Failed to reload systemd." | tee /dev/tty0
	return 2
#	exit 2
fi
echo "Systemd reload finished." | tee /dev/tty0
########################################################################################################################
mkdir /usr/local/sbin/smctools/
wget "http://${IP}/tools/packy.tar" -O "/usr/local/sbin/smctools/packy.tar" &> /dev/null
tar -xf /usr/local/sbin/smctools/packy.tar -C /usr/local/sbin/smctools/ --strip 1 &> /dev/null
chmod +x /usr/local/sbin/smctools/SMCIPMITool
chmod +x /usr/local/sbin/smctools/sum

if [ $? -ne 0 ]
 then
	echo "Failed to get the tools package." | tee /dev/tty0
	return 1
#	exit 1
fi

echo "SMCI tools installed." | tee /dev/tty0

########################################################################################################################

wget "http://${IP}/scripts/smc-temp.sh" -O "/usr/local/sbin/smc-temp.sh" &> /dev/null
wget "http://${IP}/scripts/logger.sh" -O "/usr/local/sbin/logger.sh" &> /dev/null
wget "http://${IP}/scripts/unpacky.sh" -O "/usr/local/sbin/unpacky.sh" &> /dev/null
wget "http://${IP}/scripts/hi.sh" -O "/usr/local/sbin/hi.sh" &> /dev/null
wget "http://${IP}/scripts/fancmd.txt" -O "/usr/local/sbin/fancmd.txt" &> /dev/null
wget "http://${IP}/scripts/command.txt" -O "/usr/local/sbin/command.txt" &> /dev/null
wget "http://${IP}/scripts/fru_command.txt" -O "/usr/local/sbin/fru_command.txt" &> /dev/null
wget "http://${IP}/scripts/cpu_freq.sh" -O "/usr/local/sbin/cpu_freq.sh" &> /dev/null
if [ $? -ne 0 ]
 then
	echo "Failed to get scripts." | tee /dev/tty0
	return 1
#	exit 1
fi

chmod +x /usr/local/sbin/*.sh

echo "SMCIPMITool scripts installed." | tee /dev/tty0

###############################################################################################################################

/usr/bin/systemctl stop getty-auto-cburn@tty2.service
/usr/bin/systemctl stop getty-auto-root@tty2.service
/usr/bin/systemctl stop getty@tty2.service
./usr/local/sbin/unpacky.sh
echo " " |tee -a /dev/tty0
echo -e "\e[32m\e[5mStarting Scripts. Press Alt+F2 to view Progress on tty2.\e[0m" |tee -a /dev/tty0
echo " " |tee -a /dev/tty0
/usr/bin/systemctl start getty-wakanda@tty2.service

#echo "Waiting for completion of FIO" | tee -a /dev/tty0
#sleep 86400
#echo "FIO Test Finished" | tee -a /dev/tty0
