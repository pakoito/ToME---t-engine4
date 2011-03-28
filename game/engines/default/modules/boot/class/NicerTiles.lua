-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

require "engine.class"
local Map = require "engine.Map"

module(..., package.seeall, class.make)

function _M:init()
	self.repo = {}
	self.repl = {}
end

function _M:getTile(name)
	if not name then return end

	if type(name) == "table" then
		local n = name[1]
		if rng.percent(name[2]) then n = n..rng.range(name[3], name[4]) end
		name = n
	end

	if self.repo[name] then return self.repo[name]
	else
		self.repo[name] = game.zone:makeEntityByName(game.level, "terrain", name)
		return self.repo[name]
	end
end

function _M:replace(i, j, g)
	if g then
		self.repl[#self.repl+1] = {i, j, g}
	end
end

function _M:handle(level, i, j)
	local g = level.map(i, j, Map.TERRAIN)
	if g and g.nice_tiler then
		self["niceTile"..g.nice_tiler.method:capitalize()](self, level, i, j, g, g.nice_tiler)
	end
end

function _M:replaceAll(level)
	for i = 1, #self.repl do
		local r = self.repl[i]
		level.map(r[1], r[2], Map.TERRAIN, r[3])
	end
	self.repl = {}
end

function _M:postProcessLevelTiles(level)
	for i = 0, level.map.w - 1 do for j = 0, level.map.h - 1 do
		self:handle(level, i, j)
	end end

	self:replaceAll(level)
end

function _M:updateAround(level, x, y)
	for i = x-1, x+1 do for j = y-1, y+1 do
		self:handle(level, i, j)
	end end

	self:replaceAll(level)
end

--- Make walls have a pseudo 3D effect
function _M:niceTileWall3d(level, i, j, g, nt)
	local s = level.map:checkEntity(i, j, Map.TERRAIN, "type") or "wall"
	local gn = level.map:checkEntity(i, j-1, Map.TERRAIN, "type") or "wall"
	local gs = level.map:checkEntity(i, j+1, Map.TERRAIN, "type") or "wall"
	local gw = level.map:checkEntity(i-1, j, Map.TERRAIN, "type") or "wall"
	local ge = level.map:checkEntity(i+1, j, Map.TERRAIN, "type") or "wall"

--	local gnc = level.map:checkEntity(i, j-1, Map.TERRAIN, "block_move", {open_door=true}, false, true) and true or false
--	local gsc = level.map:checkEntity(i, j+1, Map.TERRAIN, "block_move", {open_door=true}, false, true) and true or false
	local gnc = gn
	local gsc = gs

	if gs ~= s and gn ~= s and gw ~= s and ge ~= s then self:replace(i, j, self:getTile(nt.small_pillar))
	elseif gs ~= s and gn ~= s and gw ~= s and ge == s then self:replace(i, j, self:getTile(nt.pillar_4))
	elseif gs ~= s and gn ~= s and gw == s and ge ~= s then self:replace(i, j, self:getTile(nt.pillar_6))
	elseif gs == s and gn ~= s and gw ~= s and ge ~= s then self:replace(i, j, self:getTile(nt.pillar_8))
	elseif gs ~= s and gn == s and gw ~= s and ge ~= s then self:replace(i, j, self:getTile(nt.pillar_2))
	elseif gsc ~= s and gnc ~= s then self:replace(i, j, self:getTile(nt.north_south))
	elseif gsc ~= s then self:replace(i, j, self:getTile(nt.south))
	elseif gnc ~= s then self:replace(i, j, self:getTile(nt.north))
	elseif nt.inner then self:replace(i, j, self:getTile(nt.inner))
	end
end

--- Make walls have a pseudo 3D effect & rounded corners
function _M:niceTileRoundwall3d(level, i, j, g, nt)
	local s = level.map:checkEntity(i, j, Map.TERRAIN, "type") or "wall"
	local g8 = level.map:checkEntity(i, j-1, Map.TERRAIN, "type") or "wall"
	local g2 = level.map:checkEntity(i, j+1, Map.TERRAIN, "type") or "wall"
	local g4 = level.map:checkEntity(i-1, j, Map.TERRAIN, "type") or "wall"
	local g6 = level.map:checkEntity(i+1, j, Map.TERRAIN, "type") or "wall"
	local g1 = level.map:checkEntity(i-1, j+1, Map.TERRAIN, "type") or "wall"
	local g3 = level.map:checkEntity(i+1, j+1, Map.TERRAIN, "type") or "wall"
	local g7 = level.map:checkEntity(i-1, j-1, Map.TERRAIN, "type") or "wall"
	local g9 = level.map:checkEntity(i+1, j-1, Map.TERRAIN, "type") or "wall"

	-- Pillar
	if     g2 ~= s and g8 ~= s and g4 ~= s and g6 ~= s then self:replace(i, j, self:getTile(nt.pillar_small))
	elseif g8 ~= s and g4 == s and g6 == s and g7 == s and g9 == s then self:replace(i, j, self:getTile(nt.hole8))
	elseif g2 ~= s and g4 == s and g6 == s and g1 == s and g3 == s then self:replace(i, j, self:getTile(nt.hole2))
	elseif g8 ~= s and g4 ~= s and g6 ~= s then self:replace(i, j, self:getTile(nt.pillar8))
	elseif g2 ~= s and g4 ~= s and g6 ~= s then self:replace(i, j, self:getTile(nt.pillar2))
	elseif g4 ~= s and g8 ~= s and g2 ~= s then self:replace(i, j, self:getTile(nt.pillar4))
	elseif g6 ~= s and g8 ~= s and g2 ~= s then self:replace(i, j, self:getTile(nt.pillar6))
	-- Sides
	elseif g2 ~= s and g6 ~= s and g4 == s and g1 == s then self:replace(i, j, self:getTile(nt.wall19d))
	elseif g2 ~= s and g4 ~= s and g6 == s and g3 == s then self:replace(i, j, self:getTile(nt.wall37d))
	elseif g8 ~= s and g6 ~= s and g4 == s and g7 == s then self:replace(i, j, self:getTile(nt.wall73d))
	elseif g8 ~= s and g4 ~= s and g6 == s and g9 == s then self:replace(i, j, self:getTile(nt.wall91d))
	elseif g8 ~= s and g4 == s and g7 == s then self:replace(i, j, self:getTile(nt.wall7d))
	elseif g8 ~= s and g6 == s and g9 == s then self:replace(i, j, self:getTile(nt.wall9d))
	elseif g2 ~= s and g4 == s and g1 == s then self:replace(i, j, self:getTile(nt.wall1d))
	elseif g2 ~= s and g6 == s and g3 == s then self:replace(i, j, self:getTile(nt.wall3d))
	-- Top
	elseif g2 ~= s and g8 ~= s then self:replace(i, j, self:getTile(nt.wall82))
	elseif g8 ~= s and g4 ~= s then self:replace(i, j, self:getTile(nt.wall7))
	elseif g8 ~= s and g6 ~= s then self:replace(i, j, self:getTile(nt.wall9))
	elseif g8 ~= s then self:replace(i, j, self:getTile(nt.wall8))
	-- Bottom
	elseif g2 ~= s and g4 ~= s then self:replace(i, j, self:getTile(nt.wall1))
	elseif g2 ~= s and g6 ~= s then self:replace(i, j, self:getTile(nt.wall3))
	elseif g2 ~= s then self:replace(i, j, self:getTile(nt.wall2))
	elseif nt.inner then self:replace(i, j, self:getTile(nt.inner))
	end
end

--- Make doors have a pseudo 3D effect
function _M:niceTileDoor3d(level, i, j, g, nt)
	local gn = level.map:checkEntity(i, j-1, Map.TERRAIN, "type") or "wall"
	local gs = level.map:checkEntity(i, j+1, Map.TERRAIN, "type") or "wall"
	local gw = level.map:checkEntity(i-1, j, Map.TERRAIN, "type") or "wall"
	local ge = level.map:checkEntity(i+1, j, Map.TERRAIN, "type") or "wall"

	if gs == "wall" and gn == "wall" then self:replace(i, j, self:getTile(nt.north_south))
	elseif gw == "wall" and ge == "wall" then self:replace(i, j, self:getTile(nt.west_east))
	end
end

--- Randomize tiles
function _M:niceTileReplace(level, i, j, g, nt)
	self:replace(i, j, self:getTile(nt.base))
end

--- Make water have nice transition to other stuff
function _M:niceTileGenericBorders(level, i, j, g, nt, type, allow)
	local g8 = level.map:checkEntity(i, j-1, Map.TERRAIN, "subtype") or type
	local g2 = level.map:checkEntity(i, j+1, Map.TERRAIN, "subtype") or type
	local g4 = level.map:checkEntity(i-1, j, Map.TERRAIN, "subtype") or type
	local g6 = level.map:checkEntity(i+1, j, Map.TERRAIN, "subtype") or type
	local g7 = level.map:checkEntity(i-1, j-1, Map.TERRAIN, "subtype") or type
	local g9 = level.map:checkEntity(i+1, j-1, Map.TERRAIN, "subtype") or type
	local g1 = level.map:checkEntity(i-1, j+1, Map.TERRAIN, "subtype") or type
	local g3 = level.map:checkEntity(i+1, j+1, Map.TERRAIN, "subtype") or type

	-- Sides
	if     g4==type and g6==type and allow[g8] then self:replace(i, j, self:getTile(nt[g8.."8"]))
	elseif g4==type and g6==type and allow[g2] then self:replace(i, j, self:getTile(nt[g2.."2"]))
	elseif g8==type and g2==type and allow[g4] then self:replace(i, j, self:getTile(nt[g4.."4"]))
	elseif g8==type and g2==type and allow[g6] then self:replace(i, j, self:getTile(nt[g6.."6"]))
	-- Corners
	elseif allow[g4] and allow[g7] and allow[g8] then self:replace(i, j, self:getTile(nt[g7.."7"]))
	elseif allow[g4] and allow[g1] and allow[g2] then self:replace(i, j, self:getTile(nt[g1.."1"]))
	elseif allow[g2] and allow[g3] and allow[g6] then self:replace(i, j, self:getTile(nt[g3.."3"]))
	elseif allow[g6] and allow[g9] and allow[g8] then self:replace(i, j, self:getTile(nt[g9.."9"]))
	-- Inner corners
	elseif g4==type and allow[g7] and g8==type then self:replace(i, j, self:getTile(nt["inner_"..g7.."3"]))
	elseif g4==type and allow[g1] and g2==type then self:replace(i, j, self:getTile(nt["inner_"..g1.."9"]))
	elseif g2==type and allow[g3] and g6==type then self:replace(i, j, self:getTile(nt["inner_"..g3.."7"]))
	elseif g6==type and allow[g9] and g8==type then self:replace(i, j, self:getTile(nt["inner_"..g9.."1"]))
	-- Full
	elseif g1==type and g2==type and g3==type and g4==type and g6==type and g7==type and g8==type and g9==type then self:replace(i, j, self:getTile(nt[type]))
	end
end

function _M:niceTileWater(level, i, j, g, nt)
	self:niceTileGenericBorders(level, i, j, g, nt, "water", {grass=true, sand=true})
end

function _M:niceTileGrassSand(level, i, j, g, nt)
	self:niceTileGenericBorders(level, i, j, g, nt, "sand", {grass=true})
end
