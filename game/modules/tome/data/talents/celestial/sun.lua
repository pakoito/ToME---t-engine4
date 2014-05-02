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

-- Baseline blind because the class has a lot of trouble with CC early game and rushing TL4 isn't reasonable
newTalent{
	name = "Sun Beam",
	type = {"celestial/sun", 1},
	require = divi_req1,
	random_ego = "attack",
	points = 5,
	cooldown = 9,
	positive = -16,
	range = 7,
	tactical = { ATTACK = {LIGHT = 2} },
	no_energy = function(self, t) return self:attr("amplify_sun_beam") and true or false end,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	getDamage = function(self, t)
		local mult = 1
		if self:attr("amplify_sun_beam") then mult = 1 + self:attr("amplify_sun_beam") / 100 end
		return self:combatTalentSpellDamage(t, 20, 240) * mult
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.LIGHT, self:spellCrit(t.getDamage(self, t)), {type="light"})

		if self:getTalentLevel(t) >= 4 then
			local _ _, x, y = self:canProject(tg, x, y)
			self:project({type="ball", x=x, y=y, radius=2, selffire=false}, x, y, DamageType.BLIND, t.getDuration(self, t), {type="light"})
		else
			local _ _, x, y = self:canProject(tg, x, y)
			self:project({type="hit", x=x, y=y, radius=0, selffire=false}, x, y, DamageType.BLIND, t.getDuration(self, t), {type="light"})
		end

		-- Delay removal of the effect so its still there when no_energy checks
		game:onTickEnd(function()
			self:removeEffect(self.EFF_SUN_VENGEANCE)
		end)

		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Calls the a beam of light from the Sun, doing %0.2f damage to the target and blinding them.
		At level 4 the beam will be so intense it blinds all foes in radius 2 for %d turns.
		The damage dealt will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.LIGHT, damage), t.getDuration(self, t))
	end,
}

-- Core class defense to be compared with Bone Shield, Aegis, Indiscernable Anatomy, etc
-- Moderate offensive scaler
-- The CD reduction effects more abilities on the class than it doesn't
-- Banned from NPCs due to sheer scaling insanity
newTalent{
	name = "Suncloak",
	type = {"celestial/sun", 2},
	require = divi_req2,
	points = 5,
	cooldown = 20,
	fixed_cooldown = true,
	positive = -15,
	tactical = { BUFF = 2 },
	direct_hit = true,
	no_npc_use = true,
	requires_target = true,
	range = 10,
	getCap = function(self, t) return math.max(50, 100 - self:getTalentLevelRaw(t) * 10) end,
	getHaste = function(self, t) return math.min(0.9, self:combatTalentSpellDamage(t, 0.2, 0.7)) end,
	getCD = function(self, t) return math.min(0.5, self:combatTalentSpellDamage(t, 5, 450) / 1000) end,
	action = function(self, t)
		self:setEffect(self.EFF_SUNCLOAK, 6, {cap=t.getCap(self, t), haste=t.getHaste(self, t), cd=t.getCD(self, t)})
		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		return ([[You wrap yourself in a cloak of sunlight that empowers your magic and protects you for 6 turns.
		While the cloak is active your spell casting speed is increased by %d%%, your spell cooldowns are reduced by %d%%, and you cannot take more than %d%% of your maximum life from a single blow.
		The effects will increase with your Spellpower.]]):
		format(t.getHaste(self, t)*100, t.getCD(self, t)*100, t.getCap(self, t))
   end,
}

-- Can someone put a really obvious visual on this?
newTalent{
	name = "Sun's Vengeance", short_name = "SUN_VENGEANCE",
	type = {"celestial/sun",3},
	require = divi_req3,
	mode = "passive",
	points = 5,
	getCrit = function(self, t) return self:combatTalentScale(t, 2, 10, 0.75) end,
	getProcChance = function(self, t) return self:combatTalentScale(t, 40, 100) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_spellcrit", t.getCrit(self, t))
		self:talentTemporaryValue(p, "combat_physcrit", t.getCrit(self, t))
	end,
	callbackOnCrit = function(self, t, kind, dam, chance)
		if kind ~= "spell" and kind ~= "physical" then return end
		if not rng.percent(t.getProcChance(self, t)) then return end
		if self.turn_procs.sun_vengeance then return end
		self.turn_procs.sun_vengeance = true

		if self:isTalentCoolingDown(self.T_SUN_BEAM) then
			self.talents_cd[self.T_SUN_BEAM] = self.talents_cd[self.T_SUN_BEAM] - 1
			if self.talents_cd[self.T_SUN_BEAM] <= 0 then self.talents_cd[self.T_SUN_BEAM] = nil end
		else
			self:setEffect(self.EFF_SUN_VENGEANCE, 2, {})
		end
	end,
	info = function(self, t)
		local crit = t.getCrit(self, t)
		local chance = t.getProcChance(self, t)
		return ([[Infuse yourself with the raging fury of the Sun, increasing your physical and spell critical chance by %d%%.
		Each time you crit with a physical attack or a spell you have %d%% chance to gain Sun's Vengeance for 2 turns.
		While affected your Sun Beam will take no turn to use and deal 25%% more damage.
		If Sun Beam was on cooldown, the remaining turns are reduced by one instead.
		This effect can only happen once per turn.]]):
		format(crit, chance)
	end,
}

newTalent{
	name = "Path of the Sun",
	type = {"celestial/sun", 4},
	require = divi_req4,
	points = 5,
	cooldown = 15,
	positive = -20,
	tactical = { ATTACKAREA = {LIGHT = 2}, CLOSEIN = 2 },
	range = function(self, t) return self:combatTalentLimit(t, 10, 4, 9) end,
	direct_hit = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 310) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local dam = self:spellCrit(t.getDamage(self, t))
		local grids = self:project(tg, x, y, function() end)
		grids[self.x] = grids[self.x] or {}
		grids[self.x][self.y] = true
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:addEffect(self, self.x, self.y, 5, DamageType.SUN_PATH, dam / 5, 0, 5, grids, MapEffect.new{color_br=255, color_bg=249, color_bb=60, alpha=100, effect_shader="shader_images/sun_effect.png"}, nil, true)
		game.level.map:addEffect(self, self.x, self.y, 5, DamageType.COSMETIC, 0      , 0, 5, grids, {type="sun_path", args={tx=x-self.x, ty=y-self.y}, only_one=true}, nil, true)

		self:setEffect(self.EFF_PATH_OF_THE_SUN, 5, {})

		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)
		return ([[A path of sunlight appears in front of you for 5 turns. All foes standing inside take %0.2f light damage per turn.
		While standing in the path your movements cost no turns.
		The damage done will increase with your Spellpower.]]):format(damDesc(self, DamageType.LIGHT, damage / 5), radius)
	end,
}
