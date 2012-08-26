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

uberTalent{
	name = "Spectral Shield",
	mode = "passive",
	require = { special={desc="Block talent, have mana and a block value over 200.", fct=function(self)
		return self:knowTalent(self.T_BLOCK) and self:getTalentFromId(self.T_BLOCK).getBlockValue(self) >= 200 and self:getMaxMana() >= 70
	end} },
	on_learn = function(self, t)
		self:attr("spectral_shield", 1)
		self:attr("max_mana", -70)
	end,
	on_unlearn = function(self, t)
		self:attr("spectral_shield", -1)
		self:attr("max_mana", 70)
	end,
	info = function(self, t)
		return ([[Infusing your shield with raw magic your Block can now block any damage type
		Your maximum mana will be premanently reduced by 70 to create the effect.]])
		:format()
	end,
}

uberTalent{
	name = "Aether Permeation",
	mode = "passive",
	require = { special={desc="At least 25% arcane damage reduction and having been exposed to the void of space.", fct=function(self)
		return self:attr("planetary_orbit") and self:combatGetResist(DamageType.ARCANE) >= 25
	end} },
	on_learn = function(self, t)
		self.resists[DamageType.ARCANE] = (self.resists[DamageType.ARCANE] or 0) + 15
		self:attr("max_mana", -70)
		self.force_use_resist = DamageType.ARCANE
	end,
	on_unlearn = function(self, t)
		self.resists[DamageType.ARCANE] = (self.resists[DamageType.ARCANE] or 0) - 15
		self:attr("max_mana", 70)
		self.force_use_resist = nil
	end,
	info = function(self, t)
		return ([[Create a thin layer of aether all around you. Any attack passing through will check arcane resistance instead of the incomming damage resistance.
		Also increases your arcane resistance by 15%%.
		Your maximum mana will be premanently reduced by 70 to create the effect.]])
		:format()
	end,
}

uberTalent{
	name = "Mystical Cunning", image = "talents/vulnerability_poison.png",
	mode = "passive",
	require = { special={desc="Know either traps or poisons.", fct=function(self)
		return self:knowTalent(self.T_VILE_POISONS) or self:knowTalent(self.T_TRAP_MASTERY)
	end} },
	on_learn = function(self, t)
		self:attr("combat_spellresist", 20)
		self:learnTalent(self.T_VULNERABILITY_POISON, true, nil, {no_unlearn=true})
		self:learnTalent(self.T_GRAVITIC_TRAP, true, nil, {no_unlearn=true})
	end,
	on_unlearn = function(self, t)
		self:attr("combat_spellresist", -20)
	end,
	info = function(self, t)
		return ([[Your study of arcane forces has let you develop new traps and poisons (depending on which you know when learning this prodigy).
		You can learn:
		- Vulnerability Poison: reduces all resistances and deals arcane damage
		- Gravitic Trap: each turn all foes in a radius 5 around it are pulled in and take temporal damage
		You also permanently gain 20 spell save.]])
		:format()
	end,
}
