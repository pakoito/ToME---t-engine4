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

local Map = require "engine.Map"

newTalent{
	name = "Skullcracker",
	type = {"technique/thuggery", 1},
	points = 5,
	cooldown = 12,
	stamina = 20,
	tactical = { DISABLE = { confusion = 2 }, ATTACK = { PHYSICAL = 1 } },
	require = techs_req1,
	requires_target = true,
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t) / 2) end,
	getDamage = function(self, t)
		local o = self:getInven(self.INVEN_HEAD) and self:getInven(self.INVEN_HEAD)[1]

		local add = 0
		if o then
			add = 15 + o:getPriceFlags() * 0.6 * math.sqrt(o:getPowerRank() + 1) * (o:attr("metallic") and 1 or 0.5) * (o.skullcracker_mult or 1)
		end

		local totstat = self:getStat("str")
		local talented_mod = math.sqrt((self:getTalentLevel(t) + (o and o.material_level or 1)) / 10) + 1
		local power = math.max(self.combat_dam + add, 1)
		power = (math.sqrt(power / 10) - 1) * 0.8 + 1
--		print(("[COMBAT HEAD DAMAGE] power(%f) totstat(%f) talent_mod(%f)"):format(power, totstat, talented_mod))
		return self:rescaleDamage(totstat / 1.5 * power * talented_mod)
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local dam = t.getDamage(self, t)

		local _, hitted = self:attackTargetWith(target, nil, nil, nil, dam)

		if hitted then
			if target:canBe("confusion") then
				target:setEffect(target.EFF_CONFUSED, t.getDuration(self, t), {power=30 + self:getDex(70), apply_power=self:combatAttack()})
			else
				game.logSeen(target, "%s resists the headblow!", target.name:capitalize())
			end
			if target:attr("dead") then
				world:gainAchievement("HEADBANG", self, target)
			end
		end

		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[You smack your forehead against your enemy's head (or whatever sensitive part you can find), causing %0.2f physical damage. If the attack hits the target is confused for %d turns.
		Damage done increases with the quality of your headgear, your strength and your physical damage bonuses.
		Confusion power and chance increase with your Dexterity stat.]]):
		format(dam, duration)
	end,
}

newTalent{
	name = "Riot-born",
	type = {"technique/thuggery", 2},
	mode = "passive",
	points = 5,
	require = techs_req2,
	on_learn = function(self, t)
		self.stun_immune = (self.stun_immune or 0) + 0.1
		self.confusion_immune = (self.confusion_immune or 0) + 0.1
	end,
	on_unlearn = function(self, t)
		self.stun_immune = (self.stun_immune or 0) - 0.1
		self.confusion_immune = (self.confusion_immune or 0) - 0.1
	end,
	info = function(self, t)
		return ([[Your attunement to violence has given you %d%% resistance to stuns and confusion arising in battle.]]):
		format(self:getTalentLevelRaw(t) * 10)
	end,
}
newTalent{
	name = "Vicious Strikes",
	type = {"technique/thuggery", 3},
	mode = "passive",
	points = 5,
	require = techs_req3,
	on_learn = function(self, t)
		self.combat_critical_power = (self.combat_critical_power or 0) + 5
		self.combat_apr = self.combat_apr + 4
	end,
	on_unlearn = function(self, t)
		self.combat_critical_power = (self.combat_critical_power or 0) - 5
		self.combat_apr = self.combat_apr - 4
	end,
	info = function(self, t)
		return ([[You know how to hit the right places, giving +%d%% critical damage modifier and %d armour penetration.]]):
		format(self:getTalentLevelRaw(t) * 5, self:getTalentLevelRaw(t) * 4)
	end,
}

newTalent{
	name = "Total Thuggery",
	type = {"technique/thuggery", 4},
	points = 5,
	mode = "sustained",
	cooldown = 30,
	sustain_stamina = 40,
	no_energy = true,
	require = techs_req4,
	requires_target = true,
	range = 1,
	tactical = { DISABLE = 2, ATTACK = 2 },
	getCrit = function(self, t) return self:combatTalentStatDamage(t, "dex", 10, 50) / 1.5 end,
	getPen = function(self, t) return self:combatTalentStatDamage(t, "str", 10, 50) / 2 end,
	getDrain = function(self, t) return 12 - self:getTalentLevelRaw(t) end,
	activate = function(self, t)
		local ret = {
			crit = self:addTemporaryValue("combat_physcrit", t.getCrit(self, t)),
			pen = self:addTemporaryValue("resists_pen", {[DamageType.PHYSICAL] = t.getPen(self, t)}),
			drain = self:addTemporaryValue("stamina_regen_on_hit", - t.getDrain(self, t)),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_physcrit", p.crit)
		self:removeTemporaryValue("resists_pen", p.pen)
		self:removeTemporaryValue("stamina_regen_on_hit", p.drain)
		return true
	end,
	info = function(self, t)
		return ([[You go all out, trying to burn down your foes as fast as possible.
		Every hit in battle has +%d%% critical chance and +%d%% physical penetration, but each strike drains %d stamina.]]):
		format(t.getCrit(self, t), t.getPen(self, t), t.getDrain(self, t))
	end,
}

