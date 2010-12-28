#!/bin/bash
#
# usage: ./bet_template TUPLE_SIZE BET_SIZE SET_SIZE 
#

set -e

TUPLE_SIZE=$1
BET_SIZE=$2
SET_SIZE=$3

ZIP='pigz --fast -c'

COMBS_GZ_TARGET_FILE=$(mktemp)
COMBS_GZ_SOURCE_FILE=$(mktemp)
BET_FILE=$(mktemp)
./combine $TUPLE_SIZE $(seq -s ' ' 1 $SET_SIZE) | $ZIP 1>$COMBS_GZ_TARGET_FILE
while true ; do
	mv $COMBS_GZ_TARGET_FILE $COMBS_GZ_SOURCE_FILE
	set +e
	./bet_step $BET_SIZE $COMBS_GZ_SOURCE_FILE $COMBS_GZ_TARGET_FILE 1>$BET_FILE
	BET_STEP_RCODE=$?
	set -e
	test $BET_STEP_RCODE -ne 2 || break
	test $BET_STEP_RCODE -eq 0 || {
		echo "error: bet_step failure." 1>&2
		exit 1
	}
	cat $BET_FILE
done

rm -f $COMBS_GZ_TARGET_FILE $COMBS_GZ_SOURCE_FILE $BET_FILE

