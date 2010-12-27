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

LAST_REPLACE_VALUE_FILE=$(mktemp)
echo '1' 1>$LAST_REPLACE_VALUE_FILE
seq 2 $SET_SIZE | shuf | while read REPLACE_TO ; do
	REPLACE_FROM=$(cat $LAST_REPLACE_VALUE_FILE)
	echo "s/\<R${REPLACE_FROM}\>/${REPLACE_TO}/" 1>>$TRANSLATION_FILE
	echo $REPLACE_TO 1>$LAST_REPLACE_VALUE_FILE
done
REPLACE_FROM=$(cat $LAST_REPLACE_VALUE_FILE)
echo "s/\<R${REPLACE_FROM}\>/1/" 1>>$TRANSLATION_FILE
rm $LAST_REPLACE_VALUE_FILE

REPLACED_BETS_FILE=$(mktemp)
sed -r -f $TRANSLATION_FILE $TEMPLATE_FILE 1>$REPLACED_BETS_FILE
rm -f $TRANSLATION_FILE

while read UNSORTED_BET ; do
	echo $UNSORTED_BET | tr ' ' '\n' | sort -n | tr '\n' ' '
	echo
done 0<$REPLACED_BETS_FILE | ./sort_bets

rm -f $REPLACED_BETS_FILE

