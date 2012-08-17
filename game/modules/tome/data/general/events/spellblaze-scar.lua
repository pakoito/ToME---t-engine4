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

-- Find a random spot
local x, y = game.state:findEventGrid(level)
if not x then return false end

local list = mod.class.Grid:loadList("/data/general/grids/lava.lua")

local g = list.LAVA_FLOOR:clone()
g.name = "spellblaze scar"
g.on_stand = nil
level.map(x, y, engine.Map.TERRAIN, g)
game.nicer_tiles:updateAround(level, x, y)

if core.shader.active(4) then
	level.map:particleEmitter(x, y, 1, "shader_ring_rotating", {rotation=0, radius=2}, {type="flames", aam=0.5, zoom=3, npow=4, time_factor=1000, hide_center=0})
else
	level.map:particleEmitter(x, y, 1, "ultrashield", {rm=180, rM=220, gm=0, gM=0, bm=10, bM=80, am=30, aM=100, radius=1, density=60, life=14, instop=17})
end

local on_stand = function(self, x, y, who) who:setEffect(who.EFF_SPELLBLAZE_SCAR, 1, {}) end

local grids = core.fov.circle_grids(x, y, 1, "do not block")
for x, yy in pairs(grids) do for y, _ in pairs(yy) do
	local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
	g.on_stand = g.on_stand or on_stand
	game.zone:addEntity(game.level, g, "terrain", x, y)
end end

return true
