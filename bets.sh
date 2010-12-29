#!/bin/bash
#
# usage: ./bets TUPLE_SIZE-BET_SIZE-SET_SIZE 
#

set -e

TUPLE_SIZE=$1
BET_SIZE=$2
SET_SIZE=$3

TEMPLATE_NAME="${TUPLE_SIZE}-${BET_SIZE}-${SET_SIZE}"
TEMPLATE_FILE="${TEMPLATE_NAME}.template"
test -s "$TEMPLATE_FILE" || ./make_template_file "$TEMPLATE_NAME"

TRANSLATION_FILE=$(mktemp)

grep 'X' $TEMPLATE_FILE | while read BET ; do
	EXCLUDE_FILE=$(mktemp)
	echo $BET | tr ' ' '\n' | grep -v 'X' 1>$EXCLUDE_FILE
	echo $BET | tr ' ' '\n' | grep 'X' | while read WHATEVER ; do
		while true ; do
			REPLACE_VALUE=$(./random_value 1 $SET_SIZE)
			echo $REPLACE_VALUE | grep -v -q -F -x -f $EXCLUDE_FILE || continue
			echo "s/X/${REPLACE_VALUE}/" 1>>$TRANSLATION_FILE
			echo $REPLACE_VALUE 1>>$EXCLUDE_FILE
			break
		done
	done
	rm -f $EXCLUDE_FILE
done

echo 's/\<[[:digit:]]+\>/R&/g' 1>>$TRANSLATION_FILE

sort_values_by_histogram() {
	tr ' ' '\n' | \
	sed -r -e '/^[[:blank:]]*$/d' | \
	./histogram $SET_SIZE | \
	sort -n -k2 | \
	sed -e 's/ .*//'
}

SORTED_VALUES_BY_TEMPLATE_FILE=$(mktemp)
sed -e 's/X//g' $TEMPLATE_FILE | sort_values_by_histogram 1>$SORTED_VALUES_BY_TEMPLATE_FILE

sort_results_by_histogram() {
	tail -n5 | \
	sed -r -e 's/.*- *//' -e 's/\<0//g' | \
	sort_values_by_histogram
}

SORTED_VALUES_BY_RESULTS_FILE=$(mktemp)
case $SET_SIZE in
	25) ./resultados_lotofacil | sort_results_by_histogram ;;
	*) seq 1 $SET_SIZE | shuf
esac 1>$SORTED_VALUES_BY_RESULTS_FILE

paste -d ' ' $SORTED_VALUES_BY_TEMPLATE_FILE $SORTED_VALUES_BY_RESULTS_FILE | \
while read REPLACED REPLACER ; do
	echo "s/\<R${REPLACED}\>/${REPLACER}/"
done 1>>$TRANSLATION_FILE

rm -f $SORTED_VALUES_BY_RESULTS_FILE $SORTED_VALUES_BY_TEMPLATE_FILE

REPLACED_BETS_FILE=$(mktemp)
sed -r -f $TRANSLATION_FILE $TEMPLATE_FILE 1>$REPLACED_BETS_FILE
rm -f $TRANSLATION_FILE

while read UNSORTED_BET ; do
	echo $UNSORTED_BET | tr ' ' '\n' | sort -n | tr '\n' ' '
	echo
done 0<$REPLACED_BETS_FILE | ./sort_bets

rm -f $REPLACED_BETS_FILE


