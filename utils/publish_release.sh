#!/bin/sh

if test $# -lt 1 ; then
	echo "Usage: publish_release.sh [version for public]"
	exit
fi
v=$1

echo "*********** First MD5 for ToME: *********"
read tomemd1
echo "*********** Second MD5 for ToME: *********"
read tomemd2
echo "*********** MD5 for Items Vault: *********"
read ivmd
echo "*********** MD5 for Stone Wardens: *********"
read swmd

ln -fs /foreign/eyal/var/www/te4.org/htdocs/dl/t-engine/t-engine4-windows-$v.zip /foreign/eyal/var/www/te4.org/htdocs/dl/t-engine/full/tome-full-windows-$v.zip
fmd5=`md5sum /foreign/eyal/var/www/te4.org/htdocs/dl/t-engine/full/tome-full-windows-$v.zip | cut -d' ' -f1`

echo "SQL:"
echo "replace into modules_addons_versions set module='tome', addon='tome-items-vault-$v' , md5='$ivmd', md5_2 ='';"
echo "replace into modules_addons_versions set module='tome', addon='tome-stone-wardens-$v' , md5='$swmd', md5_2 ='';"
echo "replace into modules_versions set module='tome-$v', md5='$tomemd1', md5_2='$tomemd2', shown='false';"
echo "replace into modules_fullzip set file='tome-full-windows-$v.zip', md5='$fmd5';"
