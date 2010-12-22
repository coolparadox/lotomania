#!/bin/bash
#
# usage: ./comb_bet_step MISSING_BET_VALUES BET_VALUES_SOURCE_FILE COMBS_GZ_SOURCE_FILE BET_VALUES_TARGET_FILE COMBS_GZ_TARGET_FILE
#

set -e

MISSING_BET_VALUES=$1
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
if test $MISSING_BET_VALUES -lt $COMB_SIZE ; then
	HOW_MANY_NEW_BET_VALUES_WANTED=$MISSING_BET_VALUES
else
	HOW_MANY_NEW_BET_VALUES_WANTED=$COMB_SIZE
fi

FILTERED_COMBS_GZ_FILE=$COMBS_GZ_TARGET_FILE
if test -s $BET_VALUES_SOURCE_FILE ; then
	INCLUDE_FILTER_PATTERNS_FILE=$(mktemp)
	if test $COMB_SIZE -gt $HOW_MANY_NEW_BET_VALUES_WANTED ; then
		./combine $((COMB_SIZE-HOW_MANY_NEW_BET_VALUES_WANTED)) $(line 0<$BET_VALUES_SOURCE_FILE) | line2regexp 1>$INCLUDE_FILTER_PATTERNS_FILE
	else
		echo '.' 1>$INCLUDE_FILTER_PATTERNS_FILE
	fi
	EXCLUDE_FILTER_COMBINE_MIN_K=$((COMB_SIZE-HOW_MANY_NEW_BET_VALUES_WANTED+1))
	for K in $(seq -s ' ' $EXCLUDE_FILTER_COMBINE_MIN_K $COMB_SIZE) ; do
		EXCLUDE_FILTER_PATTERNS_FILE=$(mktemp)
		./combine $K $(line 0<$BET_VALUES_SOURCE_FILE) | line2regexp 1>$EXCLUDE_FILTER_PATTERNS_FILE
		set +e ; $UNZIP $COMBS_GZ_SOURCE_FILE | ./vgrep '' $EXCLUDE_FILTER_PATTERNS_FILE | grep -f $INCLUDE_FILTER_PATTERNS_FILE | $ZIP 1>$FILTERED_COMBS_GZ_FILE ; set -e
		rm -f $EXCLUDE_FILTER_PATTERNS_FILE
		$UNZIP $FILTERED_COMBS_GZ_FILE | head -n1 | grep -q -e '.' && break
	done
	rm -f $INCLUDE_FILTER_PATTERNS_FILE
else
	cp -f $COMBS_GZ_SOURCE_FILE $FILTERED_COMBS_GZ_FILE
fi

HOW_MANY_COMBS=$($UNZIP $FILTERED_COMBS_GZ_FILE | wc -l)
test $HOW_MANY_COMBS -gt 0 || {
	echo "${0}: internal error: all combinations exausted without new bet values ?!" 1>&2
	echo "unhandled combinations follow:" 1>&2
	$UNZIP $COMBS_GZ_SOURCE_FILE 1>&2
	echo "remaining bet values: $(line 0<$BET_VALUES_SOURCE_FILE)" 1>&2
	exit 1
}

COMB_VALUES_FILE=$(mktemp)
COMB_NUMBER=$(./random_value 1 $HOW_MANY_COMBS)
$UNZIP $FILTERED_COMBS_GZ_FILE | sed -n -e "${COMB_NUMBER}{p;q}" | unline 1>$COMB_VALUES_FILE

# If requested, try to randomly gather more 'full-new-values' combinations for efficiency.
MISSING_BET_VALUES=$((MISSING_BET_VALUES-HOW_MANY_NEW_BET_VALUES_WANTED))
NEW_COMB_VALUES_FILE=$(mktemp)
TIMEOUT_COUNTER=0
while test $((MISSING_BET_VALUES/COMB_SIZE)) -gt 0 ; do
	test $TIMEOUT_COUNTER -le 10 || break
	TIMEOUT_COUNTER=$((TIMEOUT_COUNTER+1))
	COMB_NUMBER=$(./random_value 1 $HOW_MANY_COMBS)
	$UNZIP $FILTERED_COMBS_GZ_FILE | sed -n -e "${COMB_NUMBER}{p;q}" | unline 1>$NEW_COMB_VALUES_FILE
	HOW_MANY_DISTINCT_VALUES=$(grep -v -F -x -f $COMB_VALUES_FILE $NEW_COMB_VALUES_FILE | wc -l)
	test $HOW_MANY_DISTINCT_VALUES -ge $COMB_SIZE || continue
	cat $NEW_COMB_VALUES_FILE >>$COMB_VALUES_FILE
	MISSING_BET_VALUES=$((MISSING_BET_VALUES-COMB_SIZE))
	TIMEOUT_COUNTER=0
done
rm -f $NEW_COMB_VALUES_FILE

# Merge new gathered bet values with current ones.
sort -n $BET_VALUES_SOURCE_FILE $COMB_VALUES_FILE | uniq 1>$BET_VALUES_TARGET_FILE
rm -f $COMB_VALUES_FILE 
unset FILTERED_COMBS_GZ_FILE

# Rebuild the unhandled combinations file.
BET_COMBS_FILE=$(mktemp)
./combine $COMB_SIZE $(line 0<$BET_VALUES_TARGET_FILE) 1>$BET_COMBS_FILE
$UNZIP $COMBS_GZ_SOURCE_FILE | ./vgrep '-F -x' $BET_COMBS_FILE | $ZIP 1>$COMBS_GZ_TARGET_FILE
rm -f $BET_COMBS_FILE

