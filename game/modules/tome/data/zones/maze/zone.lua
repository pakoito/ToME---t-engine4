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

return {
	name = "The Maze",
	level_range = {7, 16},
	level_scheme = "player",
	max_level = 7,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 40, height = 40,
--	all_remembered = true,
--	all_lited = true,
	persistent = "zone",
	ambient_music = "The Ancients.ogg",
	min_material_level = function() return game.state:isAdvanced() and 2 or 1 end,
	max_material_level = function() return game.state:isAdvanced() and 4 or 3 end,
	generator =  {
		map = {
			class = "engine.generator.map.Maze",
			up = "UP",
			down = "DOWN",
			wall = "OLD_WALL",
			floor = "OLD_FLOOR",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {20, 30},
			guardian = "MINOTAUR_MAZE",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {4, 6},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {9, 15},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "UP_WILDERNESS",
			}, },
		},
		[7] = {
			generator = { map = {
				force_last_stair = true,
				down = "QUICK_EXIT",
			}, },
		},
	},

	post_process = function(level)
		-- Place a lore note on each level
		game:placeRandomLoreObject("NOTE"..level.level)

		local p = game.party:findMember{main=true}
		if level.level == 5 and p:knowTalent(p.T_TRAP_MASTERY) then
			local l = game.zone:makeEntityByName(level, "object", "NOTE_LEARN_TRAP")
			if not l then return end
			for i = -1, 1 do for j = -1, 1 do
				local x, y = level.default_down.x + i, level.default_down.y + j
				if game.level.map:isBound(x, y) and (i ~= 0 or j ~= 0) and not game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "block_move") then
					game.zone:addEntity(level, l, "object", x, y)
					return
				end
			end end
		end
	end,
}
