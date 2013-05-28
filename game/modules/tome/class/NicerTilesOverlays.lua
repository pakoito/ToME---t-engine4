-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

local args = {...}
local _M = args[1]
local Map = require "engine.Map"

local dungeonwalls_grass = {
	["terrain/granite_wall2.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall2.png", offset=0.5},
	["terrain/granite_wall2_1.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall2.png", offset=0.5},
	["terrain/granite_wall2_2.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall2.png", offset=0.5},
	["terrain/granite_wall2_3.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall2.png", offset=0.5},
	["terrain/granite_wall2_4.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall2.png", offset=0.5},
	["terrain/granite_wall2_5.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall2.png", offset=0.5},
	["terrain/granite_wall2_6.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall2.png", offset=0.5},
	["terrain/granite_wall2_7.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall2.png", offset=0.5},
	["terrain/granite_wall2_8.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall2.png", offset=0.5},
	["terrain/granite_wall2_9.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall2.png", offset=0.5},
	["terrain/granite_wall2_10.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall2.png", offset=0.5},
	["terrain/granite_wall2_11.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall2.png", offset=0.5},
	["terrain/granite_wall2_12.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall2.png", offset=0.5},
	["terrain/granite_wall2_13.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall2.png", offset=0.5},
	["terrain/granite_wall2_14.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall2.png", offset=0.5},
	["terrain/granite_wall2_15.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall2.png", offset=0.5},
	["terrain/granite_wall2_16.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall2.png", offset=0.5},
	["terrain/granite_wall2_17.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall2.png", offset=0.5},
	["terrain/granite_door1.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall2.png", offset=0.5},
	["terrain/granite_door1_open.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall2.png", offset=0.5},
	["terrain/granite_wall_pillar_small.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall_pillar_small.png", offset=0.3},
	["terrain/granite_wall_pillar_2.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall_pillar_2.png", offset=0.4},
	["terrain/granite_wall_pillar_3.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall_pillar_3.png", offset=0.4},
	["terrain/granite_wall_pillar_1.png"] = {image="terrain/dungeonwalls_grass/grass_granite_wall_pillar_1.png", offset=0.4},
}
function _M:overlayDungeonWallsGrass(level, mode, i, j, g)
	if mode ~= "replace" then return g end
	if level.map:checkEntity(i, j+1, Map.TERRAIN, "subtype") ~= "grass" then return g end

	g = g:cloneFull()
	g:removeAllMOs()
	
	if dungeonwalls_grass[g.image] then
		g.add_mos = g.add_mos or {}
		g.add_mos[#g.add_mos+1] = {image=dungeonwalls_grass[g.image].image, display_y=dungeonwalls_grass[g.image].offset}
	end
	if g.add_displays and #g.add_displays > 0 then for i, add in ipairs(g.add_displays) do
		if dungeonwalls_grass[add.image] then
			add.add_mos = add.add_mos or {}
			add.add_mos[#add.add_mos+1] = {image=dungeonwalls_grass[add.image].image, display_y=dungeonwalls_grass[add.image].offset}
		end
	end end

	return g
end
