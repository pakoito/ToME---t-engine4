-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

-- Main quest: the Staff of Absorption
name = "A mysterious staff"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Deep in the tower of Tol Falas you fought and destroyed the Master, a powerful vampire."
	if self:isCompleted("ambush") then
		desc[#desc+1] = "On your way out of Tol Falas you were ambushed by a band of orcs."
		desc[#desc+1] = "They asked about the staff."
	elseif self:isCompleted("ambush-finished") then
		desc[#desc+1] = "On your way out of Tol Falas you were ambushed by a band of orcs and left for dead."
		desc[#desc+1] = "They asked about the staff and stole it from you."
		desc[#desc+1] = "#LIGHT_GREEN#Go at once to Minas Tirith to report those events!"
	else
		desc[#desc+1] = "In its remains you found a strange staff, it radiates power and danger and you dare not use it yourself."
		desc[#desc+1] = "You should bring it to the elders of Minas Tirith in the south east."
	end
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	game.logPlayer(who, "#00FFFF#You can feel the power of this staff just by carrying it. This is both ancient and dangerous.")
	game.logPlayer(who, "#00FFFF#It should be shown to the wise elders in Minas Tirith!")
end
