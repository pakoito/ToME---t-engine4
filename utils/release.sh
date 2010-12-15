#!/bin/sh

if test $# -lt 5 ; then
	echo "Usage: release.sh [engine version for teae] [tome version for team] [version for public] [long engine version] [long tome version]"
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
tomename="$4"
tename="$5"

rm -rf tmp
mkdir tmp
cd tmp
mkdir t-engine4-windows-"$ver"
mkdir t-engine4-src-"$ver"
mkdir t-engine4-linux32-"$ver"

# src
echo "******************** Src"
cd t-engine4-src-"$ver"
cp -a ../../bootstrap/  ../../game/ ../../C* ../../premake4.lua ../../src/ .
rm -rf game/modules/angband
find . -name '*~' -or -name '.svn' | xargs rm -rf

# create teae/teams
cd game/engines
te4_pack_engine.sh default/ te4-"$ever"
mv -i te4-*.teae boot-te4-*.team /var/www/te4.org/htdocs/dl/engines
cd ../modules
te4_pack_module.sh tome "$tver"
mv -i tome*.team /var/www/te4.org/htdocs/dl/modules/tome/
cd ../../

cd ..
tar cvjf t-engine4-src-"$ver".tar.bz2 t-engine4-src-"$ver"

# windows
echo "******************** Windows"
cd t-engine4-windows-"$ver"
cp -a ../../bootstrap/  ../../game/ ../../C* ../../dlls/* .
find . -name '*~' -or -name '.svn' | xargs rm -rf
rm -rf game/modules/angband
cd ..
zip -r -9 t-engine4-windows-"$ver".zip t-engine4-windows-"$ver"

# linux 32
echo "******************** linux32"
cd t-engine4-linux32-"$ver"
cp -a ../../bootstrap/  ../../game/ ../../C* ../../linux-bin/* .
find . -name '*~' -or -name '.svn' | xargs rm -rf
rm -rf game/modules/angband
cd ..
tar -cvjf t-engine4-linux32-"$ver".tar.bz2 t-engine4-linux32-"$ver"

#### Music less

# src
echo "******************** Src"
cd t-engine4-src-"$ver"
rm game/engines/default/data/music/*
rm game/modules/tome/data/music/*
cd ..
tar cvjf t-engine4-src-"$ver"-nomusic.tar.bz2 t-engine4-src-"$ver"

# windows
echo "******************** Windows"
cd t-engine4-windows-"$ver"
rm game/engines/default/data/music/*
rm game/modules/tome/data/music/*
cd ..
zip -r -9 t-engine4-windows-"$ver"-nomusic.zip t-engine4-windows-"$ver"

# linux 32
echo "******************** linux32"
cd t-engine4-linux32-"$ver"
rm game/engines/default/data/music/*
rm game/modules/tome/data/music/*
cd ..
tar -cvjf t-engine4-linux32-"$ver"-nomusic.tar.bz2 t-engine4-linux32-"$ver"

cp *zip *bz2 /var/www/te4.org/htdocs/dl/t-engine

########## Announce

echo "***************** FOR tome.te4.org"
echo "== $tomename =="
echo "* [http://te4.org/dl/t-engine/t-engine4-windows-$ver.zip Windows] ([http://te4.org/dl/t-engine/t-engine4-windows-$ver-nomusic.zip Without music])"
echo "* [http://te4.org/dl/t-engine/t-engine4-src-$ver.tar.bz2 Source] ([http://te4.org/dl/t-engine/t-engine4-src-$ver-nomusic.tar.bz2 Without music])"
echo "* [http://te4.org/dl/t-engine/t-engine4-linux32-$ver.tar.bz2 Linux] ([http://te4.org/dl/t-engine/t-engine4-linux32-$ver-nomusic.tar.bz2 Without music])"
echo "* Mac OSX: not yet available, should be out in a few days (check out the blog)"
echo
echo
echo "***************** FOR te4.org"
echo "== $tename =="
echo "* [/dl/t-engine/t-engine4-windows-$ver.zip Windows] ([/dl/t-engine/t-engine4-windows-$ver-nomusic.zip No music])"
echo "* [/dl/t-engine/t-engine4-src-$ver.tar.bz2 Source] ([/dl/t-engine/t-engine4-src-$ver-nomusic.tar.bz2 No music])"
echo "* [/dl/t-engine/t-engine4-linux32-$ver.tar.bz2 Linux] ([/dl/t-engine/t-engine4-linux32-$ver-nomusic.tar.bz2 Without music])"
echo "* Mac OSX: not yet available, should be out in a few days (check out the blog)"
