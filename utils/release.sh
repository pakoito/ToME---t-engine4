#!/bin/sh

if test $# -lt 3 ; then
	echo "Usage: release.sh [engine version for teae] [tome version for team] [version for public]"
	exit
fi

# Check validity
find game/ bootstrap/ -name '*lua' | xargs -n1 luac -p
if test $? -ne 0 ; then
	echo "Invalid lua files!"
	exit 1
fi

ever="$1"
tver="$2"
ver="$3"

rm -rf tmp
mkdir tmp
cd tmp
mkdir t-engine4-windows-"$ver"
mkdir t-engine4-src-"$ver"
mkdir t-engine4-linux32-"$ver"

# src
echo "******************** Src"
cd t-engine4-src-"$ver"
cp -a ../../bootstrap/  ../../game/ ../../C* ../../premake4.lua ../../src/ ../../build/ ../../mac/  .
rm -rf game/modules/angband
rm -rf game/modules/rogue
rm -rf game/modules/gruesome
find . -name '*~' -or -name '.svn' | xargs rm -rf

# create teae/teams
cd game/engines
te4_pack_engine.sh default/ te4-"$ever"
mv -f te4-*.teae boot-te4-*.team /var/www/te4.org/htdocs/dl/engines
cd ../modules
te4_pack_module.sh tome "$tver"
mv -f tome*.team /var/www/te4.org/htdocs/dl/modules/tome/
cd ../../

cd ..
tar cvjf t-engine4-src-"$ver".tar.bz2 t-engine4-src-"$ver"

# windows
echo "******************** Windows"
cd t-engine4-windows-"$ver"
cp -a ../../bootstrap/  ../../game/ ../../C* ../../dlls/* .
find . -name '*~' -or -name '.svn' | xargs rm -rf
rm -rf game/modules/angband
rm -rf game/modules/rogue
rm -rf game/modules/gruesome
cd ..
zip -r -9 t-engine4-windows-"$ver".zip t-engine4-windows-"$ver"

# linux 32
echo "******************** linux32"
cd t-engine4-linux32-"$ver"
cp -a ../../bootstrap/  ../../game/ ../../C* ../../linux-bin/* .
find . -name '*~' -or -name '.svn' | xargs rm -rf
rm -rf game/modules/angband
rm -rf game/modules/rogue
rm -rf game/modules/gruesome
cd ..
tar -cvjf t-engine4-linux32-"$ver".tar.bz2 t-engine4-linux32-"$ver"

#### Music less

# src
echo "******************** Src"
cd t-engine4-src-"$ver"
IFS=$'\n'; for i in `find game/ -name '*.ogg'`; do rm "$i"; done
cd ..
tar cvjf t-engine4-src-"$ver"-nomusic.tar.bz2 t-engine4-src-"$ver"

# windows
echo "******************** Windows"
cd t-engine4-windows-"$ver"
IFS=$'\n'; for i in `find game/ -name '*.ogg'`; do rm "$i"; done
cd ..
zip -r -9 t-engine4-windows-"$ver"-nomusic.zip t-engine4-windows-"$ver"

# linux 32
echo "******************** linux32"
cd t-engine4-linux32-"$ver"
IFS=$'\n'; for i in `find game/ -name '*.ogg'`; do rm "$i"; done
cd ..
tar -cvjf t-engine4-linux32-"$ver"-nomusic.tar.bz2 t-engine4-linux32-"$ver"

cp *zip *bz2 /var/www/te4.org/htdocs/dl/t-engine

########## Announce

echo "http://te4.org/dl/t-engine/t-engine4-windows-$ver.zip"
echo "http://te4.org/dl/t-engine/t-engine4-src-$ver.tar.bz2"
echo "http://te4.org/dl/t-engine/t-engine4-linux32-$ver.tar.bz2"
echo "http://te4.org/dl/t-engine/t-engine4-windows-$ver-nomusic.zip"
echo "http://te4.org/dl/t-engine/t-engine4-src-$ver-nomusic.tar.bz2"
echo "http://te4.org/dl/t-engine/t-engine4-linux32-$ver-nomusic.tar.bz2"
