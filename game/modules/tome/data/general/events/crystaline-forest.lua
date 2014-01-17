-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

local spots = {}
for i, spot in ipairs(level.spots) do
	if spot.type == "room" and spot.subtype:find("^forest_clearing") then
		local _, _, w, h = spot.subtype:find("^forest_clearing([0-9]+)x([0-9]+)$")
		if w and h then spots[#spots+1] = {x=spot.x, y=spot.y, w=tonumber(w), h=tonumber(h)} end
	end
end
if #spots == 0 then return false end
local clearing = rng.table(spots)

local list = mod.class.Grid:loadList("/data/general/grids/underground.lua")

local spots = {}
core.fov.calc_circle(clearing.x, clearing.y, level.map.w, level.map.h, math.max(clearing.w, clearing.h),
	function(_, lx, ly) if level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") then return true end end,
	function(_, lx, ly)
		local g = level.map(lx, ly, engine.Map.TERRAIN)
		if g.change_level or g:attr("special") then return end

		local ng = nil
		if g:check("block_move", lx, ly) then ng = list['CRYSTAL_WALL'..rng.range(2,20)]
		else ng = list['CRYSTAL_FLOOR'..rng.range(1,8)]
		end
		level.map(lx, ly, engine.Map.TERRAIN, ng:clone())
		spots[#spots+1] = {x=lx, y=ly}
		game.nicer_tiles:updateAround(level, lx,ly)
	end,
nil)
for i, spot in ipairs(spots) do game.nicer_tiles:updateAround(level, spot.x, spot.y) end

return true
