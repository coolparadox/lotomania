#!/bin/bash
#
# usage: ./comb_bet_step HOW_MANY_WANTED_BET_VALUES COMBS_GZ_SOURCE_FILE BET_VALUES_TARGET_FILE COMBS_GZ_TARGET_FILE
#

set -e

HOW_MANY_WANTED_BET_VALUES=$1
COMBS_GZ_SOURCE_FILE=$2
BET_VALUES_TARGET_FILE=$3
COMBS_GZ_TARGET_FILE=$4

ZIP='pigz -c'
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

COMB_SAMPLE=$($UNZIP 0<$COMBS_GZ_SOURCE_FILE | head -n1)
test -n "$COMB_SAMPLE" || {
	# No more combinations to try.
	cp -f $COMBS_GZ_SOURCE_FILE $COMBS_GZ_TARGET_FILE
	echo -n '' 1>$BET_VALUES_TARGET_FILE
	exit 2
}
COMB_SIZE=$(echo $COMB_SAMPLE | unline | wc -l)
test $COMB_SIZE -gt 0 || {
	echo "${0}: internal error: tuple size == 0 ?!" 1>&2
	exit 1
}

# Cycle through combinations, gathering the most valuable ones to form a bet.

NEW_COMB_VALUES_FILE=$(mktemp)
EXCLUDE_PATTERNS_FILE=$(mktemp)
FILTERED_COMBS_GZ_FILE=$(mktemp)
cp $COMBS_GZ_SOURCE_FILE $FILTERED_COMBS_GZ_FILE
HOW_MANY_FULLY_DISTINCT_TRIALS=$((HOW_MANY_WANTED_BET_VALUES/COMB_SIZE))
for TRIAL in $(seq $HOW_MANY_FULLY_DISTINCT_TRIALS -1 1) ; do
	line2regexp 0<$BET_VALUES_TARGET_FILE 1>$EXCLUDE_PATTERNS_FILE
	$UNZIP 0<$FILTERED_COMBS_GZ_FILE | ./vgrep '' $EXCLUDE_PATTERNS_FILE | $ZIP 1>$COMBS_GZ_TARGET_FILE
	cp $COMBS_GZ_TARGET_FILE $FILTERED_COMBS_GZ_FILE
	COMB=$( $UNZIP 0<$FILTERED_COMBS_GZ_FILE | head -n1 )
	test -n "$COMB" || break
	echo $COMB | unline 1>$NEW_COMB_VALUES_FILE
	HOW_MANY_DISTINCT_VALUES=$(wc -l 0<$NEW_COMB_VALUES_FILE)
	test $HOW_MANY_DISTINCT_VALUES -eq $COMB_SIZE || {
		echo "internal error: $HOW_MANY_DISTINCT_VALUES distinct values found in combination search step (should be ${COMB_SIZE})." 1>&2
		exit 1
	}
	cat $BET_VALUES_TARGET_FILE 1>>$NEW_COMB_VALUES_FILE
	sort -n $NEW_COMB_VALUES_FILE 1>$BET_VALUES_TARGET_FILE
	echo -n "${HOW_MANY_DISTINCT_VALUES} " 1>&2
done

rm -f $EXCLUDE_PATTERNS_FILE

brush_combs_file() {
	local COMBS_GZ_FILE=$1
	local VALUES_TARGET_FILE=$2
	local BET_COMBS_FILE=$(mktemp)
	./combine $COMB_SIZE $(line 0<$VALUES_TARGET_FILE) 1>$BET_COMBS_FILE
	$UNZIP 0<$COMBS_GZ_FILE | ./vgrep '-F -x' $BET_COMBS_FILE | $ZIP
	rm -f $BET_COMBS_FILE
}

cp $COMBS_GZ_SOURCE_FILE $COMBS_GZ_TARGET_FILE
brush_combs_file $COMBS_GZ_TARGET_FILE $BET_VALUES_TARGET_FILE 1>$FILTERED_COMBS_GZ_FILE
while true ; do

	HOW_MANY_VALUES_FOUND=$(wc -l 0<$BET_VALUES_TARGET_FILE)
	HOW_MANY_VALUES_MISSING=$((HOW_MANY_WANTED_BET_VALUES-HOW_MANY_VALUES_FOUND))
	test $HOW_MANY_VALUES_MISSING -gt 0 || break

	echo -n '' 1>$NEW_COMB_VALUES_FILE
	$UNZIP 0<$FILTERED_COMBS_GZ_FILE | while read COMB ; do
		echo $COMB | unline 1>$NEW_COMB_VALUES_FILE
		HOW_MANY_DISTINCT_VALUES=$(grep -v -F -x -f $BET_VALUES_TARGET_FILE $NEW_COMB_VALUES_FILE | wc -l)
		test $HOW_MANY_DISTINCT_VALUES -gt 0 || {
			echo "internal error: 0 distinct values found in combination search step." 1>&2
			exit 1
		}
		test $HOW_MANY_DISTINCT_VALUES -le $HOW_MANY_VALUES_MISSING || continue
		break
	done
	test -s $NEW_COMB_VALUES_FILE || break
	HOW_MANY_DISTINCT_VALUES=$(grep -v -F -x -f $BET_VALUES_TARGET_FILE $NEW_COMB_VALUES_FILE | wc -l)

	cat $BET_VALUES_TARGET_FILE 1>>$NEW_COMB_VALUES_FILE
	sort -n $NEW_COMB_VALUES_FILE | uniq 1>$BET_VALUES_TARGET_FILE
	echo -n "${HOW_MANY_DISTINCT_VALUES} " 1>&2

	cp $FILTERED_COMBS_GZ_FILE $COMBS_GZ_TARGET_FILE
	brush_combs_file $COMBS_GZ_TARGET_FILE $BET_VALUES_TARGET_FILE 1>$FILTERED_COMBS_GZ_FILE

done

rm -f $NEW_COMB_VALUES_FILE

cp $FILTERED_COMBS_GZ_FILE $COMBS_GZ_TARGET_FILE
rm -f $FILTERED_COMBS_GZ_FILE

