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

require "engine.class"
require "engine.Grid"
local Map = require "engine.Map"
local Dialog = require "engine.ui.Dialog"
local DamageType = require "engine.DamageType"

module(..., package.seeall, class.inherit(engine.Grid))

function _M:init(t, no_default)
	engine.Grid.init(self, t, no_default)

	self:initGlow()
end

--- Make wilderness zone entrances glow until entered once
function _M:initGlow()
	if self.glow and Map.tiles.nicer_tiles and self.change_zone then
		self.add_displays = self.add_displays or {}
		self.add_displays[#self.add_displays+1] = require("mod.class.WildernessGrid").new{change_zone=self.change_zone, display=' ', z=17}
	end
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
					if ret then
						game.level.map(x, y, engine.Map.TERRAIN, game.zone.grid_list[self.door_opened])
						game:playSoundNear({x=x,y=y}, {"ambient/door_creaks/creak_%d",1,4})

						if game.level.map.attrs(x, y, "vault_id") and e.openVault then e:openVault(game.level.map.attrs(x, y, "vault_id")) end
					end
				end, "Open", "Leave")
			end
		elseif self.door_player_stop then
			if e.player then
				Dialog:simplePopup(self.name, self.door_player_stop)
			end
		else
			game.level.map(x, y, engine.Map.TERRAIN, game.zone.grid_list[self.door_opened])
			game:playSoundNear({x=x,y=y}, {"ambient/door_creaks/creak_%d",1,4})

			if game.level.map.attrs(x, y, "vault_id") and e.openVault then e:openVault(game.level.map.attrs(x, y, "vault_id")) end
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

	-- Huge hack, if we are an actor without position this means we are not yet put on the map
	-- If so make sure we can only go where we can breathe
	if e.__is_actor and not e.x and not e:attr("no_breath") then
		local air_level, air_condition = self:check("air_level"), self:check("air_condition")
		if air_level and (not air_condition or not e.can_breath[air_condition] or e.can_breath[air_condition] <= 0) then
			return true
		end
	end

	if e and act and self.does_block_move and e.player and game.level.map.attrs(x, y, "on_block_change") then
		local ng = game.zone:makeEntityByName(game.level, "terrain", game.level.map.attrs(x, y, "on_block_change"))
		if ng then
			game.zone:addEntity(game.level, ng, "terrain", x, y)
			game.nicer_tiles:updateAround(game.level, x, y)
			if game.level.map.attrs(x, y, "on_block_change_msg") then game.logSeen({x=x, y=y}, "%s", game.level.map.attrs(x, y, "on_block_change_msg")) end
			game.level.map.attrs(x, y, "on_block_change", false)
			game.level.map.attrs(x, y, "on_block_change_msg", false)
		end
	end

	return self.does_block_move
end

--- Setup minimap color for this entity
-- You may overload this method to customize your minimap
function _M:setupMinimapInfo(mo, map)
	if self.change_level then mo:minimap(240, 0, 240) return end
	if self.special_minimap then mo:minimap(self.special_minimap.r, self.special_minimap.g, self.special_minimap.b) return end
	return engine.Grid.setupMinimapInfo(self, mo, map)
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
	local tstr
	if self.show_tooltip then
		local name = ((self.show_tooltip == true) and self.name or self.show_tooltip)
		if self.desc then
			tstr = tstring{{"uid", self.uid}, name, true, self.desc, true}
		else
			tstr = tstring{{"uid", self.uid}, name, true}
		end
	else
		tstr = tstring{{"uid", self.uid}, self.name, true}
	end

	if game.level.entrance_glow and self.change_zone and not game.visited_zones[self.change_zone] then
		tstr:add(true, {"font","bold"}, {"color","CRIMSON"}, "Never visited yet", {"color", "LAST"}, {"font","normal"}, true)
	end

	if game.player:hasLOS(x, y) then tstr:add({"color", "CRIMSON"}, "In sight", {"color", "LAST"}, true) end
	if game.level.map.lites(x, y) then tstr:add({"color", "YELLOW"}, "Lit", {"color", "LAST"}, true) end
	if self:check("block_sight", x, y) then tstr:add({"color", "UMBER"}, "Blocks sight", {"color", "LAST"}, true) end
	if self:check("block_move", x, y, game.player) then tstr:add({"color", "UMBER"}, "Blocks movement", {"color", "LAST"}, true) end
	if self:attr("air_level") then tstr:add({"color", "LIGHT_BLUE"}, "Special breathing method required", {"color", "LAST"}, true) end
	if self:attr("dig") then tstr:add({"color", "LIGHT_UMBER"}, "Diggable", {"color", "LAST"}, true) end
	if game.level.map.attrs(x, y, "no_teleport") then tstr:add({"color", "VIOLET"}, "Cannot teleport to this place", {"color", "LAST"}, true) end

	if config.settings.cheat then
		tstr:add(true, tostring(rawget(self, "type")), " / ", tostring(rawget(self, "subtype")))
		tstr:add(true, "UID: ", tostring(self.uid), true, "Coords: ", tostring(x), "x", tostring(y))
	end
	return tstr
end

--- Generate sub entities to make nice trees
function _M:makeTrees(base, max, bigheight_limit, tint)
	local function makeTree(nb, z)
		local inb = 4 - nb
		local treeid = rng.range(1, max or 5)
		return engine.Entity.new{
			z = z,
			display_scale = 1,
			display_scale = rng.float(0.5 + inb / 6, 1),
			display_x = rng.float(-1 / 3 * nb / 3, 1 / 3 * nb / 3),
			display_y = rng.float(-1 / 5 * nb / 3, 1 / 4 * nb / 3) - (treeid < (bigheight_limit or 9) and 0 or 1),
			display_on_seen = true,
			display_on_remember = true,
			display_h = treeid < (bigheight_limit or 9) and 1 or 2,
			image = (base or "terrain/tree_alpha")..treeid..".png",
			tint = tint,
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
	table.sort(tbl, function(a,b) return a.display_scale < b.display_scale end)
	for i = 1, #tbl do tbl[i].z = 16 + i - 1 end
	return tbl
end

--- Generate sub entities to make nice trees
function _M:makeSubTrees(base, max)
	local function makeTree(nb, z)
		local inb = 4 - nb
		return engine.Entity.new{
			z = z,
			display_scale = rng.float(0.5 + inb / 6, 1.3),
			display_x = rng.float(-1 / 3 * nb / 3, 1 / 3 * nb / 3),
			display_y = rng.float(-1 / 3 * nb / 3, 1 / 3 * nb / 3),
			display_on_seen = true,
			display_on_remember = true,
			image = (base or "terrain/tree_alpha")..rng.range(1,max or 5)..".png",
		}
	end

	local v = rng.range(0, 100)
	local tbl
	if v < 40 then
--		tbl = { makeTree(3, 16), makeTree(3, 17), makeTree(3, 18), }
--	elseif v < 66 then
		tbl = { makeTree(2, 16), makeTree(2, 17), }
	else
		tbl = { makeTree(1, 16), }
	end
	table.sort(tbl, function(a,b) return a.display_scale < b.display_scale end)
	for i = 1, #tbl do tbl[i].z = 16 + i - 1 end
	return tbl
end

--- Generate sub entities to make nice crystals, same as trees but change tint
function _M:makeCrystals(base, max)
	local function makeTree(nb, z)
		local inb = 4 - nb
		local r = rng.range(1, 100)
		local g = rng.range(1, 100)
		local b = rng.range(1, 100)
		local maxcol = math.max(r, g, b)
		r = r / maxcol
		g = g / maxcol
		b = b / maxcol
		return engine.Entity.new{
			z = z,
			display_scale = rng.float(0.5 + inb / 6, 1.3),
			display_x = rng.float(-1 / 3 * nb / 3, 1 / 3 * nb / 3),
			display_y = rng.float(-1 / 3 * nb / 3, 1 / 3 * nb / 3),
			display_on_seen = true,
			display_on_remember = true,
			tint_r = r,
			tint_g = g,
			tint_b = b,
			image = (base or "terrain/crystal_alpha")..rng.range(1,max or 6)..".png",
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
	table.sort(tbl, function(a,b) return a.display_scale < b.display_scale end)
	for i = 1, #tbl do tbl[i].z = 16 + i - 1 end
	return tbl
end

--- Generate sub entities to make nice shells
function _M:makeShells(base, max)
	local function makeShell(nb, z)
		local inb = 4 - nb
		return engine.Entity.new{
			z = z,
			display_scale = rng.float(0.1 + inb / 6, 0.2),
			display_x = rng.range(-1 / 3 * nb / 3, 1 / 3 * nb / 3),
			display_y = rng.range(-1 / 3 * nb / 3, 1 / 3 * nb / 3),
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
