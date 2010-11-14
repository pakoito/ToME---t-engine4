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

	
newTalent{
	name = "Backtrack",
	type = {"chronomancy/timetravel", 1},
	require = chrono_req1,
	points = 5,
	random_ego = "utility",
	paradox = 3,
	cooldown = 8,
	no_energy = true,
	tactical = {
		ESCAPE = 4,
	},
	range = function(self, t) return (3 + self:getTalentLevel(t))*getParadoxModifier(self, pm) end,
	requires_target = true,
	direct_hit = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		if math.floor(core.fov.distance(self.x, self.y, tx, ty)) > self:getTalentRange(t) then return nil end
		if not self:canBe("teleport") or game.level.map.attrs(tx, ty, "no_teleport") then
			game.logSeen(self, "The spell fizzles!")
			return true
		end
		if self:hasLOS(tx, ty) and not game.level.map:checkEntity(tx, ty, Map.TERRAIN, "block_move") and not game.level.map:checkEntity(tx, ty, Map.ACTOR, "block_move") then
			self:move(tx, ty, true)
			game:playSoundNear(self, "talents/teleport")
		else
			game.logSeen(self, "You cannot move there.")
			return nil
		end
		return true
	end,
	info = function(self, t)
		return ([[Instantly teleports you to up to %0.2f tiles away to any tile in line of sight.
		]]):format((3 + self:getTalentLevel(t))*getParadoxModifier(self, pm))
	end,
}

newTalent{
	name = "Temporal Reprieve",
	type = {"chronomancy/timetravel", 2},
	require = chrono_req2,
	points = 5,
	random_ego = "attack",
	paradox = 10,
	cooldown = 20,
	tactical = {
		UTILITY = 10,
	},
	message = "@Source@ manipulates the flow of time.",
	no_energy = true,
	action = function(self, t)
		for tid, cd in pairs(self.talents_cd) do
			self.talents_cd[tid] = cd - self:getTalentLevel(t)
		end
			return true
	end,
	info = function(self, t)
		return ([[All your talents currently on cooldown are %d turns closer to being off cooldown.]]):
		format(self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Time Skip",
	type = {"chronomancy/timetravel",3},
	require = chrono_req3,
	points = 5,
	mode = "sustained",
	cooldown = 10,
	sustain_mana = 50,
	tactical = {
		MOVEMENT = 10,
	},
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			encumb = self:addTemporaryValue("max_encumber", math.floor(self:combatTalentSpellDamage(t, 10, 110))),
			def = self:addTemporaryValue("combat_def_ranged", self:combatTalentSpellDamage(t, 4, 30)),
			lev = self:addTemporaryValue("levitation", 1),
		}
		self:checkEncumbrance()
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("max_encumber", p.encumb)
		self:removeTemporaryValue("combat_def_ranged", p.def)
		self:removeTemporaryValue("levitation", p.lev)
		self:checkEncumbrance()
		return true
	end,
	info = function(self, t)
		return ([[A gentle wind circles around the caster, increasing carrying capacity by %d and increasing defense against projectiles by %d.
		At level 4 it also makes you slightly levitate, allowing you to ignore some traps.]]):
		format(self:getTalentLevel(t) * self:combatSpellpower(0.15), 6 + self:combatSpellpower(0.07) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Rethread",
	type = {"chronomancy/timetravel", 4},
	require = chrono_req4,
	points = 5,
	mode = "sustained",
	sustain_mana = 170,
	cooldown = 15,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 5,
	do_storm = function(self, t)
		if self:getMana() <= 0 then
			local old = self.energy.value
			self.energy.value = 100000
			self:useTalent(self.T_THUNDERSTORM)
			self.energy.value = old
			return
		end

		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 5, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		for i = 1, math.floor(self:getTalentLevel(t)) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self:project(tg, a.x, a.y, DamageType.LIGHTNING, rng.avg(1, self:spellCrit(self:combatTalentSpellDamage(t, 15, 80)), 3))
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(a.x-self.x), math.abs(a.y-self.y)), "lightning", {tx=a.x-self.x, ty=a.y-self.y})
			game:playSoundNear(self, "talents/lightning")
		end
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/thunderstorm")
		game.logSeen(self, "#0080FF#A furious lightning storm forms around %s!", self.name)
		return {
			drain = self:addTemporaryValue("mana_regen", -3 * self:getTalentLevelRaw(t)),
		}
	end,
	deactivate = function(self, t, p)
		game.logSeen(self, "#0080FF#The furious lightning storm around %s calms down and disappears.", self.name)
		self:removeTemporaryValue("mana_regen", p.drain)
		return true
	end,
	info = function(self, t)
		return ([[Conjures a furious, raging lightning storm with a radius of 5 that follows you as long as this spell is active.
		Each turn a random lightning bolt will hit up to %d of your foes for 1 to %0.2f damage.
		This powerful spell will continuously drain mana while active.
		The damage will increase with the Magic stat]]):format(self:getTalentLevel(t), self:combatTalentSpellDamage(t, 15, 80))
	end,
}
