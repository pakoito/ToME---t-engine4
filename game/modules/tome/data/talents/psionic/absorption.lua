-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

local function getShieldStrength(self, t)
	local add = 0
	if self:knowTalent(self.T_FOCUSED_CHANNELING) then
		add = getGemLevel(self)*(1 + 0.1*(self:getTalentLevel(self.T_FOCUSED_CHANNELING) or 0))
	end
	--return 2 + (1+ self:getWil(8))*self:getTalentLevel(t) + add
	return self:combatTalentIntervalDamage(t, "wil", 3, 60) + add
end

local function getSpikeStrength(self, t)
	local ss = getShieldStrength(self, t)
	return  75*self:getTalentLevel(t) + ss*math.sqrt(ss)
end

newTalent{
	name = "Kinetic Shield",
	type = {"psionic/absorption", 1},
	require = psi_absorb,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	sustain_psi = 30,
	cooldown = function(self, t)
		return 20 - 2*(self:getTalentLevelRaw(self.T_ABSORPTION_MASTERY) or 0)
	end,
	range = 10,
	tactical = { DEFEND = 2 },

	--called when damage gets absorbed by kinetic shield
	ks_on_damage = function(self, t, damtype, dam)
		local mast = 20 - (2*self:getTalentLevel(self.T_ABSORPTION_MASTERY) or 0) - 0.4*getGemLevel(self)
		local total_dam = dam
		local absorbable_dam = 0.01*(60 + math.min(self:getCun(50), 40))* total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam
		if damtype ~= DamageType.PHYSICAL and damtype ~= DamageType.ACID then return total_dam end

		if dam <= self.kinetic_shield then
			self:incPsi(2 + dam/mast)
			dam = 0
		else
			self:incPsi(2 + self.kinetic_shield/mast)
			dam = dam - self.kinetic_shield
		end

		return dam + guaranteed_dam
	end,


	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local s_str = getShieldStrength(self, t)
		return {
			am = self:addTemporaryValue("kinetic_shield", s_str),
		}
	end,
	deactivate = function(self, t, p)
		local spike_str = getSpikeStrength(self, t)
		self:removeTemporaryValue("kinetic_shield", p.am)
		self:setEffect(self.EFF_KINSPIKE_SHIELD, 5, {power=spike_str})
		return true
	end,

	--called when damage gets absorbed by kinetic shield spike
	kss_on_damage = function(self, t, damtype, dam)
		local mast = 20 - (2*self:getTalentLevel(self.T_ABSORPTION_MASTERY) or 0) - 0.4*getGemLevel(self)
		local total_dam = dam
		local absorbable_dam = 0.01*(60 + math.min(self:getCun(50), 40))* total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam

		if damtype == DamageType.PHYSICAL or damtype == DamageType.ACID then
			-- Absorb damage into the shield
			if dam <= self.kinspike_shield_absorb then
				self.kinspike_shield_absorb = self.kinspike_shield_absorb - dam
				self:incPsi(2 + dam/mast)
				dam = 0
			else
				self:incPsi(2 + self.kinspike_shield_absorb/mast)
				dam = dam - self.kinspike_shield_absorb
				self.kinspike_shield_absorb = 0
			end

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
		local mast = 20 - (2*self:getTalentLevel(self.T_ABSORPTION_MASTERY) or 0) - 0.4*getGemLevel(self)
		local absorb = 60 + math.min(self:getCun(50), 40)
		return ([[Surround yourself with a shield that will absorb at most %d physical or acid damage per attack. Deactivating the shield spikes it up to a temporary (five turns) %d point shield. The effect will increase with your Willpower stat.
		Every time your shield absorbs damage, you gain two points of energy plus an additional point for every %d points of damage absorbed.
		%d%% of any given attack is subject to absorption by this shield. The rest gets through as normal. Improve this by increasing Cunning.]]):
		format(s_str, spike_str, mast, absorb)
	end,
}



newTalent{
	name = "Thermal Shield",
	type = {"psionic/absorption", 1},
	require = psi_absorb,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	sustain_psi = 30,
	cooldown = function(self, t)
		return 20 - 2*(self:getTalentLevelRaw(self.T_ABSORPTION_MASTERY) or 0)
	end,
	range = 10,
	tactical = { DEFEND = 2 },

	--called when damage gets absorbed by thermal shield
	ts_on_damage = function(self, t, damtype, dam)
		local mast = 20 - (2*self:getTalentLevel(self.T_ABSORPTION_MASTERY) or 0) - 0.4*getGemLevel(self)
		local total_dam = dam
		local absorbable_dam = 0.01*(60 + math.min(self:getCun(50), 40))* total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam
		if damtype ~= DamageType.FIRE and damtype ~= DamageType.COLD then return total_dam end

		if dam <= self.thermal_shield then
			self:incPsi(2 + dam/mast)
			dam = 0
		else
			self:incPsi(2 + self.thermal_shield/mast)
			dam = dam - self.thermal_shield
		end
		return dam + guaranteed_dam
	end,


	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local s_str = getShieldStrength(self, t)
		return {
			am = self:addTemporaryValue("thermal_shield", s_str),
		}
	end,
	deactivate = function(self, t, p)
		local spike_str = getSpikeStrength(self, t)
		self:removeTemporaryValue("thermal_shield", p.am)
		self:setEffect(self.EFF_THERMSPIKE_SHIELD, 5, {power=spike_str})
		return true
	end,

	--called when damage gets absorbed by thermal shield spike
	tss_on_damage = function(self, t, damtype, dam)
		local mast = 20 - (2*self:getTalentLevel(self.T_ABSORPTION_MASTERY) or 0) - 0.4*getGemLevel(self)
		local total_dam = dam
		local absorbable_dam = 0.01*(60 + math.min(self:getCun(50), 40))* total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam

		if damtype == DamageType.FIRE or damtype == DamageType.COLD then
			-- Absorb damage into the shield
			if dam <= self.thermspike_shield_absorb then
				self.thermspike_shield_absorb = self.thermspike_shield_absorb - dam
				self:incPsi(2 + dam/mast)
				dam = 0
			else
				self:incPsi(2 + self.thermspike_shield_absorb/mast)
				dam = dam - self.thermspike_shield_absorb
				self.thermspike_shield_absorb = 0
			end

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
		local mast = 20 - (2*self:getTalentLevel(self.T_ABSORPTION_MASTERY) or 0) - 0.4*getGemLevel(self)
		local absorb = 60 + math.min(self:getCun(50), 40)
		return ([[Surround yourself with a shield that will absorb at most %d thermal damage per attack. Deactivating the shield spikes it up to a temporary (five turns) %d point shield. The effect will increase with your Willpower stat.
		Every time your shield absorbs damage, you gain two points of energy plus an additional point for every %d points of damage absorbed.
		%d%% of any given attack is subject to absorption by this shield. The rest gets through as normal. Improve this by increasing Cunning.]]):
		format(s_str, spike_str, mast, absorb)
	end,
}

newTalent{
	name = "Charged Shield",
	type = {"psionic/absorption", 1},
	require = psi_absorb,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	sustain_psi = 30,
	cooldown = function(self, t)
		return 20 - 2*(self:getTalentLevelRaw(self.T_ABSORPTION_MASTERY) or 0)
	end,
	range = 10,
	tactical = { DEFEND = 2 },

	--called when damage gets absorbed by charged shield
	cs_on_damage = function(self, t, damtype, dam)
		local mast = 20 - (2*self:getTalentLevel(self.T_ABSORPTION_MASTERY) or 0) - 0.4*getGemLevel(self)
		local total_dam = dam
		local absorbable_dam = 0.01*(60 + math.min(self:getCun(50), 40))* total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam
		if damtype ~= DamageType.LIGHTNING and damtype ~= DamageType.BLIGHT then return total_dam end

		if dam <= self.charged_shield then
			self:incPsi(2 + dam/mast)
			dam = 0
		else
			self:incPsi(2 + self.charged_shield/mast)
			dam = dam - self.charged_shield
		end
		return dam + guaranteed_dam
	end,


	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local s_str = getShieldStrength(self, t)
		return {
			am = self:addTemporaryValue("charged_shield", s_str),
		}
	end,
	deactivate = function(self, t, p)
		local spike_str = getSpikeStrength(self, t)
		self:removeTemporaryValue("charged_shield", p.am)
		self:setEffect(self.EFF_CHARGESPIKE_SHIELD, 5, {power=spike_str})
		return true
	end,

	--called when damage gets absorbed by charged shield spike
	css_on_damage = function(self, t, damtype, dam)
		local mast = 20 - (2*self:getTalentLevel(self.T_ABSORPTION_MASTERY) or 0) - 0.4*getGemLevel(self)
		local total_dam = dam
		local absorbable_dam = 0.01*(60 + math.min(self:getCun(50), 40))* total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam
		if damtype == DamageType.LIGHTNING or damtype == DamageType.BLIGHT then
			-- Absorb damage into the shield
			if dam <= self.chargespike_shield_absorb then
				self.chargespike_shield_absorb = self.chargespike_shield_absorb - dam
				self:incPsi(2 + dam/mast)
				dam = 0
			else
				self:incPsi(2 + self.chargespike_shield_absorb/mast)
				dam = dam - self.chargespike_shield_absorb
				self.chargespike_shield_absorb = 0
			end

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
		local mast = 20 - (2*self:getTalentLevel(self.T_ABSORPTION_MASTERY) or 0) - 0.4*getGemLevel(self)
		local absorb = 60 + math.min(self:getCun(50), 40)
		return ([[Surround yourself with a shield that will absorb at most %d lightning or blight damage per attack. Deactivating the shield spikes it up to a temporary (five turns) %d point shield. The effect will increase with your Willpower stat.
		Every time your shield absorbs damage, you gain two points of energy plus an additional point for every %d points of damage absorbed.
		%d%% of any given attack is subject to absorption by this shield. The rest gets through as normal. Improve this by increasing Cunning.]]):
		format(s_str, spike_str, mast, absorb)
	end,
}

newTalent{
	name = "Absorption Mastery",
	type = {"psionic/absorption", 4},
	require = psi_wil_req2,
	points = 5,
	mode = "passive",
	info = function(self, t)
		local cooldown = 2*self:getTalentLevelRaw(t)
		local mast = 2*self:getTalentLevel(t)
		return ([[Your expertise in the art of energy absorption grows. Shield cooldowns are all reduced by %d turns, and the amount of damage absorption required to gain a point of energy is reduced by %0.2f.]]):
		format(cooldown, mast)
	end,
}
