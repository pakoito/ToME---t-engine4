#!/bin/bash

if test $# -lt 2 ; then
	echo "Usage: te4_pack_module.sh [tome] [3.9.14]"
	exit
fi

mod="$1"
version="$2"

cp -a "$mod" tmp
find tmp -name .svn -or -name '*~' | xargs rm -rf
cd tmp

mkdir mod
mv * mod
mv mod/data .

zip -r -0 ../"$mod"-"$version".team *

cd -
rm -rf tmp
