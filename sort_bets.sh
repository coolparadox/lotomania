#!/bin/bash

KEYS=$(seq -s ' ' 1 100 | sed -r -e 's/\<[[:digit:]]/-n -k&/g')

while read BET ; do
	echo $BET | \
	tr ' ' '\n' | \
	sort -n | \
	tr '\n' ' '
	echo
done | \
sort -t ' ' $KEYS

