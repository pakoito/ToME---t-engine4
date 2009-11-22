#!/bin/sh
cd game
luadoc --nofiles -d ../doc `find engine -name '*lua'`
cd ..

