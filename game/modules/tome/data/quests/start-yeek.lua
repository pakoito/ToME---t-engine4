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

name = "Following The Way"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You have been tasked to remove two threats to the yeeks.\n"
	desc[#desc+1] = "Protect the Way, and vanquish your foes.\n"
	if self:isCompleted("murgol") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have explored the underwater zone and vanquished Murgol.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* You must explore the underwater lair of Murgol.#WHITE#"
	end
	if self:isCompleted("ritch") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have explored the ritch tunnels and vanquished their queen.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* You must explore the ritch tunnels.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("ritch") and self:isCompleted("murgol") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
			who:grantQuest("rel-tunnel")
			game.logPlayer(game.player, "You should head to the tunnel to Maj'Eyal and explore the world. For the Way.")
		end
	end
end
