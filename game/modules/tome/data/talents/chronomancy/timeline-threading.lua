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

--[[newTalent{
	name = "Swap",
	type = {"chronomancy/timeline-threading", 1},
	require = chrono_req_high1,
	points = 5,
	paradox = 5,
	cooldown = 10,
	tactical = {
		ATTACK = 5,
	},
	requires_target = true,
	direct_hit = true,
	getRange = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)*getParadoxModifier(self, pm)) end,
	action = function(self, t)
		local tg = {type="hit", range=t.getRange(self, t)}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		if math.floor(core.fov.distance(self.x, self.y, tx, ty)) > t.getRange(self, t) then return nil end
		if not self:canBe("teleport") or game.level.map.attrs(tx, ty, "no_teleport") or game.level.map.attrs(self.x, self.y, "no_teleport") then
			game.logSeen(self, "The spell fizzles!")
			return true
		end
		if tx then
			local _ _, tx, ty = self:canProject(tg, tx, ty)
			if tx then
				target = game.level.map(tx, ty, Map.ACTOR)
			end
		end
		if target:canBe("teleport") then
			local hit = self:checkHit(self:combatSpellpower(), target:combatSpellResist() + (target:attr("continuum_destabilization") or 0))
			if not hit then
				game.logSeen(target, "The spell fizzles!")
				return true
			end
		end

		-- Annoy them!
		if target ~= self and target:reactionToward(self) < 0 then target:setTarget(self) end

		game.level.map:remove(self.x, self.y, Map.ACTOR)
		game.level.map:remove(target.x, target.y, Map.ACTOR)
		game.level.map(self.x, self.y, Map.ACTOR, target)
		game.level.map(target.x, target.y, Map.ACTOR, self)
		self.x, self.y, target.x, target.y = target.x, target.y, self.x, self.y
		game.level.map:particleEmitter(target.x, target.y, 1, "teleport")
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")


		if target ~= self then
			target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=self:combatSpellpower(0.3)})
		end

		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local range = t.getRange(self, t)
		return (You manipulate the spacetime continuum in such a way that you switch places with another creature with in a range of %d.
		):format (range)
	end,
}]]

newTalent{
	name = "Gather the Threads",
	type = {"chronomancy/timeline-threading", 1},
	require = chrono_req_high1,
	points = 5,
	paradox = 3,
	cooldown = 6,
	tactical = {
		BUFF = 10,
	},
	getPercent = function(self, t) return 40 + (self:combatTalentSpellDamage(t, 20, 60)*getParadoxModifier(self, pm)) end,
	action = function(self, t)
		self:setEffect(self.EFF_GATHER_THE_THREADS, 1, {power=t.getPercent(self,t)})
		return true
	end,
	info = function(self, t)
		local percent = t.getPercent(self, t)
		return ([[You pull damage you inflict the turn after casting this spell out of other timelines and into your own, inflicting %d%% damage again on any targets you damage while the spell is in effect.
		The percent will increase with the Magic stat.]]):format(percent)
	end,
}

newTalent{
	name = "Rethread",
	type = {"chronomancy/timeline-threading", 2},
	require = chrono_req_high2,
	points = 5,
	paradox = 4,
	cooldown = 6,
	tactical = {
		ATTACK = 10,
	},
	range = 6,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 200)*getParadoxModifier(self, pm) end,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:project(tg, x, y, DamageType.RETHREAD, self:spellCrit(t.getDamage(self, t)))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "temporal_lightning", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Creates a wake of temporal energy that deals %0.2f damage in a beam as you attempt to rethread the timeline.  Affected targets may be dazed, blinded, pinned, or confused for 3 turns..
		The damage will increase with the Magic stat]]):
		format(damDesc(self, DamageType.TEMPORAL, damage))
	end,
}

newTalent{
	name = "Temporal Clone",
	type = {"chronomancy/timeline-threading", 3},
	require = chrono_req_high3,
	points = 5,
	cooldown = 30,
	paradox = 5,
	tactical = {
		ATTACK = 10,
	},
	requires_target = true,
	range = 6,
	no_npc_use = true,
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)* getParadoxModifier(self, pm)) end,
	getSize = function(self, t) return 2 + math.ceil(self:getTalentLevelRaw(t) / 2 ) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		local target = game.level.map(tx, ty, Map.ACTOR)
		if not target or self:reactionToward(target) >= 0 then return end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 1, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		allowed = t.getSize(self, t)

		if target.rank >= 3.5 or -- No boss
			target:reactionToward(self) >= 0 or -- No friends
			target.size_category > allowed
			then
			game.logPlayer(self, "%s resists!", target.name:capitalize())
			return true
		end

		local m = target:clone{
			no_drops = true,
			faction = self.faction,
			summoner = self, summoner_gain_exp=true,
			summon_time = t.getDuration(self, t),
			ai_target = {actor=target},
			ai = "summoned", ai_real = target.ai,
		}

		m.energy.value = 0
		m.life = m.life
		m.forceLevelup = false
		-- Handle special things
		m.on_die = nil
		m.on_acquire_target = nil
		m.seen_by = nil
		m.can_talk = nil
		m.clone_on_hit = nil
		if m.talents.T_SUMMON then m.talents.T_SUMMON = nil end
		if m.talents.T_MULTIPLY then m.talents.T_MULTIPLY = nil end

		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "shadow")

		-- force target to attack double
		local a = game.level.map(tx, ty, Map.ACTOR)
		if a and self:reactionToward(a) < 0 then
			a:setTarget(m)
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local allowed = t.getSize(self, t)
		if allowed < 4 then
			size = "medium"
		elseif allowed < 5 then
			size = "big"
		else
			size = "huge"
		end
		return ([[Summons a double of an up to %s size target from another timeline that stays for %d turns. The copy and the target will be compelled to attack each other immediately.
		]]):
		format(size, duration)
	end,
}

newTalent{
	name = "See the Threads",
	type = {"chronomancy/timeline-threading", 4},
	require = chrono_req_high4,
	points = 5,
	paradox = 100,
	cooldown = 100,
	no_npc_use = true,
	action = function(self, t)
		self:setEffect(self.EFF_SEE_THREADS, 10, {})
		return true
	end,
	info = function(self, t)
		local percent = t.getPercent(self, t)
		return ([[Casting this spell sends you back to the moment you entered the current dungeon level.
		Traveling through time carries with it inherent penalties and doing so will permanently reduce your hit points by %d%%.]])
		:format(percent)
	end,
}
