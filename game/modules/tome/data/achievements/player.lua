-- ToME - Tales of Maj'Eyal
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

newAchievement{
	name = "Unstoppable",
	desc = [[Has returned from the dead.]],
}

newAchievement{
	name = "Utterly Destroyed", id = "EIDOLON_DEATH",
	desc = [[Died on the Eidolon Plane.]],
}

newAchievement{
	name = "Emancipation", id = "EMANCIPATION",
	desc = [[Have the golem kill a boss while its master is already dead.]],
	mode = "player",
	can_gain = function(self, who, target)
		local p = game.party:findMember{main=true}
		if p.dead and p.descriptor.subclass == "Alchemist" then return true end
	end,
	on_gain = function(_, src, personal)
--		game:setAllowedBuild("construct")
--		game:setAllowedBuild("construct_runic_golem", true)
	end,
}
