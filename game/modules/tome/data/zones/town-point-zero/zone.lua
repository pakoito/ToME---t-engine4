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

return {
	name = "Point Zero",
	level_range = {1, 15},
	level_scheme = "player",
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	update_base_level_on_enter = true,
	max_level = 1,
	width = 50, height = 50,
	decay = {300, 800, only={object=true}, no_respawn=true},
	persistent = "zone",
	all_remembered = true,
	all_lited = true,
	day_night = true,
	ambient_music = {"Virtue lost.ogg", "weather/town_small_base.ogg"},
	color_shown = {0.7, 0.6, 0.8, 1},
	color_obscure = {0.7*0.6, 0.6*0.6, 0.8*0.6, 0.6},
	allow_respec = "limited",

	no_level_connectivity = true,

	max_material_level = 2,
	store_levels_by_restock = { 8, 25, 40 },

	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "towns/point-zero",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {0, 0},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
	},

	post_process = function(level)
		-- Add defenders
		local spot = level:pickSpotRemove{type="pop", subtype="defender"}
		while spot do
			local npc = game.zone:makeEntityByName(level, "actor", "DEFENDER_OF_REALITY")
			game.zone:addEntity(level, npc, "actor", spot.x, spot.y)

			spot = level:pickSpotRemove{type="pop", subtype="defender"}
		end

		-- Cosmetic stuff
		local Map = require "engine.Map"
		if core.shader.allow("volumetric") then
			level.starfield_shader = require("engine.Shader").new("starfield", {size={Map.viewport.width, Map.viewport.height}})
		else
			level.background_particle = require("engine.Particles").new("starfield", 1, {width=Map.viewport.width, height=Map.viewport.height})
		end

		game.state:makeWeather(level, 6, {max_nb=12, chance=1, dir=120, speed={1.5, 5.9}, r=0.2, g=0.4, b=1, alpha={0.2, 0.4}, particle_name="weather/grey_cloud_%02d"})

		if not config.settings.tome.weather_effects then return end

		local Map = require "engine.Map"
		level.foreground_particle = require("engine.Particles").new(core.shader.allow("distort") and "temporalsnow" or "snowing", 1, {width=Map.viewport.width, height=Map.viewport.height, r=0.65, g=0.25, b=1, rv=-0.001, gv=0, bv=-0.001, factor=2, dir=math.rad(110+180)})
	end,

	on_enter = function()
		local level = game.level
		if level.added_highways then return end
		level.added_highways = true

		-- Setup zones
		for _, z in ipairs(level.custom_zones) do
			if z.type == "particle" then
				if z.reverse then z.x1, z.x2, z.y1, z.y2 = z.x2, z.x1, z.y2, z.y1 end
				level.map:particleEmitter(z.x1, z.y1, math.max(z.x2-z.x1, z.y2-z.y1) + 1, z.subtype, {
					tx = z.x2 - z.x1,
					ty = z.y2 - z.y1,
				})

				local g = game.level.map(z.x1, z.y1, engine.Map.TERRAIN):cloneFull()
				g.name = "temporal beam endpoint"
				g:removeAllMOs()
				g:altered()
				g.exit = {x=z.x2, y=z.y2}
				g.block_move = function(self, x, y, who, act)
					if not act or not who or not who.player then return false end
					local ox, oy = who.x, who.y
					game:onTickEnd(function()
						who:move(self.exit.x, self.exit.y, true)
						if config.settings.tome.smooth_move > 0 then
							who:resetMoveAnim()
							who:setMoveAnim(ox, oy, 24, 5)
						end
					end)
					return false
				end
				game.zone:addEntity(game.level, g, "terrain", z.x1, z.y1)

				local g = game.level.map(z.x2, z.y2, engine.Map.TERRAIN):cloneFull()
				g.name = "temporal beam endpoint"
				g:removeAllMOs()
				g:altered()
				g.exit = {x=z.x1, y=z.y1}
				g.block_move = function(self, x, y, who, act)
					if not act or not who or not who.player then return false end
					local ox, oy = who.x, who.y
					game:onTickEnd(function()
						who:move(self.exit.x, self.exit.y, true)
						if config.settings.tome.smooth_move > 0 then
							who:resetMoveAnim()
							who:setMoveAnim(ox, oy, 24, 5)
						end
					end)
					return false
				end
				game.zone:addEntity(game.level, g, "terrain", z.x2, z.y2)
			end
		end

	end,

	background = function(level, x, y, nb_keyframes)
		local Map = require "engine.Map"
		if level.starfield_shader and level.starfield_shader.shad then
			level.starfield_shader.shad:use(true)
			core.display.drawQuad(x, y, Map.viewport.width, Map.viewport.height, 1, 1, 1, 1)
			level.starfield_shader.shad:use(false)
		elseif level.background_particle then
			level.background_particle.ps:toScreen(x, y, true, 1)
		end
	end,

	foreground = function(level, x, y, nb_keyframes)
		if not config.settings.tome.weather_effects or not level.foreground_particle then return end
		level.foreground_particle.ps:toScreen(x, y, true, 1)
	end,

	on_turn = function()
		if game.turn % 100 ~= 0 then return end

		for i = 1, rng.range(3, 6) do
			local spot = game.level:pickSpot{type="pop", subtype="foes"}
			if spot then
				local npc = game.zone:makeEntityByName(game.level, "actor", "MONSTROUS_LOSGOROTH")
				game.zone:addEntity(game.level, npc, "actor", spot.x, spot.y)
			end
		end
	end,
}
