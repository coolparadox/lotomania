#!/bin/bash
#
# A 'grep -v -f PATTERN_FILE' process splitter for big pattern files.
# In SMP systems this wrapper should keep more CPUs busy.
#
# usage: ./vgrep OTHER_GREP_OPTS_STRING PATTERN_FILE
#

set -e

OTHER_GREP_OPTS_STRING="$1"
PATTERN_FILE=$2

N_CPUS=$(grep -E '^processor[[:blank:]]*:' /proc/cpuinfo | wc -l)
SPLIT_DIR=$(mktemp -d)
N_PATTTERNS=$(wc -l 0<$PATTERN_FILE)
shuf $PATTERN_FILE | \
split -l $((N_PATTTERNS/N_CPUS/2+1)) - "$SPLIT_DIR/patterns_"

GREP_SCRIPT_FILE=$(mktemp)
find $SPLIT_DIR -mindepth 1 -maxdepth 1 -type f | \
sort | \
sed -r -e "s/^/grep -v ${OTHER_GREP_OPTS_STRING} -f /" -e '$!s/$/ | \\/' 1>$GREP_SCRIPT_FILE

set +e ; sh $GREP_SCRIPT_FILE ; RCODE=$? ; set -e

rm -rf $GREP_SCRIPT_FILE $SPLIT_DIR

exit $RCODE

