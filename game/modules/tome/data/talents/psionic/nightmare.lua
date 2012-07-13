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

-- Edge TODO: Sounds, Particles, Talent Icons; All Talents
-- Idea: Nightmare effects gain a bonus to mindpower applications on slept targets, increasing chances of landing as well as brain-locks
-- Idea Night Terror: Sustain, increases mind damage by x% and increases darkness damage by X% of your +mind damage (up to 100).  Increases power of all nightmare effects on sleeping targets by X%

newTalent{
	name = "Nightmare/Waking Nightmare",
	short_name = "WAKING_NIGHTMARE",
	type = {"psionic/nightmare", 1},
	points = 5,
	require = psi_wil_req1,
	cooldown = 10,
	psi = 20,
	range = 10,
	direct_hit = true,
	requires_target = true,
	tactical = { ATTACK = { DARKNESS = 2 }, DISABLE = { confusion = 1, stun = 1, blind = 1 } },
	getChance = function(self, t) return self:combatTalentMindDamage(t, 15, 50) end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 5, 50) end,
	getDuration = function(self, t) return 4 + math.ceil(self:getTalentLevel(t)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if not x or not y then return nil end
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end

		if target:canBe("fear") then
			target:setEffect(target.EFF_WAKING_NIGHTMARE, t.getDuration(self, t), {src = self, chance=t.getChance(self, t), dam=self:mindCrit(t.getDamage(self, t)), apply_power=self:combatMindpower()})
		else
			game.logSeen(target, "%s resists the nightmare!", target.name:capitalize())
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		return ([[Inflicts %0.2f darkness damage each turn for %d turns and has a %d%% chance to randomly cause blindness, stun, or confusion (lasting 3 turns).]]):
		format(damDesc(self, DamageType.DARKNESS, (damage)), duration, chance)
	end,
}

newTalent{
	name = "Inner Demons",
	type = {"psionic/nightmare", 2},
	points = 5,
	require = psi_wil_req2,
	cooldown = 18,
	psi = 20,
	range = 10,
	direct_hit = true,
	requires_target = true,
	tactical = { ATTACK = 3 },
	getChance = function(self, t) return self:combatTalentMindDamage(t, 15, 50) end,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t) * 2) end,
	summon_inner_demons = function(self, target, t)
		-- Find space
		local x, y = util.findFreeGrid(target.x, target.y, 1, true, {[Map.ACTOR]=true})
		if not x then
			return
		end

		local m = target:clone{
			shader = "shadow_simulacrum",
			no_drops = true,
			faction = self.faction,
			summoner = self, summoner_gain_exp=true,
			summon_time = 10,
			ai_target = {actor=target},
			ai = "summoned", ai_real = "tactical",
			name = ""..target.name.."'s Inner Demon",
			desc = [[A hideous, demonic entity that resembles the creature it came from.]],
		}
		m:removeAllMOs()
		m.make_escort = nil
		m.on_added_to_level = nil

		mod.class.NPC.castAs(m)
		engine.interface.ActorAI.init(m, m)

		m.exp_worth = 0
		m.energy.value = 0
		m.player = nil
		m.max_life = m.max_life / 4
		m.life = util.bound(m.life, 0, m.max_life)
		m.inc_damage.all = (m.inc_damage.all or 0) - 50
		m.forceLevelup = function() end
		m.on_die = nil
		m.puuid = nil
		m.on_acquire_target = nil
		m.no_inventory_access = true
		m.on_takehit = nil
		m.seen_by = nil
		m.can_talk = nil
		m.clone_on_hit = nil

		-- Remove some talents
		local tids = {}
		for tid, _ in pairs(m.talents) do
			local t = m:getTalentFromId(tid)
			if t.no_npc_use then tids[#tids+1] = t end
		end
		for i, t in ipairs(tids) do
			if t.mode == "sustained" and m:isTalentActive(t.id) then m:forceUseTalent(t.id, {ignore_energy=true}) end
			m.talents[t.id] = nil
		end

		-- nil the Inner Demons effect to squelch combat log spam
		m.tmp[m.EFF_INNER_DEMONS] = nil

		-- remove detrimental timed effects
		local effs = {}
		for eff_id, p in pairs(m.tmp) do
			local e = m.tempeffect_def[eff_id]
			if e.status == "detrimental" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		while #effs > 0 do
			local eff = rng.tableRemove(effs)
			if eff[1] == "effect" then
				m:removeEffect(eff[2])
			end
		end


		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "shadow")

		game.logSeen(target, "#F53CBE#%s's Inner Demon manifests!", target.name:capitalize())

	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if not x or not y then return nil end
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end

		if target:canBe("fear") then
			target:setEffect(target.EFF_INNER_DEMONS, t.getDuration(self, t), {src = self, chance=self:mindCrit(t.getChance(self, t)), apply_power=self:combatMindpower()})
		else
			game.logSeen(target, "%s resists the demons!", target.name:capitalize())
		end

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		return ([[Brings the target's inner demons to the surface.  Each turn for %d turns there's a %d%% chance that one will be summoned.
		If the summoning is resisted the effect will end early.]]):format(duration, chance)
	end,
}