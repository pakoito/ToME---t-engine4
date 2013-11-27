#!/bin/bash

if test $# -lt 2 ; then
	echo "Usage: te4_pack_module_tome.sh tome [3.9.14] [exclude-ogg]"
	exit
fi

mod="$1"
version="$2"
exclude_ogg="$3"

cp -a "$mod" tmp
find tmp -name .svn -or -name '*~' | xargs rm -rf
cd tmp

mkdir mod
mv * mod
mv mod/data .

zip -r -0 ../"$mod"-"$version".team * -x'data/music/*' -x'data/gfx/*'
zip -r -0 ../"$mod"-"$version"-music.team data/music/*
zip -r -0 ../"$mod"-"$version"-gfx.team data/gfx/*

cd -
rm -rf tmp
