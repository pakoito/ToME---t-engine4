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
	name = "Reclaim",
	type = {"wild-gift/eyals-fury", 1},
	require = gifts_req_high1,
	points = 5,
	equilibrium = 5,
	range = 7,
	cooldown = 5,
	tactical = { ATTACK = { NATURE = 1, ACID = 1 } },
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t), talent=t, display = {particle=particle, trail=trail}, friendlyfire=false, friendlyblock=false}
	end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 320) end,
	undeadBonus = 25,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not (tx and ty) or core.fov.distance(self.x, self.y, tx, ty) > self:getTalentRange(t) then return nil end
		if not target then return true end
		local dam = self:mindCrit(t.getDamage(self, t))*(1 + ((target.undead or target.type == "construct") and t.undeadBonus/100 or 0))		
		self:project(tg, tx, ty, DamageType.ACID, dam*0.5)
		self:project(tg, tx, ty, DamageType.NATURE, dam*0.5)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[You focus the inexorable pull of nature against a single creature, eroding it and allowing it to be reclaimed by the cycle of life.
		This deals %0.1f Nature and %0.1f Acid damage to the target, and is particularly devastating against undead and constructs, dealing %d%% more damage to them.
		The damage increases with your Mindpower.]]):
		format(damDesc(self, DamageType.NATURE, dam/2), damDesc(self, DamageType.ACID, dam/2), t.undeadBonus)
	end,
}

newTalent{
	name = "Nature's Defiance",
	type = {"wild-gift/eyals-fury", 2},
	require = gifts_req_high2,
	points = 5,
	mode = "passive",
	getSave = function(self, t) return self:combatTalentMindDamage(t, 5, 50) end,
	getResist = function(self, t) return self:combatTalentMindDamage(t, 5, 40) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	getAffinity = function(self, t) return self:combatTalentLimit(t, 50, 5, 20) end, -- Limit <50%
	getPower = function(self, t) return self:combatTalentMindDamage(t, 2, 8) end,
	trigger = function(self, t, target, source_t) -- called in damage_types.lua default projector
		self:setEffect(self.EFF_NATURE_REPLENISHMENT, t.getDuration(self, t), {power = t.getPower(self, t)})
		return true
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_spellresist", t.getSave(self, t))
		self:talentTemporaryValue(p, "resists", {[DamageType.ARCANE]=t.getResist(self, t)})
		self:talentTemporaryValue(p, "damage_affinity", {[DamageType.NATURE]=t.getAffinity(self, t)})
	end,
	info = function(self, t)
		local p = t.getPower(self, t)
		return ([[Your devotion to nature has made your body more attuned to the natural world and resistant to unnatural energies.
		You gain %d Spell save, %0.1f%% Arcane resistance, and %0.1f%% Nature damage affinity.
		You defy arcane forces, so that any time you take damage from a spell, you restore %0.1f Equilibrium each turn for %d turns.
		The effects increase with your Mindpower.]]):
		format(t.getSave(self, t), t.getResist(self, t), t.getAffinity(self, t), t.getPower(self, t), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Acidfire", 
	type = {"wild-gift/eyals-fury", 3},
	require = gifts_req_high3,
	points = 5,
	equilibrium = 20,
	cooldown = 25,
	range = 8,
	radius = 4,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	tactical = { ATTACKAREA = { ACID = 2 },  DISABLE = {blind = 1} },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 70) end,
	getChance = function(self, t) return self:combatTalentLimit(t, 100, 20, 40) end, --Limit < 100%
	removeEffect = function(target) -- remove one random beneficial magical effect or sustain
	-- Go through all beneficial magical effects
		local effs = {}
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.type == "magical" and e.status == "beneficial" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		-- Go through all sustained spells
		for tid, act in pairs(target.sustain_talents) do
			if act then
				local talent = target:getTalentFromId(tid)
				if talent.is_spell then effs[#effs+1] = {"talent", tid} end
			end
		end
		if #effs == 0 then return end
		local eff = rng.tableRemove(effs)

		if eff[1] == "effect" then
			target:removeEffect(eff[2])
		else
			target:forceUseTalent(eff[2], {ignore_energy=true})
		end
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		local eff = game.level.map:addEffect(self,
			x, y, t.getDuration(self, t), -- duration
			engine.DamageType.ACID_BLIND, t.getDamage(self, t),
			self:getTalentRadius(t), -- radius
			5, nil,
			{type="vapour"},
			function(eff) --update_fct(effect)
				local act
				for i, g in pairs(eff.grids) do
					for j, _ in pairs(eff.grids[i]) do
						act = game.level.map(i, j, engine.Map.ACTOR)
						if act then
							if rng.percent(eff.chance) then
								eff.removeEffect(act)
							end
						end
					end
				end
			end,
			false, -- no friendly fire
			false -- no self fire
		)
		eff.chance = t.getChance(self, t)
		eff.removeEffect = t.removeEffect
		eff.name = "Acidfire cloud"
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		return ([[You call upon the earth to create a blinding, corrosive cloud in an area of radius %d for %d turns.
		Each turn, this cloud deals %0.1f Acid damage to each foe while (%d%% chance) burning away one beneficial magical effect.
		The damage increases with your Mindpower.]]):
		format(self:getTalentRadius(t), t.getDuration(self, t), damDesc(self, DamageType.ACID, t.getDamage(self, t)), t.getChance(self, t))
	end,
}

newTalent{
	name = "Eyal's Wrath",
	type = {"wild-gift/eyals-fury", 4},
	require = gifts_req_high5,
	points = 5,
	equilibrium = 20,
	cooldown = 20,
	radius = function(self, t) return math.floor(self:combatTalentLimit(t, 10, 4, 6)) end, --Limit < 10
	tactical = { ATTACKAREA = { Nature = 2 },  EQUILIBRIUM = 1 },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 100) end,
	getDrain = function(self, t) return self:combatTalentMindDamage(t, 10, 30) end,
	drainMagic = function(eff, act)
		if act:attr("invulnerable") or act:attr("no_timeflow") then return end
		local mana = math.min(eff.drain, act:getMana())
		local vim = math.min(eff.drain / 2, act:getVim())
		local positive = math.min(eff.drain / 4, act:getPositive())
		local negative = math.min(eff.drain / 4, act:getNegative())
		act:incMana(-mana); act:incVim(-vim); act:incPositive(-positive); act:incNegative(-negative)
		local drain = mana + vim + positive + negative
		if drain > 0 then
			game:delayedLogMessage(eff.src, act, "Eyal's Wrath", ("#CRIMSON#%s drains magical energy!"):format(eff:getName())) 
			eff.src:incEquilibrium(-drain/10)
		end
	end,
	action = function(self, t)
		-- Add a lasting map effect
		local eff = game.level.map:addEffect(self,
			self.x, self.y, 7,
			DamageType.NATURE, t.getDamage(self, t),
			t.radius(self, t),
			5, nil,
			{type="generic_vortex", args = {radius = t.radius(self, t), rm = 5, rM=55, gm=250, gM=255, bm = 180, bM=255, am= 35, aM=90, density = 100}, only_one=true },
			function(eff)
				eff.x = eff.src.x
				eff.y = eff.src.y
				local act
				for i, g in pairs(eff.grids) do
					for j, _ in pairs(eff.grids[i]) do
						act = game.level.map(i, j, engine.Map.ACTOR)
						if act and act ~= eff.src and act:reactionToward(eff.src) < 0 then
							eff.drainMagic(eff, act)
						end
					end
				end
				return true
			end,
			false, false
		)
		eff.drain = t.getDrain(self, t)
		eff.drainMagic = t.drainMagic
		eff.name = "Eyal's Wrath"
		game:playSoundNear(self, "talents/thunderstorm")
		return true
	end,
	info = function(self, t)
		local drain = t.getDrain(self, t)
		return ([[You draw deeply from your connection with nature to create a radius %d storm of natural forces around you for %d turns.
		This storm moves with you and deals %0.1f Nature damage each turn to all foes it hits.
		In addtion, it will drain up to %d Mana, %d Vim, %d Positive, and %d Negative energy from each enemy within it's area every turn, while you restore Equilibrium equal to 10%% of the amount drained.
		The damage and drain increase with your Mindpower.]]):
		format(self:getTalentRadius(t), t.getDuration(self, t), damDesc(self, DamageType.NATURE, t.getDamage(self, t)), drain, drain/2, drain/4, drain/4)
	end,
}
