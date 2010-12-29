#!/bin/bash

KEYS=$(seq -s ' ' 1 100 | sed -r -e 's/\<[[:digit:]]/-n -k&/g')
exec sort -t ' ' $KEYS

