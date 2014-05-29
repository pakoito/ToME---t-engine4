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

newTalent{
	name = "Telekinetic Smash",
	type = {"psionic/psi-fighting", 1},
	require = psi_cun_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 8,
	psi = 10,
	range = 1,
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 2 } },
	duration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	action = function(self, t)
		local weapon = self:getInven("MAINHAND") and self:getInven("MAINHAND")[1]
		if type(weapon) == "boolean" then weapon = nil end
		if not weapon or self:attr("disarmed")then
			game.logPlayer(self, "You cannot do that without a weapon in your hands.")
			return nil
		end
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		self:attr("use_psi_combat", 1)
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.9, 1.5), true)
		if self:getInven(self.INVEN_PSIONIC_FOCUS) then
			for i, o in ipairs(self:getInven(self.INVEN_PSIONIC_FOCUS)) do
				if o.combat and not o.archery then
					self:attackTargetWith(target, o.combat, nil, self:combatTalentWeaponDamage(t, 0.9, 1.5))
				end
			end
		end
		if hit and target:canBe("stun") then
			target:setEffect(target.EFF_STUNNED, t.duration(self,t), {apply_power=self:combatMindpower()})
		end
		self:attr("use_psi_combat", -1)
		return true
	end,
	info = function(self, t)
		return ([[Gather your will, and brutally smash the target with your mainhand weapon and then your telekinetically wielded weapon, doing %d%% weapon damage. 
		If your mainhand weapon hits, you will also stun the target for %d turns.
		This attack uses your Willpower and Cunning instead of Strength and Dexterity to determine Accuracy and damage.
		Any active Aura damage bonusses will extend to the weapons used for this attack.]]):
		format(100 * self:combatTalentWeaponDamage(t, 0.9, 1.5), t.duration(self,t))
	end,
}

newTalent{
	name = "Augmentation",
	type = {"psionic/psi-fighting", 2},
	require = psi_cun_req2,
	points = 5,
	mode = "sustained",
	cooldown = 0,
	sustain_psi = 10,
	no_energy = true,
	tactical = { BUFF = 2 },
	getMult = function(self, t) return self:combatTalentScale(t, 0.07, 0.25) end,
	activate = function(self, t)
		local str_power = t.getMult(self, t)*self:getWil()
		local dex_power = t.getMult(self, t)*self:getCun()
		return {
			stats = self:addTemporaryValue("inc_stats", {
				[self.STAT_STR] = str_power,
				[self.STAT_DEX] = dex_power,
			}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("inc_stats", p.stats)
		return true
	end,
	info = function(self, t)
		local inc = t.getMult(self, t)
		local str_power = inc*self:getWil()
		local dex_power = inc*self:getCun()
		return ([[While active, you give your flesh and blood body a boost in the form of precisely applied mental forces. Increases Strength and Dexterity by %d%% of your Willpower and Cunning, respectively.
		Strength increased by %d
		Dexterity increased by %d]]):
		format(inc*100, str_power, dex_power)
	end,
}

newTalent{
	name = "Warding Weapon",
	type = {"psionic/psi-fighting", 3},
	require = psi_cun_req3,
	points = 5,
	cooldown = 10,
	psi = 15,
	no_energy = true,
	tactical = { BUFF = 2 },
	getWeaponDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.75, 1.1) end,
	action = function(self, t)
		self:setEffect(self.EFF_WEAPON_WARDING, 1, {})
		return true
	end,
	info = function(self, t)
		return ([[Assume a defensive mental state.
		For one turn, you will fully block the next melee attack used against you with your telekinetically-wielded weapon and then strike the attacker with it for %d%% weapon damage. 
		At talent level 3 you will also disarm the attacker for 3 turns.
		This requires both a mainhand and a telekinetically-wielded weapon.]]):
		format(100 * t.getWeaponDamage(self, t))
	end,
}

newTalent{
	name = "Impale",
	type = {"psionic/psi-fighting", 4},
	require = psi_cun_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	psi = 20,
	range = 3,
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 2 } },
	getDamage = function (self, t) return math.floor(self:combatTalentMindDamage(t, 12, 340)) end,
	getWeaponDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.5, 2.6) end,
	getShatter = function(self, t) return self:combatTalentLimit(t, 100, 10, 85) end,
	action = function(self, t)
		local weapon = self:getInven(self.INVEN_PSIONIC_FOCUS) and self:getInven(self.INVEN_PSIONIC_FOCUS)[1]
		if type(weapon) == "boolean" then weapon = nil end
		if not weapon or self:attr("disarmed")then
			game.logPlayer(self, "You cannot do that without a weapon in your telekinetic slot.")
			return nil
		end
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 3 then return nil end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, t.getWeaponDamage(self, t))
		if hit and target:canBe("cut") then
			target:setEffect(target.EFF_CUT, 4, {power=t.getDamage(self,t)/4, apply_power=self:combatMindpower()})
		end

		if hit and rng.percent(t.getShatter(self, t)) and self:getTalentLevel(t) >= 3 then
			local effs = {}

			-- Go through all shield effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.status == "beneficial" and e.subtype and e.subtype.shield then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			for i = 1, 1 do
				if #effs == 0 then break end
				local eff = rng.tableRemove(effs)

				if eff[1] == "effect" then
					game.logSeen(self, "#CRIMSON#%s shatters %s shield!", self.name:capitalize(), target.name)
					target:removeEffect(eff[2])
				end
			end
		end
		return true
	end,
	info = function(self, t)
		return ([[Focus your will into a powerful thrust of your telekinetically-wielded weapon to impale your target and then viciously rip it free.
		This deals %d%% weapon damage and then causes the victim to bleed for %0.1f Physical damage over four turns. 
		At level 3 the thrust is so powerful that it has %d%% chance to shatter a temporary damage shield if one exists.
		Your Willpower and Cunning are used instead of Strength and Dexterity to determine Accuracy and damage.
		The bleeding damage increases with your Mindpower.]]):
		format(100 * t.getWeaponDamage(self, t), damDesc(self, DamageType.PHYSICAL, t.getDamage(self,t)), t.getShatter(self, t))
	end,
}



