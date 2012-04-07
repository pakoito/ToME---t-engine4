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

newAchievement{
	name = "Level 10",
	show = "full",
	desc = [[Got a character to level 10.]],
}
newAchievement{
	name = "Level 20",
	show = "full",
	desc = [[Got a character to level 20.]],
}
newAchievement{
	name = "Level 30",
	show = "full",
	desc = [[Got a character to level 30.]],
}
newAchievement{
	name = "Level 40",
	show = "full",
	desc = [[Got a character to level 40.]],
}
newAchievement{
	name = "Level 50",
	show = "full",
	desc = [[Got a character to level 50.]],
}

newAchievement{
	name = "Unstoppable",
	show = "full",
	desc = [[Has returned from the dead.]],
}

newAchievement{
	name = "Utterly Destroyed", id = "EIDOLON_DEATH",
	show = "name",
	desc = [[Died on the Eidolon Plane.]],
}

newAchievement{
	name = "Fool of a Took!", id = "HALFLING_SUICIDE",
	show = "name",
	desc = [[Killed oneself as a halfling.]],
	can_gain = function(self, who)
		if who.descriptor and who.descriptor.race == "Halfling" then return true end
	end
}

newAchievement{
	name = "Emancipation", id = "EMANCIPATION",
	image = "npc/alchemist_golem.png",
	show = "name",
	desc = [[Have the golem kill a boss while its master is already dead.]],
	mode = "player",
	can_gain = function(self, who, target)
		local p = game.party:findMember{main=true}
		if target.rank >= 3.5 and p.dead and p.descriptor.subclass == "Alchemist" and p.alchemy_golem and game.level:hasEntity(p.alchemy_golem) and not p.alchemy_golem.dead then
			return true
		end
	end,
	on_gain = function(_, src, personal)
--		game:setAllowedBuild("construct")
--		game:setAllowedBuild("construct_runic_golem", true)
	end,
}

newAchievement{
	name = "Take you with me", id = "BOSS_REVENGE",
	show = "full",
	desc = [[Kill a boss while already dead.]],
	mode = "player",
	can_gain = function(self, who, target)
		local p = game.party:findMember{main=true}
		if target.rank >= 3.5 and p.dead then
			return true
		end
	end,
}

newAchievement{
	name = "Look at me, I'm playing a roguelike!", id = "SELF_CENTERED",
	show = "name",
	desc = [[Linking yourself in the ingame chat.]],
}

newAchievement{
	name = "Fear me not!", id = "FEARSCAPE",
	show = "full",
	desc = [[Survive the Fearscape!]],
}
