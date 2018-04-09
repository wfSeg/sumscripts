#!/bin/bash

mapfile -t command < /root/test_item.txt

# this grabs the IPMI IP address of the system

# ipmitool lan print | grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sed 's/[^0-9,.]*//g' > /usr/local/sbin/ipmi




ipmitool lan print | egrep -i IP\ Address | sed 's/[^0-9,.]*//g' | tr -d "\n" > /root/ipmi.txt
mapfile -t ipmi < /root/ipmi.txt

U=ADMIN
P=ADMIN
W="===================="
w="------------------------------"

# Drink the purple drink
echo "Wakanda Forever.";

# Gathering info loop
for i in "${ipmi[@]}"; do
	D=/root/$i.log
	i='172.16.105.247'
	smc="./SMCIPMITool $i $U $P";
	echo "$W Test for system at IPMI IP address $i $W"  2>&1 | tee -a $D;
	date 2>&1 | tee -a $D;
        
		echo "#########################################"
		echo "stress up system with cburn SAT"
		echo "Waiting 30s for SAT to fully run "
		/root/x86-sat/./stressapptest -s 3600 &>/dev/null &
		sleep 30
		echo "#########################################"
	power=0 
		echo "Clear existing policy 1"   
	    	$smc nm delpolicy 1 >/dev/null
		sleep 10
	
	    	for k in {1..10} ;do
	    	    p=`$smc nm20 oemgetpower |cut -d " " -f 1 `
	    	    echo "Sampling current power:$p"
	    	    sleep 0.5
	    	    let  "power+=$p"
		done
		let "power1=$(($power/10))"
		echo "Average Power=$power1"
		echo "#############################################"
		echo "Apply power policy #1(70% of current power)"
		echo "Setting power limit to $(($power1*7/10))w"
		echo "#############################################"
		$smc nm addpolicy 1 $(($power1*7/10)) 3000 5 >/dev/null
		$smc nm scanpolicy 
		echo "============================================================"
		sleep 10
                power=0

	    	for k in {1..10} ;do
	    	    p=`$smc nm20 oemgetpower |cut -d " " -f 1 `
                    echo "Sampling power with policy enable:$p"
	            sleep 0.5
                    let "power+=$p"
		done
                    let "power2=$(($power/10))"
                    echo "Average power with policy enable:$power2"
		    echo "Average power without policy:$power1"
		let "tolerance=$(($power2-$((power1*7/10))))"
		if [ $tolerance -lt 10 -a $((-$tolerance)) -lt 10 ];then
		    echo "tolerance:$tolerance"
		    echo "pass!"
		    else 
		    echo "Fail,please check logs"
		fi
	
                echo "Clear existing policy 1 and nm power policy test is finished"
				echo "SAT will be killed automatically, no worry.
                $smc nm delpolicy 1 >/dev/null
		pin=`pgrep stressapptest`
		kill $pin


	echo -e " \n";
	done              

