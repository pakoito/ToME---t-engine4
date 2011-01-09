#!/bin/sh
rm -rf doc
cd game/engines/default/
 luadoc --nofiles -d ../../../doc `find ../../../src/ -name 'core*luadoc'` `find engine -name '*lua'`
cd -
