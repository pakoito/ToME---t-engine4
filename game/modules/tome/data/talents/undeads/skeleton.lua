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

newTalent{
	name = "Skeleton",
	type = {"undead/skeleton", 1},
	mode = "passive",
	require = undeads_req1,
	points = 5,
	on_learn = function(self, t)
		self:incStat(self.STAT_STR, 2)
		self:incStat(self.STAT_DEX, 2)
	end,
	on_unlearn = function(self, t)
		self:incStat(self.STAT_STR, -2)
		self:incStat(self.STAT_DEX, -2)
	end,
	info = function(self, t)
		return ([[Improves your skeletal condition, increasing strength and dexterity by %d.]]):format(2 * self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Sharp Bones",
	type = {"undead/skeleton", 2},
	require = undeads_req2,
	points = 5,
	cooldown = 15,
	tactical = {
		ATTACK = 10,
	},
	range = 1,
	action = function(self, t)
		local x, y = self.x, self.y
		if game.level.map(x, y, game.level.map.TRAP) then
			game.logPlayer(self, "There is already a trap here!")
			return
		end

		local dam = (10 + self:getStr(20)) * self:getTalentLevel(t)

		local e = require("mod.class.Trap").new{
			type = "physical", subtype="sharp", id_by_type=true, unided_name = "trap", identified=true,
			name = "sharp bones",
			display = '^', color=colors.ANTIQUE_WHITE,
			triggered = function(self, x, y, who)
				self:project({type="hit",x=x,y=y}, x, y, engine.DamageType.BLEED, dam)
				return true, true
			end,
			summoner_gain_exp = true,
			summoner = self,
		}
		game.zone:addEntity(game.level, e, "trap", x, y)

		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		return ([[Lay down some sharpened bones to make a simple trap that will cause anyone stepping on it to bleed for %d damage.]]):
		format(damDesc(self, DamageType.PHYSICAL, (10 + self:getStr(20)) * self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Bone Armour",
	type = {"undead/skeleton", 3},
	require = undeads_req3,
	points = 5,
	cooldown = 30,
	tactical = {
		DEFEND = 20,
	},
	action = function(self, t)
		self:setEffect(self.EFF_DAMAGE_SHIELD, 10, {power=(8 + self:getDex(20)) * self:getTalentLevel(t)})
		return true
	end,
	info = function(self, t)
		return ([[Creates a shield of bones absorbing %d damage. Lasts for 10 turns.
		The damage absorbed increases with dexterity.]]):
		format((5 + self:getDex(20)) * self:getTalentLevel(t))
	end,
}

newTalent{ short_name = "SKELETON_REASSEMBLE",
	name = "Re-assemble",
	type = {"undead/skeleton",4},
	require = undeads_req4,
	points = 5,
	cooldown = 45,
	tactical = {
		DEFEND = 10,
	},
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 5 then
			self:attr("self_resurrect", 1)
		end
	end,
	on_unlearn = function(self, t)
		if self:getTalentLevelRaw(t) == 4 then
			self:attr("self_resurrect", -1)
		end
	end,
	action = function(self, t)
		self:heal(self:getTalentLevel(t) * self.level / 2, self)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[Re-position some of your bones, healing yourself for %d.
		At level 5 you will gain the ability to completely re-assemble your body should it be destroyed (can only be used once)]]):
		format(self:getTalentLevel(t) * self.level / 2)
	end,
}
