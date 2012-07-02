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
local x, y = rng.range(1, level.map.w - 2), rng.range(1, level.map.h - 2)
local tries = 0
while not game.state:canEventGrid(level, x, y) and tries < 100 do
	x, y = rng.range(1, level.map.w - 2), rng.range(1, level.map.h - 2)
	tries = tries + 1
end
if tries >= 100 then return false end

local id = "fearscape-invasion-"..game.turn

local changer = function(id)
	local npcs = mod.class.NPC:loadList{"/data/general/npcs/minor-demon.lua", "/data/general/npcs/major-demon.lua"}
	local objects = mod.class.Object:loadList("/data/general/objects/objects.lua")
	local terrains = mod.class.Grid:loadList({"/data/general/grids/basic.lua", "/data/general/grids/void.lua"}, nil, nil, function(e)
		if e.image then e.image = e.image:gsub("^terrain/floating_rocks", "terrain/red_floating_rocks") end
	end)
	terrains.PORTAL_BACK = mod.class.Grid.new{
		type = "floor", subtype = "floor",
		display = "&", color = colors.BLUE,
		name = "portal",
		image = "terrain/red_floating_rocks05_01.png",
		add_displays = { mod.class.Grid.new{image="terrain/demon_portal3.png"} },
		change_level = 1, change_zone = "wilderness",
		change_level_shift_back = true,
		change_zone_auto_stairs = true,
	}
	local zone = mod.class.Zone.new(id, {
		name = "orbital fearscape platform",
		level_range = {game.zone:level_adjust_level(game.level, game.zone, "actor"), game.zone:level_adjust_level(game.level, game.zone, "actor")},
		level_scheme = "player",
		max_level = 1,
		actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
		width = 30, height = 30,
		ambient_music = "World of Ice.ogg",
		reload_lists = false,
		projectile_speed_mod = 0.3,
		persistent = "zone",
		min_material_level = game.zone.min_material_level,
		max_material_level = game.zone.max_material_level,
		generator =  {
			map = {
				class = "engine.generator.map.Cavern",
				zoom = 4,
				min_floor = 400,
				floor = "FLOATING_ROCKS",
				wall = "OUTERSPACE",
				down = "PORTAL_BACK",
				force_last_stair = true,
			},
			actor = {
				class = "mod.class.generator.actor.Random",
				nb_npc = {12, 12},
				guardian = {random_elite={life_rating=function(v) return v * 1.5 + 4 end, nb_rares=4, name_scheme="#rng# the Invader", on_die=function(self) world:gainAchievement("EVENT_FEARSCAPE", game:getPlayer(true)) end}},
			},
			object = {
				class = "engine.generator.object.Random",
				filters = {{type="gem"}},
				nb_object = {6, 9},
			},
			trap = {
				class = "engine.generator.trap.Random",
				nb_trap = {6, 9},
			},
		},
		post_process = function(level)
			local Map = require "engine.Map"
			local Quadratic = require "engine.Quadratic"
			level.background_particle1 = require("engine.Particles").new("starfield_static", 1, {width=Map.viewport.width, height=Map.viewport.height, nb=300, a_min=0.5, a_max = 0.8, size_min = 1, size_max = 3})
			level.background_particle2 = require("engine.Particles").new("starfield_static", 1, {width=Map.viewport.width, height=Map.viewport.height, nb=300, a_min=0.5, a_max = 0.9, size_min = 4, size_max = 8})
			level.world_sphere = Quadratic.new()
			game.zone.world_sphere_rot = (game.zone.world_sphere_rot or 0)
			game.zone.cloud_sphere_rot = (game.zone.world_cloud_rot or 0)
		end,

		background = function(level, x, y, nb_keyframes)
			local Map = require "engine.Map"
			level.background_particle1.ps:toScreen(x, y, true, 1)
			local parx, pary = level.map.mx / (level.map.w - Map.viewport.mwidth), level.map.my / (level.map.h - Map.viewport.mheight)
			level.background_particle2.ps:toScreen(x - parx * 40, y - pary * 40, true, 1)

			core.display.glDepthTest(true)
			core.display.glMatrix(true)
			core.display.glTranslate(x + 350 - parx * 60, y + 350 - pary * 60, 0)
			core.display.glRotate(120, 0, 1, 0)
			core.display.glRotate(300, 1, 0, 0)
			core.display.glRotate(game.zone.world_sphere_rot, 0, 0, 1)
			core.display.glColor(1, 1, 1, 1)

			local tex = Map.tiles:get('', 0, 0, 0, 0, 0, 0, "shockbolt/terrain/eyal-world.png")
			tex:bind(0)
			level.world_sphere.q:sphere(300)

			local tex = Map.tiles:get('', 0, 0, 0, 0, 0, 0, "shockbolt/terrain/cloud-world.png")
			tex:bind(0)
			core.display.glRotate(game.zone.cloud_sphere_rot, 0, 0, 1)
			level.world_sphere.q:sphere(304)

			game.zone.world_sphere_rot = game.zone.world_sphere_rot + 0.01 * nb_keyframes
			game.zone.cloud_sphere_rot = game.zone.cloud_sphere_rot + rng.float(0.01, 0.02) * nb_keyframes

			core.display.glMatrix(false)
			core.display.glDepthTest(false)
		end,

--		levels = { [1] = { generator = { map = { up = "CAVEFLOOR", }, }, }, },
		npc_list = npcs,
		grid_list = terrains,
		object_list = objects,
		trap_list = mod.class.Trap:loadList("/data/general/traps/elemental.lua"),
	})
	return zone
end

local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
g.name = "fearscape invasion portal"
g.display='&' g.color_r=0 g.color_g=0 g.color_b=255 g.notice = true
g.change_level=1 g.change_zone=id g.glow=true
g.add_displays = g.add_displays or {}
g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/demon_portal3.png"}
g.nice_tiler = nil
g:initGlow()
g.real_change = changer
g.change_level_check = function(self)
	game:changeLevel(1, self.real_change(self.change_zone), {temporary_zone_shift=true})
	self.change_level_check = nil
	self.real_change = nil
	return true
end
g.block_move = function(self, x, y, who, act, couldpass)
	if not who or not who.player or not act then return false end
	if self.broken then
		game.log("#VIOLET#The portal is already broken!")
		return false
	end

	require("engine.ui.Dialog"):yesnoPopup("Fearscape Portal", "Do you wish to enter the portal or just destroy it?", function(ret)
		game.log("#VIOLET#The portal is broken!")
		if not ret then
			self:change_level_check()
		end
		self.broken = true
		self.change_level = nil
	end, "Destroy", "Enter")

	return false
end

game.zone:addEntity(game.level, g, "terrain", x, y)

local respawn = function(self)
	local portal = game.level.map(self.fearscape_portal_x, self.fearscape_portal_y, engine.Map.TERRAIN)
	if not portal or portal.broken then return end
	local i, j = util.findFreeGrid(self.fearscape_portal_x, self.fearscape_portal_y+1, 10, true, {[engine.Map.ACTOR]=true})
	if not i then return end

	local npcs = mod.class.NPC:loadList{"/data/general/npcs/major-demon.lua"}
	local m = game.zone:makeEntity(game.level, "actor", {base_list=npcs}, nil, true)
	if not m then return end

	m.fearscape_portal_x = self.fearscape_portal_x
	m.fearscape_portal_y = self.fearscape_portal_y
	m.fearscape_respawn = self.fearscape_respawn
	m.exp_worth = 0
	m.no_drops = true
	m.faction = "fearscape"
	m.on_die = function(self) self:fearscape_respawn() end
	game.zone:addEntity(game.level, m, "actor", i, j)
	game.logSeen(m, "#VIOLET#A demon steps out of the portal!")
end

-- Spawn two that will keep on being replenished
local base = {fearscape_portal_x=x, fearscape_portal_y=y, fearscape_respawn=respawn}
respawn(base)
respawn(base)

return true
