#!/bin/bash

name="out"
if test -n "$2"; then
	name="$2"
fi

rm $name.ogv $name.avi
recordmydesktop --windowid $1 --fps 50 --full-shots --device pulse -o $name.ogv
mencoder $name.ogv -ovc xvid -oac mp3lame -xvidencopts pass=1 -o $name.avi

#ffmpeg -i input.ogv -c copy output.mkv
