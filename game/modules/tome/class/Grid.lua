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
require "engine.Grid"
local Dialog = require "engine.ui.Dialog"
local DamageType = require "engine.DamageType"

module(..., package.seeall, class.inherit(engine.Grid))

function _M:init(t, no_default)
	engine.Grid.init(self, t, no_default)
end

function _M:block_move(x, y, e, act, couldpass)
	-- Path strings
	if not e then e = {}
	elseif type(e) == "string" then
		e = loadstring(e)()
	end

	-- Open doors
	if self.door_opened and e.open_door and act then
		if self.door_player_check then
			if e.player then
				Dialog:yesnoPopup(self.name, self.door_player_check, function(ret)
					if ret then game.level.map(x, y, engine.Map.TERRAIN, game.zone.grid_list[self.door_opened]) end
				end, "Open", "Leave")
			end
		else
			game.level.map(x, y, engine.Map.TERRAIN, game.zone.grid_list[self.door_opened])
		end
		return true
	elseif self.door_opened and not couldpass then
		return true
	elseif self.door_opened and couldpass and not e.open_door then
		return true
	end

	-- Pass walls
	if self.can_pass and e.can_pass then
		for what, check in pairs(e.can_pass) do
			if self.can_pass[what] and self.can_pass[what] <= check then return false end
		end
	end

	return self.does_block_move
end

function _M:on_move(x, y, who, forced)
	if forced then return end
	if who.move_project and next(who.move_project) then
		for typ, dam in pairs(who.move_project) do
			DamageType:get(typ).projector(who, x, y, typ, dam)
		end
	end
end

function _M:tooltip(x, y)
	if self.show_tooltip then
		local name = ((self.show_tooltip == true) and self.name or self.show_tooltip)
		if self.desc then
			return tstring{{"uid", self.uid}, name, true, self.desc}
		else
			return tstring{{"uid", self.uid}, name}
		end
	else
		return tstring{{"uid", self.uid}, self.name}
	end
end

--- Generate sub entities to make nice trees
function _M:makeTrees(base, max)
	local function makeTree(nb, z)
		local inb = 4 - nb
		return engine.Entity.new{
			z = z,
			display_scale = rng.float(0.5 + inb / 6, 1.3),
			display_x = rng.range(-engine.Map.tile_w / 3 * nb / 3, engine.Map.tile_w / 3 * nb / 3),
			display_y = rng.range(-engine.Map.tile_h / 3 * nb / 3, engine.Map.tile_h / 3 * nb / 3),
			display_on_seen = true,
			display_on_remember = true,
			image = (base or "terrain/tree_alpha")..rng.range(1,max or 5)..".png",
		}
	end

	local v = rng.range(0, 100)
	local tbl
	if v < 33 then
		tbl = { makeTree(3, 16), makeTree(3, 17), makeTree(3, 18), }
	elseif v < 66 then
		tbl = { makeTree(2, 16), makeTree(2, 17), }
	else
		tbl = { makeTree(1, 16), }
	end
	table.sort(tbl, function(a,b) return a.display_y < b.display_y end)
	return tbl
end

--- Generate sub entities to make nice shells
function _M:makeShells(base, max)
	local function makeShell(nb, z)
		local inb = 4 - nb
		return engine.Entity.new{
			z = z,
			display_scale = rng.float(0.1 + inb / 6, 0.2),
			display_x = rng.range(-engine.Map.tile_w / 3 * nb / 3, engine.Map.tile_w / 3 * nb / 3),
			display_y = rng.range(-engine.Map.tile_h / 3 * nb / 3, engine.Map.tile_h / 3 * nb / 3),
			display_on_seen = true,
			display_on_remember = true,
			image = (base or "terrain/tree_alpha")..rng.range(1,max or 5)..".png",
		}
	end

	local v = rng.range(0, 100)
	local tbl
	if v < 33 then
		return nil
	elseif v < 66 then
		tbl = { makeShell(2, 2), makeShell(2, 3), }
	else
		tbl = { makeShell(1, 2), }
	end
	table.sort(tbl, function(a,b) return a.display_y < b.display_y end)
	return tbl
end

--- Generate sub entities to make translucent water
function _M:makeWater(z, prefix)
	prefix = prefix or ""
	return { engine.Entity.new{
		z = z and 16 or 9,
		image = "terrain/"..prefix.."water_floor_alpha.png",
		shader = prefix.."water", textures = { function() return _3DNoise, true end },
		display_on_seen = true,
		display_on_remember = true,
	} }
end

--- Merge sub entities
function _M:mergeSubEntities(...)
	local tbl = {}
	for i, t in ipairs{...} do if t then
		for j, e in ipairs(t) do
			tbl[#tbl+1] = e
		end
	end end
	return tbl
end
