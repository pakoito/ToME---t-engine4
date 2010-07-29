-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

local loadIfNot = function(f)
	if loaded[f] then return end
	load(f, entity_mod)
end

-- Load all NPCs anyway but with higher rarity
loadIfNot("/data/general/npcs/ant.lua")
--loadIfNot("/data/general/npcs/aquatic_critter.lua")
--loadIfNot("/data/general/npcs/aquatic_demon.lua")
loadIfNot("/data/general/npcs/bear.lua")
--loadIfNot("/data/general/npcs/bone-giant.lua")
loadIfNot("/data/general/npcs/canine.lua")
loadIfNot("/data/general/npcs/cold-drake.lua")
--loadIfNot("/data/general/npcs/faeros.lua")
loadIfNot("/data/general/npcs/fire-drake.lua")
loadIfNot("/data/general/npcs/ghoul.lua")
loadIfNot("/data/general/npcs/jelly.lua")
loadIfNot("/data/general/npcs/minotaur.lua")
loadIfNot("/data/general/npcs/molds.lua")
--loadIfNot("/data/general/npcs/mummy.lua")
loadIfNot("/data/general/npcs/ooze.lua")
loadIfNot("/data/general/npcs/orc-grushnak.lua")
loadIfNot("/data/general/npcs/orc.lua")
loadIfNot("/data/general/npcs/orc-rak-shor.lua")
loadIfNot("/data/general/npcs/orc-vor.lua")
loadIfNot("/data/general/npcs/plant.lua")
--loadIfNot("/data/general/npcs/ritch.lua")
loadIfNot("/data/general/npcs/rodent.lua")
loadIfNot("/data/general/npcs/sandworm.lua")
loadIfNot("/data/general/npcs/skeleton.lua")
loadIfNot("/data/general/npcs/snake.lua")
loadIfNot("/data/general/npcs/snow-giant.lua")
loadIfNot("/data/general/npcs/spider.lua")
--loadIfNot("/data/general/npcs/sunwall-town.lua")
loadIfNot("/data/general/npcs/swarm.lua")
loadIfNot("/data/general/npcs/thieve.lua")
loadIfNot("/data/general/npcs/troll.lua")
loadIfNot("/data/general/npcs/vampire.lua")
loadIfNot("/data/general/npcs/vermin.lua")
loadIfNot("/data/general/npcs/wight.lua")
loadIfNot("/data/general/npcs/xorn.lua")
