#!/bin/bash
#
# usage: ./comb_bet_step HOW_MANY_WANTED_BET_VALUES COMBS_GZ_SOURCE_FILE BET_VALUES_TARGET_FILE COMBS_GZ_TARGET_FILE
#

set -e

HOW_MANY_WANTED_BET_VALUES=$1
COMBS_GZ_SOURCE_FILE=$2
BET_VALUES_TARGET_FILE=$3
COMBS_GZ_TARGET_FILE=$4

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
	sed -e 's/$/\\>/' -e 's/^/\\</' $BET_VALUES_TARGET_FILE 1>$EXCLUDE_PATTERNS_FILE
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
rm -f $FILTERED_COMBS_GZ_FILE
INCLUDE_PATTERN_FILE=$(mktemp)
for DISTINCT_SIZE in $(seq $((COMB_SIZE-1)) -1 1) ; do
	while true ; do
		HOW_MANY_VALUES_FOUND=$(wc -l 0<$BET_VALUES_TARGET_FILE)
		HOW_MANY_VALUES_MISSING=$((HOW_MANY_WANTED_BET_VALUES-HOW_MANY_VALUES_FOUND))
		test $HOW_MANY_VALUES_MISSING -ge $DISTINCT_SIZE || break
		EXCLUDE_COMB_SIZE=$((COMB_SIZE-DISTINCT_SIZE+1))
		./combine $EXCLUDE_COMB_SIZE $(line 0<$BET_VALUES_TARGET_FILE) | line2regexp 1>$EXCLUDE_PATTERNS_FILE
		INCLUDE_COMB_SIZE=$((COMB_SIZE-DISTINCT_SIZE))
		./combine $INCLUDE_COMB_SIZE $(line 0<$BET_VALUES_TARGET_FILE) | line2regexp 1>$INCLUDE_PATTERN_FILE
		COMB=$( $UNZIP 0<$COMBS_GZ_SOURCE_FILE | ./vgrep '--line-buffered' $EXCLUDE_PATTERNS_FILE | grep --line-buffered -f $INCLUDE_PATTERN_FILE | head -n1 )
		test -n "$COMB" || break
		echo $COMB | unline 1>$NEW_COMB_VALUES_FILE
		HOW_MANY_DISTINCT_VALUES=$(grep -v -F -x -f $BET_VALUES_TARGET_FILE $NEW_COMB_VALUES_FILE | wc -l)
		test $HOW_MANY_DISTINCT_VALUES -eq $DISTINCT_SIZE || {
			echo "internal error: $HOW_MANY_DISTINCT_VALUES distinct values found in combination search step (should be ${DISTINCT_SIZE})." 1>&2
			exit 1
		}
		cat $BET_VALUES_TARGET_FILE 1>>$NEW_COMB_VALUES_FILE
		sort -n $NEW_COMB_VALUES_FILE | uniq 1>$BET_VALUES_TARGET_FILE
		echo -n "${HOW_MANY_DISTINCT_VALUES} " 1>&2
	done
done
rm -f $EXCLUDE_PATTERNS_FILE $INCLUDE_PATTERN_FILE $NEW_COMB_VALUES_FILE

# Filter the covered combinations out of the combinations file.
BET_COMBS_FILE=$(mktemp)
./combine $COMB_SIZE $(line 0<$BET_VALUES_TARGET_FILE) 1>$BET_COMBS_FILE
$UNZIP 0<$COMBS_GZ_SOURCE_FILE | ./vgrep '-F -x' $BET_COMBS_FILE | $ZIP 1>$COMBS_GZ_TARGET_FILE
rm -f $BET_COMBS_FILE

