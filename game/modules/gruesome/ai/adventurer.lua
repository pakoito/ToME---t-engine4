-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

local dirs = {
	[1] = {2},
	[2] = {3},
	[3] = {6},
	[4] = {1},
	[6] = {9},
	[7] = {4},
	[8] = {7},
	[9] = {8},
}

newAI("adventurer", function(self)
	-- Creature will randomly either spin or move.  Chance of each can
	-- be varied.  Currently set based on light range, so that enemies
	-- with longer ranges are more likely to turn, whilst short-sighted
	-- enemies move around more.
	if rng.chance(self.lite) then
		self:moveDir(rng.table{1,2,3,4,6,7,8,9})
	else
		self.dir = rng.table(dirs[self.dir])
		game.level.map.changed = true
		self:useEnergy()
	end
	return true
end)
