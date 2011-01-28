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
	name = "Paradox Mastery",
	type = {"chronomancy/paradox", 1},
	require = chrono_req1,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self.resists[DamageType.TEMPORAL] = (self.resists[DamageType.TEMPORAL] or 0) + 5
	end,
	on_unlearn = function(self, t)
		self.resists[DamageType.TEMPORAL] = (self.resists[DamageType.TEMPORAL] or 0) - 5
	end,
	info = function(self, t)
		return ([[You've learned to better control and resist the dangers of chronomancy.  Increases your effective willpower for static history, failure, and backfire calculations by %d%% and increases your Temporal resistance by %d%%.]]):
		format(self:getTalentLevel(t) * 10, self:getTalentLevelRaw(t) * 5)
	end,
}

newTalent{
	name = "Paradox Shield",
	type = {"chronomancy/paradox", 2},
	require = chrono_req2,
	points = 5,
	random_ego = "attack",
	mana = 40,
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
			local tgr = {type="beam", range=self:getTalentRange(t), friendlyfire=false, talent=t, x=sx, y=sy}
			print("[Chain lightning] jumping from", sx, sy, "to", actor.x, actor.y)
			local dam = self:spellCrit(self:combatTalentSpellDamage(t, 10, 200))
			self:project(tgr, actor.x, actor.y, DamageType.LIGHTNING, rng.avg(rng.avg(dam / 3, dam, 3), dam, 5))
			game.level.map:particleEmitter(sx, sy, math.max(math.abs(actor.x-sx), math.abs(actor.y-sy)), "lightning", {tx=actor.x-sx, ty=actor.y-sy, nb_particles=150, life=6})
			sx, sy = actor.x, actor.y
		end

		game:playSoundNear(self, "talents/lightning")

		return true
	end,
	info = function(self, t)
		return ([[Invokes a forking beam of lightning doing %0.2f to %0.2f damage and forking to an other target.
		It can hit up to %d targets and will never hit the same one twice, neither will it hit the caster.
		The damage will increase with the Magic stat]]):
		format(
			self:combatTalentSpellDamage(t, 10, 200) / 3,
			self:combatTalentSpellDamage(t, 10, 200),
			3 + self:getTalentLevelRaw(t)
		)
	end,
}

newTalent{
	name = "Redux",
	type = {"chronomancy/paradox",3},
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
	name = "Paradox Clone",
	type = {"chronomancy/paradox", 1},
	require = chrono_req1,
	points = 5,
	paradox = 15,
	cooldown = 1,
	tactical = { ATTACK = 1, DISABLE = 2 },
	range = 5,
	no_npc_use = true,
	on_pre_use = timeline_check,
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)* getParadoxModifier(self, pm)) end,
	getModifier = function(self, t) return rng.range(t.getDuration(self,t), t.getDuration(self, t)*4) end,
	action = function (self, t)
		local sex = game.player.female and "she" or "he"
		local a = mod.class.NPC.new{}
		a:replaceWith(game.player:resolveSource():cloneFull())
		mod.class.NPC.castAs(a)
		engine.interface.ActorAI.init(a, a)
		a.no_drops = true
		a.energy.value = 0
		a.player = nil
		a.name = a.name.."'s future self"
		a.color_r = 176 a.color_g = 196 a.color_b = 222
		a._mo:invalidate()
		a.faction = self.faction
		a.max_life = a.max_life
		a.life = a.max_life
		a.summoner = self
		a.summoner_gain_exp=true
		a.summon_time = t.getDuration(self, t)
		a.ai = "summoned"
		a.ai_real = "tactical"
		a.ai_tactic = resolvers.tactic("ranged")
		a.ai_state = { talent_in=1, }
		a.desc = [[The real you... or so ]]..sex..[[ says.]]

		-- Remove some talents
		local tids = {}
		for tid, _ in pairs(a.talents) do
			local t = a:getTalentFromId(tid)
			if t.no_npc_use then tids[#tids+1] = t end
		end
		for i, t in ipairs(tids) do
			if t.mode == "sustained" and a:isTalentActive(t.id) then a:forceUseTalent(t.id, {ignore_energy=true}) end
			a.talents[t.id] = nil
		end

		local x, y = util.findFreeGrid(self.x, self.y, 10, true, {[engine.Map.ACTOR]=true})
		if x and y then
			game.zone:addEntity(game.level, a, "actor", x, y)
		end
		game:playSoundNear(self, "talents/spell_generic")
		self:setEffect(self.EFF_IMMINENT_PARADOX_CLONE, t.getDuration(self, t) + t.getModifier(self, t), {})
	end,
	info = function(self, t)
		return ([[Conjures a furious, raging lightning storm with a radius of 5 that follows you as long as this spell is active.
		Each turn a random lightning bolt will hit up to %d of your foes for 1 to %0.2f damage.
		This powerful spell will continuously drain mana while active.
		The damage will increase with the Magic stat]]):format(self:getTalentLevel(t), self:combatTalentSpellDamage(t, 15, 80))
	end,
}
