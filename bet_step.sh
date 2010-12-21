#!/bin/bash
#
# usage: ./bet_step BET_SIZE COMBS_GZ_SOURCE_FILE COMBS_GZ_TARGET_FILE
#

set -e

BET_SIZE=$1
COMBS_GZ_SOURCE_FILE=$2
COMBS_GZ_TARGET_FILE=$3

WORK_DIR=$(mktemp -d)
BET_VALUES_SOURCE_FILE="$WORK_DIR/bets_src"
COMBS_GZ_SOURCE_TMP_FILE="$WORK_DIR/combs_src.gz"
BET_VALUES_TARGET_FILE="$WORK_DIR/bets_tgt"
COMBS_GZ_TARGET_TMP_FILE="$WORK_DIR/combs_tgt.gz"

touch $BET_VALUES_TARGET_FILE
cp $COMBS_GZ_SOURCE_FILE $COMBS_GZ_TARGET_TMP_FILE

HOW_MANY_BET_VALUES=0
while true ; do
	mv $BET_VALUES_TARGET_FILE $BET_VALUES_SOURCE_FILE
	mv $COMBS_GZ_TARGET_TMP_FILE $COMBS_GZ_SOURCE_TMP_FILE
	set +e
	./comb_bet_step $BET_SIZE $BET_VALUES_SOURCE_FILE $COMBS_GZ_SOURCE_TMP_FILE $BET_VALUES_TARGET_FILE $COMBS_GZ_TARGET_TMP_FILE
	COMB_STEP_RCODE=$?
	set -e
	test $COMB_STEP_RCODE -ne 2 || break
	test $COMB_STEP_RCODE -eq 0 || {
		echo "error: comb_bet_step failure." 1>&2
		exit 1
	}
	HOW_MANY_BET_VALUES=$(wc -l 0<$BET_VALUES_TARGET_FILE)
	test $HOW_MANY_BET_VALUES -lt $BET_SIZE || break
done
mv $COMBS_GZ_TARGET_TMP_FILE $COMBS_GZ_TARGET_FILE
tr '\n' ' ' 0<$BET_VALUES_TARGET_FILE
echo
exit $COMB_STEP_RCODE
