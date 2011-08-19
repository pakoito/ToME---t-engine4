#!/bin/bash

if test $# -lt 2 ; then
	echo "Usage: te4_pack_engine.sh [default/] [te4-5_0.9.14]"
	exit
fi

version="$2"
dir="$1"
exclude_ogg="$3"

cp -a "$dir" tmp
find tmp -name .svn -or -name '*~' | xargs rm -rf

cd tmp

cd modules
te4_pack_module.sh boot "$version" "$exclude_ogg"
mv boot-"$version"*.team ../../
cd ..
rm -rf modules

zip -r -0 ../"$version".teae *
cd ..
rm -rf tmp
