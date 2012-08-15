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

return {
	name = "Derth",
	level_range = {1, 15},
	level_scheme = "player",
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	update_base_level_on_enter = true,
	max_level = 1,
	width = 196, height = 80,
	decay = {300, 800, only={object=true}, no_respawn=true},
	persistent = "zone",
	all_remembered = true,
	all_lited = true,
	day_night = true,
	ambient_music = {"Virtue lost.ogg", "weather/town_small_base.ogg"},

	max_material_level = 2,

	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "towns/derth",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {10, 10},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
	},

	post_process = function(level)
		game.state:makeAmbientSounds(level, {
			town_small={ chance=250, volume_mod=1, pitch=1, random_pos={rad=10}, files={"ambient/town/town_small1","ambient/town/town_small2"}},
		})
	end,

	on_enter = function(_, _, newzone)
		if game.player.level <= 10 and not game.player:hasQuest("arena-unlock") then
			local spot = game.level:pickSpot{type="npc", subtype="arena"}
			local m = game.zone:makeEntityByName(game.level, "actor", "ARENA_AGENT")
			if spot and m then
				game.zone:addEntity(game.level, m, "actor", spot.x, spot.y)
			end
		end
		if game.player:hasQuest("lightning-overload") then
			game.player:hasQuest("lightning-overload"):enter_derth()
		end
	end,


	foreground = function(level, x, y, nb_keyframes)
		-- Make cosmetic eagles fly over derth
		if nb_keyframes > 10 then return end
		local Map = require "engine.Map"
		if not level.eagle then
			if nb_keyframes > 0 and rng.chance(800 / nb_keyframes) then
				local dir = -math.rad(rng.float(310, 340))
				local dirv = math.rad(rng.float(-0.1, 0.1))
				local y = rng.range(0, level.map.w / 2 * Map.tile_w)
				level.eagle = require("engine.Particles").new("eagle", 1, {x=0, y=y, dir=dir, dirv=dirv})
				level.eagle_s = require("engine.Particles").new("eagle", 1, {x=0, y=y, height=Map.viewport.height, shadow=true, dir=dir, dirv=dirv})
			end
		else
			local dx, dy = level.map:getScreenUpperCorner() -- Display at map border, always, so it scrolls with the map
			if level.eagle then level.eagle.ps:toScreen(dx, dy, true, 1) end
			if level.eagle_s then level.eagle_s.ps:toScreen(dx + 100, dy + 120, true, 1) end
			if nb_keyframes > 0 and rng.chance(1000 / nb_keyframes) then game:playSound("actions/eagle_scream") end
			if level.eagle and not level.eagle.ps:isAlive() then level.eagle = nil end
			if level.eagle_s and not level.eagle_s.ps:isAlive() then level.eagle_s = nil end
		end
	end,
}
