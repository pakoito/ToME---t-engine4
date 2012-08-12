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
	name = "Dreams",
	display_name = function(x, y)
		if game.level.level == 1 then return "Dream of vulnerability" end
		return "Dream ???"
	end,
	variable_zone_name = true,
	level_range = {25, 35},
	level_scheme = "player",
	max_level = 1,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	ambient_music = "Woods of Eremae.ogg",
	min_material_level = 3,
	max_material_level = 3,
	generator =  {
	},
	levels =
	{
		[1] = {
			motionblur = 2,
			width = 48, height = 48,
			color_shown = {0.9, 0.7, 0.4, 1},
			color_obscure = {0.9*0.6, 0.7*0.6, 0.4*0.6, 0.6},
			generator = {
				map = {
					class = "engine.generator.map.Maze",
					up = "FLOOR",
					down = "DREAM_END",
					wall = "JUNGLE_TREE",
					floor = "JUNGLE_GRASS",
					widen_w = 3, widen_h = 3,
					force_last_stair = true,
				},
				actor = {
					class = "mod.class.generator.actor.Random",
					nb_npc = {20, 20},
					filter = {type="feline"},
					randelite = 0,
				},
				object = {
					class = "engine.generator.object.Random",
					nb_object = {0, 0},
				},
				trap = {
					class = "engine.generator.trap.Random",
					nb_trap = {0, 0},
				},
			}
		},
	},

	on_enter = function(lev, old_lev)
		-- Dream of vulnerability
		if lev == 1 then
			local f = require("mod.class.Player").new{
				name = "frail mouse", image = "npc/vermin_rodent_giant_white_mouse.png",
				type = "vermin", subtype = "rodent",
				display = "r", color=colors.WHITE,
				body = { INVEN = 10 },
				infravision = 10,
				sound_moam = {"creatures/rats/rat_hurt_%d", 1, 2},
				sound_die = {"creatures/rats/rat_die_%d", 1, 2},
				sound_random = {"creatures/rats/rat_%d", 1, 3},
				stats = { str=8, dex=15, mag=3, con=5, cun=15, },
				combat = {sound="creatures/rats/rat_attack", dam=5, atk=0, apr=10 },
				combat_armor = 1, combat_def = 1,
				rank = 1,
				movement_speed = 1.4,
				size_category = 1,
				level_range = {1, 1}, exp_worth = 1,
				max_life = 10,
				resolvers.talents{
					T_STEALTH = 12,
					T_SHADOWSTRIKE = 5,
					T_HIDE_IN_PLAIN_SIGHT = 15,
					T_EVASION = 30,
					T_NIMBLE_MOVEMENTS = 3,
					T_PIERCING_SIGHT = 30,
				},
				on_die = function(self)
					game.level:addEntity(self.summoner)
					game:onTickEnd(function()
						game:changeLevel(1, "noxious-caldera")
						if self.success then
							world:gainAchievement("ALL_DREAMS", self.summoner, "mice")
						else
							game.player:takeHit(game.player.life * 2 / 3, game.player)
						end
					end)
				end,
			}
			f:resolve()
			f:resolve(nil, true)
			f.summoner = game.player

			local oldp = game.player
			game.party:addMember(f, {temporary_level=1, control="full"})
			f.x = game.player.x
			f.y = game.player.y
			game.party:setPlayer(f, true)
			game.level:addEntity(f)
			game.level.map:remove(f.x, f.y, engine.Map.ACTOR)
			game.level:removeEntity(oldp)
			f:move(f.x, f.y, true)
			f.energy.value = 1000
			game.paused = true
			game.player:updateMainShader()

			require("engine.ui.Dialog"):simpleLongPopup("Deep slumber...", [[The noxious fumes have invaded all your body, you suddently fall in a deep slumber...
... you feel weak ...
... you feel unimportant ...
... you feel like ... food ...
You feel like running away!]], 600)
		end
	end,
}
