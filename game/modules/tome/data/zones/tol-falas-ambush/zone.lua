-- ToME - Tales of Middle-Earth
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
	name = "Ambush!",
	level_range = {20, 50},
	level_scheme = "player",
	max_level = 1,
	actor_adjust_level = function(zone, level, e) return zone.base_level + 20 end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
--	persistant = true,
	ambiant_music = "last",
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "zones/tol-falas-ambush",
		},
		actor = {
			class = "engine.generator.actor.Random",
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

	on_enter = function(lev, old_lev, newzone)
		if newzone then
			game.logPlayer(game.player, "#VIOLET#As you come out of Tol Falas you encounter a band of orcs!")
			game.player:setQuestStatus("staff-absorption", engine.Quest.COMPLETED, "ambush")

			-- Next tiem the player dies (and he WILL die) he wont really die
			game.player.die = function(self)
				self.dead = false
				self.die = nil
				self.life = 1
				for _, e in pairs(game.level.entities) do
					if e ~= self then
						game.level:removeEntity(e)
						e.dead = true
					end
				end

				local o, item, inven_id = game.player:findInAllInventories("Staff of Absorption")
				game.player:removeObject(inven_id, item, true)
				o:removed()

				game.logPlayer(self, "#VIOLET#You wake up after a few hours, surprised to be alive, but the staff is gone!")
				game.logPlayer(self, "#VIOLET#Go at once to Minas Tirith to report those events!")

				local exit = game.level.map(10, 6, game.level.map.TERRAIN)
				exit.change_level = 1
				exit.change_zone = "wilderness"

				self:setQuestStatus("staff-absorption", engine.Quest.COMPLETED, "ambush-finish")
			end

			local Chat = require("engine.Chat")
			local chat = Chat.new("tol-falas-ambush", {name="Ukruk the Fierce"}, game.player)
			chat:invoke()
		end
	end,
}
