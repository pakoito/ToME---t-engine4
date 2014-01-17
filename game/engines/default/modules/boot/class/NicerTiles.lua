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

require "engine.class"
local Map = require "engine.Map"

module(..., package.seeall, class.make)

function _M:init()
	self.repo = {}
	self.repl = {}
	self.edits = {}
end

function _M:getTile(name)
	if not name then return end

	if type(name) == "table" then
		local n = name[1]
		if rng.percent(name[2]) then n = n..rng.range(name[3], name[4]) end
		name = n
	end

	local e
	if self.repo[name] then e = self.repo[name]
	else
		self.repo[name] = game.zone:makeEntityByName(game.level, "terrain", name)
		e = self.repo[name]
	end
	if e and e.force_clone then
		e = e:clone()
	end
	return e
end

function _M:replace(i, j, g)
	if g then
		self.repl[#self.repl+1] = {i, j, g}
	end
end

function _M:edit(i, j, id, e)
	if not e then return end
	self.edits[i] = self.edits[i] or {}
	self.edits[i][j] = self.edits[i][j] or {}
	local ee = self.edits[i][j]
	ee[#ee+1] = {use_id=id, add_displays=e.add_displays, add_mos=e.add_mos, add_mos_shader=e.add_mos_shader, image=e.image, min=e.min, max=e.max}
end

function _M:handle(level, i, j)
	local g = level.map(i, j, Map.TERRAIN)
	if g then
		if g.nice_tiler then self["niceTile"..g.nice_tiler.method:capitalize()](self, level, i, j, g, g.nice_tiler) end
		if g.nice_editer then self["editTile"..g.nice_editer.method:capitalize()](self, level, i, j, g, g.nice_editer) end
		if g.nice_editer2 then self["editTile"..g.nice_editer2.method:capitalize()](self, level, i, j, g, g.nice_editer2) end
	end
end

function _M:replaceAll(level)
	for i = 1, #self.repl do
		local r = self.repl[i]
		level.map(r[1], r[2], Map.TERRAIN, r[3])
	end
	self.repl = {}

	-- In-place entities edition, now this is becoming tricky, but powerful
	for i, jj in pairs(self.edits) do for j, ee in pairs(jj) do
		local g = level.map(i, j, Map.TERRAIN)

		local id = {g.name or "???"}
		for __, e in ipairs(ee) do
			if not e.use_id then id = nil break end
			id[#id+1] = e.use_id
		end
		if id then id = table.concat(id, "|") end

		-- If we made this one already, use it
		if self.edit_entity_store and self.edit_entity_store[id] then
			level.map(i, j, Map.TERRAIN, self.edit_entity_store[id])
		-- Otherwise compute this new combo and store the entity
		else
			local cloned = false
			if not g.force_clone or not self.edit_entity_store then g = g:cloneFull() g.force_clone = true cloned = true end

			g:removeAllMOs(true)

			-- Edit the first add_display entity, or add a dummy if none
			if not g.__edit_d then
				g.add_displays = g.add_displays or {}
				g.add_displays[#g.add_displays+1] = require(g.__CLASSNAME).new{image="invis.png", force_clone=true}
				g.__edit_d = #g.add_displays
			end
			local gd = g.add_displays[g.__edit_d]

			for __, e in ipairs(ee) do
				if e.add_mos then
					-- Add all the mos
					gd.add_mos = gd.add_mos or {}
					local mos = gd.add_mos
					for i = 1, #e.add_mos do
						mos[#mos+1] = table.clone(e.add_mos[i])
						mos[#mos].image = mos[#mos].image:format(rng.range(e.min, e.max))
					end
					if e.add_mos_shader then gd.shader = e.add_mos_shader end
					gd._mo = nil
				end
				if e.add_displays then
					g.add_displays = g.add_displays or {}
					for i = 1, #e.add_displays do
						 g.add_displays[#g.add_displays+1] = require(g.__CLASSNAME).new(e.add_displays[i])
						g.add_displays[#g.add_displays].image = g.add_displays[#g.add_displays].image:format(rng.range(e.min, e.max))
					end
				end
				if e.image then g.image = e.image end
			end

			level.map(i, j, Map.TERRAIN, g)
			level.map:updateMap(i, j)
			if self.edit_entity_store then self.edit_entity_store[id] = g end
		end
	end end
	self.edits = {}
end

function _M:postProcessLevelTiles(level)
	self.edit_entity_store = {}

	for i = 0, level.map.w - 1 do for j = 0, level.map.h - 1 do
		self:handle(level, i, j)
	end end

	self:replaceAll(level)

	self.edit_entity_store = nil
end

function _M:updateAround(level, x, y)
	self.edit_entity_store = nil

	for i = x-1, x+1 do for j = y-1, y+1 do
		self:handle(level, i, j)
	end end

	self:replaceAll(level)
end

--- Make walls have a pseudo 3D effect
function _M:niceTileWall3d(level, i, j, g, nt)
	local s = level.map:checkEntity(i, j, Map.TERRAIN, "type") or "wall"
	local gn = level.map:checkEntity(i, j-1, Map.TERRAIN, "type") or "wall"
	local dn = level.map:checkEntity(i, j-1, Map.TERRAIN, "door_opened")
	local gs = level.map:checkEntity(i, j+1, Map.TERRAIN, "type") or "wall"
	local ds = level.map:checkEntity(i, j+1, Map.TERRAIN, "door_opened")
	local gw = level.map:checkEntity(i-1, j, Map.TERRAIN, "type") or "wall"
	local ge = level.map:checkEntity(i+1, j, Map.TERRAIN, "type") or "wall"

	if gs ~= s and gn ~= s and gw ~= s and ge ~= s then self:replace(i, j, self:getTile(nt.small_pillar))
	elseif gs ~= s and gn ~= s and gw ~= s and ge == s then self:replace(i, j, self:getTile(nt.pillar_4))
	elseif gs ~= s and gn ~= s and gw == s and ge ~= s then self:replace(i, j, self:getTile(nt.pillar_6))
	elseif gs == s and gn ~= s and gw ~= s and ge ~= s then self:replace(i, j, self:getTile(nt.pillar_8))
	elseif gs ~= s and gn == s and gw ~= s and ge ~= s then self:replace(i, j, self:getTile(nt.pillar_2))
	elseif gs ~= s and gn ~= s then self:replace(i, j, self:getTile(nt.north_south))
	elseif gs == s and ds and gn ~= s then self:replace(i, j, self:getTile(nt.north_south))
	elseif gs ~= s and gn == s and dn then self:replace(i, j, self:getTile(nt.north_south))
	elseif gs ~= s then self:replace(i, j, self:getTile(nt.south))
	elseif gs == s and ds then self:replace(i, j, self:getTile(nt.south))
	elseif gn ~= s then self:replace(i, j, self:getTile(nt.north))
	elseif gn == s and dn then self:replace(i, j, self:getTile(nt.north))
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


local defs = {
grass = { method="borders", type="grass", forbid={lava=true, rock=true},
	default8={add_mos={{image="terrain/grass/grass_2_%02d.png", display_y=-1}}, min=1, max=5},
	default2={add_mos={{image="terrain/grass/grass_8_%02d.png", display_y=1}}, min=1, max=5},
	default4={add_mos={{image="terrain/grass/grass_6_%02d.png", display_x=-1}}, min=1, max=5},
	default6={add_mos={{image="terrain/grass/grass_4_%02d.png", display_x=1}}, min=1, max=4},

	default1={add_mos={{image="terrain/grass/grass_9_%02d.png", display_x=-1, display_y=1}}, min=1, max=3},
	default3={add_mos={{image="terrain/grass/grass_7_%02d.png", display_x=1, display_y=1}}, min=1, max=3},
	default7={add_mos={{image="terrain/grass/grass_3_%02d.png", display_x=-1, display_y=-1}}, min=1, max=3},
	default9={add_mos={{image="terrain/grass/grass_1_%02d.png", display_x=1, display_y=-1}}, min=1, max=3},

	default1i={add_mos={{image="terrain/grass/grass_inner_1_%02d.png", display_x=-1, display_y=1}}, min=1, max=3},
	default3i={add_mos={{image="terrain/grass/grass_inner_3_%02d.png", display_x=1, display_y=1}}, min=1, max=3},
	default7i={add_mos={{image="terrain/grass/grass_inner_7_%02d.png", display_x=-1, display_y=-1}}, min=1, max=3},
	default9i={add_mos={{image="terrain/grass/grass_inner_9_%02d.png", display_x=1, display_y=-1}}, min=1, max=3},
},
}


--- Make water have nice transition to other stuff
function _M:editTileGenericBorders(level, i, j, g, nt, type)
	local kind = nt.use_type and "type" or "subtype"
	local g5 = level.map:checkEntity(i, j,   Map.TERRAIN, kind) or type
	local g8 = level.map:checkEntity(i, j-1, Map.TERRAIN, kind) or type
	local g2 = level.map:checkEntity(i, j+1, Map.TERRAIN, kind) or type
	local g4 = level.map:checkEntity(i-1, j, Map.TERRAIN, kind) or type
	local g6 = level.map:checkEntity(i+1, j, Map.TERRAIN, kind) or type
	local g7 = level.map:checkEntity(i-1, j-1, Map.TERRAIN, kind) or type
	local g9 = level.map:checkEntity(i+1, j-1, Map.TERRAIN, kind) or type
	local g1 = level.map:checkEntity(i-1, j+1, Map.TERRAIN, kind) or type
	local g3 = level.map:checkEntity(i+1, j+1, Map.TERRAIN, kind) or type
	if nt.forbid then
		if nt.forbid[g5] then g5 = type end
		if nt.forbid[g4] then g4 = type end
		if nt.forbid[g6] then g6 = type end
		if nt.forbid[g8] then g8 = type end
		if nt.forbid[g2] then g2 = type end
		if nt.forbid[g1] then g1 = type end
		if nt.forbid[g3] then g3 = type end
		if nt.forbid[g7] then g7 = type end
		if nt.forbid[g9] then g9 = type end
	end

	local id = "genbord:"..table.concat({type,tostring(g1==g5),tostring(g2==g5),tostring(g3==g5),tostring(g4==g5),tostring(g5==g5),tostring(g6==g5),tostring(g7==g5),tostring(g8==g5),tostring(g9==g5)}, ",")

	-- Sides
	if g5 ~= g8 then self:edit(i, j, id, nt[g8.."8"] or nt["default8"]) end
	if g5 ~= g2 then self:edit(i, j, id, nt[g2.."2"] or nt["default2"]) end
	if g5 ~= g4 then self:edit(i, j, id, nt[g4.."4"] or nt["default4"]) end
	if g5 ~= g6 then self:edit(i, j, id, nt[g6.."6"] or nt["default6"]) end
	-- Corners
	if g5 ~= g7 and g5 == g4 and g5 == g8 then self:edit(i, j, id, nt[g7.."7"] or nt["default7"]) end
	if g5 ~= g9 and g5 == g6 and g5 == g8 then self:edit(i, j, id, nt[g9.."9"] or nt["default9"]) end
	if g5 ~= g1 and g5 == g4 and g5 == g2 then self:edit(i, j, id, nt[g1.."1"] or nt["default1"]) end
	if g5 ~= g3 and g5 == g6 and g5 == g2 then self:edit(i, j, id, nt[g3.."3"] or nt["default3"]) end
	-- Inner corners
	if g5 ~= g7 and g5 ~= g4 and g5 ~= g8 then self:edit(i, j, id, nt[g7.."7i"] or nt["default7i"]) end
	if g5 ~= g9 and g5 ~= g6 and g5 ~= g8 then self:edit(i, j, id, nt[g9.."9i"] or nt["default9i"]) end
	if g5 ~= g1 and g5 ~= g4 and g5 ~= g2 then self:edit(i, j, id, nt[g1.."1i"] or nt["default1i"]) end
	if g5 ~= g3 and g5 ~= g6 and g5 ~= g2 then self:edit(i, j, id, nt[g3.."3i"] or nt["default3i"]) end
end

function _M:editTileBorders(level, i, j, g, nt)
	self:editTileGenericBorders(level, i, j, g, nt, nt.type or "grass")
end
function _M:editTileBorders_def(level, i, j, g, nt)
	self:editTileGenericBorders(level, i, j, g, defs[nt.def], defs[nt.def].type or "grass")
end
