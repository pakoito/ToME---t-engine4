-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
	name = "Weapon of Light",
	type = {"celestial/combat", 1},
	mode = "sustained",
	require = divi_req1,
	points = 5,
	cooldown = 10,
	sustain_positive = 10,
	tactical = { BUFF = 2 },
	range = 10,
	getDamage = function(self, t) return 7 + self:combatSpellpower(0.092) * self:combatTalentScale(t, 1, 5) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
		}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Infuse your weapon with the power of the Sun, doing %0.2f light damage at the cost of 3 positive energy for each blow dealt.
		If you do not have enough positive energy, the sustain will have no effect.
		The damage dealt will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.LIGHT, damage))
	end,
}

newTalent{
	name = "Martyrdom",
	type = {"celestial/combat", 2},
	require = divi_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 22,
	positive = 25,
	tactical = { DISABLE = 2 },
	range = 6,
	reflectable = true,
	requires_target = true,
	getReturnDamage = function(self, t) return self:combatLimit(self:getTalentLevel(t)^.5, 100, 15, 1, 40, 2.24) end, -- Limit <100%
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		game:playSoundNear(self, "talents/spell_generic")
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:setEffect(self.EFF_MARTYRDOM, 10, {src = self, power=t.getReturnDamage(self, t), apply_power=self:combatSpellpower()})
		else
			return
		end
		return true
	end,
	info = function(self, t)
		local returndamage = t.getReturnDamage(self, t)
		return ([[Designate a target as a martyr for 10 turns. When the martyr deals damage, it also damages itself for %d%% of the damage dealt.]]):
		format(returndamage)
	end,
}

newTalent{
	name = "Wave of Power",
	type = {"celestial/combat",3},
	require = divi_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	positive = 10,
	tactical = { ATTACK = 2 },
	requires_target = true,
	range = function(self, t) return 2 + math.max(0, self:combatStatScale("str", 0.8, 8)) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 1.9) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			self:attackTarget(target, nil, t.getDamage(self, t), true)
		else
			return
		end
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[In a pure display of power, you project a melee attack, doing %d%% damage.
		The range will increase with your Strength.]]):
		format(100 * damage)
	end,
}

newTalent{
	name = "Crusade",
	type = {"celestial/combat", 4},
	require = divi_req4,
	random_ego = "attack",
	points = 5,
	cooldown = 10,
	positive = 10,
	tactical = { ATTACK = {LIGHT = 2} },
	range = 1,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.8, 1.6) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		self:attackTarget(target, DamageType.LIGHT, t.getDamage(self, t), true)
		self:attackTarget(target, DamageType.LIGHT, t.getDamage(self, t), true)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Concentrate the power of the Sun into two blows; each blow does %d%% of your weapon damage as light damage.]]):
		format(100 * damage)
	end,
}

