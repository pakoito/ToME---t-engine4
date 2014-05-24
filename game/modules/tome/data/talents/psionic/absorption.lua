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
	return math.max(0, self:combatMindpower())
end

local function getSpikeStrength(self, t)
	local ss = getShieldStrength(self, t)
	return 75*self:getTalentLevel(t) + ss*6.85
end

local function getEfficiency(self, t)
	return self:combatTalentLimit(t, 100, 50, 70)/100 -- Limit to <100%
end

local function maxPsiAbsorb(self, t) -- Max psi/turn to prevent runaway psi gains (solipsist randbosses)
	return 2 + self:combatTalentScale(t, 0.3, 1)
end

local function shieldMastery(self, t)
	return 100-self:combatTalentMindDamage(t, 40, 50)
end

local function kineticElement(self, t, damtype)
	if damtype == DamageType.PHYSICAL then return true end
	if damtype == DamageType.ACID and self:getTalentLevel(self.T_KINETIC_SHIELD) >= 2 then return true end
	if damtype == DamageType.NATURE and self:getTalentLevel(self.T_KINETIC_SHIELD) >= 4 then return true end
	if damtype == DamageType.TEMPORAL and self:getTalentLevel(self.T_KINETIC_SHIELD) >= 6 then return true end
	return false
end

local function thermalElement(self, t, damtype)
	if damtype == DamageType.FIRE then return true end
	if damtype == DamageType.COLD and self:getTalentLevel(self.T_THERMAL_SHIELD) >= 2 then return true end
	if damtype == DamageType.LIGHT and self:getTalentLevel(self.T_THERMAL_SHIELD) >= 4 then return true end
	if damtype == DamageType.ARCANE and self:getTalentLevel(self.T_THERMAL_SHIELD) >= 6 then return true end
	return false
end

local function chargedElement(self, t, damtype)
	if damtype == DamageType.LIGHTNING then return true end
	if damtype == DamageType.BLIGHT and self:getTalentLevel(self.T_CHARGED_SHIELD) >= 3 then return true end
	if damtype == DamageType.DARKNESS and self:getTalentLevel(self.T_CHARGED_SHIELD) >= 3 then return true end
	if damtype == DamageType.MIND and self:getTalentLevel(self.T_CHARGED_SHIELD) >= 6 then return true end
	return false
end

local function shieldAbsorb(self, t, p, absorbed)
	local cturn = math.floor(game.turn / 10)
	if cturn ~= p.last_absorbs.last_turn then
		local diff = cturn - p.last_absorbs.last_turn
		for i = 5, 0, -1 do
			local ni = i + diff
			if ni <= 5 then
				p.last_absorbs.values[ni] = p.last_absorbs.values[i]
			end
			p.last_absorbs.values[i] = nil
		end
	end
	p.last_absorbs.values[0] = (p.last_absorbs.values[0] or 0) + absorbed
	p.last_absorbs.last_turn = cturn
end

local function shieldSpike(self, t, p)
	local val = 0
	for i = 0, 5 do val = val + (p.last_absorbs.values[i] or 0) end

	self:setEffect(self.EFF_PSI_DAMAGE_SHIELD, 5, {power=val})
end

local function shieldOverlay(self, t, p)
	local val = 0
	for i = 0, 5 do val = val + (p.last_absorbs.values[i] or 0) end
	if val <= 0 then return "" end
	local fnt = "buff_font_small"
	if val >= 1000 then fnt = "buff_font_smaller" end
	return tostring(math.ceil(val)), fnt
end

newTalent{
	name = "Kinetic Shield",
	type = {"psionic/absorption", 1},
	require = psi_cun_req1,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	sustain_psi = 10,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 14, 10, true)) end, --Limit > 5
	range = 0,
	no_energy = true,
	tactical = { DEFEND = 2 },
	callbackOnActBase = function(self, t)
		shieldAbsorb(self, t, self.sustain_talents[t.id], 0) -- make sure we compute the table correctly
	end,
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
		local kinetic_shield = self.kinetic_shield
		local mast = shieldMastery(self, t)
		local total_dam = dam
		local absorbable_dam = getEfficiency(self,t)* total_dam
		if self:hasEffect(self.EFF_TRANSCENDENT_TELEKINESIS) then absorbable_dam = total_dam kinetic_shield = kinetic_shield * 2 end
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam
		if not kineticElement(self, t, damtype) then return total_dam end		

		local psigain = 0
		if dam <= kinetic_shield then
			psigain = 1 + dam/mast
			shieldAbsorb(self, t, ks, dam)
			dam = 0
		else
			psigain = 1 + kinetic_shield/mast
			dam = dam - kinetic_shield
			shieldAbsorb(self, t, ks, kinetic_shield)
		end
		psigain = math.min(maxPsiAbsorb(self, t) - ks.psi_gain, psigain)
		ks.psi_gain = ks.psi_gain + psigain
		self:incPsi(psigain)

		return dam + guaranteed_dam
	end,
	adjust_shield_gfx = function(self, t, v, p)
		if not p then p = self:isTalentActive(t.id) end
		if not p then return end

		self:removeParticles(p.particle)
		if v then
			if core.shader.active(4) then p.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.4, img="shield5"}, {type="runicshield", ellipsoidalFactor=1, time_factor=-10000, llpow=1, aadjust=7, bubbleColor={1, 0, 0.3, 0.6}, auraColor={1, 0, 0.3, 1}}))
			else p.particle = self:addParticles(Particles.new("generic_shield", 1, {r=1, g=0, b=0.3, a=1}))
			end
		else
			if core.shader.active(4) then p.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1, img="shield5"}, {type="shield", ellipsoidalFactor=1, time_factor=-10000, llpow=1, aadjust=3, color={1, 0, 0.3}}))
			else p.particle = self:addParticles(Particles.new("generic_shield", 1, {r=1, g=0, b=0.3, a=0.5}))
			end
		end
	end,
	iconOverlay = shieldOverlay,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local s_str = getShieldStrength(self, t)

		local ret = {
			am = self:addTemporaryValue("kinetic_shield", s_str),
			game_turn = game.turn,
			psi_gain = 0,
			last_absorbs = {last_turn=math.floor(game.turn / 10), values={}},
		}
		t.adjust_shield_gfx(self, t, self:hasEffect(self.EFF_TRANSCENDENT_TELEKINESIS), ret)
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		local spike_str = getSpikeStrength(self, t)
		self:removeTemporaryValue("kinetic_shield", p.am)
		if self:attr("save_cleanup") then return true end

		if self:getTalentLevel(t) >= 3 then shieldSpike(self, t, p) end
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
		local absorb = 100*getEfficiency(self,t)
		return ([[Surround yourself with a shield that will absorb %d%% of any physical attack, up to a maximum of %d damage per attack.
		Every time your shield absorbs damage, you convert some of the attack into energy, gaining two points of Psi, plus an additional point for every %0.1f points of damage absorbed, up to a maximum %0.1f points each turn.
		At talent level 2, you can also absorb acid damage.
		At talent level 3, when you de-activate the shield all the absorbed damage in the last 6 turns is released as a full psionic shield (absorbing all damage).
		At talent level 4, you can also absorb nature damage.
		At talent level 6, you can also absorb temporal damage.
		The maximum amount of damage your shield can absorb and the efficiency of the psi gain scale with your mindpower.]]):
		format(absorb, s_str, shieldMastery(self, t), maxPsiAbsorb(self,t))
	end,
}

newTalent{
	name = "Thermal Shield",
	type = {"psionic/absorption", 1},
	require = psi_cun_req2,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	sustain_psi = 10,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 14, 10, true)) end, --Limit > 5
	range = 0,
	no_energy = true,
	tactical = { DEFEND = 2 },
	callbackOnActBase = function(self, t)
		shieldAbsorb(self, t, self.sustain_talents[t.id], 0) -- make sure we compute the table correctly
	end,
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
		local thermal_shield = self.thermal_shield
		local total_dam = dam
		local absorbable_dam = getEfficiency(self,t)* total_dam
		if self:hasEffect(self.EFF_TRANSCENDENT_PYROKINESIS) then absorbable_dam = total_dam thermal_shield = thermal_shield * 2 end
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam
		if not thermalElement(self, t, damtype) then return total_dam end
		
		local psigain = 0
		if dam <= thermal_shield then
			psigain = 1 + dam/mast
			shieldAbsorb(self, t, ts, dam)
			dam = 0
		else
			psigain = 1 + thermal_shield/mast
			shieldAbsorb(self, t, ts, thermal_shield)
			dam = dam - thermal_shield
		end
		
		psigain = math.min(maxPsiAbsorb(self, t) - ts.psi_gain, psigain)
		ts.psi_gain = ts.psi_gain + psigain
		self:incPsi(psigain)
		
		return dam + guaranteed_dam
	end,
	adjust_shield_gfx = function(self, t, v, p)
		if not p then p = self:isTalentActive(t.id) end
		if not p then return end

		self:removeParticles(p.particle)
		if v then
			if core.shader.active(4) then p.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.4, img="shield5"}, {type="runicshield", ellipsoidalFactor=1, time_factor=-10000, llpow=1, aadjust=7, bubbleColor={0.3, 1, 1, 0.6}, auraColor={0.3, 1, 1, 1}}))
			else p.particle = self:addParticles(Particles.new("generic_shield", 1, {r=0.3, g=1, b=1, a=1}))
			end
		else
			if core.shader.active(4) then p.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1, img="shield5"}, {type="shield", ellipsoidalFactor=1, time_factor=-10000, llpow=1, aadjust=3, color={0.3, 1, 1}}))
			else p.particle = self:addParticles(Particles.new("generic_shield", 1, {r=0.3, g=1, b=1, a=0.5}))
			end
		end
	end,
	iconOverlay = shieldOverlay,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local s_str = getShieldStrength(self, t)

		local ret = {
			am = self:addTemporaryValue("thermal_shield", s_str),
			game_turn = game.turn,
			psi_gain = 0,
			last_absorbs = {last_turn=math.floor(game.turn / 10), values={}},
		}
		t.adjust_shield_gfx(self, t, self:hasEffect(self.EFF_TRANSCENDENT_PYROKINESIS), ret)
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		local spike_str = getSpikeStrength(self, t)
		self:removeTemporaryValue("thermal_shield", p.am)
		if self:attr("save_cleanup") then return true end

		if self:getTalentLevel(t) >= 3 then shieldSpike(self, t, p) end
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
		local absorb = 100*getEfficiency(self,t)
		return ([[Surround yourself with a shield that will absorb %d%% of any fire attack, up to a maximum of %d damage per attack. 
		Every time your shield absorbs damage, you convert some of the attack into energy, gaining two points of Psi, plus an additional point for every %0.1f points of damage absorbed, up to a maximum %0.1f points each turn.
		At talent level 2, you can also absorb cold damage.
		At talent level 3, when you de-activate the shield all the absorbed damage in the last 6 turns is released as a full psionic shield (absorbing all damage).
		At talent level 4, you can also absorb light damage.
		At talent level 6, you can also absorb arcane damage.
		The maximum amount of damage your shield can absorb and the efficiency of the psi gain scale with your mindpower.]]):
		format(absorb, s_str, shieldMastery(self, t), maxPsiAbsorb(self,t))
	end,
}

newTalent{
	name = "Charged Shield",
	type = {"psionic/absorption", 1},
	require = psi_cun_req3,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	sustain_psi = 10,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 14, 10, true)) end, --Limit > 5
	range = 0,
	no_energy = true,
	tactical = { DEFEND = 2 },
	callbackOnActBase = function(self, t)
		shieldAbsorb(self, t, self.sustain_talents[t.id], 0) -- make sure we compute the table correctly
	end,
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
		local charged_shield = self.charged_shield
		local total_dam = dam
		local absorbable_dam = getEfficiency(self,t)* total_dam
		if self:hasEffect(self.EFF_TRANSCENDENT_ELECTROKINESIS) then absorbable_dam = total_dam charged_shield = charged_shield * 2 end
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam
		if not chargedElement(self, t, damtype) then return total_dam end

		local psigain = 0
		if dam <= charged_shield then
			psigain = 1 + dam/mast
			shieldAbsorb(self, t, cs, dam)
			dam = 0
		else
			psigain = 1 + charged_shield/mast
			dam = dam - charged_shield
			shieldAbsorb(self, t, cs, charged_shield)
		end
		psigain = math.min(maxPsiAbsorb(self, t) - cs.psi_gain, psigain)
		cs.psi_gain = cs.psi_gain + psigain
		self:incPsi(psigain)
		return dam + guaranteed_dam
	end,
	adjust_shield_gfx = function(self, t, v, p)
		if not p then p = self:isTalentActive(t.id) end
		if not p then return end

		self:removeParticles(p.particle)
		if v then
			if core.shader.active(4) then p.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.4, img="shield5"}, {type="runicshield", ellipsoidalFactor=1, time_factor=-10000, llpow=1, aadjust=7, bubbleColor={0.8, 1, 0.2, 0.6}, auraColor={0.8, 1, 0.2, 1}}))
			else p.particle = self:addParticles(Particles.new("generic_shield", 1, {r=0.8, g=1, b=0.2, a=1}))
			end
		else
			if core.shader.active(4) then p.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1, img="shield5"}, {type="shield", ellipsoidalFactor=1, time_factor=-10000, llpow=1, aadjust=3, color={0.8, 1, 0.2}}))
			else p.particle = self:addParticles(Particles.new("generic_shield", 1, {r=0.8, g=1, b=0.2, a=0.5}))
			end
		end
	end,
	iconOverlay = shieldOverlay,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local s_str = getShieldStrength(self, t)

		local ret = {
			am = self:addTemporaryValue("charged_shield", s_str),
			game_turn = game.turn,
			psi_gain = 0,
			last_absorbs = {last_turn=math.floor(game.turn / 10), values={}},
		}
		t.adjust_shield_gfx(self, t, self:hasEffect(self.EFF_TRANSCENDENT_ELECTROKINESIS), ret)
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		local spike_str = getSpikeStrength(self, t)
		self:removeTemporaryValue("charged_shield", p.am)
		if self:attr("save_cleanup") then return true end

		if self:getTalentLevel(t) >= 3 then shieldSpike(self, t, p) end
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
		local absorb = 100*getEfficiency(self,t)
		return ([[Surround yourself with a shield that will absorb %d%% of any lightning attack, up to a maximum of %d damage per attack.
		Every time your shield absorbs damage, you convert some of the attack into energy, gaining two points of Psi, plus an additional point for every %0.1f points of damage absorbed, up to a maximum %0.1f points each turn.
		At talent level 2, you can also absorb blight damage.
		At talent level 3, when you de-activate the shield all the absorbed damage in the last 6 turns is released as a full psionic shield (absorbing all damage).
		At talent level 4, you can also absorb darkness damage.
		At talent level 6, you can also absorb mind damage.
		The maximum amount of damage your shield can absorb and the efficiency of the psi gain scale with your mindpower.]]):
		format(absorb, s_str, shieldMastery(self, t), maxPsiAbsorb(self,t))
	end,
}

newTalent{
	name = "Forcefield",
	type = {"psionic/absorption", 4},
	require = psi_cun_req4,
	points = 5,
	mode = "sustained",
	sustain_psi = 30,
	cooldown = 40,
	no_energy = true,
	tactical = { BUFF = 2, HEAL = 4 },
	range = 0,
	radius = 1,
	getResist = function(self, t) return self:combatTalentLimit(t, 80, 30, 65) end,
	getCost = function(self, t) return 1.0 - self:combatTalentLimit(t, 1, 0.5, 0.85) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	activate = function(self, t)
		local ret = {}
		if core.shader.active(4) then
			ret.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.4, blend=true, img="forcefield"}, {type="shield", shieldIntensity=0.15, color={1,1,1}}))
		else
			ret.particle = self:addParticles(Particles.new("damage_shield", 1))
		end
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	callbackOnTakeDamage = function(self, t, src, x, y, damtype, dam, tmp, no_martyr)
		local ff = self:isTalentActive(t.id)
		if not ff then return dam end
		local total_dam = dam
		local absorbable_dam = t.getResist(self,t) / 100 * total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		local psicost = t.getCost(self,t) * absorbable_dam
		self:incPsi(-psicost)
		return {dam=guaranteed_dam}
	end,
	callbackOnActBase = function(self, t)
		if self.psi < self.max_psi / 10 then self:forceUseTalent(self.T_FORCEFIELD, {ignore_energy=true}) return end
		self:incPsi(self.max_psi / -10)
		
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.MINDKNOCKBACK, 0)
	end,
	info = function(self, t)
		return ([[Surround yourself with a forcefield, reducing all incoming damage by %d%% and knocking back adjacent enemies each turn. 
		This talent drains 10%% of your maximum psi each turn, plus an additional %0.2f psi for every point of damage reduced.]]):
		format(t.getResist(self,t), t.getCost(self,t))
	end,
}
