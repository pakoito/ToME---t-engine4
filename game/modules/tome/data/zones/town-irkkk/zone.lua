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
	name = "Irkkk",
	level_range = {1, 15},
	level_scheme = "player",
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	update_base_level_on_enter = true,
	max_level = 1,
	width = 196, height = 80,
	decay = {300, 800, only={object=true}, no_respawn=true},
	persistent = "zone",
	all_remembered = true,
	day_night = true,
	all_lited = true,
	ambient_music = {"Virtue lost.ogg", "weather/jungle_base.ogg"},

	max_material_level = 2,

	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "towns/irkkk",
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
			jungle1={ chance=250, volume_mod=0.6, pitch=0.6, random_pos={rad=10}, files={"ambient/jungle/jungle1","ambient/jungle/jungle2","ambient/jungle/jungle3"}},
			jungle2={ chance=250, volume_mod=1, pitch=1, random_pos={rad=10}, files={"ambient/jungle/jungle1","ambient/jungle/jungle2","ambient/jungle/jungle3"}},
			jungle3={ chance=250, volume_mod=1.6, pitch=1.4, random_pos={rad=10}, files={"ambient/jungle/jungle1","ambient/jungle/jungle2","ambient/jungle/jungle3"}},
		})
	end,

	foreground = function(level, x, y, nb_keyframes)
		-- Make cosmetic birds fly over
		if nb_keyframes > 10 then return end
		local Map = require "engine.Map"
		if not level.bird then
			if nb_keyframes > 0 and rng.chance(500 / nb_keyframes) then
				local dir = -math.rad(rng.float(310, 340))
				local dirv = math.rad(rng.float(-0.1, 0.1))
				local y = rng.range(0, level.map.w / 2 * Map.tile_w)
				local size = rng.range(32, 64)
				level.bird = require("engine.Particles").new("eagle", 1, {x=0, y=y, dir=dir, dirv=dirv, size=size, life=800, vel=7, image="particles_images/birds_tropical_01"})
				level.bird_s = require("engine.Particles").new("eagle", 1, {x=0, y=y, shadow=true, dir=dir, dirv=dirv, size=size, life=800, vel=7, image="particles_images/birds_tropical_shadow_01"})
			end
		else
			local dx, dy = level.map:getScreenUpperCorner() -- Display at map border, always, so it scrolls with the map
			if level.bird then level.bird.ps:toScreen(dx, dy, true, 1) end
			if level.bird_s then level.bird_s.ps:toScreen(dx + 100, dy + 120, true, 1) end
			if level.bird and not level.bird.ps:isAlive() then level.bird = nil end
			if level.bird_s and not level.bird_s.ps:isAlive() then level.bird_s = nil end
		end
	end,
}
