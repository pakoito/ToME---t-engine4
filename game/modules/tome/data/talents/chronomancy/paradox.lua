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
	name = "Paradox Mastery",
	type = {"chronomancy/paradox", 1},
	mode = "passive",
	require = chrono_req_high1,
	points = 5,
	on_learn = function(self, t)
		self.resists[DamageType.TEMPORAL] = (self.resists[DamageType.TEMPORAL] or 0) + 7
	end,
	on_unlearn = function(self, t)
		self.resists[DamageType.TEMPORAL] = self.resists[DamageType.TEMPORAL] - 7
	end,
	info = function(self, t)
		local resist = self:getTalentLevelRaw(t) * 7
		local stability = math.floor(self:getTalentLevel(t)/2)
		return ([[You've learned to focus your control over the spacetime continuum and resist anomalous effects.  Increases your Temporal resistance by %d%%, extends the duration of the Static History stability effect by %d turns, and increases your effective willpower for failure, anomaly, and backfire calculations by %d%%.]]):
		format(resist, stability, self:getTalentLevel(t) * 10)
	end,
}

newTalent{
	name = "Cease to Exist",
	type = {"chronomancy/paradox", 2},
	require = chrono_req_high2,
	points = 5,
	cooldown = 24,
	paradox = 20,
	range = 10,
	tactical = { ATTACK = 2 },
	requires_target = true,
	direct_hit = true,
	no_npc_use = true,
	getDuration = function(self, t) return 4 + math.floor(self:getTalentLevel(t) * getParadoxModifier(self, pm)) end,
	getPower = function(self, t) return self:combatTalentSpellDamage(t, 10, 50) * getParadoxModifier(self, pm) end,
	do_instakill = function(self, t)
		-- search for target because it's ID will change when the chrono restore takes place
		local tg = false
		local grids = core.fov.circle_grids(self.x, self.y, 10, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and a:hasEffect(a.EFF_CEASE_TO_EXIST) then
				tg = a
			end
		end end
		
		if tg then
			game:onTickEnd(function()
				tg:removeEffect(tg.EFF_CEASE_TO_EXIST)
				game.logSeen(tg, "#LIGHT_BLUE#%s never existed, this never happened!", tg.name:capitalize())
				tg:die(self)
			end)
		end
	end,
	action = function(self, t)
		-- check for other chrono worlds
		if checkTimeline(self) == true then
			return
		end
		
		-- get our target
		local tg = {type="hit", range=self:getTalentRange(t)}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		
		local target = game.level.map(tx, ty, Map.ACTOR)
		if not target then return end
		
		-- does the spell hit?  if not nothing happens
		if not self:checkHit(self:combatSpellpower(), target:combatSpellResist()) then
			game.logSeen(target, "%s resists!", target.name:capitalize())
			return true
		end
	
		-- Manualy start cooldown before the chronoworld is made
		game.player:startTalentCooldown(t)
		
		-- set up chronoworld next, we'll load it when the target dies in class\actor
		game:onTickEnd(function()
			game:chronoClone("cease_to_exist")
		end)
			
		target:setEffect(target.EFF_CEASE_TO_EXIST, t.getDuration(self,t), {power=t.getPower(self, t)})
				
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local power = t.getPower(self, t)
		return ([[Over the next %d turns you attempt to remove the target from the timeline.  It's resistances will be reduced by %d%% and if you manage to kill it while the spell is in effect you'll be returned to the point in time you cast this spell and the target will be slain.
		This spell splits the timeline.  Attempting to use another spell that also splits the timeline while this effect is active will be unsuccessful.
		The duration will scale with your Paradox and the resistance penalty will scale with your paradox and spellpower.]])
		:format(duration, power)
	end,
}

newTalent{
	name = "Fade From Time",
	type = {"chronomancy/paradox", 3},
	require = chrono_req_high3,
	points = 5,
	paradox = 10,
	cooldown = 24,
	tactical = { DEFEND = 2, CURE = 2 },
	getResist = function(self, t) return self:combatTalentSpellDamage(t, 10, 50) * getParadoxModifier(self, pm) end,
	action = function(self, t)
		self:setEffect(self.EFF_FADE_FROM_TIME, 10, {power=t.getResist(self, t)})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local resist = t.getResist(self, t)
		return ([[You partially remove yourself from the timeline for 10 turns, increasing your resistance to all damage by %d%%, reducing the duration of all effects by %d%%, and reducing all damage you deal by 20%%.
		The resistance bonus, effect reduction, and damage penalty will gradually lose power over the course of the spell.
		The effect will scale with your Paradox and Spellpower.]]):
		format(resist, resist, resist/10)
	end,
}

newTalent{
	name = "Paradox Clone",
	type = {"chronomancy/paradox", 4},
	require = chrono_req_high4,
	points = 5,
	paradox = 25,
	cooldown = 50,
	tactical = { ATTACK = 1, DISABLE = 2 },
	range = 2,
	requires_target = true,
	no_npc_use = true,
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)*getParadoxModifier(self, pm)) end,
	getModifier = function(self, t) return rng.range(t.getDuration(self,t)*2, t.getDuration(self, t)*4) end,
	action = function (self, t)
		if checkTimeline(self) == true then
			return
		end

		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		if not tx or not ty then return nil end
		
		local x, y = util.findFreeGrid(tx, ty, 2, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		local sex = game.player.female and "she" or "he"
		local m = require("mod.class.NPC").new(self:clone{
			no_drops = true,
			faction = self.faction,
			summoner = self, summoner_gain_exp=true,
			summon_time = t.getDuration(self, t),
			ai_target = {actor=nil},
			ai = "summoned", ai_real = "tactical",
			ai_tactic = resolvers.tactic("ranged"), ai_state = { talent_in=1, ally_compassion=10},
			desc = [[The real you... or so ]]..sex..[[ says.]]
		})
		m:removeAllMOs()
		m.make_escort = nil
		m.on_added_to_level = nil
		
		m.energy.value = 0
		m.player = nil
		m.puuid = nil
		m.max_life = m.max_life
		m.life = util.bound(m.life, 0, m.max_life)
		m.forceLevelup = function() end
		m.die = nil
		m.on_die = nil
		m.on_acquire_target = nil
		m.seen_by = nil
		m.can_talk = nil
		m.on_takehit = nil
		m.no_inventory_access = true
		m.clone_on_hit = nil
		m.remove_from_party_on_death = true
		
		-- Remove some talents
		local tids = {}
		for tid, _ in pairs(m.talents) do
			local t = m:getTalentFromId(tid)
			if t.no_npc_use then tids[#tids+1] = t end
		end
		for i, t in ipairs(tids) do
			m.talents[t.id] = nil
		end
		
		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "temporal_teleport")
		game:playSoundNear(self, "talents/teleport")

		if game.party:hasMember(self) then
			game.party:addMember(m, {
				control="no",
				type="minion",
				title="Paradox Clone",
				orders = {target=true},
			})
		end

		self:setEffect(self.EFF_IMMINENT_PARADOX_CLONE, t.getDuration(self, t) + t.getModifier(self, t), {})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[You summon your future self to fight alongside you for %d turns.  At some point in the future you'll be pulled into the past to fight along side your past self after the initial effect ends.
		This spell splits the timeline.  Attempting to use another spell that also splits the timeline while this effect is active will be unsuccessful.
		The duration will scale with your Paradox.]]):format(duration)
	end,
}
