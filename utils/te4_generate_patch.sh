#!/bin/bash

rm -rf __tmp_patch
mkdir __tmp_patch
cd __tmp_patch

os="$1"
old="$2"
new="$3"

if test "$os" = 'windows'; then
	ext=".zip"
	unpack="unzip"
fi
if test "$os" = 'linux64'; then
	ext=".tar.bz2"
	unpack="tar xvjf"
fi
if test "$os" = 'linux32'; then
	ext=".tar.bz2"
	unpack="tar xvjf"
fi

$unpack /foreign/eyal/var/www/te4.org/htdocs/dl/t-engine/t-engine4-$os-$old$ext
$unpack /foreign/eyal/var/www/te4.org/htdocs/dl/t-engine/t-engine4-$os-$new$ext

oldv=`ls t-engine4-$os-$old/game/modules/tome-*[0-9].team | head -n1 | sed -e 's/^.*tome-//' -e 's/\.team$//'`
newv=`ls t-engine4-$os-$new/game/modules/tome-*[0-9].team | head -n1 | sed -e 's/^.*tome-//' -e 's/\.team$//'`

cd "t-engine4-$os-$new"
sh ../../utils/te4_patch.sh $oldv $newv ../t-engine4-$os-$old ../patch $os
pmd5=`md5sum ../$os-patch-$oldv-to-$newv.zip | cut -d' ' -f1`
cp "../$os-patch-$oldv-to-$newv.zip" /foreign/eyal/var/www/te4.org/htdocs/dl/t-engine/patch/

echo "SQL:"
echo "REPLACE INTO patch_chain SET os='$os', vfrom='$oldv', vto='$newv', file='$os-patch-$oldv-to-$newv.zip', md5='$pmd5', shown='false';"
