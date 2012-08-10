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



newTalent{
	name = "Deflect Projectiles",
	type = {"psionic/grip", 1},
	require = psi_cun_high1,
	points = 5,
	mode = "sustained",
	sustain_psi = 35,
	getEvasion = function(self, t) return 10 + self:getTalentLevel(t) * 7, self:getTalentLevel(t) >= 4 and 2 or 1 end,
	activate = function(self, t)
		local chance, spread = t.getEvasion(self, t)
		return {
			chance = self:addTemporaryValue("projectile_evasion", chance),
			spread = self:addTemporaryValue("projectile_evasion_spread", spread),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("projectile_evasion", p.chance)
		self:removeTemporaryValue("projectile_evasion_spread", p.spread)
		return true
	end,
	info = function(self, t)
		local chance, spread = t.getEvasion(self, t)
		return ([[You learn to devote a portion of your attention to mentally swatting, grabbing, or otherwise deflecting incoming projectiles.
		All projectiles targetting you have a %d%% chance to instead target a spot %d grids nearby.]]):
		format(chance, spread)
	end,

}

newTalent{
	name = "Bind",
	type = {"psionic/grip", 2},
	require = psi_cun_high2,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t)
		local c = 25
		local gem_level = getGemLevel(self)
		return math.max(c - gem_level, 0)
	end,
	psi = 10,
	tactical = { DISABLE = 2 },
	range = function(self, t)
		local r = 5
		local gem_level = getGemLevel(self)
		local mult = (1 + 0.02*gem_level*(self:getTalentLevel(self.T_REACH)))
		r = math.floor(r*mult)
		return math.min(r, 10)
	end,
	getDuration = function (self, t)
		local gem_level = getGemLevel(self)
		return self:combatStatTalentIntervalDamage(t, "combatMindpower", 3, 10, 0.2) + gem_level
	end,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=0, selffire=false, talent=t} end,
	action = function(self, t)
		local gem_level = getGemLevel(self)
		local dur = t.getDuration(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		game:playSoundNear(self, "talents/spell_generic")
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:setEffect(self.EFF_PSIONIC_BIND, dur, {power=1, apply_power=self:combatMindpower()})
		else
			return
		end
		return true
	end,
	info = function(self, t)
		local dur = t.getDuration(self, t)
		return ([[Bind the target in crushing bands of telekinetic force, immobilizing it for %d turns.
		The use of a telekinetically-wielded gem or mindstar as a focus will improve the effects of this talent considerably.]]):
		format(dur)
	end,
}

newTalent{
	name = "Implode",
	type = {"psionic/grip", 3},
	require = psi_cun_high3,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t)
		local c = 45
		local gem_level = getGemLevel(self)
		return math.max(c - 2 * gem_level, 0)
	end,
	psi = 40,
	tactical = { ATTACK = { PHYSICAL = 2 } },
	no_npc_use = true,
	range = function(self, t)
		local r = 3
		local gem_level = getGemLevel(self)
		local mult = (1 + 0.02*gem_level*(self:getTalentLevel(self.T_REACH)))
		r = math.floor(r*mult)
		return math.min(r, 10)
	end,
	getDuration = function (self, t)
		local gem_level = getGemLevel(self)
		return self:combatStatTalentIntervalDamage(t, "combatMindpower", 2, 6, 0.2)
	end,
	getDamage = function (self, t)
		local gem_level = getGemLevel(self)
		return self:combatStatTalentIntervalDamage(t, "combatMindpower", 60, 120, 0.25)*(1 + 0.1*gem_level)
	end,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=0, selffire=false, talent=t} end,
	action = function(self, t)
		local dur = t.getDuration(self, t)
		local dam = t.getDamage(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.IMPLOSION, {dur=dur, dam=dam})
--		target:crossTierEffect(target.EFF_OFFBALANCE, self:combatMindpower())

		return true
	end,
	info = function(self, t)
		local dur = t.getDuration(self, t)
		local dam = t.getDamage(self, t)
		return ([[Crush the target mercilessly with constant, bone-shattering pressure, slowing it by 50%% for %d turns and dealing %d damage each turn.
		The use of a telekinetically-wielded gem or mindstar as a focus will improve the effects of this talent considerably.]]):
		format(dur, dam)
	end,
}


newTalent{
	name = "Greater Telekinetic Grasp",
	type = {"psionic/grip", 4},
	require = psi_cun_high4,
	points = 5,
	mode = "passive",
	stat_sub = function(self, t)
		return .6 + .04 * self:getTalentLevel(t)
	end,
	on_learn = function(self, t)
		self.disarm_immune = (self.disarm_immune or 0) + .2
	end,

	on_unlearn = function(self, t)
		self.disarm_immune = (self.disarm_immune or 0) - .2
	end,
	info = function(self, t)
		local boost = 100 * t.stat_sub(self, t)
		return ([[Use finely controlled forces to augment both your flesh-and-blood grip and your telekinetic grip. This does the following:
		Increases disarm immunity by %d%%.
		Allows %d%% of willpower and cunning (instead of the usual 60%%) to be substituted for strength and dexterity for the purposes of determining damage done by telekinetically-wielded weapons.
		At talent level 5, telekinetically wielded gems and mindstars will be treated as one material level higher than they actually are.
		]]):
		format(self:getTalentLevelRaw(t)*20, boost)
	end,
}
