#!/bin/bash

if test $# -lt 2 ; then
	echo "Usage: te4_pack_module.sh [tome] [3.9.14] [exclude-ogg]"
	exit
fi

mod="$1"
version="$2"
exclude_ogg="$3"

cp -a "$mod" tmp
find tmp -name .svn -or -name '*~' | xargs rm -rf
cd tmp

if test "$exclude_ogg" -eq 1; then
	IFS=$'\n'; for i in `find -name '*.ogg'`; do
		echo "$i"|grep '/music/' -q
		if test $? -eq 0; then rm "$i"; fi
	done
fi

mkdir mod
mv * mod
mv mod/data .

if test "$exclude_ogg" -eq 1; then
	zip -r -0 ../"$mod"-"$version-nomusic".team *
else
	zip -r -0 ../"$mod"-"$version".team *
fi

cd -
rm -rf tmp
