#!/bin/bash
#
# usage: ./check_matches_lotomania CONC_FROM CONC_TO VALUE [VALUE [VALUE [...]]]
#

CONC_FROM=$1
CONC_TO=$2
shift 2

RESULTS_LOTOFACIL_FILE=$(mktemp)
./resultados_lotofacil | \
sed -n -e "/^${CONC_FROM}\>/,/^${CONC_TO}\>/p" | \
sed -r -e 's/.*- *//' -e 's/\<0//g' | \
while read L ; do
	echo $L | ./sort_bets
done 1>$RESULTS_LOTOFACIL_FILE

./check_matches $( echo "$*" | sed -e 's/\<0//g' ) 0<$RESULTS_LOTOFACIL_FILE

rm -f $RESULTS_LOTOFACIL_FILE

