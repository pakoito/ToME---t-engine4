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

name = "Future Echoes"
stables = 0
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "The unhallowed morass is the name of the 'zone' surrounding Point Zero."
	desc[#desc+1] = "The temporal spiders that inhabit it are growing restless and started attacking at random. You need to investigate what is going on."
	if self:isCompleted("morass") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have explored the morass and destroyed the weaver queen, finding strange traces on it.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* You must explore the morass.#WHITE#"
	end
	if self:isCompleted("saved") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have helped defend Point Zero.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("saved") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
			world:gainAchievement("UNHALLOWED_MORASS", game.player)
			who:grantQuest(who.chronomancer_race_start_quest)
		end
	end
	if status == self.FAILED then
		who:grantQuest(who.chronomancer_race_start_quest)
	end
end

on_grant = function(self, who)
	local npc
	for uid, e in pairs(game.level.entities) do
		if e.define_as and e.define_as == "ZEMEKKYS" then npc = e break end
	end
	if not npc then return end
	local x, y = util.findFreeGrid(npc.x, npc.y, 10, true, {[engine.Map.ACTOR]=true})
	if not x or not y then return end

	who:move(x, y, true)

	local Chat = require"engine.Chat"
	local chat = Chat.new("zemekkys-start-chronomancers", npc, who)
	chat:invoke()
end
