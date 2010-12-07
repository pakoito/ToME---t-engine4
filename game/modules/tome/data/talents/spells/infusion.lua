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

local function cancelInfusions(self)
	local chants = {self.T_ACID_INFUSION, self.T_LIGHTNING_INFUSION, self.T_FROST_INFUSION}
	for i, t in ipairs(chants) do
		if self:isTalentActive(t) then
			self:forceUseTalent(t, {ignore_energy=true})
		end
	end
end

newTalent{
	name = "Fire Infusion",
	type = {"spell/infusion", 1},
	mode = "passive",
	require = spells_req1,
	points = 5,
	getIncrease = function(self, t) return self:getTalentLevel(t) * 0.07 end,
	info = function(self, t)
		local daminc = t.getIncrease(self, t)
		return ([[When you throw your alchemist bombs you infuse them with explosive fire, increasing damage by %d%%, and setting foes ablaze.]]):
		format(100 * daminc)
	end,
}

newTalent{
	name = "Acid Infusion",
	type = {"spell/infusion", 2},
	mode = "sustained",
	require = spells_req2,
	sustain_mana = 30,
	points = 5,
	cooldown = 30,
	getIncrease = function(self, t) return self:getTalentLevel(t) * 0.05 end,
	activate = function(self, t)
		cancelInfusions(self)
		game:playSoundNear(self, "talents/arcane")
		return {
--			particle = self:addParticles(Particles.new("arcane_power", 1)),
		}
	end,
	deactivate = function(self, t, p)
--		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local daminc = t.getIncrease(self, t)
		return ([[When you throw your alchemist bombs you infuse them with explosive acid that can blind, increasing damage by %d%%.]]):
		format(100 * daminc)
	end,
}

newTalent{
	name = "Lightning Infusion",
	type = {"spell/infusion", 3},
	mode = "sustained",
	require = spells_req3,
	sustain_mana = 30,
	points = 5,
	cooldown = 30,
	getIncrease = function(self, t) return self:getTalentLevel(t) * 0.05 end,
	activate = function(self, t)
		cancelInfusions(self)
		game:playSoundNear(self, "talents/arcane")
		return {
--			particle = self:addParticles(Particles.new("arcane_power", 1)),
		}
	end,
	deactivate = function(self, t, p)
--		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local daminc = t.getIncrease(self, t)
		return ([[When you throw your alchemist bombs you infuse them with lightning that can daze, increasing damage by %d%%.]]):
		format(100 * daminc)
	end,
}

newTalent{
	name = "Frost Infusion",
	type = {"spell/infusion", 4},
	mode = "sustained",
	require = spells_req4,
	sustain_mana = 30,
	points = 5,
	cooldown = 30,
	getIncrease = function(self, t) return self:getTalentLevel(t) * 0.05 end,
	activate = function(self, t)
		cancelInfusions(self)
		game:playSoundNear(self, "talents/arcane")
		return {
--			particle = self:addParticles(Particles.new("arcane_power", 1)),
		}
	end,
	deactivate = function(self, t, p)
--		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local daminc = t.getIncrease(self, t)
		return ([[When you throw your alchemist bombs you infuse them with frost that can freeze, increasing damage by %d%%.]]):
		format(100 * daminc)
	end,
}
