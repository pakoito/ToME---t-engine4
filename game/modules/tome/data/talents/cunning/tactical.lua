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

local function getStrikingStyle(self, dam)
	local dam = 0
	if self:isTalentActive(self.T_STRIKING_STANCE) then
		local t = self:getTalentFromId(self.T_STRIKING_STANCE)
		dam = t.getDamage(self, t)
	end
	return dam / 100
end

newTalent{
	name = "Tactical Expert",
	type = {"cunning/tactical", 1},
	require = cuns_req1,
	mode = "passive",
	points = 5,
	getDefense = function(self, t) return (4 + self:getCun(10)) end,
	getMaximum = function(self, t) return t.getDefense(self, t) * math.ceil(self:getTalentLevel(t)) end,
	do_tact_update = function (self, t)
		local nb_foes = 0
		local act
		for i = 1, #self.fov.actors_dist do
			act = self.fov.actors_dist[i]
			if act and game.level:hasEntity(act) and self:reactionToward(act) < 0 and self:canSee(act) and act["__sqdist"] <= 2 then nb_foes = nb_foes + 1 end
		end

		local defense = nb_foes * t.getDefense(self, t)

		if defense <= t.getMaximum(self, t) then
			defense = defense
		else
			defense = t.getMaximum(self, t)
		end

		return defense
	end,
	info = function(self, t)
		local defense = t.getDefense(self, t)
		local maximum = t.getMaximum(self, t)
		return ([[Your defense is increased by %d for every adjacent visible foe up to a maximum of +%d defense.
		The defense increase per enemy and maximum defense bonus will scale with the cunning stat.]]):format(defense, maximum)
	end,
}

newTalent{
	name = "Counter Attack",
	type = {"cunning/tactical", 2},
	require = cuns_req2,
	mode = "passive",
	points = 5,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.5, 0.9) + getStrikingStyle(self, dam) end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[When you avoid a melee blow you have a %d%% chance to get a free, automatic attack against your foe for %d%% damage.
		Unarmed fighters using it do consider it a strike for the purpose of stance damage bonuses (if have any) and will have a damage bonus.
		Armed fighters use it normaly.
		The chance of countering increases with the cunning stat.]]):format(self:getTalentLevel(t) * (5 + self:getCun(5, true)), damage)
	end,
}

newTalent{
	name = "Set Up",
	type = {"cunning/tactical", 3},
	require = cuns_req3,
	points = 5,
	random_ego = "utility",
	cooldown = 12,
	stamina = 12,
	tactical = { DISABLE = 1, DEFEND = 2 },
	getPower = function(self, t) return 5 + self:combatTalentStatDamage(t, "cun", 1, 25) end,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t)) end,
	getDefense = function(self, t) return 5 + self:combatTalentStatDamage(t, "cun", 1, 50) end,
	action = function(self, t)
		self:setEffect(self.EFF_DEFENSIVE_MANEUVER, t.getDuration(self, t), {power=t.getDefense(self, t)})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local power = t.getPower(self, t)
		local defense = t.getDefense(self, t)
		return ([[Increases defense by %d for %d turns.  When you avoid a melee blow you set the target up, increasing the chance of you landing a critical strike on them by %d%% and reducing their saving throws by %d.
		The defense increase will scale with the cunning stat.]])
		:format(defense, duration, power, power)
	end,
}

newTalent{
	name = "Exploit Weakness",
	type = {"cunning/tactical", 4},
	require = cuns_req4,
	mode = "sustained",
	points = 5,
	cooldown = 30,
	sustain_stamina = 30,
	tactical = { BUFF = 2 },
	getReductionMax = function(self, t) return 7 * self:getTalentLevel(t) end,
	do_weakness = function(self, t, target)
		target:setEffect(target.EFF_WEAKENED_DEFENSES, 3, {inc = - 5, max = - t.getReductionMax(self, t)})
	end,
	activate = function(self, t)
		return {
			dam = self:addTemporaryValue("inc_damage", {[DamageType.PHYSICAL]=-10}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("inc_damage", p.dam)
		return true
	end,
	info = function(self, t)
		local reduction = t.getReductionMax(self, t)
		return ([[Systematically find the weaknesses in your opponents physical resists at the cost of 10%% of your physical damage.  Each time you hit an opponent with a melee attack you reduce their physical resistance by 5%% up to a maximum of %d%%.
		]]):format(reduction)
	end,
}
