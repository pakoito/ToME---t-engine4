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

local function cancelAuras(self)
	local auras = {self.T_CHARGED_AURA, self.T_THERMAL_AURA, self.T_KINETIC_AURA,}
	for i, t in ipairs(auras) do
		if self:isTalentActive(t) then
			self:forceUseTalent(t, {ignore_energy=true})
		end
	end
end

newTalent{
	name = "Telekinetic Smash",
	type = {"psionic/psi-fighting", 1},
	require = psi_wil_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	psi = 10,
	range = 1,
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 2 } },
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
		self.use_psi_combat = true
		self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 1.8, 3))
		self.use_psi_combat = false
		return true
	end,
	info = function(self, t)
		return ([[Gather your will and brutally smash the target with your mainhand weapon, doing %d%% weapon damage. If Conduit is active, it will extend to include your mainhand weapon for this attack. This attack uses your Willpower and Cunning instead of Strength and Dexterity to determine accuracy and damage.]]):
		format(100 * self:combatTalentWeaponDamage(t, 1.8, 3))
	end,
}

newTalent{
	name = "Augmentation",
	type = {"psionic/psi-fighting", 2},
	require = psi_wil_req2,
	points = 5,
	mode = "sustained",
	cooldown = 0,
	sustain_psi = 10,
	no_energy = true,
	tactical = { BUFF = 2 },
	activate = function(self, t)
		local str_power = math.floor(0.05*self:getTalentLevel(t)*self:getWil())
		local dex_power = math.floor(0.05*self:getTalentLevel(t)*self:getCun())
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
		local inc = 5*self:getTalentLevel(t)
		local str_power = math.floor(0.05*self:getTalentLevel(t)*self:getWil())
		local dex_power = math.floor(0.05*self:getTalentLevel(t)*self:getCun())
		return ([[While active, you give your flesh and blood body a little aid in the form of precisely applied mental forces. Increases Strength and Dexterity by %d%% of your Willpower and Cunning, respectively.
		Strength increased by %d
		Dexterity increased by %d]]):
		format(inc, str_power, dex_power)
	end,
}

newTalent{
	name = "Conduit",
	type = {"psionic/psi-fighting", 3},
	require = psi_wil_req3, no_sustain_autoreset = true,
	cooldown = 1,
	mode = "sustained",
	sustain_psi = 0,
	points = 5,
	tactical = { ATTACK = function(self, t)
		local vals = {}
		if self:isTalentActive(self.T_KINETIC_AURA) then
			vals[PHYSICAL] = 1
		end
		if self:isTalentActive(self.T_THERMAL_AURA) then
			vals[FIRE] = 1
		end
		if self:isTalentActive(self.T_CHARGED_AURA) then
			vals[LIGHTNING] = 1
		end
		return vals
	end},
	activate = function(self, t)
		local ret = {
		k_aura_on = self:isTalentActive(self.T_KINETIC_AURA),
		t_aura_on = self:isTalentActive(self.T_THERMAL_AURA),
		c_aura_on = self:isTalentActive(self.T_CHARGED_AURA),
		}
		local cur_psi = self:getPsi()
		self:incPsi(-5000)
		--self.sustain_talents[t.id] = {}
		cancelAuras(self)
		self:incPsi(cur_psi)
		return ret
	end,
	do_combat = function(self, t, target)
		local mult = 1 + 0.2*(self:getTalentLevel(t))
		local auras = self:isTalentActive(t.id)
		if auras.k_aura_on then
			local k_aura = self:getTalentFromId(self.T_KINETIC_AURA)
			local k_dam = mult * k_aura.getAuraStrength(self, k_aura)
			DamageType:get(DamageType.PHYSICAL).projector(self, target.x, target.y, DamageType.PHYSICAL, k_dam)
		end
		if auras.t_aura_on then
			local t_aura = self:getTalentFromId(self.T_THERMAL_AURA)
			local t_dam = mult * t_aura.getAuraStrength(self, t_aura)
			DamageType:get(DamageType.FIRE).projector(self, target.x, target.y, DamageType.FIRE, t_dam)
		end
		if auras.c_aura_on then
			local c_aura = self:getTalentFromId(self.T_CHARGED_AURA)
			local c_dam = mult * c_aura.getAuraStrength(self, c_aura)
			DamageType:get(DamageType.LIGHTNING).projector(self, target.x, target.y, DamageType.LIGHTNING, c_dam)
		end
	end,

	deactivate = function(self, t)
		return true
	end,
	info = function(self, t)
		local mult = 1 + 0.2*(self:getTalentLevel(t))
		return ([[When activated, turns off any active auras and uses your telekinetically wielded weapon as a conduit for the energies that were being channeled through those auras.
		Any auras used by Conduit will not start to cool down until Conduit has been deactivated. The damage from each aura applied by Conduit is multiplied by %0.2f, and does not drain energy.]]):
		format(mult)
	end,
}

newTalent{
	name = "Frenzied Psifighting",
	type = {"psionic/psi-fighting", 4},
	require = psi_wil_req4,
	cooldown = 20,
	psi = 30,
	points = 5,
	tactical = { ATTACK = { PHYSICAL = 3 } },
	action = function(self, t)
		local targets = 1 + math.ceil(self:getTalentLevel(t)/5)
		self:setEffect(self.EFF_PSIFRENZY, 3 * self:getTalentLevelRaw(t), {power=targets})
		return true
	end,
	--getTargNum = function(self, t) return 1 + math.ceil(self:getTalentLevel(t)/5) end,
	info = function(self, t)
		local targets = 1 + math.ceil(self:getTalentLevel(t)/5)
		local dur = 3 * self:getTalentLevelRaw(t)
		return ([[Your telekinetically wielded weapon enters a frenzy for %d turns, striking up to %d targets every turn.]]):
		format(dur, targets)
	end,
}

