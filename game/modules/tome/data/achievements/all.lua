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

-------------- Levels
newAchievement{
	name = "Level 10",
	desc = [[Got a character to level 10.]],
}
newAchievement{
	name = "Level 20",
	desc = [[Got a character to level 20.]],
}
newAchievement{
	name = "Level 30",
	desc = [[Got a character to level 30.]],
}
newAchievement{
	name = "Level 40",
	desc = [[Got a character to level 40.]],
}
newAchievement{
	name = "Level 50",
	desc = [[Got a character to level 50.]],
}

--------------- Main objectives
newAchievement{
	name = "Vampire crusher",
	desc = [[Destroyed the Master in its lair of Tol Falas.]],
}
newAchievement{
	name = "A dangerous secret",
	desc = [[Found the mysterious staff and told Minas Tirith about it.]],
}

--------------- Misc
newAchievement{
	name = "That was close",
	desc = [[Kill your target while having only 1 life left.]],
}
newAchievement{
	name = "Size matters",
	desc = [[Do over 600 damage in one attack]],
}
newAchievement{
	name = "Exterminator",
	desc = [[Killed 1000 creatures]],
	can_gain = function(who)
		who.nb_kill_creatures = (who.nb_kill_creatures or 0) + 1
		if who.nb_kill_creatures >= 1000 then return true end
	end
}
