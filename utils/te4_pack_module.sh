#!/bin/bash

if test $# -lt 2 ; then
	echo "Usage: te4_pack_module.sh [tome] [3.9.14] [exclude-ogg]"
	exit
fi

mod="$1"
version="$2"
exclude_ogg="$3"

pushd "$mod"
teams=`lua <<EOS
local init = loadfile("init.lua")
local d = {}
setfenv(init, d)
init()
if not d.teams then return end
for i, def in ipairs(d.teams) do
	io.write(def[1]..":"..table.concat(def[3],":"):gsub("^/", ""):gsub(":/", ":"))
	if i < #d.teams then io.write(";") end
end
EOS`
teams=`echo "$teams"| sed "s/#name#/$mod/g" | sed "s/#version#/$version/g"`
popd

cp -a "$mod" tmp
find tmp -name .svn -or -name '*~' | xargs rm -rf
pushd tmp

if test "$exclude_ogg" -eq 1; then
	IFS=$'\n'; for i in `find -name '*.ogg'`; do
		echo "$i"|grep '/music/' -q
		if test $? -eq 0; then rm "$i"; fi
	done
fi

mkdir mod
mv * mod
mv mod/data .

IFS=';'
for teamdef in `echo "$teams"`; do
	tname=`echo "$teamdef"|cut -d: -f1`
	tlist=`echo "$teamdef"|cut -d: -f2-`
	echo "=== Teamdef: $tname"
	IFS=':'
	for list in `echo "$tlist"`; do
		echo "=== Adding: $tlist"
		zip --quiet -r -0 ../"$tname" "$list"
		rm -rf "$list"
	done
	IFS=';'
done

if test "$exclude_ogg" -eq 1; then
	zip --quiet -r -0 ../"$mod"-"$version-nomusic".team *
else
	zip --quiet -r -0 ../"$mod"-"$version".team *
fi

popd
rm -rf tmp
