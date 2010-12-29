#!/bin/bash

set -e

UPPER_VALUE=$1

WORK_DIR=$(mktemp -d)

for VALUE in $(seq 1 $UPPER_VALUE) ; do
	touch ${WORK_DIR}/${VALUE}
done

while read VALUE ; do
	echo '' 1>>${WORK_DIR}/${VALUE}
done

find $WORK_DIR -mindepth 1 -maxdepth 1 -type f -exec basename '{}' ';' | sort -n | while read VALUE ; do
	echo -n "${VALUE} "
	wc -l 0<$WORK_DIR/$VALUE
done

rm -rf $WORK_DIR

