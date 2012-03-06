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

name = "Serpentine Invaders"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Nagas are invading the slazish fens. The Sunwall cannot fight on two fronts; you need to stop the invaders before it is too late.\n Locate and destroy the invaders' portal."
	if self:isCompleted("slazish") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have destroyed the naga portal. The invasion is stopped.#WHITE#"

		if self:isCompleted("return") then
			desc[#desc+1] = "#LIGHT_GREEN#* You are back in Var'Eyal, the Far East as the people from the west call it.#WHITE#"
		else
			desc[#desc+1] = "#SLATE#* However, you were teleported to a distant land. You must find a way back to the Gates of Morning.#WHITE#"
		end
	else
		desc[#desc+1] = "#SLATE#* You must stop the nagas.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("return") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
--			who:grantQuest(who.celestial_race_start_quest)
		end
	end
end
