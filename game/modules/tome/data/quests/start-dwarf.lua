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

name = "Reknor is lost!"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You were part of a group of dwarves sent to investigate the situation of the kingdom of Reknor."
	desc[#desc+1] = "When you arrived there you found nothing but orcs, well organized and very powerful."
	desc[#desc+1] = "Most of your team was killed there and now you and Norgan (the sole survivor besides you) must hurry back to the Iron Council to bring the news."
	desc[#desc+1] = "Let nothing stop you."
	if self:isCompleted("norgan-survived") then
		desc[#desc+1] = "Both Norgan and you made it home."
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		who:grantQuest("deep-bellow")
		who:grantQuest("starter-zones")
	end
end

on_grant = function(self, who)
	local x, y = util.findFreeGrid(game.player.x, game.player.y, 20, true, {[engine.Map.ACTOR]=true})
	local norgan = game.zone:makeEntityByName(game.level, "actor", "NORGAN")
	game.zone:addEntity(game.level, norgan, "actor", x, y)

	game.party:addMember(norgan, {
		control="order", type="squadmate", title="Norgan",
		orders = {leash=true, anchor=true}, -- behavior=true},
	})
end
