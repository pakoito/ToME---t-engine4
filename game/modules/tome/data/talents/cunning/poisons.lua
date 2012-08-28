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

local Map = require "engine.Map"

----------------------------------------------------------------
-- Poisons
----------------------------------------------------------------

newTalent{
	name = "Vile Poisons",
	type = {"cunning/poisons", 1},
	points = 5,
	mode = "passive",
	require = cuns_req_high1,
	on_learn = function(self, t)
		local lev = self:getTalentLevelRaw(t)
		if lev == 1 then
			self.vile_poisons = {}
			self:learnTalent(self.T_DEADLY_POISON, true, nil, {no_unlearn=true})
		elseif lev == 2 then
			self:learnTalent(self.T_NUMBING_POISON, true, nil, {no_unlearn=true})
		elseif lev == 3 then
			self:learnTalent(self.T_INSIDIOUS_POISON, true, nil, {no_unlearn=true})
		elseif lev == 4 then
			self:learnTalent(self.T_CRIPPLING_POISON, true, nil, {no_unlearn=true})
		elseif lev == 5 then
			self:learnTalent(self.T_STONING_POISON, true, nil, {no_unlearn=true})
		end
	end,
	on_unlearn = function(self, t)
		local lev = self:getTalentLevelRaw(t)
		if lev == 0 then
			self:unlearnTalent(self.T_DEADLY_POISON)
			self.vile_poisons = nil
		elseif lev == 1 then
			self:unlearnTalent(self.T_NUMBING_POISON)
		elseif lev == 2 then
			self:unlearnTalent(self.T_INSIDIOUS_POISON)
		elseif lev == 3 then
			self:unlearnTalent(self.T_CRIPPLING_POISON)
		elseif lev == 4 then
			self:unlearnTalent(self.T_STONING_POISON)
		end
	end,
	info = function(self, t)
		return ([[Learn how to coat your weapons with poison. Each level you will learn a new kind of poison:
		Level 1: Deadly Poison
		Level 2: Numbing Poison
		Level 3: Insidious Poison
		Level 4: Crippling Poison
		Level 5: Stoning Poison
		New poisons can also be learned from special teachers in the world.
		Also increases the effectiveness of your poisons by %d%%. (The effect varies for each poison).
		Coating your weapons in poisons does not break stealth.
		You may only have two poisons active at once.
		Every time you hit a creature with one of your weapons you have %d%% chance to randomly apply one of your active poisons.
		The chance to apply a poison lowers if the target already has poisons.]]):
		format(self:getTalentLevel(t) * 20, 20 + self:getTalentLevel(t) * 5)
	end,
}

newTalent{
	name = "Venomous Strike",
	type = {"cunning/poisons", 2},
	points = 5,
	cooldown = 5,
	stamina = 7,
	require = cuns_req_high2,
	requires_target = true,
	tactical = { ATTACK = function(self, t, target)
		local nb = 0
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.subtype.poison then nb = nb + 1 end
		end
		return { NATURE = nb}
	end },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local nb = 0
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.subtype.poison then nb = nb + 1 end
		end
		local dam = self:combatTalentWeaponDamage(t, 0.5 + nb * 0.6, 0.9 + nb * 1)

		self:attackTarget(target, DamageType.NATURE, dam, true)

		return true
	end,
	info = function(self, t)
		local dam0 = 100 * self:combatTalentWeaponDamage(t, 0.5, 0.9)
		local dam1 = 100 * self:combatTalentWeaponDamage(t, 0.5 + 0.6,   0.9 + 1)
		local dam2 = 100 * self:combatTalentWeaponDamage(t, 0.5 + 0.6*2, 0.9 + 1*2)
		local dam3 = 100 * self:combatTalentWeaponDamage(t, 0.5 + 0.6*3, 0.9 + 1*3)
		return ([[You hit your target doing nature damage depending on the number of poisons on the target:
		- 0 poisons: %d%%
		- 1 poisons: %d%%
		- 2 poisons: %d%%
		- 3 poisons: %d%%
		]]):
		format(dam0, dam1, dam2, dam3)
	end,
}
newTalent{
	name = "Empower Poisons",
	type = {"cunning/poisons", 3},
	points = 5,
	cooldown = 24,
	stamina = 15,
	require = cuns_req_high3,
	requires_target = true,
	no_energy = true,
	tactical = { ATTACK = {NATURE = 1} },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local mod = (100 + self:combatTalentStatDamage(t, "cun", 40, 250)) / 100
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.subtype.poison then
				p.dur = math.ceil(p.dur / 2)
				p.power = (p.power or 0) * mod
			end
		end

		game.level.map:particleEmitter(target.x, target.y, 1, "slime")
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Reduce the duration of all poisons on the target by 50%% but increases their damage by %d%%.
		Effect increases with your Cunning.]]):
		format(100 + self:combatTalentStatDamage(t, "cun", 40, 250))
	end,
}

newTalent{
	name = "Toxic Death",
	type = {"cunning/poisons", 4},
	points = 5,
	mode = "passive",
	require = cuns_req_high4,
	on_kill = function(self, t, target)
		local possible = {}
		for _, coord in pairs(util.adjacentCoords(target.x, target.y)) do
			if game.level.map:isBound(coord[1], coord[2]) then
				local tgt = game.level.map(coord[1], coord[2], Map.ACTOR)
				if tgt and not tgt.dead then possible[tgt] = true end
			end
		end
		possible[self] = nil
		possible[target] = nil
		possible = table.keys(possible)

		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.subtype.poison and p.src == self then
				for i, tgt in ipairs(possible) do if rng.percent(20 + self:getTalentLevelRaw(t) * 8) and not tgt:hasEffect(eff_id) and self:reactionToward(tgt) < 0 then
					p.src = nil
					local pp = table.clone(p)
					pp.src = self
					p.src = self
					tgt:setEffect(eff_id, pp.dur, pp)
				end end
			end
		end
	end,
	info = function(self, t)
		return ([[When you kill a creature all the poisons affecting it will have %d%% chances to spread to each adjacent foes.]]):format(20 + self:getTalentLevelRaw(t) * 8)
	end,
}

----------------------------------------------------------------
-- Poisons effects
----------------------------------------------------------------

local function checkChance(self, target)
	local chance = 20 + self:getTalentLevel(self.T_VILE_POISONS) * 5
	local nb = 1
	for eff_id, p in pairs(target.tmp) do
		local e = target.tempeffect_def[eff_id]
		if e.subtype.poison then nb = nb + 1 end
	end
	return rng.percent(chance / nb)
end

local function cancelPoisons(self)
	local todel = {}
	for tid, p in pairs(self.sustain_talents) do
		local t = self:getTalentFromId(tid)
		if t.type[1] == "cunning/poisons-effects" then
			todel[#todel+1] = tid
		end
	end
	while #todel > 1 do self:forceUseTalent(rng.tableRemove(todel), {ignore_energy=true}) end
end

newTalent{
	name = "Deadly Poison",
	type = {"cunning/poisons-effects", 1},
	points = 1,
	mode = "sustained",
	cooldown = 10,
	no_break_stealth = true,
	no_energy = true,
	tactical = { BUFF = 2 },
	getDuration = function(self, t) return 5 + self:getTalentLevel(self.T_VILE_POISONS) end,
	getDOT = function(self, t) return 8 + self:combatTalentStatDamage(self.T_VILE_POISONS, "cun", 10, 60) * 0.4 end,
	proc = function(self, t, target)
		if not checkChance(self, target) then return end
		target:setEffect(target.EFF_POISONED, t.getDuration(self, t), {src=self, power=t.getDOT(self, t), max_power=t.getDOT(self, t) * 4})
	end,
	activate = function(self, t)
		cancelPoisons(self)
		self.vile_poisons = self.vile_poisons or {}
		self.vile_poisons[t.id] = true
		return {}
	end,
	deactivate = function(self, t, p)
		self.vile_poisons[t.id] = nil
		return true
	end,
	info = function(self, t)
		return ([[Coat your weapons with a deadly poison, inflicting %d nature damage per turn for %d turns.
		The damage scales with your Cunning.
		Every application of the poison stacks.]]):
		format(damDesc(self, DamageType.NATURE, t.getDOT(self, t)), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Numbing Poison",
	type = {"cunning/poisons-effects", 1},
	points = 1,
	mode = "sustained",
	cooldown = 10,
	no_break_stealth = true,
	no_energy = true,
	tactical = { BUFF = 2 },
	getDuration = function(self, t) return 5 + self:getTalentLevel(self.T_VILE_POISONS) end,
	getDOT = function(self, t) return 8 + self:combatTalentStatDamage(self.T_VILE_POISONS, "cun", 10, 50) * 0.4 end,
	getEffect = function(self, t) return 10 + self:getTalentLevel(self.T_VILE_POISONS) * 3 end,
	proc = function(self, t, target)
		if not checkChance(self, target) then return end
		target:setEffect(target.EFF_NUMBING_POISON, t.getDuration(self, t), {src=self, power=t.getDOT(self, t), reduce=t.getEffect(self, t)})
	end,
	activate = function(self, t)
		cancelPoisons(self)
		self.vile_poisons = self.vile_poisons or {}
		self.vile_poisons[t.id] = true
		return {}
	end,
	deactivate = function(self, t, p)
		self.vile_poisons[t.id] = nil
		return true
	end,
	info = function(self, t)
		return ([[Coat your weapons with a numbing poison, inflicting %d nature damage per turn for %d turns.
		Poisoned creatures will deal %d%% less damage.
		The effects scales with your Cunning.]]):
		format(damDesc(self, DamageType.NATURE, t.getDOT(self, t)), t.getDuration(self, t), t.getEffect(self, t))
	end,
}

newTalent{
	name = "Insidious Poison",
	type = {"cunning/poisons-effects", 1},
	points = 1,
	mode = "sustained",
	cooldown = 10,
	no_break_stealth = true,
	no_energy = true,
	tactical = { BUFF = 2 },
	getDuration = function(self, t) return 5 + self:getTalentLevel(self.T_VILE_POISONS) end,
	getDOT = function(self, t) return 8 + self:combatTalentStatDamage(self.T_VILE_POISONS, "cun", 10, 50) * 0.4 end,
	getEffect = function(self, t) return 30 + self:getTalentLevel(self.T_VILE_POISONS) * 5.5 end,
	proc = function(self, t, target)
		if not checkChance(self, target) then return end
		target:setEffect(target.EFF_INSIDIOUS_POISON, t.getDuration(self, t), {src=self, power=t.getDOT(self, t), heal_factor=t.getEffect(self, t)})
	end,
	activate = function(self, t)
		cancelPoisons(self)
		self.vile_poisons = self.vile_poisons or {}
		self.vile_poisons[t.id] = true
		return {}
	end,
	deactivate = function(self, t, p)
		self.vile_poisons[t.id] = nil
		return true
	end,
	info = function(self, t)
		return ([[Coat your weapons with an insidious poison, inflicting %d nature damage per turn for %d turns.
		Poisoned creatures heals are reduced by %d%%.
		The effects scales with your Cunning.]]):
		format(damDesc(self, DamageType.NATURE, t.getDOT(self, t)), t.getDuration(self, t), t.getEffect(self, t))
	end,
}

newTalent{
	name = "Crippling Poison",
	type = {"cunning/poisons-effects", 1},
	points = 1,
	mode = "sustained",
	cooldown = 10,
	no_break_stealth = true,
	no_energy = true,
	tactical = { BUFF = 2 },
	getDuration = function(self, t) return 3 + self:getTalentLevel(self.T_VILE_POISONS) end,
	getDOT = function(self, t) return 8 + self:combatTalentStatDamage(self.T_VILE_POISONS, "cun", 10, 50) * 0.4 end,
	getEffect = function(self, t) return 10 + self:getTalentLevel(self.T_VILE_POISONS) * 3 end,
	proc = function(self, t, target)
		if not checkChance(self, target) then return end
		target:setEffect(target.EFF_CRIPPLING_POISON, t.getDuration(self, t), {src=self, power=t.getDOT(self, t), fail=t.getEffect(self, t)})
	end,
	activate = function(self, t)
		cancelPoisons(self)
		self.vile_poisons = self.vile_poisons or {}
		self.vile_poisons[t.id] = true
		return {}
	end,
	deactivate = function(self, t, p)
		self.vile_poisons[t.id] = nil
		return true
	end,
	info = function(self, t)
		return ([[Coat your weapons with a crippling poison, inflicting %d nature damage per turn for %d turns.
		Every time a poisoned creature tries to use a talent it will have %d%% chances to fail and lose a turn.
		The damage scales with your Cunning.]]):
		format(damDesc(self, DamageType.NATURE, t.getDOT(self, t)), t.getDuration(self, t), t.getEffect(self, t))
	end,
}

newTalent{
	name = "Stoning Poison",
	type = {"cunning/poisons-effects", 1},
	points = 1,
	mode = "sustained",
	cooldown = 10,
	no_break_stealth = true,
	no_energy = true,
	tactical = { BUFF = 2 },
	getDuration = function(self, t) return 12 - self:getTalentLevel(self.T_VILE_POISONS) end,
	getDOT = function(self, t) return 8 + self:combatTalentStatDamage(self.T_VILE_POISONS, "cun", 10, 30) * 0.4 end,
	getEffect = function(self, t) return math.ceil(2 + self:getTalentLevel(t) / 2) end,
	proc = function(self, t, target)
		if not checkChance(self, target) then return end
		if target:hasEffect(target.EFF_STONED) or target:hasEffect(target.EFF_STONE_POISON) then return end
		target:setEffect(target.EFF_STONE_POISON, t.getDuration(self, t), {src=self, power=t.getDOT(self, t), stone=t.getEffect(self, t)})
	end,
	activate = function(self, t)
		cancelPoisons(self)
		self.vile_poisons = self.vile_poisons or {}
		self.vile_poisons[t.id] = true
		return {}
	end,
	deactivate = function(self, t, p)
		self.vile_poisons[t.id] = nil
		return true
	end,
	info = function(self, t)
		return ([[Coat your weapons with a stoning poison, inflicting %d nature damage per turn for %d turns.
		When the poison ends the victim turns into stone for %d turns.
		The damage scales with your Cunning.]]):
		format(damDesc(self, DamageType.NATURE, t.getDOT(self, t)), t.getDuration(self, t), t.getEffect(self, t))
	end,
}


newTalent{
	name = "Vulnerability Poison",
	type = {"cunning/poisons-effects", 1},
	points = 1,
	mode = "sustained",
	cooldown = 10,
	no_break_stealth = true,
	no_energy = true,
	is_spell = true,
	tactical = { BUFF = 2 },
	getDuration = function(self, t) return 12 - self:getTalentLevel(self.T_VILE_POISONS) end,
	getDOT = function(self, t) return 8 + self:combatTalentStatDamage(self.T_VILE_POISONS, "cun", 10, 30) * 0.4 end,
	getEffect = function(self, t) return self:combatTalentStatDamage(self.T_VILE_POISONS, "cun", 15, 35) end,
	proc = function(self, t, target)
		if not checkChance(self, target) then return end
		target:setEffect(target.EFF_VULNERABILITY_POISON, t.getDuration(self, t), {src=self, power=t.getDOT(self, t), res=t.getEffect(self, t)})
	end,
	activate = function(self, t)
		cancelPoisons(self)
		self.vile_poisons = self.vile_poisons or {}
		self.vile_poisons[t.id] = true
		return {}
	end,
	deactivate = function(self, t, p)
		self.vile_poisons[t.id] = nil
		return true
	end,
	info = function(self, t)
		return ([[Coat your weapons with an arcane poison, inflicting %d arcane damage per turn for %d turns.
		Poisoned creatures resistances are reduced by %d%%.
		The damage scales with your Cunning.]]):
		format(damDesc(self, DamageType.NATURE, t.getDOT(self, t)), t.getDuration(self, t), t.getEffect(self, t))
	end,
}

