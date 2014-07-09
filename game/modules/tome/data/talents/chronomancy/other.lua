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

-- Paradox Functions

-- Paradox modifier.  This dictates paradox cost and spellpower scaling
-- Note that 300 is the optimal balance
-- Caps at -50% and +50%
getParadoxModifier = function (self)
	local pm = util.bound(math.sqrt(self:getParadox() / 300), 0.5, 1.5)
--	local pm = math.sqrt(self:getParadox()/300)
--	pm = math.min(1.5, pm)
--	pm = math.max(0.5, pm)
	return pm
end

-- Paradox cost (regulates the cost of paradox talents)
getParadoxCost = function (self, t, value)
	local pm = getParadoxModifier(self)
	return value * pm
end

-- Paradox Spellpower (regulates spellpower for chronomancy)
getParadoxSpellpower = function(self, mod, add)
	local pm = getParadoxModifier(self)
	local mod = mod or 0
	local spellpower = self:combatSpellpower(pm + mod, add)
	return spellpower
end

--- Warden weapon functions
-- Checks for weapons in main and quickslot
doWardenPreUse = function(self, weapon, silent)
	if weapon == "bow" then
		if not self:hasArcheryWeapon("bow") and not self:hasArcheryWeaponQS("bow") then
			return false
		end
	end
	if weapon == "dual" then
		if not self:hasDualWeapon() and not self:hasDualWeaponQS() then
			return false
		end
	end
	return true
end

-- Swaps weapons if needed
doWardenWeaponSwap = function(self, t, dam, type)
	local swap = false
	local dam = dam or 0
	local warden_weapon
	
	if t.type[1]:find("^chronomancy/blade") or type == "blade" then
		local mainhand, offhand = self:hasDualWeapon()
		if not mainhand then
			swap = true
			warden_weapon = "blade"
		end
	elseif t.type[1]:find("^chronomancy/bow") or type == "bow" then
		if not self:hasArcheryWeapon("bow") then
			swap = true
			warden_weapon = "bow"
		end
	end
	if swap == true then
		local old_inv_access = self.no_inventory_access				-- Make sure clones can swap
		self.no_inventory_access = nil
		self:quickSwitchWeapons(true, "warden")
		self.no_inventory_access = old_inv_access
		
		if self:knowTalent(self.T_BLENDED_THREADS) then
			if not self.turn_procs.blended_threads then
				self.turn_procs.blended_threads = warden_weapon
			end
			if self.turn_procs.blended_threads == warden_weapon then
				dam = dam * (1 + self:callTalent(self.T_BLENDED_THREADS, "getPercent"))
			end
		end
	end
	return dam
end

-- Checks for blended threads and adds the bonus
getWardenWeaponDamage = function(self, t, base, max, t2)
	local damage = self:combatTalentWeaponDamage(t, base, max, t2)
	local effect = self:hasEffect(self.EFF_BLENDED_THREADS)
	if effect then
		if effect.weapon == "bow" and t.warden_weapon == "bow" then
			damage = damage + effect.dam
		elseif effect.weapon == "dual" and t.warden_weapon == "dual" then
			damage = damage + effect.dam
		end
	end
	return damage
end

-- Turns off friendly fire on archery spells after we learn Temporal Hounds 
getWardenTarget = function(self, t)
	if t.weapon == "bow" then
		return {type="bolt", range=self:getTalentRange(t), talent=t,  friendlyfire=not self:knowTalent(self.T_TEMPORAL_HOUNDS), friendlyblock=not self:knowTalent(self.T_TEMPORAL_HOUNDS)}
	end
end

-- Spell functions
makeParadoxClone = function(self, target, duration)
	local m = target:cloneFull{
		shader = "shadow_simulacrum",
		shader_args = { color = {0.6, 0.6, 0.2}, base = 0.8, time_factor = 1500 },
		no_drops = true,
		faction = target.faction,
		summoner = target, summoner_gain_exp=true,
		summon_time = duration,
		ai_target = {actor=nil},
		ai = "summoned", ai_real = "tactical",
		name = ""..target.name.."'s temporal clone",
		desc = [[A creature from another timeline.]],
	}
	m:removeAllMOs()
	m.make_escort = nil
	m.on_added_to_level = nil
	m.on_added = nil

	mod.class.NPC.castAs(m)
	engine.interface.ActorAI.init(m, m)

	m.exp_worth = 0
	m.energy.value = 0
	m.player = nil
	m.max_life = m.max_life
	m.life = util.bound(m.life, 0, m.max_life)
	m.forceLevelup = function() end
	m.on_die = nil
	m.die = nil
	m.puuid = nil
	m.on_acquire_target = nil
	m.no_inventory_access = true
	m.on_takehit = nil
	m.seen_by = nil
	m.can_talk = nil
	m.clone_on_hit = nil
	m.self_resurrect = nil
	if m.talents.T_SUMMON then m.talents.T_SUMMON = nil end
	if m.talents.T_MULTIPLY then m.talents.T_MULTIPLY = nil end
	
	-- Clones never flee because they're awesome
	m.ai_tactic = m.ai_tactic or {}
	m.ai_tactic.escape = 0
	
	-- Remove some talents
	local tids = {}
	for tid, _ in pairs(m.talents) do
		local t = m:getTalentFromId(tid)
		if t.no_npc_use then tids[#tids+1] = t end
		if t.remove_on_clone then tids[#tids+1] = t end
	end
	for i, t in ipairs(tids) do
		if t.mode == "sustained" and m:isTalentActive(t.id) then m:forceUseTalent(t.id, {ignore_energy=true, silent=true}) end
		m.talents[t.id] = nil
	end
	
	-- remove timed effects
	local effs = {}
	for eff_id, p in pairs(m.tmp) do
		local e = m.tempeffect_def[eff_id]
		effs[#effs+1] = {"effect", eff_id}
	end

	while #effs > 0 do
		local eff = rng.tableRemove(effs)
		if eff[1] == "effect" then
			m:removeEffect(eff[2])
		end
	end
	return m
end

-- Make sure we don't run concurrent chronoworlds; to prevent lag and possible game breaking bugs or exploits
checkTimeline = function(self)
	if game._chronoworlds  == nil then
		return false
	else
		return true
	end
end

-- Misc. Paradox Talents
newTalent{
	name = "Spacetime Tuning",
	type = {"chronomancy/other", 1},
	points = 1,
	tactical = { PARADOX = 2 },
	no_npc_use = true,
	no_unlearn_last = true,
	on_learn = function(self, t)
		if not self.preferred_paradox then self.preferred_paradox = 300 end
	end,
	on_unlearn = function(self, t)
		if self.preferred_paradox then self.preferred_paradox = nil end
	end,
	getDuration = function(self, t) 
		local power = math.floor(self:combatSpellpower()/10)
		return math.max(20 - power, 10)
	end,
	action = function(self, t)
		function getQuantity(title, prompt, default, min, max)
			local result
			local co = coroutine.running()

			local dialog = engine.dialogs.GetQuantity.new(
				title,
				prompt,
				default,
				max,
				function(qty)
					result = qty
					coroutine.resume(co)
				end,
				min)
			dialog.unload = function(dialog)
				if not dialog.qty then coroutine.resume(co) end
			end

			game:registerDialog(dialog)
			coroutine.yield()
			return result
		end

		local paradox = getQuantity(
			"Spacetime Tuning",
			"What's your preferred paradox level?",
			math.floor(self.paradox))
		if not paradox then return end
		if paradox > 1000 then paradox = 1000 end
		self.preferred_paradox = paradox
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local preference = self.preferred_paradox
		local spellpower = getParadoxSpellpower(self)
		local _, will_modifier = self:getModifiedParadox()
		local after_will = self:getModifiedParadox()
		local anomaly = self:paradoxFailChance()
		return ([[Use to set your preferred Paradox.  While resting you'll adjust your Paradox towards this number over %d turns.
		The time it takes you to adjust your Paradox scales down with your Spellpower to a minimum of 10 turns.
		
		Preferred Paradox           : %d
		Spellpower for Chronomancy  : %d
		Willpower Paradox Modifier  : %d
		Paradox after Willpower     : %d
		Current Anomaly Chance      : %d%%]]):format(duration, preference, spellpower, will_modifier, after_will, anomaly)
	end,
}

-- Talents from older versions to keep save files compatable
newTalent{
	name = "Stop",
	type = {"chronomancy/other",1},
	require = chrono_req1,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	cooldown = 12,
	tactical = { ATTACKAREA = 1, DISABLE = 3 },
	range = 6,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1.3, 2.7)) end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=self:spellFriendlyFire(), talent=t}
	end,
	getDuration = function(self, t) return math.ceil(self:combatTalentScale(self:getTalentLevel(t), 2.3, 4.3)) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 170, getParadoxSpellpower(self)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		local grids = self:project(tg, x, y, DamageType.STOP, t.getDuration(self, t))
		self:project(tg, x, y, DamageType.TEMPORAL, self:spellCrit(t.getDamage(self, t)))

		game.level.map:particleEmitter(x, y, tg.radius, "temporal_flash", {radius=tg.radius, tx=x, ty=y})
		game:playSoundNear(self, "talents/tidalwave")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		return ([[Inflicts %0.2f temporal damage, and attempts to stun all creatures in a radius %d ball for %d turns.
		The damage will scale with your Spellpower.]]):
		format(damage, radius, duration)
	end,
}

newTalent{
	name = "Slow",
	type = {"chronomancy/other", 1},
	require = chrono_req1,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 30) end,
	cooldown = 24,
	tactical = { ATTACKAREA = {TEMPORAL = 2}, DISABLE = 2 },
	range = 6,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.25, 3.25))	end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getSlow = function(self, t) return math.min(10 + self:combatTalentSpellDamage(t, 10, 50, getParadoxSpellpower(self))/ 100 , 0.6) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 60, getParadoxSpellpower(self)) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.CHRONOSLOW, {dam=t.getDamage(self, t), slow=t.getSlow(self, t)},
			self:getTalentRadius(t),
			5, nil,
			{type="temporal_cloud"},
			nil, self:spellFriendlyFire()
		)
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local slow = t.getSlow(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		return ([[Creates a time distortion in a radius of %d that lasts for %d turns, decreasing global speed by %d%% for 3 turns and inflicting %0.2f temporal damage each turn to all targets within the area.
		The slow effect and damage dealt will scale with your Spellpower.]]):
		format(radius, duration, 100 * slow, damDesc(self, DamageType.TEMPORAL, damage))
	end,
}

newTalent{
	name = "Swap",
	type = {"chronomancy/other", 1},
	require = chrono_req1,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 10,
	tactical = { DISABLE = 2, },
	requires_target = true,
	direct_hit = true,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	getConfuseDuration = function(self, t) return math.floor(self:combatTalentScale(self:getTalentLevel(t), 3, 7)) end,
	getConfuseEfficency = function(self, t) return math.min(50, self:getTalentLevelRaw(t) * 10) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		if tx then
			local _ _, tx, ty = self:canProject(tg, tx, ty)
			if tx then
				target = game.level.map(tx, ty, Map.ACTOR)
				if not target then return nil end
			end
		end
		
		-- checks for spacetime mastery hit bonus
		local power = getParadoxSpellpower(self)
		if self:knowTalent(self.T_SPACETIME_MASTERY) then
			power =  getParadoxSpellpower(self) * (1 + self:callTalent(self.T_SPACETIME_MASTERY, "getPower"))
		end
		
		if target:canBe("teleport") and self:checkHit(power, target:combatSpellResist() + (target:attr("continuum_destabilization") or 0)) then
			-- first remove the target so the destination tile is empty
			game.level.map:remove(target.x, target.y, Map.ACTOR)
			local px, py 
			px, py = self.x, self.y
			if self:teleportRandom(tx, ty, 0) then
				-- return the target at the casters old location
				game.level.map(px, py, Map.ACTOR, target)
				self.x, self.y, target.x, target.y = target.x, target.y, px, py
				game.level.map:particleEmitter(target.x, target.y, 1, "temporal_teleport")
				game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
				target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=self:combatSpellpower(0.3)})
				-- confuse them
				self:project(tg, target.x, target.y, DamageType.CONFUSION, { dur = t.getConfuseDuration(self, t), dam = t.getConfuseEfficency(self, t),	})
			else
				-- return the target without effect
				game.level.map(target.x, target.y, Map.ACTOR, target)
				game.logSeen(self, "The spell fizzles!")
			end
		else
			game.logSeen(target, "%s resists the swap!", target.name:capitalize())
		end

		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local duration = t.getConfuseDuration(self, t)
		local power = t.getConfuseEfficency(self, t)
		return ([[You manipulate the spacetime continuum in such a way that you switch places with another creature with in a range of %d.  The targeted creature will be confused (power %d%%) for %d turns.
		The spell's hit chance will increase with your Spellpower.]]):format (range, power, duration)
	end,
}

newTalent{
	name = "Spacetime Mastery",
	type = {"chronomancy/other", 1},
	mode = "passive",
	require = chrono_req1,
	points = 5,
	getPower = function(self, t) return math.max(0, self:combatTalentLimit(t, 1, 0.15, 0.5)) end, -- Limit < 100%
	cdred = function(self, t, scale) return math.floor(scale*self:combatTalentLimit(t, 0.8, 0.1, 0.5)) end, -- Limit < 80% of cooldown
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "talent_cd_reduction", {[self.T_BANISH] = t.cdred(self, t, 10)})
		self:talentTemporaryValue(p, "talent_cd_reduction", {[self.T_DIMENSIONAL_STEP] = t.cdred(self, t, 10)})
		self:talentTemporaryValue(p, "talent_cd_reduction", {[self.T_SWAP] = t.cdred(self, t, 10)})
		self:talentTemporaryValue(p, "talent_cd_reduction", {[self.T_TEMPORAL_WAKE] = t.cdred(self, t, 10)})
		self:talentTemporaryValue(p, "talent_cd_reduction", {[self.T_WORMHOLE] = t.cdred(self, t, 20)})
	end,
	info = function(self, t)
		local cooldown = t.cdred(self, t, 10)
		local wormhole = t.cdred(self, t, 20)
		return ([[Your mastery of spacetime reduces the cooldown of Banish, Dimensional Step, Swap, and Temporal Wake by %d, and the cooldown of Wormhole by %d.  Also improves your Spellpower for purposes of hitting targets with chronomancy effects that may cause continuum destabilization (Banish, Time Skip, etc.), as well as your chance of overcoming continuum destabilization, by %d%%.]]):
		format(cooldown, wormhole, t.getPower(self, t)*100)
		
	end,
}

newTalent{
	name = "Static History",
	type = {"chronomancy/other", 1},
	require = chrono_req1,
	points = 5,
	message = "@Source@ rearranges history.",
	cooldown = 24,
	tactical = { PARADOX = 2 },
	getDuration = function(self, t)
		local duration = math.floor(self:combatTalentScale(t, 1.5, 3.5))
		if self:knowTalent(self.T_PARADOX_MASTERY) then
			duration = duration + self:callTalent(self.T_PARADOX_MASTERY, "stabilityDuration")
		end
		return duration
	end,
	getReduction = function(self, t) return self:combatTalentSpellDamage(t, 20, 200) end,
	action = function(self, t)
		self:incParadox (- t.getReduction(self, t))
		game:playSoundNear(self, "talents/spell_generic")
		self:setEffect(self.EFF_SPACETIME_STABILITY, t.getDuration(self, t), {})
		return true
	end,
	info = function(self, t)
		local reduction = t.getReduction(self, t)
		local duration = t.getDuration(self, t)
		return ([[By slightly reorganizing history, you reduce your Paradox by %d and temporarily stabilize the timeline; this allows chronomancy to be used without chance of failure for %d turns (backfires and anomalies may still occur).
		The paradox reduction will increase with your Spellpower.]]):
		format(reduction, duration)
	end,
}

newTalent{
	name = "Quantum Feed",
	type = {"chronomancy/other", 1},
	require = chrono_req1,
	mode = "sustained",
	points = 5,
	sustain_stamina = 50,
	sustain_paradox = 100,
	cooldown = 18,
	tactical = { BUFF = 2 },
	getPower = function(self, t) return self:combatTalentScale(t, 1.5, 7.5, 0.75) + self:combatTalentStatDamage(t, "wil", 5, 20) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/arcane")
		return {
			stats = self:addTemporaryValue("inc_stats", {[self.STAT_MAG] = t.getPower(self, t)}),
			spell = self:addTemporaryValue("combat_spellresist", t.getPower(self, t)),
			particle = self:addParticles(Particles.new("arcane_power", 1)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("inc_stats", p.stats)
		self:removeTemporaryValue("combat_spellresist", p.spell)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[You've learned to boost your magic through your control over the spacetime continuum.  Increases your Magic and your Spell Save by %d.
		The effect will scale with your Willpower.]]):format(power)
	end
}

newTalent{
	name = "Moment of Prescience",
	type = {"chronomancy/other", 1},
	require = chrono_req1,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	cooldown = 18,
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 18, 3, 10.5)) end, -- Limit < 18
	getPower = function(self, t) return self:combatTalentScale(t, 4, 15) end, -- Might need a buff
	tactical = { BUFF = 4 },
	no_energy = true,
	no_npc_use = true,
	action = function(self, t)
		local power = t.getPower(self, t)
		-- check for Spin Fate
		local eff = self:hasEffect(self.EFF_SPIN_FATE)
		if eff then
			local bonus = math.max(0, (eff.cur_save_bonus or eff.save_bonus) / 2)
			power = power + bonus
		end

		self:setEffect(self.EFF_PRESCIENCE, t.getDuration(self, t), {power=power})
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		local duration = t.getDuration(self, t)
		return ([[You pull your awareness fully into the moment, increasing your stealth detection, see invisibility, defense, and accuracy by %d for %d turns.
		If you have Spin Fate active when you cast this spell, you'll gain a bonus to these values equal to 50%% of your spin.
		This spell takes no time to cast.]]):
		format(power, duration)
	end,
}