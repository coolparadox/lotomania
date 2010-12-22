#!/bin/bash

set -e

BET_FILE=$(mktemp)
while read BET ; do

	echo $BET 1>$BET_FILE
	for BET_VALUE in $(seq 1 100) ; do
		grep -q "\<${BET_VALUE}\>" $BET_FILE || echo -n "${BET_VALUE} "
	done
	echo
done

rm -f $BET_FILE

