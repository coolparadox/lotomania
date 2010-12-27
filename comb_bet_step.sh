#!/bin/bash
#
# usage: ./comb_bet_step HOW_MANY_WANTED_BET_VALUES BET_VALUES_SOURCE_FILE COMBS_GZ_SOURCE_FILE BET_VALUES_TARGET_FILE COMBS_GZ_TARGET_FILE
#

set -e

HOW_MANY_WANTED_BET_VALUES=$1
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

line2regexp() {
	sed -r -e 's/ *$//' -e 's/ +/\\>.*\\</g' -e 's/^/\\</' -e 's/$/\\>/'
}

COMB_SAMPLE=$($UNZIP $COMBS_GZ_SOURCE_FILE | head -n1)
test -n "$COMB_SAMPLE" || {
	# No more combinations to try.
	cp -f $COMBS_GZ_SOURCE_FILE $COMBS_GZ_TARGET_FILE
	cp -f $BET_VALUES_SOURCE_FILE $BET_VALUES_TARGET_FILE
	exit 2
}
COMB_SIZE=$(echo $COMB_SAMPLE | unline | wc -l)
test $COMB_SIZE -gt 0 || {
	echo "${0}: internal error: tuple size == 0 ?!" 1>&2
	exit 1
}

# Cycle through combinations, gathering the most valuable ones to form a bet.
COMB_VALUES_FILE=$(mktemp)
NEW_COMB_VALUES_FILE=$(mktemp)
for DISTINCT_SIZE in $(seq $COMB_SIZE -1 1) ; do
	$UNZIP $COMBS_GZ_SOURCE_FILE | while read COMB ; do
		HOW_MANY_VALUES_FOUND=$(wc -l 0<$COMB_VALUES_FILE)
		HOW_MANY_VALUES_MISSING=$((HOW_MANY_WANTED_BET_VALUES-HOW_MANY_VALUES_FOUND))
		test $HOW_MANY_VALUES_MISSING -ge $DISTINCT_SIZE || break
		echo $COMB | unline 1>$NEW_COMB_VALUES_FILE
		HOW_MANY_DISTINCT_VALUES=$(grep -v -F -x -f $COMB_VALUES_FILE $NEW_COMB_VALUES_FILE | wc -l)
		test $HOW_MANY_DISTINCT_VALUES -eq $DISTINCT_SIZE || continue
		cat $COMB_VALUES_FILE 1>>$NEW_COMB_VALUES_FILE
		sort -n $NEW_COMB_VALUES_FILE | uniq 1>$COMB_VALUES_FILE
	done
done
rm -f $NEW_COMB_VALUES_FILE

# Merge new gathered bet values with current ones.
sort -m -n $BET_VALUES_SOURCE_FILE $COMB_VALUES_FILE | uniq 1>$BET_VALUES_TARGET_FILE
rm -f $COMB_VALUES_FILE 

# Filter the covered combinations out of the combinations file.
BET_COMBS_FILE=$(mktemp)
./combine $COMB_SIZE $(line 0<$BET_VALUES_TARGET_FILE) 1>$BET_COMBS_FILE
$UNZIP $COMBS_GZ_SOURCE_FILE | ./vgrep '-F -x' $BET_COMBS_FILE | $ZIP 1>$COMBS_GZ_TARGET_FILE
rm -f $BET_COMBS_FILE

