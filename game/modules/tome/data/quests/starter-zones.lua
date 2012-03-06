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

-- Quest for Maze, Sandworm & Old Forest
name = "Into the darkness"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "It is time to explore some new places -- dark, forgotten and dangerous ones."
	desc[#desc+1] = "The Old Forest is just south-east of the town of Derth."
	desc[#desc+1] = "The Maze is west of Derth."
	desc[#desc+1] = "The Sandworm Lair is to the far west of Derth, near the sea."
	desc[#desc+1] = "The Daikara is on the eastern borders of the Thaloren forest."
	if self:isCompleted("old-forest") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have explored the Old Forest and vanquished Wrathroot.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* You must explore the Old Forest and find out what lurks there and what treasures are to be gained!#WHITE#"
	end
	if self:isCompleted("maze") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have explored the Maze and vanquished the Minotaur.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* You must explore the Maze and find out what lurks there and what treasures are to be gained!#WHITE#"
	end
	if self:isCompleted("sandworm-lair") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have explored the Sandworm Lair and vanquished their Queen.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* You must explore the Sandworm Lair and find out what lurks there and what treasures are to be gained!#WHITE#"
	end
	if self:isCompleted("daikara") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have explored the Daikara and vanquished the Dragon.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* You must explore the Daikara and find out what lurks there and what treasures are to be gained!#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("old-forest") and self:isCompleted("maze") and self:isCompleted("sandworm-lair") and self:isCompleted("daikara") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
			who:grantQuest("dreadfell")
		end
	end
end
