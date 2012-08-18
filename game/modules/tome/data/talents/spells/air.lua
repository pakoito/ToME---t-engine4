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
	name = "Lightning",
	type = {"spell/air", 1},
	require = spells_req1,
	points = 5,
	random_ego = "attack",
	mana = 10,
	cooldown = 3,
	tactical = { ATTACK = 2 },
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 350) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:spellCrit(t.getDamage(self, t))
		self:project(tg, x, y, DamageType.LIGHTNING, rng.avg(dam / 3, dam, 3))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "lightning", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Conjures up mana into a powerful beam of lightning doing %0.2f to %0.2f damage
		The damage will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.LIGHTNING, damage / 3),
		damDesc(self, DamageType.LIGHTNING, damage))
	end,
}

newTalent{
	name = "Chain Lightning",
	type = {"spell/air", 2},
	require = spells_req2,
	points = 5,
	random_ego = "attack",
	mana = 40,
	cooldown = 8,
	tactical = { ATTACKAREA = 2 },
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 250) end,
	getTargetCount = function(self, t) return 3 + self:getTalentLevelRaw(t) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local fx, fy = self:getTarget(tg)
		if not fx or not fy then return nil end

		local nb = t.getTargetCount(self, t)
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
				self:project({type="ball", selffire=false, x=dx, y=dy, radius=10, range=0}, dx, dy, function(bx, by)
					local actor = game.level.map(bx, by, Map.ACTOR)
					if actor and not affected[actor] and self:reactionToward(actor) < 0 then
						print("[Chain lightning] found possible actor", actor.name, bx, by, "distance", core.fov.distance(dx, dy, bx, by))
						affected[actor] = true
					end
				end)
				return true
			end
		end)

		if not first then return end
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
			local tgr = {type="beam", range=self:getTalentRange(t), selffire=false, talent=t, x=sx, y=sy}
			print("[Chain lightning] jumping from", sx, sy, "to", actor.x, actor.y)
			local dam = self:spellCrit(t.getDamage(self, t))
			self:project(tgr, actor.x, actor.y, DamageType.LIGHTNING, rng.avg(rng.avg(dam / 3, dam, 3), dam, 5))
			game.level.map:particleEmitter(sx, sy, math.max(math.abs(actor.x-sx), math.abs(actor.y-sy)), "lightning", {tx=actor.x-sx, ty=actor.y-sy, nb_particles=150, life=6})
			sx, sy = actor.x, actor.y
		end

		game:playSoundNear(self, "talents/lightning")

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local targets = t.getTargetCount(self, t)
		return ([[Invokes a forking beam of lightning doing %0.2f to %0.2f damage and forking to another target.
		It can hit up to %d targets up to 10 grids apart and will never hit the same one twice; nor will it hit the caster.
		The damage will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.LIGHTNING, damage / 3),
			damDesc(self, DamageType.LIGHTNING, damage),
			targets)
	end,
}

newTalent{
	name = "Feather Wind",
	type = {"spell/air",3},
	require = spells_req3,
	points = 5,
	mode = "sustained",
	cooldown = 10,
	sustain_mana = 10,
	tactical = { BUFF = 2 },
	getEncumberance = function(self, t) return math.floor(self:combatTalentSpellDamage(t, 10, 110)) end,
	getRangedDefence = function(self, t) return self:combatTalentSpellDamage(t, 4, 30) end,
	getSpeed = function(self, t) return 0.05 * self:getTalentLevel(t) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			encumb = self:addTemporaryValue("max_encumber", t.getEncumberance(self, t)),
			def = self:addTemporaryValue("combat_def_ranged", t.getRangedDefence(self, t)),
		}
		if self:getTalentLevel(t) >= 4 then
			ret.lev = self:addTemporaryValue("levitation", 1)
			ret.traps = self:addTemporaryValue("avoid_pressure_traps", 1)
		end
		if self:getTalentLevel(t) >= 5 then
			ret.ms = self:addTemporaryValue("movement_speed", t.getSpeed(self, t))
		end

		self:checkEncumbrance()
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("max_encumber", p.encumb)
		self:removeTemporaryValue("combat_def_ranged", p.def)
		if p.lev then self:removeTemporaryValue("levitation", p.lev) end
		if p.traps then self:removeTemporaryValue("avoid_pressure_traps", p.traps) end
		if p.ms then self:removeTemporaryValue("movement_speed", p.ms) end
		self:checkEncumbrance()
		return true
	end,
	info = function(self, t)
		local encumberance = t.getEncumberance(self, t)
		local rangedef = t.getRangedDefence(self, t)
		return ([[A gentle wind circles around the caster, increasing carrying capacity by %d and increasing defense against projectiles by %d.
		At level 4 it also makes you slightly levitate, allowing you to ignore some traps.
		At level 5 it also grants %d%% movement speed.]]):
		format(encumberance, rangedef, t.getSpeed(self, t) * 100)
	end,
}

newTalent{
	name = "Thunderstorm",
	type = {"spell/air", 4},
	require = spells_req4,
	points = 5,
	mode = "sustained",
	sustain_mana = 100,
	cooldown = 15,
	tactical = { ATTACKAREA = 3 },
	range = 6,
	direct_hit = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 80) end,
	getTargetCount = function(self, t) return math.floor(self:getTalentLevel(t)) end,
	getManaDrain = function(self, t) return -1.5 * self:getTalentLevelRaw(t) end,
	do_storm = function(self, t)
		local mana = t.getManaDrain(self, t)
		if self:getMana() <= mana + 1 then return end

		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 6, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="ball", radius=1, range=self:getTalentRange(t), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self:project(tg, a.x, a.y, DamageType.LIGHTNING, rng.avg(1, self:spellCrit(t.getDamage(self, t)), 3))
			game.level.map:particleEmitter(a.x, a.y, tg.radius, "ball_lightning", {radius=tg.radius, tx=x, ty=y})
			game:playSoundNear(self, "talents/lightning")
			self:incMana(mana)
		end
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/thunderstorm")
		game.logSeen(self, "#0080FF#A furious lightning storm forms around %s!", self.name)
		return {
		}
	end,
	deactivate = function(self, t, p)
		game.logSeen(self, "#0080FF#The furious lightning storm around %s calms down and disappears.", self.name)
		return true
	end,
	info = function(self, t)
		local targetcount = t.getTargetCount(self, t)
		local damage = t.getDamage(self, t)
		local manadrain = t.getManaDrain(self, t)
		return ([[Conjures a furious, raging lightning storm with a radius of 6 that follows you as long as this spell is active.
		Each turn a random lightning bolt will hit up to %d of your foes for 1 to %0.2f damage in a radius of 1.
		This powerful spell will drain %0.2f mana with each hit.
		The damage will increase with your Spellpower.]]):
		format(targetcount, damDesc(self, DamageType.LIGHTNING, damage),-manadrain)
	end,
}
