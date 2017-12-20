#!/bin/bash

WORKDIR="/home/ubuntu/recording"
PREDIR="/home/ubuntu/pre_recording"
FILENAME="translation_service" # without extension .mp3
INDEX_FILE="$PREDIR/.INDEX_FILE"

# VAR Init
INDEX="001"
CURRENT_INDEX=""


# REQUIREMENTS check
[ ! -d $PREDIR ] && mkdir $PREDIR

# find the last file present in the PREDIR
CURRENT_INDEX=$(ls -1 $PREDIR | tail -1 | cut -d"." -f1 | cut -d"-" -f2)
PRE_INDEX=$(cat $INDEX_FILE 2>/dev/null)

if [ "$CURRENT_INDEX" != "" ]
then
	# THE DIR RECORDIND WASN'T COPIED; read from there the file index
	newindex=$(($CURRENT_INDEX + 1))
	printf -v NEWINDEX '%03d' "$newindex"
	echo $NEWINDEX > $INDEX_FILE
	NEWFILENAME="$FILENAME-$NEWINDEX"
elif [ "$PRE_INDEX" != "" ]
then
	# USING THE PRE_INDEX FILE; this means that the recording had been copied
	newindex=${PRE_INDEX##+(0)}
	newindex=$(($new_index + 1))
	printf -v NEWINDEX '%03d' "$newindex"
	echo $NEWINDEX > $INDEX_FILE
	NEWFILENAME="$FILENAME-$NEWINDEX"
else
	# FIRST RECORDING
	NEWFILENAME="$FILENAME-$INDEX"
fi

mv $WORKDIR/$FILENAME.mp3 $PREDIR/$NEWFILENAME.mp3
