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

local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
g.name = "antimagic bush"
g.display='~' g.color_r=0 g.color_g=255 g.color_b=100 g.notice = true
g.add_displays = g.add_displays or {}
g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/antimagic_bush.png", z=5}
g.nice_tiler = nil
game.zone:addEntity(game.level, g, "terrain", x, y)

if core.shader.active(4) then
	level.map:particleEmitter(x, y, 3, "shader_ring_rotating", {rotation=0, radius=6}, {type="flames", aam=0.5, zoom=0.4, npow=5, time_factor=15000, color1={0,0.8,0.5,1}, color2={0,0.8,0.7,1}, hide_center=0})
else
	level.map:particleEmitter(x, y, 3, "ultrashield", {rm=0, rM=0, gm=160, gM=240, bm=100, bM=160, am=80, aM=150, radius=3, density=60, life=14, instop=17})
end

local on_stand = function(self, x, y, who) who:setEffect(who.EFF_ANTIMAGIC_BUSH, 1, {}) end

local grids = core.fov.circle_grids(x, y, 3, "do not block")
for x, yy in pairs(grids) do for y, _ in pairs(yy) do
	local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
	g.on_stand = g.on_stand or on_stand
	game.zone:addEntity(game.level, g, "terrain", x, y)
end end

return true
