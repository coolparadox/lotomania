#!/bin/bash

set -e

usage() {
	echo "usage: ./probability MULTIPLIER GUARANTEED_SIZE MATCH_SIZE BET_SIZE WINNING_SIZE SET_SIZE" 1>&2
	exit 1
}

fail_with() {
	echo "error: $*" 1>&2
	exit 1
}

MULTIPLIER=$1
test -n "$MULTIPLIER" || usage
shift
GUARANTEED_SIZE=$1
test -n "$GUARANTEED_SIZE" || usage
shift
MATCH_SIZE=$1
test -n "$MATCH_SIZE" || usage
test $MATCH_SIZE -ge $GUARANTEED_SIZE || fail_with "MATCH_SIZE is lesser than GUARANTEED_SIZE."
shift
BET_SIZE=$1
test -n "$BET_SIZE" || usage
test $BET_SIZE -ge $MATCH_SIZE || fail_with "BET_SIZE is lesser than MATCH_SIZE."
shift
WINNING_SIZE=$1
test -n "$WINNING_SIZE" || usage
test $WINNING_SIZE -ge $MATCH_SIZE || fail_with "WINNING_SIZE is lesser than MATCH_SIZE."
shift
SET_SIZE=$1
test -n "$SET_SIZE" || usage
test $SET_SIZE -ge $BET_SIZE || fail_with "SET_SIZE is lesser than BET_SIZE."
shift
test $# -eq 0 || usage

test $GUARANTEED_SIZE -eq 0 || exec ./probability $MULTIPLIER 0 $((MATCH_SIZE-GUARANTEED_SIZE)) $((BET_SIZE-GUARANTEED_SIZE)) $((WINNING_SIZE-GUARANTEED_SIZE)) $((SET_SIZE-GUARANTEED_SIZE))

HOW_MANY_TOTAL_COMBS_IN_SET=$( ./combination $WINNING_SIZE $SET_SIZE )
HOW_MANY_TOTAL_COMBS_IN_BET=$( ./combination $MATCH_SIZE $BET_SIZE )
HOW_MANY_REMAINING_COMBS_IN_SET=$( ./combination $((WINNING_SIZE-MATCH_SIZE)) $((SET_SIZE-BET_SIZE)) )

PROB_INVERTED=$( echo "${HOW_MANY_TOTAL_COMBS_IN_SET}/(${HOW_MANY_TOTAL_COMBS_IN_BET}*${HOW_MANY_REMAINING_COMBS_IN_SET}*${MULTIPLIER})" | bc )
echo "1/${PROB_INVERTED}"

