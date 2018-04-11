#!/bin/bash

# timer

s=5
while [ $s -gt 0 ]; do
	echo "Test start in $s";
	sleep 1;
	let s=s-1;
done

# another timer example
secs=30
while [ $secs -gt 0 ]; do
	echo -ne "Test Starts in: $secs\033[0K\r"
	sleep 1
	: $((secs--))
done