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

local function select(id)
	if id == 1 or id == 2 then
		game:chronoRestore("see_threads_"..id, true)
	end
	if game._chronoworlds then
		game._chronoworlds.see_threads_1 = nil
		game._chronoworlds.see_threads_2 = nil
		game._chronoworlds.see_threads_3 = nil
		game._chronoworlds.see_threads_base = nil
	end

	game.logPlayer(game.player, "#LIGHT_BLUE#You select the timeline and re-arrange the universe to your liking!")
	game.level.map:particleEmitter(game.player.x, game.player.y, 1, "rewrite_universe")
	game._chronoworlds = nil
end

newChat{ id="welcome",
	text = [[You have lived ]]..turns..[[ turns in three different timelines. Which do you choose to be the real timeline?]],
	answers = {
		{"The first.", action=function(npc, player) select(1) end},
		{"The second.", action=function(npc, player) select(2) end},
		{"The third.", action=function(npc, player) select(3) end},
	}
}

return "welcome"
