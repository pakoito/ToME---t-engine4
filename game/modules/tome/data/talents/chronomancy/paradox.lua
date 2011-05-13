-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
	mode = "sustained",
	require = chrono_req_high1,
	sustain_paradox = 75,
	cooldown = 10,
	points = 5,
	getResist = function(self, t) return 10 + (self:combatTalentSpellDamage(t, 10, 50)) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/arcane")
		return {
			particle = self:addParticles(Particles.new("temporal_focus", 1)),
			temp = self:addTemporaryValue("resists", {[DamageType.TEMPORAL]=t.getResist(self, t)}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("resists", p.temp)
		return true
	end,
	info = function(self, t)
		local resist = t.getResist(self, t)
		return ([[You've learned to focus your control over the spacetime continuum and resist anomalous effects.  Increases your effective willpower for static history, failure, and backfire calculations by %d%% and increases your Temporal resistance by %d%%.
		The resistance will scale with the Magic stat.]]):
		format(self:getTalentLevel(t) * 10, resist)
	end,
}

newTalent{
	name = "Damage Shunt",
	type = {"chronomancy/paradox", 2},
	require = chrono_req_high2,
	points = 5,
	paradox = 10,
	cooldown = 15,
	tactical = { DEFEND = 2 },
	no_energy = true,
	getAbsorb = function(self, t) return self:combatTalentSpellDamage(t, 30, 470) * getParadoxModifier(self, pm) end,
	action = function(self, t)
		self:setEffect(self.EFF_DAMAGE_SHUNT, 10, {power=t.getAbsorb(self, t)})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local absorb = t.getAbsorb(self, t)
		return ([[Divides up to %0.2f damage evenly along every second of your past and future, effectively negating it.  Damage Shunt lasts 10 turns or until the maximum damage limit has been reached.
		Casting Damage Shunt costs no time and the effect will scale with your Paradox and Magic stat.]]):
		format(absorb)
	end,
}

newTalent{
	name = "Flawed Design",
	type = {"chronomancy/paradox",3},
	require = chrono_req_high3,
	points = 5,
	cooldown = 20,
	paradox = 20,
	range = 10,
	tactical = { DISABLE = 2 },
	requires_target = true,
	direct_hit = true,
	getDuration = function(self, t) return 2 + math.floor(self:getTalentLevel(t) * getParadoxModifier(self, pm)) end,
	getReduction = function(self, t) return 10 + (self:combatTalentSpellDamage(t, 10, 40) * getParadoxModifier(self, pm)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end
			if target:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) then
				target:setEffect(target.EFF_FLAWED_DESIGN, t.getDuration(self,t), {power=t.getReduction(self, t)})
			end
		end)
		game:playSoundNear(self, "talents/generic2")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local reduction = t.getReduction(self, t)
		return ([[By altering the target's past you change its present, reducing all of its resistances by %d%% for %d turns.
		The duration and reduction will scale with your Paradox.  The reduction will increase with your Magic stat.]]):
		format(reduction, duration)
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
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)* getParadoxModifier(self, pm)) end,
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

		local sex = game.player.female and "she" or "he"
		local a = mod.class.NPC.new{}
		a:replaceWith(game.player:resolveSource():cloneFull())
		mod.class.NPC.castAs(a)
		engine.interface.ActorAI.init(a, a)
		a.no_drops = true
		a.energy.value = 0
		a.player = nil
		--a.name = a.name.."'s paradox clone"
		a.name = a.name
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
		a.ai_state = { talent_in=1, ally_compassion=10}
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

		local x, y = util.findFreeGrid(tx, ty, 10, true, {[engine.Map.ACTOR]=true})
		if x and y then
			game.zone:addEntity(game.level, a, "actor", x, y)
		end
		game:playSoundNear(self, "talents/spell_generic")
		self:setEffect(self.EFF_IMMINENT_PARADOX_CLONE, t.getDuration(self, t) + t.getModifier(self, t), {})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[You summon your future self to fight alongside you for %d turns.
		The duration will scale with your Paradox.]]):format(duration)
	end,
}
