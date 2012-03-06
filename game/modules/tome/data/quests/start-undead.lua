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

name = "The rotting stench of the dead"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You have been resurrected as an undead by some dark powers."
	desc[#desc+1] = "However, the ritual failed in some way and you retain your own mind. You need to get out of this dark place and try to carve a place for yourself in the world."
	if self:isCompleted("black-cloak") then
		desc[#desc+1] = "You have found a very special cloak that will help you walk among the living without trouble."
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		who:grantQuest("starter-zones")
	end
end

on_grant = function(self, who)
	local npc
	for uid, e in pairs(game.level.entities) do
		if e.define_as and e.define_as == "NECROMANCER" then npc = e break end
	end

	local Chat = require"engine.Chat"
	local chat = Chat.new("undead-start-game", npc, who)
	chat:invoke()
	self:setStatus(engine.Quest.COMPLETED, "talked-start")
end
