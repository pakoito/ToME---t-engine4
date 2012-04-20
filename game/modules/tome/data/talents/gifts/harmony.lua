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

newTalent{
	name = "Waters of Life",
	type = {"wild-gift/harmony", 1},
	require = gifts_req1,
	points = 5,
	cooldown = 30,
	equilibrium = 10,
	tactical = { HEAL=2 },
	no_energy = true,
	on_pre_use = function(self, t)
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.subtype.disease or e.subtype.poison then
				return true
			end
		end
		return false
	end,
	is_heal = true,
	action = function(self, t)
		local nb = 0
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.subtype.disease or e.subtype.poison then
				nb = nb + 1
			end
		end
		self:heal(self:mindCrit(nb * self:combatTalentStatDamage(t, "wil", 20, 60)))

		self:setEffect(self.EFF_WATERS_OF_LIFE, 5 + self:getTalentLevel(t), {})

		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		return ([[The waters of life flow through you, purifying any poisons or diseases currently affecting you.
		For %d turns all poisons and diseases will heal you instead of damaging you.
		When activated it also heals you for %d life per diseases or poisons on you.
		The healing will increase with your Willpower stat.]]):
		format(5 + self:getTalentLevel(t), self:combatTalentStatDamage(t, "wil", 20, 60))
	end,
}

newTalent{
	name = "Elemental Harmony",
	type = {"wild-gift/harmony", 2},
	require = gifts_req2,
	points = 5,
	mode = "sustained",
	sustain_equilibrium = 20,
	cooldown = 30,
	tactical = { BUFF = 3 },
	activate = function(self, t)
		return {
			tmpid = self:addTemporaryValue("elemental_harmony", self:getTalentLevel(t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("elemental_harmony", p.tmpid)
		return true
	end,
	info = function(self, t)
		local power = self:getTalentLevel(t)
		local turns = 5 + math.ceil(power)
		local fire = 100 * (0.1 + power / 16)
		local cold = 3 + power * 2
		local lightning = math.floor(power)
		local acid = 5 + power * 2
		local nature = 5 + power * 1.4
		return ([[Befriend the natural elements that constitute nature. Each time you are hit by one of the elements you gain a special effect for %d turns. This can only happen every %d turns.
		Fire: +%d%% global speed
		Cold: +%d armour
		Lightning: +%d to all stats
		Acid: +%0.2f life regen
		Nature: +%d%% to all resists]]):
		format(turns, turns, fire, cold, lightning, acid, nature)
	end,
}

newTalent{
	name = "One with Nature",
	type = {"wild-gift/harmony", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 15,
	cooldown = 30,
	no_energy = true,
	tactical = { BUFF = 2 },
	on_pre_use = function(self, t) return self:hasEffect(self.EFF_INFUSION_COOLDOWN) end,
	action = function(self, t)
		self:removeEffect(self.EFF_INFUSION_COOLDOWN)
		local tids = {}
		local nb = self:getTalentLevelRaw(t)
		for tid, _ in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if tt.type[1] == "inscriptions/infusions" and self:isTalentCoolingDown(tt) then tids[#tids+1] = tid end
		end
		for i = 1, nb do
			if #tids == 0 then break end
			local tid = rng.tableRemove(tids)
			self.talents_cd[tid] = self.talents_cd[tid] - (1 + math.floor(self:getTalentLevel(t) / 2))
			if self.talents_cd[tid] <= 0 then self.talents_cd[tid] = nil end
		end
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		local turns = 1 + math.floor(self:getTalentLevel(t) / 2)
		local nb = self:getTalentLevelRaw(t)
		return ([[Commune with nature, removing the infusion saturation effect and reducing the cooldown of %d infusions by %d turns.]]):
		format(nb, turns)
	end,
}

newTalent{
	name = "Healing Nexus",
	type = {"wild-gift/harmony", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 24,
	cooldown = 20,
	range = 10,
	tactical = { DISABLE = 3, HEAL = 0.5 },
	direct_hit = true,
	requires_target = true,
	range = 0,
	radius = function(self, t) return 1 + self:getTalentLevelRaw(t) end,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=true, talent=t} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local grids = self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_HEALING_NEXUS, 3 + self:getTalentLevelRaw(t), {src=self, pct=0.4 + self:getTalentLevel(t) / 10, eq=5 + self:getTalentLevel(t)})
		end)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_acid", {radius=tg.radius})
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		return ([[A wave a natural energies flow around you in a radius of %d, all creatures hit will suffer healing nexus for %d turns.
		While under the effect all healing done to the creature will instead heal you for %d%% of the heal value (and no healing at all goes to the target).
		Each heal leeched will also restore %d equilibrium]]):
		format(self:getTalentRadius(t), 3 + self:getTalentLevelRaw(t), (0.4 + self:getTalentLevel(t) / 10) * 100, 5 + self:getTalentLevel(t))
	end,
}
