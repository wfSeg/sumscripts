#!/bin/bash

#timer

s=5
while [ $s -gt 0 ]; do
	echo "Test start in $s";
	sleep 1;
	let s=s-1;
done