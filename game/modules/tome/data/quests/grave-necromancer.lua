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

name = "And now for a grave"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Ungrol of Last Hope asked you to look for his wife's friend Celia, who has been reported missing. She frequently visits her late husband's mausoleum, in the graveyard near Last Hope."
	if self:isCompleted("note") then
		desc[#desc+1] = "You searched for Celia in the graveyard near Last Hope, and found a note. In it, Celia reveals that she has been conducting experiments in the dark arts, in an attempt to extend her life... also, she is pregnant."
	end
	if self:isCompleted("coffins") then
		desc[#desc+1] = "You have tracked Celia to her husband's mausoleum in the graveyard near Last Hope. It seems she has taken some liberties with the corpses there."
	end
	if self:isCompleted("kill") then
		desc[#desc+1] = "You have laid Celia to rest, putting an end to her gruesome experiments."
	elseif self:isCompleted("kill-necromancer") then
		desc[#desc+1] = "You have laid Celia to rest, putting an end to her failed experiments. You have taken her heart, for your own experiments. You do not plan to fail as she did."
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
	end
end
