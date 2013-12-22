-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
local Object = require "engine.Object"

newTalent{
	name = "Acid Infusion",
	type = {"spell/acid-alchemy", 1},
	mode = "sustained",
	require = spells_req1,
	sustain_mana = 30,
	points = 5,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getIncrease = function(self, t) return self:combatTalentScale(t, 0.05, 0.25) * 100 end,
	activate = function(self, t)
		cancelAlchemyInfusions(self)
		game:playSoundNear(self, "talents/arcane")
		local ret = {}
		self:talentTemporaryValue(ret, "inc_damage", {[DamageType.ACID] = t.getIncrease(self, t)})
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local daminc = t.getIncrease(self, t)
		return ([[When you throw your alchemist bombs, you infuse them with explosive acid that can blind.
		In addition all acid damage you do is increased by %d%%.]]):
		format(daminc)
	end,
}

newTalent{
	name = "Caustic Golem",
	type = {"spell/acid-alchemy", 2},
	require = spells_req2,
	mode = "passive",
	points = 5,
	getDuration = function(self, t) return math.floor(self:combatScale(self:combatSpellpower(0.03) * self:getTalentLevel(t), 2, 0, 10, 8)) end,
	getChance = function(self, t) return math.floor(self:combatScale(self:combatSpellpower(0.03) * self:getTalentLevel(t), 20, 0, 55, 8)) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 5, 120) end,
	applyEffect = function(self, t, golem)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		local dam = t.getDamage(self, t)
		golem:setEffect(golem.EFF_CAUSTIC_GOLEM, duration, {chance=chance, dam=dam})
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		local dam = t.getDamage(self, t)
		return ([[While you have Acid Infusion active, when your bombs hit your golem they coat it in acid for %d turns.
		While coated any melee hits has %d%% chance to trigger a small cone of acid doing %0.2f damage to all caught inside (this can only happen once per turn).
		Effects will increase with your Spellpower.]]):
		format(duration, chance, dam)
	end,
}


--lightning talent idea:
--lightning strike counterattack
--lightning speed, +bonus global speed based on lack of hp


newTalent{
	name = "",
	type = {"spell/acid-alchemy",3},
	require = spells_req3,
	info = function(self, t)
		local daminc = t.getIncrease(self, t)
		return ([[When you throw your alchemist bombs, you infuse them with explosive acid that can blind, increasing damage by %d%%.
		In addition all ACID damage you do is increased by %d%%.]]):
		format(daminc)
	end,
}

newTalent{
	name = "Body acid Ice",
	type = {"spell/acid-alchemy",4},
	require = spells_req4,
	mode = "sustained",
	cooldown = 40,
	sustain_mana = 100,
	points = 5,
	range = 6,
	tactical = { BUFF=1 },
	critResist = function(self, t) return self:combatTalentScale(t, 10, 50) end,
	getResistance = function(self, t) return self:combatTalentSpellDamage(t, 5, 45) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/ice")
		local ret = {}
		self:talentTemporaryValue(ret, "resists", {[DamageType.PHYSICAL] = t.getResistance(self, t) * 0.6})
		self:talentTemporaryValue(ret, "damage_affinity", {[DamageType.COLD] = t.getResistance(self, t)})
		self:talentTemporaryValue(ret, "ignore_direct_crits", t.critResist(self, t))
		return ret
	end,
	info = function(self, t)
		local daminc = t.getIncrease(self, t)
		return ([[When you throw your alchemist bombs, you infuse them with explosive acid that can blind, increasing damage by %d%%.
		In addition all ACID damage you do is increased by %d%%.]]):
		format(daminc)
	end,
}
