#!/bin/bash

newv=$2
oldv=$1

oldd=$3

patch=$4

os=$5

rm -rf "$patch"
mkdir -p "$patch"

pl="$patch/__patchlist"
touch $pl
fm="$patch/__final_md5s"
touch $fm

for file in `find . -type f`; do
	file=`echo $file|sed s@^\./@@`
	echo $file
	if test -f "$oldd/$file"; then
		cmp -s "$oldd/$file" "$file"
		if test $? -ne 0; then
			echo "$file" | grep -q "^game/"
			if test $? -ne 0; then
				echo "* File changed $file - override"
				mkdir -p "$patch"/`dirname $file`
				cp "$file" "$patch"/$file
				echo "override('$file')" >> $pl
				echo -n "$file:" >> $fm
				md5sum "$file" | cut -d' ' -f1 >> $fm
			else
				echo "* File changed $file - patch"
				p=`dirname $file`/`basename $file`.patch
				mkdir -p "$patch"/`dirname $file`
				bsdiff "$oldd/$file" "$file" "$patch"/$p
				echo "change('$file', '$p')" >> $pl
				echo -n "$file:" >> $fm
				md5sum "$file" | cut -d' ' -f1 >> $fm
			fi
		fi
	else
		rfile=`echo "$file"|sed s/$newv/$oldv/g`
		if test -f "$oldd/$rfile"; then
			echo "* Update version file $rfile / $file"
			mkdir -p "$patch"/`dirname $file`
			p=`dirname $file`/`basename $rfile`-to-`basename $file`.patch
			bsdiff "$oldd/$rfile" "$file" "$patch"/$p
			echo "update('$rfile', '$file', '$p')" >> $pl
			echo -n "$file:" >> $fm
			md5sum "$file" | cut -d' ' -f1 >> $fm
		else
			echo "* New file $file"
			mkdir -p "$patch"/`dirname $file`
			cp $file "$patch"/`dirname $file`
			echo "download('$file')" >> $pl
			echo -n "$file:" >> $fm
			md5sum "$file" | cut -d' ' -f1 >> $fm
		fi
	fi
done

cd "$patch"
zip -r ../$os-patch-$oldv-to-$newv.zip *
