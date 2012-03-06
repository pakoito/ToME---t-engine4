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

name = "Hidden treasure"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You have found all the clues leading to the hidden treasure. There should be a way on the third level of the Trollmire."
	desc[#desc+1] = "It looks extremely dangerous, however - beware."
	if self:isEnded() then
		desc[#desc+1] = "You have slain Bill. His treasure is yours for the taking."
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then who:setQuestStatus(self.id, engine.Quest.DONE) end
end

on_grant = function(self)
	if game.level.level == 3 then
		self:enter_level3()
	end
end

enter_level3 = function(self)
	if game.level.hidden_way_to_bill then return end

	-- Reveal entrance to level 4
	local g = game.zone:makeEntityByName(game.level, "terrain", "GRASS_DOWN6"):clone()
	g.name = "way to the hidden trollmire treasure"
	g.desc = "Beware!"
	g.change_level_check = function()
		require("engine.ui.Dialog"):yesnoPopup("Danger...", "This way lead to the lair of a mighty troll, traces of blood are everywhere. Are you sure?", function(ret)
			if ret then game:changeLevel(4) end
		end)
		return true
	end
	local level = game.level
	local spot = level.default_down
	game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
	level.hidden_way_to_bill = true

	require("engine.ui.Dialog"):simplePopup("Hidden treasure", "The way to the treasure is to the east. But beware, death probably awaits there.")
end
