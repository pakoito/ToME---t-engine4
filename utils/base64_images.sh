#!/bin/bash

event=$1
shift 1

for img in $*; do
	data=`base64 "$img"`
	echo "core.display.virtualImage('/data/gfx/shockbolt/$event/$img', mime.unb64[[$data]])"
done
