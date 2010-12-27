#!/bin/bash
#
# usage: ./check_matches VALUE [VALUE [VALUE [...]]] 0<BETS_FILE
#

set -e

VALUES_FILE=$(mktemp)
echo $* | tr ' ' '\n' 1>$VALUES_FILE

while read BET ; do
	HOW_MANY_MATCHES=$(echo $BET | tr ' ' '\n' | grep -F -x -f $VALUES_FILE | wc -l)
	echo "${HOW_MANY_MATCHES}: ${BET}"
done | sort -n -r

rm -f $VALUES_FILE

