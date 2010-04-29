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

newEntity{
	name = "Novice mage",
	level_range = {1, 10},
	rarity = 4,
	coords = {{ x=23, y=10, likelymap={
		[[    11111111   ]],
		[[ 1111122222211 ]],
		[[111111222222111]],
		[[111111222222211]],
		[[111111232222211]],
		[[111111222222211]],
		[[111111222222111]],
		[[111111222222111]],
		[[111111111111111]],
		[[ 1111111111111 ]],
		[[   111111111   ]],
	}}},
	on_encounter = function(self, who)

	end,
}
