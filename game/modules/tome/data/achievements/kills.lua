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
	mode = "player",
	can_gain = function(self, who)
		self.nb = (self.nb or 0) + 1
		print(self.nb, "***")
		if self.nb >= 1000 then return true end
	end
}
newAchievement{
	name = "Pest Control",
	desc = [[Killed 1000 reproducing vermins]],
	mode = "player",
	can_gain = function(self, who, target)
		if target:knowTalent(target.T_MULTIPLY) then
			self.nb = (self.nb or 0) + 1
			if self.nb >= 1000 then return true end
		end
	end
}
newAchievement{
	name = "Reaver",
	desc = [[Killed 1000 humanoids]],
	mode = "player",
	can_gain = function(self, who, target)
		if target.type == "humanoid" then
			self.nb = (self.nb or 0) + 1
			if self.nb >= 1000 then return true end
		end
	end,
	on_gain = function(_, src, personal)
		game:setAllowedBuild("corrupter")
		game:setAllowedBuild("corrupter_reaver", true)
	end,
}
