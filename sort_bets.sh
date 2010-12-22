#!/bin/bash

KEYS=$(seq -s ' ' 1 100 | sed -r -e 's/\<[[:digit:]]/-k&/g')
exec sort -n -t ' ' $KEYS

