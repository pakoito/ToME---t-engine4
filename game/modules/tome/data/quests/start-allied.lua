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

-- Quest for Trollmire & Amon Sul
name = "Of trolls and damp caves"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Explore the caves below the ruins of Kor'Pul and the Trollmire in search of treasure and glory!\n"
	if self:isCompleted("trollmire") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have explored the Trollmire and vanquished the Prox the Troll.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* You must explore the Trollmire and find out what lurks there and what treasures are to be gained!#WHITE#"
	end
	if self:isCompleted("kor-pul") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have explored the ruins of Kor'Pul and vanquished the Shade.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* You must explore the ruins of Kor'Pul and find out what lurks there and what treasures are to be gained!#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("kor-pul") and self:isCompleted("trollmire") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
			who:grantQuest("starter-zones")
		end
	end
end
