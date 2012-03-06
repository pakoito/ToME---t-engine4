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

name = "Echoes of the Spellblaze"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You have heard that within the scintillating caves lie strange crystals imbued with Spellblaze energies.\n"
	desc[#desc+1] = "There are also rumours of a regenade Shaloren camp to the west.\n"
	if self:isCompleted("spellblaze") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have explored the scintillating caves and destroyed the Spellblaze Crystal.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* You must explore the scintillating caves.#WHITE#"
	end
	if self:isCompleted("rhaloren") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have explored the Rhaloren camp and killed the Inquisitor.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* You must explore the renegade Shaloren camp.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("spellblaze") and self:isCompleted("rhaloren") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
			who:grantQuest("starter-zones")
		end
	end
end
