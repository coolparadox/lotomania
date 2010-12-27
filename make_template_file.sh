#!/bin/bash
#
# usage: ./make_template_file TUPLE_SIZE-BET_SIZE-SET_SIZE 
#

set -e
set -o pipefail

TEMPLATE_NAME="$1"

TUPLE_SIZE=$(echo "$TEMPLATE_NAME" | awk -F '-' '{print $1}')
BET_SIZE=$(echo "$TEMPLATE_NAME" | awk -F '-' '{print $2}')
SET_SIZE=$(echo "$TEMPLATE_NAME" | awk -F '-' '{print $3}')

TEMPLATE_NAME="${TUPLE_SIZE}-${BET_SIZE}-${SET_SIZE}"
echo "generating $TEMPLATE_NAME template file..." 1>&2
TEMPLATE_TMP_FILE=$(mktemp)
( ./bet_template "$TUPLE_SIZE" "$BET_SIZE" "$SET_SIZE" | tee $TEMPLATE_TMP_FILE ) | \
sed -e 's/^/--> /' 1>&2

TEMPLATE_TARGET_FILE="${TEMPLATE_NAME}.template"
cp $TEMPLATE_TMP_FILE $TEMPLATE_TARGET_FILE

rm -f $TEMPLATE_TMP_FILE
echo "$TEMPLATE_NAME template file generated."

