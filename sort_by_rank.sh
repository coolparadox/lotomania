#!/bin/sh

set -e

SORT_DIR=$(mktemp -d)
echo "working in ${SORT_DIR} ..." 1>&2

sed -r -e "s|^([^:]*):.*|echo & >>${SORT_DIR}/\1|" | sh

(
	set -e
	cd $SORT_DIR
	find . -mindepth 1 -maxdepth 1 -type f | \
	sed -e 's|.*/||' | \
	sort -n -r | \
	xargs cat
)

rm -rf $SORT_DIR

