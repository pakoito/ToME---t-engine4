#!/bin/sh
rm -rf doc
cd game/engines/default/
luadoc --nofiles -d ../../../doc `find engine -name '*lua'`
cd -

