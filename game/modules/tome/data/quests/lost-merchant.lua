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

name = "Trapped!"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You heard a plea for help and decided to investigate..."
	desc[#desc+1] = "Only to find yourself trapped inside an unknown tunnel complex."
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub and sub == "evil" then
		game.level.map(who.x, who.y, game.level.map.TERRAIN, game.zone.grid_list.UP_WILDERNESS)
		game.logPlayer(who, "A stairway out appears at your feet. The Lord says: 'And remember, you are MINE. I will call you.'")
	end

	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
	end
end

leave_zone = function(self, who)
	if self:isStatus(self.COMPLETED, "evil") then return end
	local merchant_alive = false
	for uid, e in pairs(game.level.entities) do
		if e.is_merchant and not e.dead then
			merchant_alive = true
			break
		end
	end
	if merchant_alive then
		game.logPlayer(who, "#LIGHT_BLUE#The merchant thanks you for saving his life. He gives you 8 gold and asks you to meet him again in Last Hope.")
		who:incMoney(8)
		who.changed = true
		who:setQuestStatus(self.id, engine.Quest.COMPLETED, "saved")
		world:gainAchievement("LOST_MERCHANT_RESCUE", game.player)
	end
	who:setQuestStatus(self.id, engine.Quest.COMPLETED)
end

is_assassin_alive = function(self)
	local assassin_alive = false
	for uid, e in pairs(game.level.entities) do
		if e.is_assassin_lord and not e.dead then
			assassin_alive = true
			break
		end
	end
	return assassin_alive
end
