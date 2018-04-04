#!/bin/bash

REGEX="^[[:upper:]]{2}[[:lower:]]*$"

# Test 1
String=Hello
if [[ $STRING =~ $REGEX ]]; then
	echo "Match."
else
	echo "No match."
fi
# ==> "No match."

# Test 2
String=HEllo
if [[ $STRING =~ $REGEX ]]; then
	echo "Match."
else
	echo "No match."
fi
# ==> "Match."