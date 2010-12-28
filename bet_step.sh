#!/bin/bash
#
# usage: ./bet_step BET_SIZE COMBS_GZ_SOURCE_FILE COMBS_GZ_TARGET_FILE
#

set -e

BET_SIZE=$1
COMBS_GZ_SOURCE_FILE=$2
COMBS_GZ_TARGET_FILE=$3

BET_VALUES_TARGET_FILE=$(mktemp)

touch $BET_VALUES_TARGET_FILE

set +e
./comb_bet_step $BET_SIZE $COMBS_GZ_SOURCE_FILE $BET_VALUES_TARGET_FILE $COMBS_GZ_TARGET_FILE
COMB_STEP_RCODE=$?
set -e
case $COMB_STEP_RCODE in
	0) ;;
	2) exit 2 ;;
	*) 
		echo "error: comb_bet_step failure." 1>&2
		exit 1
		;;
esac

HOW_MANY_BET_VALUES=$(wc -l 0<$BET_VALUES_TARGET_FILE)
while test $HOW_MANY_BET_VALUES -lt $BET_SIZE ; do
	echo 'X' 1>>$BET_VALUES_TARGET_FILE
	HOW_MANY_BET_VALUES=$((HOW_MANY_BET_VALUES+1))
done

tr '\n' ' ' 0<$BET_VALUES_TARGET_FILE
echo
rm -rf $BET_VALUES_TARGET_FILE

