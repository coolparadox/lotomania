#!/bin/bash

set -e

usage() {
	echo "usage: ./generate_bets GAME TUPLE_SIZE BET_SIZE GROUP_LABEL" 1>&2
	echo "GAME is one of: lotofacil, duplasena" 1>&2
	exit 1
}

fail_with() {
	echo "error: $*" 1>&2
	exit 1
}

GAME="$1"
test -n "$GAME" || usage
case $GAME in
	lotofacil|duplasena) source "conf/${GAME}.params" ;;
	*) fail_with "unknown game '${GAME}'." ;;
esac

shift
TUPLE_SIZE=$1
test -n "$TUPLE_SIZE" || usage

shift
BET_SIZE=$1
test -n "$BET_SIZE" || usage
test $BET_SIZE -gt $TUPLE_SIZE || fail_with "bet size (${BET_SIZE}) is lesser than tuple size (${TUPLE_SIZE})."
test $BET_SIZE -ge $BET_SIZE_MIN -a $BET_SIZE -le $BET_SIZE_MAX || fail_with "invalid bet size '${BET_SIZE}' for this game."

shift
GROUP_LABEL=$1
test -n "$GROUP_LABEL" || usage

shift
test $# -eq 0 || usage

RESULT_DIR="${GAME}/${GROUP_LABEL}"
mkdir -p $RESULT_DIR

ALL_BETS_FILE_NAME="${TUPLE_SIZE}-${BET_SIZE}-${SET_SIZE}.all"
ALL_BETS_FILE="${RESULT_DIR}/${ALL_BETS_FILE_NAME}"
./bets $TUPLE_SIZE $BET_SIZE $SET_SIZE 1>$ALL_BETS_FILE
(
	cd $RESULT_DIR
	split -d -l $BETS_PER_SLIP -a 4 $ALL_BETS_FILE_NAME 'bets.'
)

##FIXME: debug
#echo -n 1>$RESULT_DIR/bets.0000
#for I in $(seq 1 $BETS_PER_SLIP) ; do
	#seq -s ' ' 1 ${SET_SIZE} 1>>$RESULT_DIR/bets.0000
#done

bets_to_data() {
	local SECTOR='-1'
	local LINE
	local COLUMN
	while read BET ; do
		SECTOR=$((SECTOR+1))
		echo $BET | sed -e 's/ *$//' -e 's/ /\n/g' | while read BET_VALUE ; do
			LINE=$(bet_line $BET_VALUE)
			COLUMN=$(bet_column $BET_VALUE)
			echo $SECTOR $LINE $COLUMN
		done
	done
}

metapost_bullet_xy() {

	local COLOR=$1
	local X=$2
	local Y=$3

	echo "draw (${X}mm,${Y}mm) withcolor $COLOR withpen pencircle xscaled ${BULLET_WIDTH}mm yscaled ${BULLET_HEIGHT}mm;"

}

metapost_bullet_slc() {

	local COLOR=$1
	local SECTOR=$2
	local LINE=$3
	local COLUMN=$4

	local X=$(echo "${X_ZERO} + ${SECTOR}*${SECTOR_X_DELTA} + ${LINE}*${X_DELTA}" | bc)
	local Y=$(echo "${Y_ZERO} + ${COLUMN}*${Y_DELTA}" | bc)
	metapost_bullet_xy "$COLOR" $X $Y

}

data_to_metapost() {

	local LABEL="$1"

	echo 'prologues := 3;'
	echo 'beginfig(-1);'
	echo "draw (0,0) withpen pencircle scaled 0 withcolor white;"

	for I in $(seq 1 $BETS_PER_SLIP) ; do
		echo "1 $SET_SIZE"
	done | \
	bets_to_data | \
	while read SECTOR LINE COLUMN ; do
		metapost_bullet_slc 'white' $SECTOR $LINE $COLUMN
	done

	COVERED_SECTORS_FILE=$(mktemp)
	while read SECTOR LINE COLUMN ; do
		metapost_bullet_slc 'black' $SECTOR $LINE $COLUMN
		echo $SECTOR 1>>$COVERED_SECTORS_FILE
	done
	for SECTOR in $(seq 0 $((BETS_PER_SLIP-1))) ; do
		test $NULL_BET_MARKERS_FLAG -ne 0 || break
		echo $SECTOR | grep -q -F -x -f $COVERED_SECTORS_FILE || {
			X=$(echo "${NULL_BET_MARKER_X} + ${SECTOR}*${SECTOR_X_DELTA}" | bc)
			Y=$NULL_BET_MARKER_Y
			metapost_bullet_xy 'black' $X $Y
		}
	done
	rm -f $COVERED_SECTORS_FILE

	test $BET_SIZE_MARKERS_FLAG -eq 0 || {
		X=$BET_SIZE_MARKERS_X_ZERO
		Y=$(echo "${BET_SIZE_MARKERS_Y_ZERO} + (${BET_SIZE}-${BET_SIZE_MIN})*${BET_SIZE_MARKERS_Y_DELTA}" | bc)
		metapost_bullet_xy 'black' $X $Y
	}

	echo "label.lft(btex ${LABEL} etex rotated 90,(${LABEL_X}mm,${LABEL_Y}mm));"

	echo 'endfig;'
	echo 'end;'
}

ERR_FILE=$(mktemp)
find $RESULT_DIR -mindepth 1 -maxdepth 1 -type f -name 'bets.*' | while read BET_FILE_OLD ; do
	ID=$(echo "$BET_FILE_OLD" | sed -e 's/.*\.//')
	BET_FILE="$RESULT_DIR/${ID}.bets"
	mv $BET_FILE_OLD $BET_FILE
	DATA_FILE="$RESULT_DIR/${ID}.data"
	bets_to_data 0<$BET_FILE 1>$DATA_FILE
	METAPOST_FILE="$RESULT_DIR/${ID}.mp"
	LABEL="${GROUP_LABEL}-${ID}"
	data_to_metapost "$LABEL" 0<$DATA_FILE 1>$METAPOST_FILE
	( cd $RESULT_DIR && mpost $ID 1>$ERR_FILE 2>&1 ) || {
		cat $ERR_FILE 1>&2
		exit 1
	}
	PS_FILE="$RESULT_DIR/${ID}.ps"
	BBOX_WIDTH=$(identify $PS_FILE | awk '{print $3}' | awk -Fx '{print $1}')
	BBOX_HEIGHT=$(identify $PS_FILE | awk '{print $3}' | awk -Fx '{print $2}')
	( cd $RESULT_DIR && ps2pdf -dAutoRotatePages=/None -dDEVICEWIDTHPOINTS=${BBOX_WIDTH} -dDEVICEHEIGHTPOINTS=$((BBOX_HEIGHT+BBOX_HEIGHT_PS_POINTS_INCREASE)) "${ID}.ps" )
	echo "--> bet slip ${ID} processed." 1>&2
done
rm -f $ERR_FILE

PDF_FILES=$(find $RESULT_DIR -mindepth 1 -maxdepth 1 -type f -name '*.pdf' -exec basename '{}' ';' | sort -n | tr '\n' ' ')
( cd $RESULT_DIR && gs -q -sPAPERSIZE=a4 -dAutoRotatePages=/None -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile='all_bets.pdf' $PDF_FILES )

echo "files generated in directory '${RESULT_DIR}'." 1>&2

