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
	name = "Pyromancer",
	desc = [[Unlocked Archmage class and did over one million fire damage (with any item/talent/class).]],
	show = "full",
	mode = "world",
	can_gain = function(self, who, dam)
		self.nb = (self.nb or 0) + dam
		return self.nb > 1000000 and profile.mod.allow_build.mage
	end,
	track = function(self) return tstring{tostring(math.floor(self.nb or 0))," / 1000000"} end,
	on_gain = function(_, src, personal)
		game:setAllowedBuild("mage_pyromancer", true)
		local p = game.party:findMember{main=true}
		if p.descriptor.subclass == "Archmage"  then
			if p:knowTalentType("spell/wildfire") == nil then
				p:learnTalentType("spell/wildfire", false)
				p:setTalentTypeMastery("spell/wildfire", 1.3)
			end
		end
	end,
}
newAchievement{
	name = "Cryomancer",
	desc = [[Unlocked Archmage class and did over one million cold damage (with any item/talent/class).]],
	show = "full",
	mode = "world",
	can_gain = function(self, who, dam)
		self.nb = (self.nb or 0) + dam
		return self.nb > 1000000 and profile.mod.allow_build.mage
	end,
	track = function(self) return tstring{tostring(math.floor(self.nb or 0))," / 1000000"} end,
	on_gain = function(_, src, personal)
		game:setAllowedBuild("mage_cryomancer", true)
		local p = game.party:findMember{main=true}
		if p.descriptor.subclass == "Archmage"  then
			if p:knowTalentType("spell/ice") == nil then
				p:learnTalentType("spell/ice", false)
				p:setTalentTypeMastery("spell/ice", 1.3)
			end
		end
	end,
}
newAchievement{
	name = "Lichform",
	desc = [[Achieved your wild dreams of power and eternal life: you turned into a Lich!]],
	show = "name",
}
