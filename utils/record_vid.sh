#!/bin/bash
rm out.ogv out.avi
recordmydesktop --windowid $1 --fps 50 --full-shots --no-sound
mencoder out.ogv -ovc xvid -oac mp3lame -xvidencopts pass=1 -o out.avi

#ffmpeg -i input.ogv -c copy output.mkv
