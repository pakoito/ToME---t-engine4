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
		return ([[Learn how to coat your melee weapons, sling and bow ammo with poison. Each level, you will learn a new kind of poison:
		Level 1: Deadly Poison
		Level 2: Numbing Poison
		Level 3: Insidious Poison
		Level 4: Crippling Poison
		Level 5: Stoning Poison
		New poisons can also be learned from special teachers in the world.
		Also increases the effectiveness of your poisons by %d%%. (The effect varies for each poison.)
		Coating your weapons in poisons does not break stealth.
		You may only have two poisons active at once.
		Every time you hit a creature with one of your weapons, you have a %d%% chance to randomly apply one of your active poisons.
		The chance to apply a poison lowers if the target is already poisoned.]]):
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
	archery_onreach = function(self, t, x, y, tg, target)
		if not target then return end

		local nb = 0
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.subtype.poison then nb = nb + 1 end
		end
		tg.archery.mult = self:combatTalentWeaponDamage(t, 0.5 + nb * 0.6, 0.9 + nb * 1)
	end,
	speed = "weapon",
	action = function(self, t)
		if not self:hasArcheryWeapon() then
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
		else
			local targets = self:archeryAcquireTargets(nil, {one_shot=true})
			if not targets then return end
			self:archeryShoot(targets, t, nil, {mult=1, damtype=DamageType.NATURE})
		end

		return true
	end,
	info = function(self, t)
		local dam0 = 100 * self:combatTalentWeaponDamage(t, 0.5, 0.9)
		local dam1 = 100 * self:combatTalentWeaponDamage(t, 0.5 + 0.6,   0.9 + 1)
		local dam2 = 100 * self:combatTalentWeaponDamage(t, 0.5 + 0.6*2, 0.9 + 1*2)
		local dam3 = 100 * self:combatTalentWeaponDamage(t, 0.5 + 0.6*3, 0.9 + 1*3)
		return ([[You hit your target, doing nature damage depending on the number of poisons on the target:
		- 0 poisons: %d%%
		- 1 poisons: %d%%
		- 2 poisons: %d%%
		- 3 poisons: %d%%
		If you wield a bow or sling you shoot instead.
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
		return ([[Reduces the duration of all poisons on the target by 50%%, but increases their damage by %d%%.
		The effect increases with your Cunning.]]):
		format(100 + self:combatTalentStatDamage(t, "cun", 40, 250))
	end,
}

newTalent{
	name = "Toxic Death",
	type = {"cunning/poisons", 4},
	points = 5,
	mode = "passive",
	require = cuns_req_high4,
	getRadius = function(self, t) return self:combatTalentScale(t, 1, 3) end,
	on_kill = function(self, t, target)
		local poisons = {}
		for k, v in pairs(target.tmp) do
			local e = target.tempeffect_def[k]
			if e.subtype.poison and v.src and v.src == self then
				poisons[k] = target:copyEffect(k)
			end
		end

		local tg = {type="ball", range = 10, radius=t.getRadius(self, t), selffire = false, friendlyfire = false, talent=t}
		self:project(tg, target.x, target.y, function(tx, ty)
			local target2 = game.level.map(tx, ty, Map.ACTOR)
			if not target2 or target2 == self then return end
			for eff, p in pairs(poisons) do
				target2:setEffect(eff, p.dur, table.clone(p))
			end
		end)
	end,
	info = function(self, t)
		return ([[When you kill a creature, all the poisons affecting it will have a %d%% chance to spread to foes in a radius of %d.]]):format(20 + self:getTalentLevelRaw(t) * 8, t.getRadius(self, t))
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
	no_unlearn_last = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(self:getTalentLevel(self.T_VILE_POISONS), 6, 10)) end,
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
	no_unlearn_last = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(self:getTalentLevel(self.T_VILE_POISONS), 6, 10)) end,
	getDOT = function(self, t) return 8 + self:combatTalentStatDamage(self.T_VILE_POISONS, "cun", 10, 50) * 0.4 end,
	getEffect = function(self, t) return self:combatTalentLimit(self:getTalentLevel(self.T_VILE_POISONS), 100, 13, 25) end, -- Limit effect to <100%
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
		The effects scale with your Cunning.]]):
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
	no_unlearn_last = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(self:getTalentLevel(self.T_VILE_POISONS), 6, 10)) end,
	getDOT = function(self, t) return 8 + self:combatTalentStatDamage(self.T_VILE_POISONS, "cun", 10, 50) * 0.4 end,
	getEffect = function(self, t) return self:combatTalentLimit(self:getTalentLevel(self.T_VILE_POISONS), 100, 35.5, 57.5) end, -- Limit -healing effect to <100%
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
		Poisoned creatures have their healing reduced by %d%%.
		The effects scale with your Cunning.]]):
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
	no_unlearn_last = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(self:getTalentLevel(self.T_VILE_POISONS), 4, 8)) end,
	getDOT = function(self, t) return 8 + self:combatTalentStatDamage(self.T_VILE_POISONS, "cun", 10, 50) * 0.4 end,
	getEffect = function(self, t) return self:combatTalentLimit(self:getTalentLevel(self.T_VILE_POISONS), 50, 13, 25) end, --	Limit effect to < 50%
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
		Every time a poisoned creature tries to use a talent, it will have a %d%% chance to fail and lose a turn.
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
	no_unlearn_last = true,
	getDuration = function(self, t) return math.ceil(self:combatTalentLimit(self:getTalentLevel(self.T_VILE_POISONS), 0, 11, 7)) end, -- Make sure it takes at least 1 turn
	getDOT = function(self, t) return 8 + self:combatTalentStatDamage(self.T_VILE_POISONS, "cun", 10, 30) * 0.4 end,
	getEffect = function(self, t) return math.floor(self:combatTalentScale(self:getTalentLevel(self.T_VILE_POISONS), 3, 5)) end,
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
		When the poison runs its full duration, the victim will turn to stone for %d turns.
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
	no_unlearn_last = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(self:getTalentLevel(self.T_VILE_POISONS), 3, 7)) end,
	getDOT = function(self, t) return 8 + self:combatTalentStatDamage(self.T_VILE_POISONS, "cun", 10, 30) * 0.4 end,
	getEffect = function(self, t) return self:combatLimit(self:combatTalentStatDamage(self.T_VILE_POISONS, "cun", 15, 35), 100, 0, 0, 25.8, 25.8) end, -- Limit < 100%
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
		The resistances of poisoned creatures are reduced by %d%%.
		The damage scales with your Cunning.]]):
		format(damDesc(self, DamageType.NATURE, t.getDOT(self, t)), t.getDuration(self, t), t.getEffect(self, t))
	end,
}
