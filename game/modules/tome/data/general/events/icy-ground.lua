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

local spots = game.state:findEventGridRadius(level, 3, 6)
if not spots then return false end

local list = mod.class.Grid:loadList("/data/general/grids/ice.lua")

for _, spot in ipairs(spots) do
	level.map(spot.x, spot.y, engine.Map.TERRAIN, list.ICY_FLOOR)
end
for _, spot in ipairs(spots) do game.nicer_tiles:updateAround(level, spot.x, spot.y) end

return true
