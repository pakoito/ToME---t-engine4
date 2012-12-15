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

newChat{ id="welcome",
	action = function(npc, player) player:attr("invulnerable", 1) end,
	text = [[#LIGHT_GREEN#*A tall man, glowing like a star, appears out of nowhere.*#WHITE#
You destroyed *it* both? I am sorry for my harsh tone when we first met, but repairing time threads is stressful.
I cannot stay. I still have much to do. But take this-- it should help you.
#LIGHT_GREEN#*He disappears again before you can even reply. A rift opens, to Maj'Eyal... you hope.*#WHITE#]],
	answers = {
		{"Ok...", action = function(npc, player)
			player:attr("invulnerable", -1)
			local o = game.zone:makeEntityByName(game.level, "object", "RUNE_RIFT")
			if o then
				o:identify(true)
				game.zone:addEntity(game.level, o, "object")
				player:addObject(player.INVEN_INVEN, o)
				game.log("The temporal warden gives you: %s.", o:getName{do_color=true})
			end

			game:setAllowedBuild("chronomancer")
			game:setAllowedBuild("chronomancer_temporal_warden", true)

			local g = game.zone:makeEntityByName(game.level, "terrain", "RIFT")
			g.change_level = 3
			g.change_zone = "daikara"
			local oe = game.level.map(player.x, player.y, engine.Map.TERRAIN)
			if oe:attr("temporary") and oe.old_feat then 
				oe.old_feat = g
			else
				game.zone:addEntity(game.level, g, "terrain", player.x, player.y)
			end
		end},
	}
}

return "welcome"
