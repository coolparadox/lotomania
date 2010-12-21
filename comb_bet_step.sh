#!/bin/bash
#
# usage: ./comb_bet_step BET_SIZE BET_VALUES_SOURCE_FILE COMBS_GZ_SOURCE_FILE BET_VALUES_TARGET_FILE COMBS_GZ_TARGET_FILE
#

set -e

BET_SIZE=$1
BET_VALUES_SOURCE_FILE=$2
COMBS_GZ_SOURCE_FILE=$3
BET_VALUES_TARGET_FILE=$4
COMBS_GZ_TARGET_FILE=$5

ZIP='pigz -9c'
UNZIP='pigz -dc'

unline() {
	sed -e 's/ *$//' -e 's/  */\n/g'
}

line() {
	tr '\n' ' '
}

HOW_MANY_BET_VALUES=$(wc -l 0<$BET_VALUES_SOURCE_FILE)
test $HOW_MANY_BET_VALUES -lt $BET_SIZE || {
	echo "error: there are at least $BET_SIZE bet values available." 1>&2
	exit 1
}

HOW_MANY_COMBS=$($UNZIP $COMBS_GZ_SOURCE_FILE | wc -l)
test $HOW_MANY_COMBS -gt 0 || {
	# Combinations are over; cannot gather more bet values.
	cp $BET_VALUES_SOURCE_FILE $BET_VALUES_TARGET_FILE
	cp $COMBS_GZ_SOURCE_FILE $COMBS_GZ_TARGET_FILE
	exit 2
}

COMB_VALUES_FILE=$(mktemp)
COMB_NUMBER=$(./random_value 1 $HOW_MANY_COMBS)
$UNZIP $COMBS_GZ_SOURCE_FILE | sed -n -e "${COMB_NUMBER}{p;q}" | unline 1>$COMB_VALUES_FILE
sort -n $BET_VALUES_SOURCE_FILE $COMB_VALUES_FILE | uniq | head -n $BET_SIZE 1>$BET_VALUES_TARGET_FILE
rm -f $COMB_VALUES_FILE 

BET_COMBS_FILE=$(mktemp)
COMB_SIZE=$($UNZIP $COMBS_GZ_SOURCE_FILE | head -n1 | unline | wc -l)
./combine $COMB_SIZE $(line 0<$BET_VALUES_TARGET_FILE) 1>$BET_COMBS_FILE
$UNZIP $COMBS_GZ_SOURCE_FILE | grep -v -F -x -f $BET_COMBS_FILE | $ZIP 1>$COMBS_GZ_TARGET_FILE
rm -f $BET_COMBS_FILE

