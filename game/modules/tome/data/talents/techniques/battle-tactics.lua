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
	name = "Greater Weapon Focus",
	type = {"technique/battle-tactics", 1},
	require = techs_req_high1,
	points = 5,
	cooldown = 20,
	stamina = 25,
	no_energy = true,
	tactical = { ATTACK = 3 },
	getdur = function(self,t) return math.floor(self:combatTalentLimit(t, 20, 5.3, 10.5)) end, -- Limit to <20
	getchance = function(self,t) return self:combatLimit(self:combatTalentStatDamage(t, "dex", 10, 90),100, 6.8, 6.8, 61, 61) end, -- Limit < 100%
	action = function(self, t)
		self:setEffect(self.EFF_GREATER_WEAPON_FOCUS, t.getdur(self,t), {chance=t.getchance(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Concentrate on your blows; each strike has a %d%% chance to deal another, similar, blow for %d turns.
		This works for all blows, even ones from other talents and from shield bashes.
		The chance increases with your Dexterity.]]):format(t.getchance(self, t), t.getdur(self, t))
	end,
}

newTalent{ -- Doesn't scale past level 5, could use some bonus for higher talent levels
	name = "Step Up",
	type = {"technique/battle-tactics", 2},
	require = techs_req_high2,
	mode = "passive",
	points = 5,
	info = function(self, t)
		return ([[After killing a foe, you have a %d%% chance to gain a 1000%% movement speed bonus for 1 game turn.
		The bonus disappears as soon as any action other than moving is done.
		Note: since you will be moving very fast, game turns will pass very slowly.]]):format(math.min(100, self:getTalentLevelRaw(t) * 20))
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
	healloss = function(self,t) return self:combatTalentLimit(t, 100, 17, 50) end, -- Limit to < 100%
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

				target:setEffect(target.EFF_DEEP_WOUND, 7, {src=self, heal_factor=t.healloss(self, t), power=dam / 7, apply_power=self:combatAttack()})
			end
		end
		return true
	end,
	info = function(self, t)
		local heal = t.healloss(self,t)
		return ([[Lashes at the target, doing %d%% weapon damage.
		If the attack hits, the target will bleed for %d%% weapon damage over 7 turns, and all healing will be reduced by %d%%.]]):
		format(100 * self:combatTalentWeaponDamage(t, 1, 1.7), 100 * self:combatTalentWeaponDamage(t, 2, 3.2), heal)
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
		return self:combatTalentLimit(t, 0, -14, -6 ) -- Limit <0 (no stamina regen)
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
		For each 10%% of your health below maximum you are currently at, you gain 5%% all damage resistance and 2.5%% all damage resistance cap.
		This consumes stamina rapidly (%d stamina/turn).]]):
		format(drain)
	end,
}

