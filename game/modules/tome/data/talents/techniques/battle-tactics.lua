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
	name = "Greater Weapon Focus",
	type = {"technique/battle-tactics", 1},
	require = techs_req_high1,
	points = 5,
	cooldown = 20,
	stamina = 25,
	no_energy = true,
	tactical = { ATTACK = 3 },
	action = function(self, t)
		self:setEffect(self.EFF_GREATER_WEAPON_FOCUS, math.floor(4 + self:getTalentLevel(t) * 1.3), {chance=self:combatTalentStatDamage(t, "dex", 10, 90)})
		return true
	end,
	info = function(self, t)
		return ([[Concentrate on your blows, each strike has %d%% chance to deal another similar blow for %d turns.
		This works for all blows, even ones from other talents and shield bashes.
		The chance increases with your Dexterity.]]):format(self:combatTalentStatDamage(t, "dex", 10, 90), math.floor(4 + self:getTalentLevel(t) * 1.3))
	end,
}

newTalent{
	name = "Step Up",
	type = {"technique/battle-tactics", 2},
	require = techs_req_high2,
	mode = "passive",
	points = 5,
	info = function(self, t)
		return ([[After killing a foe you have %d%% chances to gain a 1000%% movement speed bonus for 1 game turns.
		The bonus disappears as soon as any action other than moving is done.
		Note: since you will be moving very fast, game turns will pass very slowly.]]):format(self:getTalentLevelRaw(t) * 20)
	end,
}

newTalent{
	name = "Bleeding Edge",
	type = {"technique/battle-tactics", 3},
	require = techs_req_high3,
	points = 5,
	cooldown = 12,
	stamina = 24,
	requires_target = true,
	tactical = { ATTACK = { weapon = 1, cut = 1 }, DISABLE = 2 },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 1, 1.7), true)
		if hit then
			if target:canBe("cut") then
				local sw = self:getInven("MAINHAND")
				if sw then
					sw = sw[1] and sw[1].combat
				end
				sw = sw or self.combat
				local dam = self:combatDamage(sw)
				local damrange = self:combatDamageRange(sw)
				dam = rng.range(dam, dam * damrange)
				dam = dam * self:combatTalentWeaponDamage(t, 2, 3.2)

				target:setEffect(target.EFF_DEEP_WOUND, 7, {src=self, heal_factor=self:getTalentLevel(t) * 10, power=dam / 7, apply_power=self:combatAttack()})
			end
		end
		return true
	end,
	info = function(self, t)
		return ([[Lashes at the target, doing %d%% weapon damage.
		If the attack hits the target will bleed for %d%% weapon damage over 7 turns and all healing will be reduced by %d%%.]]):
		format(100 * self:combatTalentWeaponDamage(t, 1, 1.7), 100 * self:combatTalentWeaponDamage(t, 2, 3.2), self:getTalentLevel(t) * 10)
	end,
}

newTalent{
	name = "True Grit",
	type = {"technique/battle-tactics", 4},
	require = techs_req_high4,
	points = 5,
	mode = "sustained",
	cooldown = 30,
	sustain_stamina = 70,
	tactical = { BUFF = 2 },
	do_turn = function(self, t)
		local p = self:isTalentActive(t.id)
		if p.resid then self:removeTemporaryValue("resists", p.resid) end
		if p.cresid then self:removeTemporaryValue("resists_cap", p.cresid) end
		local perc = (1 - (self.life / self.max_life)) * 10 * 5
		p.resid = self:addTemporaryValue("resists", {all=perc})
		p.cresid = self:addTemporaryValue("resists_cap", {all=perc/2})
	end,
	getStaminaDrain = function(self, t)
		return -16 + 2 * self:getTalentLevelRaw(t)
	end,
	activate = function(self, t)
		return {
			stamina = self:addTemporaryValue("stamina_regen", t.getStaminaDrain(self, t))
		}
	end,
	deactivate = function(self, t, p)
		if p.resid then self:removeTemporaryValue("resists", p.resid) end
		if p.cresid then self:removeTemporaryValue("resists_cap", p.cresid) end
		self:removeTemporaryValue("stamina_regen", p.stamina)
		return true
	end,
	info = function(self, t)
		local drain = t.getStaminaDrain(self, t)
		return ([[Take a defensive stance to resist the onslaught of your foes.
		For each 10%% of your total life you lack, you gain 5%% global damage resistance and global damage resistance cap.
		This consumes stamina rapidly(%d stamina/turn).]]):
		format(drain)
	end,
}

