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

-- Note: This is consistent with raw damage but is applied after damage multipliers
local function getShieldStrength(self, t)
	local mult = 1
	if self:knowTalent(self.T_ABSORPTION_MASTERY) then
		mult = 1 + 0.5 * self:getTalentLevel(self.T_ABSORPTION_MASTERY)
	end
	return math.max(0, self:combatScale((1+ self:getWil(8, true))*self:getTalentLevel(t), 10, 2, 50, 50)*mult)
end

local function getSpikeStrength(self, t)
	local ss = getShieldStrength(self, t)
	return 75*self:getTalentLevel(t) + ss*6.85
end

local function getEfficiency(self, t)
	return self:combatStatLimit("cun", 1, 0.53, 0.80) -- Limit to <100%
end

local function maxPsiAbsorb(self, t) -- Max psi/turn to prevent runaway psi gains (solipsist randbosses)
	return 2 + self:combatTalentScale(t, 0.3, 1) + self:callTalent(self.T_SHIELD_DISCIPLINE, "absorbLimit")
end

local function shieldMastery(self, t)
	return 30 - self:callTalent(self.T_SHIELD_DISCIPLINE, "mastery") - 0.4*getGemLevel(self)
end

local function kineticElement(self, t, damtype)
	if damtype == DamageType.PHYSICAL or damtype == DamageType.ACID then return true end
	if damtype == DamageType.NATURE and self:getTalentLevel(self.T_ABSORPTION_MASTERY) >= 3 then return true end
	if damtype == DamageType.TEMPORAL and self:getTalentLevel(self.T_ABSORPTION_MASTERY) >= 6 then return true end
	return false
end

local function thermalElement(self, t, damtype)
	if damtype == DamageType.FIRE or damtype == DamageType.COLD then return true end
	if damtype == DamageType.LIGHT and self:getTalentLevel(self.T_ABSORPTION_MASTERY) >= 3 then return true end
	if damtype == DamageType.ARCANE and self:getTalentLevel(self.T_ABSORPTION_MASTERY) >= 6 then return true end
	return false
end

local function chargedElement(self, t, damtype)
	if damtype == DamageType.LIGHTNING or damtype == DamageType.BLIGHT then return true end
	if damtype == DamageType.DARKNESS and self:getTalentLevel(self.T_ABSORPTION_MASTERY) >= 3 then return true end
	if damtype == DamageType.MIND and self:getTalentLevel(self.T_ABSORPTION_MASTERY) >= 6 then return true end
	return false
end

newTalent{
	name = "Kinetic Shield",
	type = {"psionic/absorption", 1},
	require = psi_wil_req1,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	sustain_psi = 10,
	cooldown = function(self, t) return 15 - self:getTalentLevelRaw(t) end,
	range = 10,
	no_energy = true,
	tactical = { DEFEND = 2 },
	on_pre_use = function(self, t, silent)
		if self:isTalentActive(self.T_THERMAL_SHIELD) and self:isTalentActive(self.T_CHARGED_SHIELD) then
			if not silent then game.logSeen(self, "You may only sustain two shields at once. Shield activation cancelled.") end
			return false
		end
		return true
	end,
	--called when damage gets absorbed by kinetic shield
	ks_on_damage = function(self, t, damtype, dam)
		local ks = self:isTalentActive(self.T_KINETIC_SHIELD)
		if not ks then return dam end
		if ks.game_turn + 10 <= game.turn then
			ks.psi_gain = 0
			ks.game_turn = game.turn
		end
		local mast = shieldMastery(self, t)
		local total_dam = dam
		local absorbable_dam = getEfficiency(self,t)* total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam
		if not kineticElement(self, t, damtype) then return total_dam end		

		local psigain = 0 
		if dam <= self.kinetic_shield then
			psigain = 2 + dam/mast
			dam = 0
		else
			psigain = 2 + self.kinetic_shield/mast
			dam = dam - self.kinetic_shield
		end
		psigain = math.min(maxPsiAbsorb(self, t) - ks.psi_gain, psigain)
		ks.psi_gain = ks.psi_gain + psigain
		self:incPsi(psigain)
		return dam + guaranteed_dam
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local s_str = getShieldStrength(self, t)

		local particle
		if core.shader.active(4) then
			particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1, img="shield5"}, {type="shield", ellipsoidalFactor=1, time_factor=-10000, llpow=1, aadjust=3, color={1, 0, 0.3}}))
		else
			particle = self:addParticles(Particles.new("generic_shield", 1, {r=1, g=0, b=0.3, a=0.5}))
		end

		return {
			am = self:addTemporaryValue("kinetic_shield", s_str),
			particle = particle,
			game_turn = game.turn,
			psi_gain = 0,
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		local spike_str = getSpikeStrength(self, t)
		self:removeTemporaryValue("kinetic_shield", p.am)
		if self:attr("save_cleanup") then return true end
		self:removeEffect(self.EFF_THERMSPIKE_SHIELD)
		self:removeEffect(self.EFF_CHARGESPIKE_SHIELD)
		self:setEffect(self.EFF_KINSPIKE_SHIELD, 5, {power=spike_str, psi_gain=p.psi_gain, game_turn=p.game_turn})
		return true
	end,
	--called when damage gets absorbed by kinetic shield spike
	kss_on_damage = function(self, t, damtype, dam)
		local kss = self:hasEffect(self.EFF_KINSPIKE_SHIELD)
		if not kss then return dam end
		if kss.game_turn + 10 <= game.turn then
			kss.psi_gain = 0
			kss.game_turn = game.turn
		end
		local mast = shieldMastery(self, t)
		local total_dam = dam
		local absorbable_dam = 1*total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam

--		local psigain = 0
		if kineticElement(self, t, damtype) then
			-- Absorb damage into the shield
			if dam <= self.kinspike_shield_absorb then
			self.kinspike_shield_absorb = self.kinspike_shield_absorb - dam
--				psigain = 2 + 2*dam/mast
				dam = 0
			else
--				psigain = 2 + 2*self.kinspike_shield_absorb/mast 
				dam = dam - self.kinspike_shield_absorb
				self.kinspike_shield_absorb = 0
			end

--			psigain = math.min(2*maxPsiAbsorb(self, t) - kss.psi_gain, psigain)
--			kss.psi_gain = kss.psi_gain + psigain
--			self:incPsi(psigain)

			if self.kinspike_shield_absorb <= 0 then
				game.logPlayer(self, "Your spiked kinetic shield crumbles under the damage!")
				self:removeEffect(self.EFF_KINSPIKE_SHIELD)
			end
			return dam + guaranteed_dam
		else
			return total_dam
		end
	end,
	info = function(self, t)
		local s_str = getShieldStrength(self, t)
		local spike_str = getSpikeStrength(self, t)
		local xs = (kineticElement(self, t, DamageType.NATURE) and ", nature" or "")..(kineticElement(self, t, DamageType.TEMPORAL) and ", temporal" or "")
		local absorb = 100*getEfficiency(self,t)
		return ([[Surround yourself with a shield that will absorb %d%% of any physical%s or acidic attack, up to a maximum of %d damage per attack. Deactivating the shield spikes it up to a temporary (five turns) %d point shield (only one shield can spike at once).
		Every time your shield absorbs damage, you convert some of the attack into energy, gaining two points of Psi, plus an additional point for every %0.1f points of damage absorbed, up to a maximum %0.1f points each turn. Spiked Shields redirect this energy back into the Shield, so no Psi is gained.
		The percentage your shield absorbs scales with cunning and the maximum amount it can absorb scales with willpower.]]):
		format(absorb, xs, s_str, spike_str, shieldMastery(self, t), maxPsiAbsorb(self,t))
	end,
}



newTalent{
	name = "Thermal Shield",
	type = {"psionic/absorption", 2},
	require = psi_wil_req2,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	sustain_psi = 10,
	cooldown = function(self, t) return 15 - self:getTalentLevelRaw(t) end,
	range = 10,
	no_energy = true,
	tactical = { DEFEND = 2 },
	on_pre_use = function(self, t, silent)
		if self:isTalentActive(self.T_KINETIC_SHIELD) and self:isTalentActive(self.T_CHARGED_SHIELD) then
			if not silent then game.logSeen(self, "You may only sustain two shields at once. Shield activation cancelled.") end
			return false
		end
		return true
	end,

	--called when damage gets absorbed by thermal shield
	ts_on_damage = function(self, t, damtype, dam)
		local ts = self:isTalentActive(self.T_THERMAL_SHIELD)
		if not ts then return dam end
		if ts.game_turn + 10 <= game.turn then
			ts.psi_gain = 0
			ts.game_turn = game.turn
		end
		local mast = shieldMastery(self, t)
		local total_dam = dam
		local absorbable_dam = getEfficiency(self,t)* total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam
		if not thermalElement(self, t, damtype) then return total_dam end
		
		local psigain = 0
		if dam <= self.thermal_shield then
			psigain = 2 + dam/mast
			dam = 0
		else
			psigain = 2 + self.thermal_shield/mast
			dam = dam - self.thermal_shield
		end
		
		psigain = math.min(maxPsiAbsorb(self, t) - ts.psi_gain, psigain)
		ts.psi_gain = ts.psi_gain + psigain
		self:incPsi(psigain)
		
		return dam + guaranteed_dam
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local s_str = getShieldStrength(self, t)
		local particle
		if core.shader.active(4) then
			particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1, img="shield5"}, {type="shield", ellipsoidalFactor=1, time_factor=-10000, llpow=1, aadjust=3, color={0.3, 1, 1}}))
		else
			particle = self:addParticles(Particles.new("generic_shield", 1, {r=0.3, g=1, b=1, a=0.5}))
		end
		return {
			am = self:addTemporaryValue("thermal_shield", s_str),
			particle = particle,
			game_turn = game.turn,
			psi_gain = 0,
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		local spike_str = getSpikeStrength(self, t)
		self:removeTemporaryValue("thermal_shield", p.am)
		if self:attr("save_cleanup") then return true end
		self:removeEffect(self.EFF_KINSPIKE_SHIELD)
		self:removeEffect(self.EFF_CHARGESPIKE_SHIELD)
		self:setEffect(self.EFF_THERMSPIKE_SHIELD, 5, {power=spike_str, psi_gain=p.psi_gain, game_turn=p.game_turn})
		return true
	end,
	--called when damage gets absorbed by thermal shield spike
	tss_on_damage = function(self, t, damtype, dam)
		local tss = self:hasEffect(self.EFF_THERMSPIKE_SHIELD)
		if not tss then return dam end
		if tss.game_turn + 10 <= game.turn then
			tss.psi_gain = 0
			tss.game_turn = game.turn
		end
		local mast = shieldMastery(self, t)
		local total_dam = dam
		local absorbable_dam = 1* total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam

--		local psigain = 0
		if thermalElement(self, t, damtype) then
			-- Absorb damage into the shield
			if dam <= self.thermspike_shield_absorb then
				self.thermspike_shield_absorb = self.thermspike_shield_absorb - dam
--				psigain = 2 + 2*dam/mast
				dam = 0
			else
--				psigain = 2 + 2*self.thermspike_shield_absorb/mast
				dam = dam - self.thermspike_shield_absorb
				self.thermspike_shield_absorb = 0
			end
--			psigain = math.min(2*maxPsiAbsorb(self, t) - tss.psi_gain, psigain)
--			tss.psi_gain = tss.psi_gain + psigain
--			self:incPsi(psigain)
			if self.thermspike_shield_absorb <= 0 then
				game.logPlayer(self, "Your spiked thermal shield crumbles under the damage!")
				self:removeEffect(self.EFF_THERMSPIKE_SHIELD)
			end
			return dam + guaranteed_dam
		else
			return total_dam
		end
	end,
	info = function(self, t)
		local s_str = getShieldStrength(self, t)
		local spike_str = getSpikeStrength(self, t)
		local xs = (thermalElement(self, t, DamageType.LIGHT) and ", light" or "")..(thermalElement(self, t, DamageType.ARCANE) and ", arcane" or "")
		local absorb = 100*getEfficiency(self,t)
		return ([[Surround yourself with a shield that will absorb %d%% of any fire%s or cold attack, up to a maximum of %d damage per attack. Deactivating the shield spikes it up to a temporary (five turns) %d point shield (only one shield can spike at once).
		Every time your shield absorbs damage, you convert some of the attack into energy, gaining two points of Psi, plus an additional point for every %0.1f points of damage absorbed, up to a maximum %0.1f points each turn. Spiked Shields redirect this energy back into the Shield, so no Psi is gained.
		The percentage your shield absorbs scales with cunning and the maximum amount it can absorb scales with willpower.]]):
		format(absorb, xs, s_str, spike_str, shieldMastery(self, t), maxPsiAbsorb(self,t))
	end,
}

newTalent{
	name = "Charged Shield",
	type = {"psionic/absorption", 3},
	require = psi_wil_req3,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	sustain_psi = 10,
	cooldown = function(self, t) return 15 - self:getTalentLevelRaw(t) end,
	range = 10,
	no_energy = true,
	tactical = { DEFEND = 2 },
	on_pre_use = function(self, t, silent)
		if self:isTalentActive(self.T_KINETIC_SHIELD) and self:isTalentActive(self.T_THERMAL_SHIELD) then
			if not silent then game.logSeen(self, "You may only sustain two shields at once. Shield activation cancelled.") end
			return false
		end
		return true
	end,
	--called when damage gets absorbed by charged shield
	cs_on_damage = function(self, t, damtype, dam)
		local cs = self:isTalentActive(self.T_CHARGED_SHIELD)
		if not cs then return dam end
		if cs.game_turn + 10 <= game.turn then
			cs.psi_gain = 0
			cs.game_turn = game.turn
		end
		local mast = shieldMastery(self, t)
		local total_dam = dam
		local absorbable_dam = getEfficiency(self,t)* total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam
		if not chargedElement(self, t, damtype) then return total_dam end

		local psigain = 0
		if dam <= self.charged_shield then
			psigain = 2 + dam/mast
			dam = 0
		else
			psigain = 2 + self.charged_shield/mast
			dam = dam - self.charged_shield
		end
		psigain = math.min(maxPsiAbsorb(self, t) - cs.psi_gain, psigain)
		cs.psi_gain = cs.psi_gain + psigain
		self:incPsi(psigain)
		return dam + guaranteed_dam
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local s_str = getShieldStrength(self, t)
		local particle
		if core.shader.active(4) then
			particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1, img="shield5"}, {type="shield", ellipsoidalFactor=1, time_factor=-10000, llpow=1, aadjust=3, color={0.8, 1, 0.2}}))
		else
			particle = self:addParticles(Particles.new("generic_shield", 1, {r=0.8, g=1, b=0.2, a=0.5}))
		end
		return {
			am = self:addTemporaryValue("charged_shield", s_str),
			particle = particle,
			game_turn = game.turn,
			psi_gain = 0,
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		local spike_str = getSpikeStrength(self, t)
		self:removeTemporaryValue("charged_shield", p.am)
		if self:attr("save_cleanup") then return true end
		self:removeEffect(self.EFF_THERMSPIKE_SHIELD)
		self:removeEffect(self.EFF_KINSPIKE_SHIELD)
		self:setEffect(self.EFF_CHARGESPIKE_SHIELD, 5, {power=spike_str, psi_gain=p.psi_gain, game_turn=p.game_turn})
		return true
	end,
	--called when damage gets absorbed by charged shield spike
	css_on_damage = function(self, t, damtype, dam)
		local css = self:hasEffect(self.EFF_CHARGESPIKE_SHIELD)
		if not css then return dam end
		if css.game_turn + 10 <= game.turn then
			css.psi_gain = 0
			css.game_turn = game.turn
		end
		local mast = shieldMastery(self, t)
		local total_dam = dam
		local absorbable_dam = 1* total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam
	
--		local psigain = 0
		if chargedElement(self, t, damtype) then	
			-- Absorb damage into the shield
			if dam <= self.chargespike_shield_absorb then
				self.chargespike_shield_absorb = self.chargespike_shield_absorb - dam
--				psigain = 2 + 2*dam/mast
				dam = 0
			else
--				psigain = 2 + 2*self.chargespike_shield_absorb/mast
				dam = dam - self.chargespike_shield_absorb
				self.chargespike_shield_absorb = 0
			end
			
--			psigain = math.min(2*maxPsiAbsorb(self, t) - css.psi_gain, psigain)
--			css.psi_gain = css.psi_gain + psigain
--			self:incPsi(psigain)

			if self.chargespike_shield_absorb <= 0 then
				game.logPlayer(self, "Your spiked charged shield crumbles under the damage!")
				self:removeEffect(self.EFF_CHARGESPIKE_SHIELD)
			end
			return dam + guaranteed_dam
		else
			return total_dam
		end
	end,
	info = function(self, t)
		local s_str = getShieldStrength(self, t)
		local spike_str = getSpikeStrength(self, t)
		local xs = (chargedElement(self, t, DamageType.DARKNESS) and ", darkness" or "")..(chargedElement(self, t, DamageType.MIND) and ", mind" or "")
		local absorb = 100*getEfficiency(self,t)
		return ([[Surround yourself with a shield that will absorb %d%% of any lightning%s or blight attack, up to a maximum of %d damage per attack. Deactivating the shield spikes it up to a temporary (five turns) %d point shield (only one shield can spike at once).
		Every time your shield absorbs damage, you convert some of the attack into energy, gaining two points of Psi, plus an additional point for every %0.1f points of damage absorbed, up to a maximum %0.1f points each turn. Spiked Shields redirect this energy back into the Shield, so no Psi is gained.
		The percentage your shield absorbs scales with cunning and the maximum amount it can absorb scales with willpower.]]):
		format(absorb, xs, s_str, spike_str, shieldMastery(self, t), maxPsiAbsorb(self,t))
	end,
}

newTalent{
	name = "Absorption Mastery",
	type = {"psionic/absorption", 4},
	require = psi_wil_req4,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 30, 100, 60)) end, --Limit to >30
	psi = 15,
	points = 5,
	no_energy = true,
	tactical = { BUFF = 3 },
	action = function(self, t)
		if self.talents_cd[self.T_KINETIC_SHIELD] == nil and self.talents_cd[self.T_THERMAL_SHIELD] == nil and self.talents_cd[self.T_CHARGED_SHIELD] == nil then
			return
		else
			self.talents_cd[self.T_KINETIC_SHIELD] = nil
			self.talents_cd[self.T_THERMAL_SHIELD] = nil
			self.talents_cd[self.T_CHARGED_SHIELD] = nil
			return true
		end
	end,

	info = function(self, t)
		return ([[When activated, brings all shields off cooldown. Additional talent points spent in Absorption Mastery allow it to be used more frequently.
		At level 3 and 6, your shields gain new elemental absorption:
		- Kinetic Shield: Nature at level 3, Temporal at level 6
		- Thermal Shield: Light at level 3, Arcane at level 6
		- Charged Shield: Darkness at level 3, Mind at level 6
		Also increases the maximum amount absorbable by your shields by %d%%.]]):format(self:getTalentLevel(t)*5)
	end,
}
