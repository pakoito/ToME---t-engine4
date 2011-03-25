-- ToME - Tales of Maj'Eyal
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
	if g and Map.tiles.nicer_tiles and g.nice_tiler then
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
	if not Map.tiles.nicer_tiles then return end

	for i = 0, level.map.w - 1 do for j = 0, level.map.h - 1 do
		self:handle(level, i, j)
	end end

	self:replaceAll(level)
end

function _M:updateAround(level, x, y)
	if not Map.tiles.nicer_tiles then return end

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
	elseif (g1==type or not allow[g1]) and (g2==type or not allow[g2]) and (g3==type or not allow[g3]) and (g4==type or not allow[g4]) and (g6==type or not allow[g6]) and (g7==type or not allow[g7]) and (g8==type or not allow[g8]) and (g9==type or not allow[g9]) then self:replace(i, j, self:getTile(nt[type]))
	end
end

function _M:niceTileWater(level, i, j, g, nt)
	self:niceTileGenericBorders(level, i, j, g, nt, "water", {grass=true, sand=true})
end

function _M:niceTileGrassSand(level, i, j, g, nt)
	self:niceTileGenericBorders(level, i, j, g, nt, "sand", {grass=true})
end

-- This array is precomputed, it holds the possible combinations of walls and the nice tile they generate
-- The data is bit-encoded
local full_wall3d = {
	[0x00000000] = 'pillar',
	[0x000001e4] = 'wall1',
	[0x000001e8] = 'wall2',
	[0x000001ec] = 'wall2',
	[0x00000002] = 'pillar8',
	[0x00000008] = 'pillar6',
	[0x00000020] = 'pillar4',
	[0x00000080] = 'pillar2',
	[0x00000082] = 'pillar82',
	[0x0000008a] = 'wall6',
	[0x00000009] = 'pillar6',
	[0x0000008e] = 'wall6',
	[0x00000126] = 'wall7',
	[0x000001a9] = 'wall2',
	[0x000001ad] = 'wall2',
	[0x00000027] = 'wall7',
	[0x00000028] = 'pillar46',
	[0x000000a2] = 'wall4',
	[0x0000002a] = 'wall8',
	[0x000000a8] = 'wall2',
	[0x0000002b] = 'wall8',
	[0x000000ac] = 'wall2',
	[0x000001e9] = 'wall2',
	[0x000001ed] = 'wall2',
	[0x0000002f] = 'wall8',
	[0x000000c0] = 'pillar2',
	[0x0000018a] = 'wall6',
	[0x0000018e] = 'wall6',
	[0x000000ca] = 'wall6',
	[0x000000ce] = 'wall6',
	[0x000001a2] = 'wall4',
	[0x000001a6] = 'wall4',
	[0x0000012b] = 'wall8',
	[0x0000012f] = 'wall8',
	[0x000000e2] = 'wall4',
	[0x000000e6] = 'wall4',
	[0x000000e8] = 'wall2',
	[0x000000ec] = 'wall2',
	[0x00000003] = 'pillar8',
	[0x0000016e] = 'wall8',
	[0x000001e2] = 'wall4',
	[0x000001e6] = 'wall4',
	[0x0000016b] = 'wall8',
	[0x0000016f] = 'wall8',
	[0x0000000b] = 'wall9',
	[0x0000000f] = 'wall9',
	[0x00000124] = 'pillar4',
	[0x0000004b] = 'wall9',
	[0x000001ee] = 'inner_wall9',
	[0x000001e0] = 'wall1',
	[0x0000018b] = 'wall6',
	[0x0000018f] = 'wall6',
	[0x0000008b] = 'wall6',
	[0x000001ca] = 'wall6',
	[0x0000008f] = 'wall6',
	[0x00000049] = 'pillar6',
	[0x000001a3] = 'wall4',
	[0x000001a7] = 'wall4',
	[0x000001a4] = 'wall1',
	[0x000001af] = 'inner_wall3',
	[0x000000a6] = 'wall4',
	[0x0000004f] = 'wall9',
	[0x00000120] = 'pillar4',
	[0x00000024] = 'pillar4',
	[0x000000a3] = 'wall4',
	[0x000000c8] = 'wall3',
	[0x000001cb] = 'wall6',
	[0x000000a9] = 'wall2',
	[0x0000012a] = 'wall8',
	[0x000000ad] = 'wall2',
	[0x000001c9] = 'wall3',
	[0x0000012e] = 'wall8',
	[0x000001e3] = 'wall4',
	[0x000001e7] = 'wall4',
	[0x000001eb] = 'inner_wall7',
	[0x000001ef] = 'base',
	[0x00000006] = 'pillar8',
	[0x00000048] = 'pillar6',
	[0x00000007] = 'pillar8',
	[0x00000180] = 'pillar2',
	[0x00000026] = 'wall7',
	[0x00000127] = 'wall7',
	[0x000001cf] = 'wall6',
	[0x000000c9] = 'wall3',
	[0x000000cb] = 'wall6',
	[0x0000002e] = 'wall8',
	[0x000000cf] = 'wall6',
	[0x000001a0] = 'wall1',
	[0x0000006a] = 'wall8',
	[0x0000006b] = 'wall8',
	[0x000001ac] = 'wall2',
	[0x000001ce] = 'wall6',
	[0x0000006e] = 'wall8',
	[0x0000006f] = 'wall8',
	[0x0000016a] = 'wall8',
	[0x000001c0] = 'pillar2',
	[0x000000e3] = 'wall4',
	[0x000001c8] = 'wall3',
	[0x000000e7] = 'wall4',
	[0x000000e9] = 'wall2',
	[0x000001a8] = 'wall2',
	[0x000000ed] = 'wall2',
	[0x000000ef] = 'inner_wall1',
	[0x000000a7] = 'wall4',
}

--- Make walls have a pseudo 3D effect
function _M:niceTileMountain3d(level, i, j, g, nt)
	local s = level.map:checkEntity(i, j, Map.TERRAIN, "type") or "wall"
	local g1 = level.map:checkEntity(i-1, j+1, Map.TERRAIN, "type") == s and 1 or 0
	local g2 = level.map:checkEntity(i, j+1, Map.TERRAIN, "type")   == s and 2 or 0
	local g3 = level.map:checkEntity(i+1, j+1, Map.TERRAIN, "type") == s and 4 or 0
	local g4 = level.map:checkEntity(i-1, j, Map.TERRAIN, "type")   == s and 8 or 0
	local g6 = level.map:checkEntity(i+1, j, Map.TERRAIN, "type")   == s and 32 or 0
	local g7 = level.map:checkEntity(i-1, j-1, Map.TERRAIN, "type") == s and 64 or 0
	local g8 = level.map:checkEntity(i, j-1, Map.TERRAIN, "type")   == s and 128 or 0
	local g9 = level.map:checkEntity(i+1, j-1, Map.TERRAIN, "type") == s and 256 or 0

	-- We compute a single number whose 9 first bits represent the walls
	local v = bit.bor(g1, g2, g3, g4, g6, g7, g8, g9)
	if full_wall3d[v] then self:replace(i, j, self:getTile(nt[full_wall3d[v]])) end
end






--------------------------------------------------------------------------
-- Uncommand to use: the generator for the predefined wall indices
--------------------------------------------------------------------------
--[=[
local names = {
-- Full
[ [[
111
1 1
111]] ] = "base",

-- Borders
[ [[
*0*
1 1
*1*]] ] = "wall8",

[ [[
*1*
1 1
*0*]] ] = "wall2",

[ [[
*1*
0 1
*1*]] ] = "wall4",

[ [[
*1*
1 0
*1*]] ] = "wall6",

-- Corners
[ [[
11*
1 0
*00]] ] = "wall3",

[ [[
00*
0 1
*11]] ] = "wall7",

[ [[
*11
0 1
00*]] ] = "wall1",

[ [[
*00
1 0
11*]] ] = "wall9",

-- Inner walls
[ [[
111
1 1
110]] ] = "inner_wall7",

[ [[
011
1 1
111]] ] = "inner_wall3",

[ [[
110
1 1
111]] ] = "inner_wall1",

[ [[
111
1 1
011]] ] = "inner_wall9",


-- Pillar
[ [[
000
0 0
000]] ] = "pillar",


-- Smalls
[ [[
00*
0 1
00*]] ] = 'pillar4',
[ [[
000
1 1
000]] ] = 'pillar46',
[ [[
*00
1 0
*00]] ] = 'pillar6',
[ [[
000
0 0
*1*]] ] = 'pillar8',
[ [[
010
0 0
010]] ] = 'pillar82',
[ [[
*1*
0 0
000]] ] = 'pillar2',

}

local function bitprint(v)
	local r = ""
	for i = 1, 16 do
		if bit.band(v, bit.lshift(1, i-1)) ~= 0 then r = r.."1" else r = r.."0" end
	end
	return r
end

local res = {}
string.get = function(self, x) return self:sub(x,x) end
local function strssub(str, x, c)
	return str:sub(1,x-1)..c..str:sub(x+1)
end

local function run(names)
	for test, name in pairs(names) do
		repeat
		local v = 0
		local dont = false
		if test:get(1) == "1" then v = bit.bor(v, bit.lshift(1, 7-1))
		elseif test:get(1) == "*" then run{[strssub(test, 1, "1")]=name, [strssub(test, 1, "0")]=name} dont=true end
		if test:get(2) == "1" then v = bit.bor(v, bit.lshift(1, 8-1))
		elseif test:get(2) == "*" then run{[strssub(test, 2, "1")]=name, [strssub(test, 2, "0")]=name} dont=true end
		if test:get(3) == "1" then v = bit.bor(v, bit.lshift(1, 9-1))
		elseif test:get(3) == "*" then run{[strssub(test, 3, "1")]=name, [strssub(test, 3, "0")]=name} dont=true end
		if test:get(5) == "1" then v = bit.bor(v, bit.lshift(1, 4-1))
		elseif test:get(5) == "*" then run{[strssub(test, 5, "1")]=name, [strssub(test, 5, "0")]=name} dont=true end
		if test:get(7) == "1" then v = bit.bor(v, bit.lshift(1, 6-1))
		elseif test:get(7) == "*" then run{[strssub(test, 7, "1")]=name, [strssub(test, 7, "0")]=name} dont=true end
		if test:get(9) == "1" then v = bit.bor(v, bit.lshift(1, 1-1))
		elseif test:get(9) == "*" then run{[strssub(test, 9, "1")]=name, [strssub(test, 9, "0")]=name} dont=true end
		if test:get(10) == "1" then v = bit.bor(v, bit.lshift(1, 2-1))
		elseif test:get(10) == "*" then run{[strssub(test, 10, "1")]=name, [strssub(test, 10, "0")]=name} dont=true end
		if test:get(11) == "1" then v = bit.bor(v, bit.lshift(1, 3-1))
		elseif test:get(11) == "*" then run{[strssub(test, 11, "1")]=name, [strssub(test, 11, "0")]=name} dont=true end

		if not dont then
			res[v] = name
		end
		until true
	end
end

run(names)


for v, name in pairs(res) do
--	print(name,"=>", bitprint(v))
	print(("	[0x%s] = '%s',"):format(bit.tohex(v), name))
end
--os.exit()
]=]
