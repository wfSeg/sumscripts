#!/bin/bash

# Get IPMI IP address on this system
# ipmitool lan print | grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sed 's/[^0-9,.]*//g' > /usr/local/sbin/ipmi.txt
ipmitool lan print | egrep -i IP\ Address | sed 's/[^0-9,.]*//g' | tr -d "\n" > /usr/local/sbin/ipmi.txt
mapfile -t ipmi < /usr/local/sbin/ipmi.txt

U=ADMIN
P=ADMIN

# define global variables
smc="/usr/local/sbin/smctools/SMCIPMITool ${ipmi[0]} $U $P";
: <<'END'
END
# Gathering info loop
mapfile -t command < /usr/local/sbin/command.txt
for i in "${command[@]}"; do
	echo -e "\nRunning '$i' command";
	$smc $i;
done
	echo -e "\n";

# Test SMCIPMITool user creation and deletion
$smc user list
for i in {3..10}; do
	echo -e "Adding User ID: $i";
	$smc user add $i user$i password$i 4;
	if [[ $i != 10 ]]; then
		echo -e "Testing User ID: $i";
		$smc user test user$i password$i;
	elif [[ $i == 10 ]]; then
		$smc user list;
	fi
done
echo -e "Done testing users, deleting users now.";
for i in {3..10}; do
	$smc user delete $i;
done
	$smc user list;

# Test SMCIPMITool FRU read / write, restore from cfg file
echo -e "Showing default FRU";
$smc ipmi fru;
echo -e "Creating fru.backup";
$smc ipmi frubackup /usr/local/sbin/fru.backup
# $smc ipmi fruw ct Spaceship
echo -e "Customizing FRU"
$smc ipmi fruw cp WAK-AND-DA408 &> /dev/null
$smc ipmi fruw cs 123ABC-456DEF &> /dev/null
$smc ipmi fruw bdt 202207041776 &> /dev/null
$smc ipmi fruw bpn Wakandan Board &> /dev/null
$smc ipmi fruw bs ABC123-DEF456 &> /dev/null
$smc ipmi fruw bp X12WKN-D4 &> /dev/null
$smc ipmi fruw pm Wakanda &> /dev/null
$smc ipmi fruw pn Forever &> /dev/null
$smc ipmi fruw ppm WAKANDA-BOARD &> /dev/null
$smc ipmi fruw pv 3.0 &> /dev/null
$smc ipmi fruw ps 10987654CBA &> /dev/null
$smc ipmi fruw pat Property of Wakanda &> /dev/null
echo -e "Finished modifying FRU\nDisplaying changed FRU"
$smc ipmi fru
echo -e "Restoring default FRU from backup\nDisplaying default FRU"
$smc ipmi frurestore /usr/local/sbin/fru.backup
$smc ipmi fru

# Test Fan Modes and Record speed for each mode
echo -e "Checking for supported fan modes"
$smc ipmi fan | sed 's/[^0-9,.]*//g' | sed '/^\s*$/d' > /usr/local/sbin/supportedfanmodes.txt
mapfile -t fanmodes < /usr/local/sbin/supportedfanmodes.txt
for i in ${fanmodes[@]}; do
	echo -e "\nTesting Fan Mode '$i'"
	$smc ipmi fan $i &> /dev/null
	sleep 30;
	$smc ipmi fan | grep Current;
	$smc ipmi sensor | grep FAN
done

# Stevie G part of test
echo -e "#########################################"
echo -e "stress up system with cburn SAT"
echo -e "Waiting 30s for SAT to fully run "
./root/x86-sat/stressapptest -s 3600 &>/dev/null &
echo -e "#########################################"
sleep 30
power=0 
echo -e "Clear existing policy 1"   
	$smc nm delpolicy 1 >/dev/null
sleep 10
for k in {1..10} ;do
	p=`$smc nm20 oemgetpower | cut -d " " -f 1 `
	echo -e "Sampling current power:$p"
	sleep 0.5
	let  "power+=$p"
done
let "power1=$(($power/10))"
echo -e "Average Power=$power1"
echo -e "#############################################"
echo -e "Apply power policy #1(70% of current power)"
echo -e "Setting power limit to $(($power1*7/10))w"
echo -e "#############################################"
$smc nm addpolicy 1 $(($power1*7/10)) 3000 5 >/dev/null
$smc nm scanpolicy 
echo -e "============================================================"
sleep 10
        power=0
for k in {1..10} ;do
	p=`$smc nm20 oemgetpower |cut -d " " -f 1 `
	echo -e "Sampling power with policy enable:$p"
	sleep 0.5
	let "power+=$p"
done
let "power2=$(($power/10))"
echo -e "Average power with policy enable:$power2"
echo -e "Average power without policy:$power1"
let "tolerance=$(($power2-$((power1*7/10))))"
if [ $tolerance -lt 10 -a $((-$tolerance)) -lt 10 ];then
	echo -e "tolerance:$tolerance"
	echo -e "pass!"
	else 
	echo -e "Fail,please check logs"
fi
	echo -e "Clear existing policy 1 and nm power policy test is finished"
	echo -e "SAT will be killed automatically, no worry."
	$smc nm delpolicy 1 >/dev/null
pin=`pgrep stressapptest`
kill $pin
