-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

local random_zone_mode = false
if type(entity_mod) == "table" then
	random_zone_mode = entity_mod.random_zone_mode
	entity_mod = false
end
local todo = {}

local loadIfNot = loadIfNot or function(f)
	if loaded[f] then return end
	todo[#todo+1] = {f=f, mod=entity_mod}
end

-- Load all NPCs anyway but with higher rarity
loadIfNot("/data/general/npcs/ant.lua")
--loadIfNot("/data/general/npcs/aquatic_critter.lua")
--loadIfNot("/data/general/npcs/aquatic_demon.lua")
loadIfNot("/data/general/npcs/bear.lua")
loadIfNot("/data/general/npcs/bird.lua")
--loadIfNot("/data/general/npcs/bone-giant.lua")
loadIfNot("/data/general/npcs/canine.lua")
loadIfNot("/data/general/npcs/cold-drake.lua")
--loadIfNot("/data/general/npcs/faeros.lua")
loadIfNot("/data/general/npcs/fire-drake.lua")
loadIfNot("/data/general/npcs/ghost.lua")
loadIfNot("/data/general/npcs/ghoul.lua")
--loadIfNot("/data/general/npcs/gwelgoroth.lua")
loadIfNot("/data/general/npcs/horror.lua")
loadIfNot("/data/general/npcs/horror_temporal.lua")
--loadIfNot("/data/general/npcs/horror-corrupted.lua")
loadIfNot("/data/general/npcs/jelly.lua")
loadIfNot("/data/general/npcs/lich.lua")
loadIfNot("/data/general/npcs/minor-demon.lua")
loadIfNot("/data/general/npcs/major-demon.lua")
loadIfNot("/data/general/npcs/minotaur.lua")
loadIfNot("/data/general/npcs/molds.lua")
loadIfNot("/data/general/npcs/multihued-drake.lua")
--loadIfNot("/data/general/npcs/mummy.lua")
loadIfNot("/data/general/npcs/naga.lua")
loadIfNot("/data/general/npcs/ooze.lua")
loadIfNot("/data/general/npcs/orc-grushnak.lua")
loadIfNot("/data/general/npcs/orc-gorbat.lua")
loadIfNot("/data/general/npcs/orc.lua")
loadIfNot("/data/general/npcs/orc-rak-shor.lua")
loadIfNot("/data/general/npcs/orc-vor.lua")
loadIfNot("/data/general/npcs/plant.lua")
--loadIfNot("/data/general/npcs/ritch.lua")
loadIfNot("/data/general/npcs/rodent.lua")
loadIfNot("/data/general/npcs/sandworm.lua")
loadIfNot("/data/general/npcs/skeleton.lua")
--loadIfNot("/data/general/npcs/shade.lua")
loadIfNot("/data/general/npcs/snake.lua")
loadIfNot("/data/general/npcs/snow-giant.lua")
loadIfNot("/data/general/npcs/spider.lua")
loadIfNot("/data/general/npcs/storm-drake.lua")
--loadIfNot("/data/general/npcs/sunwall-town.lua")
loadIfNot("/data/general/npcs/swarm.lua")
--loadIfNot("/data/general/npcs/telugoroth.lua")
loadIfNot("/data/general/npcs/thieve.lua")
loadIfNot("/data/general/npcs/troll.lua")
loadIfNot("/data/general/npcs/vampire.lua")
loadIfNot("/data/general/npcs/vermin.lua")
loadIfNot("/data/general/npcs/wight.lua")
loadIfNot("/data/general/npcs/wild-drake.lua")
loadIfNot("/data/general/npcs/xorn.lua")

loadIfNot("/data/general/npcs/humanoid_random_boss.lua")

-- Select some random dominant ones for random zones
if random_zone_mode then
	local nt = {}
	local nb = #todo
	for i = 1, nb do nt[#nt+1] = rng.tableRemove(todo) end
	todo = nt
	-- The first 4 are much more likely
	for i = 4, #todo do
		todo[i].mod = rarity(4, 35)
	end
end

for i = 1, #todo do
	load(todo[i].f, todo[i].mod)
end
