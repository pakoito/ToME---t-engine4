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

return {
	name = "Southern Beach",
	level_range = {24, 35},
	level_scheme = "player",
	max_level = 1,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
	persistent = "zone",
	ambient_music = "Woods of Eremae.ogg",
	min_material_level = 3,
	max_material_level = 3,
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "zones/south-beach",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {0, 0},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {0, 0},
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

	on_enter = function(lev, old_lev, newzone)
		if not game.level.data.first_enter then
			game.level.data.first_enter = true
			game.player:move(7, 12, true)

			local m = game.zone:makeEntityByName(game.level, "actor", "MELINDA_BEACH", true)
			if m then
				game.zone:addEntity(game.level, m, "actor", 5, 12)
				m:setPersonalReaction(game.player, 100)
				game.party:addMember(m, {
					control="no",
					type="Girlfriend",
					title=m.name,
					temporary_level=1,
				})
				local chat = require("engine.Chat").new("melinda-beach", m, game.player)
				chat:invoke()
			end
		end
	end,

	start_yaech = function()
		game.level.data.yaech_start_in = 10
	end,

	more_spawn = function()
		local melinda = game.party:findMember{type="Girlfriend"}
		for i = 1, 20 do
			local m = game.zone:makeEntity(game.level, "actor", {type = "humanoid", subtype = "yaech"}, nil, true)
			local spot = game.level:pickSpotRemove{type="spawn", subtype="yaech"}
			local x, y
			if spot then x, y = util.findFreeGrid(spot.x, spot.y, 1, true, {[engine.Map.ACTOR]=true}) end
			if m and x and y then
				game.zone:addEntity(game.level, m, "actor", x, y)
				m:setTarget(melinda)
			end
		end
		game.level.data.blight_start_in = 30
	end,

	on_turn = function(self)
		if game.level.data.yaech_start_in then
			game.level.data.yaech_start_in = game.level.data.yaech_start_in - 1
			if game.level.data.yaech_start_in < 0 then
				game.level.data.yaech_start_in = nil
				local melinda = game.party:findMember{type="Girlfriend"}
				if melinda then melinda:doEmote("Look over there!", 120) end
				game.level.data.nb_yaech_killed = 0
				for i = 1, 12 do
					local m = game.zone:makeEntity(game.level, "actor", {type = "humanoid", subtype = "yaech"}, nil, true)
					local spot = game.level:pickSpotRemove{type="spawn", subtype="yaech"}
					if m and spot then
						game.zone:addEntity(game.level, m, "actor", spot.x, spot.y)
						m:setTarget(melinda)
						m.on_die = function() if game.level.data.nb_yaech_killed then
							game.level.data.nb_yaech_killed = game.level.data.nb_yaech_killed + 1
							if game.level.data.nb_yaech_killed >= 4 then
								local melinda = game.party:findMember{type="Girlfriend"}
								if melinda then
									game.bignews:say(120, "#DARK_GREEN#Melinda begins to glow with an eerie aura!")
									melinda.self_resurrect = 1
									melinda.resists = {}									
									game.zone.more_spawn()
								end
								game.level.data.nb_yaech_killed = nil
							end
						end end
					end
				end
			end
		end
		if game.level.data.blight_start_in then
			game.level.data.blight_start_in = game.level.data.blight_start_in - 1
			if game.level.data.blight_start_in < 0 then
				game.level.data.blight_start_in = nil
				local melinda = game.party:findMember{type="Girlfriend"}
				if melinda then
					melinda:die(melinda)
				end
			end
		end
	end,
}
