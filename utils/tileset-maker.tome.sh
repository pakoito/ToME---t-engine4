#!/bin/bash

cd game/modules/tome/data/gfx/
rm -f ts-shockbolt* ; lua ../../../../../utils/tileset-maker.lua ts-shockbolt-all /data/gfx/ `find shockbolt/terrain/*png shockbolt/terrain/*/*png shockbolt/npc/*png shockbolt/object/*png shockbolt/trap/*png shockbolt/player/*/*png shockbolt/player/*png -name '*png'`
