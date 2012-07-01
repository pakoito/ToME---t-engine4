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

-- Unique
if game.state:doneEvent(event_id) then return end

-- Find a random spot
local x, y = rng.range(1, level.map.w - 2), rng.range(1, level.map.h - 2)
local tries = 0
while not game.state:canEventGrid(level, x, y) and tries < 100 do
	x, y = rng.range(1, level.map.w - 2), rng.range(1, level.map.h - 2)
	tries = tries + 1
end
if tries >= 100 then return false end

local id = "rat-lich-"..game.turn

local changer = function(id)
	local npcs = mod.class.NPC:loadList{"/data/general/npcs/undead-rat.lua"}
	local objects = mod.class.Object:loadList("/data/general/objects/objects.lua")
	local terrains = mod.class.Grid:loadList("/data/general/grids/basic.lua")
	terrains.UP_WILDERNESS.change_level_shift_back = true
	terrains.UP_WILDERNESS.change_zone_auto_stairs = true

	objects.RATLICH_SKULL = mod.class.Object.new{
		define_as = "RATLICH_SKULL",
		power_source = {arcane=true},
		unique = true,
		slot = "TOOL",
		type = "tool", subtype="skull", image = "object/artifact/skull_of_the_rat_lich.png",
		unided_name = "dusty rat skull",
		name = "Skull of the Rat Lich",
		display = "*", color=colors.BLACK,
		level_range = {10, 25},
		cost = 150,
		encumber = 1,
		material_level = 3,
		desc = [[This ancient skull is all that remains of the Rat Lich. Some fragments of its power remain.]],

		wielder = {
			combat_spellpower = 10,
			combat_spellcrit = 4,
			on_melee_hit = {[engine.DamageType.DARKNESS]=12},
		},
		max_power = 70, power_regen = 1,
		use_power = { name = "raise undead rats", power = 70, use = function(self, who)
			if not who:canBe("summon") then game.logPlayer(who, "You cannot summon; you are suppressed!") return end

			local NPC = require "mod.class.NPC"
			local list = NPC:loadList("/data/general/npcs/undead-rat.lua")

			for i = 1, 2 do
				-- Find space
				local x, y = util.findFreeGrid(who.x, who.y, 5, true, {[engine.Map.ACTOR]=true})
				if not x then break end

				local e
				repeat e = rng.tableRemove(list)
				until not e.unique and e.rarity

				local rat = game.zone:finishEntity(game.level, "actor", e)
				rat.make_escort = nil
				rat.silent_levelup = true
				rat.faction = who.faction
				rat.ai = "summoned"
				rat.ai_real = "dumb_talented_simple"
				rat.summoner = who
				rat.summon_time = 10

				local necroSetupSummon = getfenv(who:getTalentFromId(who.T_CREATE_MINIONS).action).necroSetupSummon
				necroSetupSummon(who, rat, x, y, nil, true, true)

				game:playSoundNear(who, "talents/spell_generic2")
			end
			return {id=true, used=true}
		end },
	}

	local zone = mod.class.Zone.new(id, {
		name = "Forsaken Crypt",
		level_range = {game.zone:level_adjust_level(game.level, game.zone, "actor"), game.zone:level_adjust_level(game.level, game.zone, "actor")},
		level_scheme = "player",
		max_level = 1,
		actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
		width = 50, height = 50,
		ambient_music = "Dark Secrets.ogg",
		reload_lists = false,
		persistent = "zone",
		min_material_level = game.zone.min_material_level,
		max_material_level = game.zone.max_material_level,
		generator =  {
			map = {
				class = "engine.generator.map.Roomer",
				nb_rooms = 10,
				rooms = {"random_room", {"money_vault",5}},
				lite_room_chance = 50,
				['.'] = "FLOOR",
				['#'] = "WALL",
				up = "UP_WILDERNESS",
				down = "DOWN",
				door = "DOOR",
			},
			actor = {
				class = "mod.class.generator.actor.Random",
				nb_npc = {35, 45},
				guardian = "RATLICH",
			},
			object = {
				class = "engine.generator.object.Random",
				nb_object = {6, 9},
			},
			trap = {
				class = "engine.generator.trap.Random",
				nb_trap = {6, 9},
			},
		},
		npc_list = npcs,
		grid_list = terrains,
		object_list = objects,
		trap_list = mod.class.Trap:loadList("/data/general/traps/natural_forest.lua"),
	})
	return zone
end

local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
g.name = "forsaken crypt"
g.display='>' g.color_r=0 g.color_g=0 g.color_b=255 g.notice = true
g.change_level=1 g.change_zone=id g.glow=true
g.add_displays = g.add_displays or {}
g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/crystal_ladder_down.png", z=5}
g.nice_tiler = nil
g:initGlow()
g.real_change = changer
g.change_level_check = function(self)
	game:changeLevel(1, self.real_change(self.change_zone), {temporary_zone_shift=true})
	require("engine.ui.Dialog"):simplePopup("Forsaken Crypt", "You hear squeaks and the sounds of clicking bone echo around you...")
	self.change_level_check = nil
	self.real_change = nil
	return true
end
game.zone:addEntity(game.level, g, "terrain", x, y)

return true
