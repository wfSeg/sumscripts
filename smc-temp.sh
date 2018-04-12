#!/bin/bash

# Get IPMI IP address on this system
# ipmitool lan print | grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sed 's/[^0-9,.]*//g' > ${DIR}/ipmi.txt
ipmitool lan print | egrep -i IP\ Address | sed 's/[^0-9,.]*//g' | tr -d "\n" > ${DIR}/ipmi.txt;
mapfile -t ipmi < ${DIR}/ipmi.txt;

# define global variables
U=ADMIN
P=ADMIN
DIR="${DIR}"
q="=============================="
smc="${DIR}/smctools/SMCIPMITool ${ipmi[0]} $U $P";
sumtool="${DIR}/smctools/sum -i ${ipmi[0]} -u $U -p $P -c"
: <<'END'
END
# Use SUM to create backup of BMC config
echo -e "Backing up BMC config to ${DIR}/smctools/bmccfg.txt";
$sumtool getbmccfg --file ${DIR}/smctools/bmccfg.txt &> /dev/null;


# Basic SMCIMPITool commands loop, test a lot of functions
mapfile -t command < ${DIR}/command.txt;
for i in "${command[@]}"; do
	echo -e "\n$q$q\nRunning '$i' command\n$q$q\n";
	$smc $i;
done
	echo -e "\n";

# Test SMCIPMITool user creation and deletion
$smc user list;
for i in {3..10}; do
	echo -e "Adding User ID: $i";
	$smc user add $i user$i password$i 4;
	if [[ $i != 10 ]]; then
		echo -e "Testing User ID: $i";
		$smc user test user$i password$i;
		echo -e "Change User ID: $i access level to Operator";
		$smc user level $i 3;
		echo -e "Check if User ID: $i access level changed";
		$smc user test user$i password$i;
	elif [[ $i == 10 ]]; then
		$smc user list;
	fi
done
echo -e "Done testing users, deleting users now.";
for i in {3..10}; do
	$smc user delete $i &> /dev/null;
done
	$smc user list;

# Test SMCIPMITool FRU read / write, restore from cfg file
echo -e "\n$q$q\nFRU Testing\n$q$q\nShowing default FRU";
$smc ipmi fru;
echo -e "Creating fru.backup";
$smc ipmi frubackup ${DIR}/fru.backup;
echo -e "Customizing FRU"
#oifs=$IFS
#IFS=$'\n' frucmd=( $(sed -n 's,",\\",g; s,^.*$,"&",p' ${DIR}/fru_command.txt) )
#IFS=$oifs
mapfile -t frucmd < ${DIR}/fru_command.txt;
for i in "${frucmd[@]}"; do
	echo -e "Writing FRU '$i'";
	$smc ipmi fruw $i &> /dev/null;
done
echo -e "Finished modifying FRU\n\nDisplaying changed FRU\n$q$q";
$smc ipmi fru;
echo -e "Restoring default FRU from backup\n\nDisplaying default FRU\n$q$q";
$smc ipmi frurestore ${DIR}/fru.backup;
$smc ipmi fru;

# Test Fan Modes and Record speed for each mode
echo -e "\n$q$q\nFan Modes Testing\n$q$q\nChecking for supported fan modes";
$smc ipmi fan | sed 's/[^0-9,.]*//g' | sed '/^\s*$/d' > ${DIR}/supportedfanmodes.txt;
mapfile -t fanmodes < ${DIR}/supportedfanmodes.txt;
for i in "${fanmodes[@]}"; do
	echo -e "\nTesting Fan Mode '$i'"
	$smc ipmi fan $i &> /dev/null
	sleep 30;
	$smc ipmi fan | grep Current;
	$smc ipmi sensor | grep FAN
done

# StevenG part of test
nm_detect=`$smc nm detect`;
if [ "$nm_detect" != "This device supports Node Manager" ];then
	echo -e "$q$q\nThis system doesn't support NM, skip NM test\n$q$q";
else 
	echo -e "$q$q\nTesting Power Policy using node manager\n$q$q\nRunning cburn SAT to stress test system";
	echo -e "Waiting 60s for SAT to fully run";
	mem_size=$(free -m | grep "Mem:" | cut -d":" -f2 |sed 's/  */,/g' | cut -d "," -f4);
	/root/x86-sat/./stressapptest -M $((mem_size*9/10)) -s 3600 &>/dev/null &
	secs=60
	while [ $secs -gt 0 ]; do
		echo -ne "Test Starts in: $secs\033[0K\r";
		sleep 1;
		: $((secs--));
	done
	power=0
	echo -e "Clearing policy ID:1";
	$smc nm delpolicy 1 &>/dev/null;
	echo -e "Checking for policies";
	$smc nm20 scanpolicy;
	for k in {1..10} ;do
		p=`$smc nm20 oemgetpower | cut -d " " -f 1 `;
		echo -e "Sampling current power: $p W";
		sleep 0.5;
		let  "power+=$p";
	done
	let "power1=$(($power/10))";
	echo -e "$q$q\nAverage Power = $power1 W";
	echo -ne "Measuring CPU frequency, please wait\n";
	sh ${DIR}/cpu_freq.sh;
	echo -e "Apply power policy #1 (80% of current power)";
	echo -e "Setting power limit to $(($power1*8/10)) W";
	$smc nm addpolicy 1 $(($power1*8/10)) 6000 10 >/dev/null;
	$smc nm scanpolicy;
	echo -e "";
	sleep 10;
	power=0
	for k in {1..10} ;do
		p=`$smc nm20 oemgetpower |cut -d " " -f 1 `;
		echo -e "Sampling power with policy enable: $p W";
		sleep 0.5;
		let "power+=$p";
	done
	let "power2=$(($power/10))";
	echo -e "$q$q\nAverage power with policy enable: $power2 W";
	echo -ne "Measuring CPU frequency, please wait\n";
	sh ${DIR}/cpu_freq.sh;
	echo -e "Average power without policy: $power1 W";
	let "tolerance=$(($power2-$((power1*8/10))))";
	if [ $tolerance -lt 10 -a $((-$tolerance)) -lt 10 ];then
		echo -e "Tolerance: $tolerance W";
		echo -e "$q$q\nPASS!\n$q$q";
	else 
		echo -e "$q$q\nFAIL\n$q$q\nPlease check logs or check if system overheated";
		echo -e "Make sure system is removed from SPM!";
	fi
	echo -e "Clear existing policy 1 and nm power policy test is finished";
	echo -e "SAT will be killed automatically, no worry.";
	$smc nm delpolicy 1 >/dev/null;
	pin=`pgrep stressapptest`;
	kill $pin;
fi

# Use SUM to restore BMC to default config
echo -e "Restoring BMC config from ${DIR}/smctools/bmccfg.txt";
$sumtool changebmccfg --file ${DIR}/smctools/bmccfg.txt
