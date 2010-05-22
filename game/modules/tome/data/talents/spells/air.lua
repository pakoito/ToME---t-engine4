-- ToME - Tales of Middle-Earth
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
	name = "Lightning",
	type = {"spell/air", 1},
	require = spells_req1,
	points = 5,
	mana = 10,
	cooldown = 3,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	reflectable = true,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.LIGHTNING, rng.avg(1, self:spellCrit(20 + self:combatSpellpower(0.8) * self:getTalentLevel(t)), 3), {type="lightning"})
		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		return ([[Conjures up mana into a powerful beam of lightning doing 1 to %0.2f damage
		The damage will increase with the Magic stat]]):format(20 + self:combatSpellpower(0.8) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Chain Lightning",
	type = {"spell/air", 2},
	require = spells_req2,
	points = 5,
	mana = 20,
	cooldown = 8,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	reflectable = true,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local fx, fy = self:getTarget(tg)
		if not fx or not fy then return nil end

		local nb = 3 + self:getTalentLevelRaw(t)
		local affected = {}
		local first = nil

		self:project(tg, fx, fy, function(dx, dy)
			print("[Chain lightning] targetting", fx, fy, "from", self.x, self.y)
			local actor = game.level.map(dx, dy, Map.ACTOR)
			if actor and not affected[actor] then
				ignored = false
				affected[actor] = true
				first = actor

				print("[Chain lightning] looking for more targets", nb, " at ", dx, dy, "radius ", 10, "from", actor.name)
				self:project({type="ball", friendlyfire=false, x=dx, y=dy, radius=10, range=0}, dx, dy, function(bx, by)
					local actor = game.level.map(bx, by, Map.ACTOR)
					if actor and not affected[actor] and self:reactionToward(actor) < 0 then
						print("[Chain lightning] found possible actor", actor.name, bx, by, "distance", core.fov.distance(dx, dy, bx, by))
						affected[actor] = true
					end
				end)
				return true
			end
		end)

		local targets = { first }
		affected[first] = nil
		local possible_targets = table.listify(affected)
		print("[Chain lightning] Found targets:", #possible_targets)
		for i = 2, nb do
			if #possible_targets == 0 then break end
			local act = rng.tableRemove(possible_targets)
			targets[#targets+1] = act[1]
		end

		local sx, sy = self.x, self.y
		for i, actor in ipairs(targets) do
			local tgr = {type="beam", range=self:getTalentRange(t), talent=t, x=sx, y=sy}
			print("[Chain lightning] jumping from", sx, sy, "to", actor.x, actor.y)
			self:project(tgr, actor.x, actor.y, DamageType.LIGHTNING, rng.avg(1, self:spellCrit(20 + self:combatSpellpower(0.8) * self:getTalentLevel(t)), 5), {type="lightning"})
			sx, sy = actor.x, actor.y
		end

		game:playSoundNear(self, "talents/lightning")

		return true
	end,
	info = function(self, t)
		return ([[Invokes a forking beam of lightning doing 1 to %0.2f damage and forking to an other target.
		It can hit up to %d targets and will never hit the same one twice, neither will it hit the caster.
		The damage will increase with the Magic stat]]):
		format(
			20 + self:combatSpellpower(0.8) * self:getTalentLevel(t),
			3 + self:getTalentLevelRaw(t)
		)
	end,
}

newTalent{
	name = "Feather Wind",
	type = {"spell/air",3},
	require = spells_req3,
	points = 5,
	mode = "sustained",
	cooldown = 10,
	sustain_mana = 100,
	tactical = {
		MOVEMENT = 10,
	},
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			encumb = self:addTemporaryValue("max_encumber", math.floor(self:getTalentLevel(t) * self:combatSpellpower(0.15))),
			def = self:addTemporaryValue("combat_def_ranged", 6 + self:combatSpellpower(0.07) * self:getTalentLevel(t)),
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
	name = "Thunderstorm",
	type = {"spell/air", 4},
	require = spells_req4,
	points = 5,
	mode = "sustained",
	sustain_mana = 250,
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

			self:project(tg, a.x, a.y, DamageType.LIGHTNING, rng.avg(1, self:spellCrit(20 + self:combatSpellpower(0.2) * self:getTalentLevel(t)), 3), {type="lightning"})
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
		The damage will increase with the Magic stat]]):format(self:getTalentLevel(t), 20 + self:combatSpellpower(0.2) * self:getTalentLevel(t))
	end,
}
