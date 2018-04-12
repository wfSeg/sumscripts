#!/bin/bash

# Scratch pad
# Trying to store directory

ipmitool lan print | egrep -i IP\ Address | sed 's/[^0-9,.]*//g' | tr -d "\n" > /usr/local/sbin/ipmi.txt;
mapfile -t ipmi < /usr/local/sbin/ipmi.txt;
U=ADMIN
P=ADMIN

DIR="/usr/local/sbin"
smc="${DIR}/smctools/SMCIPMITool ${ipmi[0]} $U $P" 
echo $smc
$smc ipmi ver
# ok, used double quotes, and {} braces for DIR, it works now. Finally.