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

newTalentType{ type="technique/horror", name = "horror techniques", hide = true, description = "Physical talents of the various horrors of the world." }
newTalentType{ no_silence=true, is_spell=true, type="spell/horror", name = "horror spells", hide = true, description = "Spell talents of the various horrors of the world." }
newTalentType{ type="other/horror", name = "horror powers", hide = true, description = "Unclassified talents of the various horrors of the world." }

local oldTalent = newTalent
local newTalent = function(t) if type(t.hide) == "nil" then t.hide = true end return oldTalent(t) end


-- Nightmare Horror Powers
newTalent{
	name = "Inner Demons",
	type = {"spell/horror", 1},
	points = 5,
	cooldown = 10,
	mana = 16,
	range = 10,
	direct_hit = true,
	requires_target = true,
	tactical = { ATTACK = 3 },
	getChance = function(self, t) return self:combatTalentSpellDamage(t, 5, 50) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 5, 50) end,
	getDuration = function(self, t) return 8 + math.ceil(self:getTalentLevel(t) * 4) end,
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
		
		m.energy.value = 0
		m.player = nil
		m.max_life = m.max_life / 2
		m.life = util.bound(m.life, 0, m.max_life)
		m.inc_damage.all = (m.inc_damage.all or 0) - 50
		m.forceLevelup = function() end
		m.on_die = nil
		m.on_acquire_target = nil
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

		game.logSeen(target, "%s's Inner Demon manifests!", target.name:capitalize())
		
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if not x or not y then return nil end
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end
		
		if target:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) and target:canBe("fear") then
			target:setEffect(target.EFF_INNER_DEMONS, t.getDuration(self, t), {src = self, chance=t.getChance(self, t), dam=t.getDamage(self, t)})
		else
			game.logSeen(target, "%s resists the demons!", target.name:capitalize())
		end
		
		return true
	end,
	info = function(self, t)
		return ([[Brings the targets inner demons to the surface.  Each turn there's a chance that one will be summoned.  If the summoning is resisted the effect will end early.]])
	end,
}

newTalent{
	name = "Waking Nightmare",
	type = {"spell/horror", 1},
	points = 5,
	cooldown = 10,
	mana = 16,
	range = 10,
	direct_hit = true,
	requires_target = true,
	tactical = { ATTACK = 2, DISABLE = 3 },
	getChance = function(self, t) return 10 + self:combatTalentSpellDamage(t, 5, 50) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 5, 50) end,
	getDuration = function(self, t) return 4 + math.ceil(self:getTalentLevel(t)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if not x or not y then return nil end
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end
		
		if target:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) and target:canBe("fear") then
			target:setEffect(target.EFF_WAKING_NIGHTMARE, t.getDuration(self, t), {src = self, chance=t.getChance(self, t), dam=t.getDamage(self, t)})
		else
			game.logSeen(target, "%s resists the nightmare!", target.name:capitalize())
		end
		
		return true
	end,
	info = function(self, t)
		return ([[Darkness damage and a chance to randomly blind, stun, or confuse each turn.]])
	end,
}

newTalent{
	name = "Abyssal Shroud",
	type = {"spell/horror", 1},
	points = 5,
	cooldown = 10,
	mana = 30,
	cooldown = 12,
	tactical = { ATTACKAREA = 2, DISABLE = 3 },
	range = 6,
	radius = 3,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 40) end,
	getDarknessPower = function(self, t) return self:combatTalentSpellDamage(t, 15, 40) end,
	getLiteReduction = function(self, t) return self:getTalentLevelRaw(t) end,
	getDuration = function(self, t) return 4 + math.ceil(self:getTalentLevel(t)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.ABYSSAL_SHROUD, {dam=t.getDamage(self, t), power=t.getDarknessPower(self, t), lite=t.getLiteReduction(self, t)},
			self:getTalentRadius(t),
			5, nil,
			{type="circle_of_death"},
			nil, false
		)

		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		return ([[An area of effect that causes darkness damage and reduces the lite radius and darkness resistance of those within.]])
	end,
}

-- Void Horror Powers
newTalent{
	name = "Echoes From The Void",
	type = {"other/horror", 1},
	points = 5,
	message = "@Source@ shows @Target@ the madness of the void.",
	cooldown = 10,
	range = 10,
	requires_target = true,
	tactical = { ATTACK = 4 },
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 100) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if not x or not y then return nil end
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end
		
		if target:checkHit(src:combatMindpower(), target:combatMentalResist(), 0, 95, 15) and target:canBe("fear") then
			target:setEffect(target.EFF_VOID_ECHOES, 6, {src= self, power=t.getDamage(self, t)})
		else
			game.logSeen(target, "%s resists the void!", target.name:capitalize())
		end
		
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[Causes the void echoes status effect which does mind and resource damage every turn the target fails a mental save.]])
	end,
}

newTalent{
	name = "Void Shards",
	type = {"other/horror", 1},
	points = 5,
	message = "@Source@ summons void shards.",
	cooldown = 20,
	range = 10,
	requires_target = true,
	tactical = { ATTACK = 4 },
	requires_target = true,
	is_summon = true,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 5, 50) end,
	getExplosion = function(self, t) return self:combatTalentMindDamage(t, 20, 300) end,
	getSummonTime = function(self, t) return 6 + math.ceil(self:getTalentLevel(t)) end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end
		
		if self:getTalentLevel(t) < 5 then self:setEffect(self.EFF_SUMMON_DESTABILIZATION, 500, {power=5}) end
		
		for i = 1, self:getTalentLevelRaw(t) do
		-- Find space
			local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "Not enough space to summon!")
				break
			end

			local NPC = require "mod.class.NPC"
			local m = NPC.new{
				type = "horror", subtype = "temporal",
				display = "h", color=colors.GREY, image = "npc/horror_temporal_void_horror.png",
				name = "void shard", faction = self.faction,
				desc = [[It looks like a small hole in the fabric of spacetime.]],
				stats = { str=22, dex=20, wil=15, con=15 },
				
				--level_range = {self.level, self.level}, 
				exp_worth = 0,
				max_life = resolvers.rngavg(5,10),
				life_rating = 2,
				rank = 2,
				size_category = 1,
							
				autolevel = "summoner",
				ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_snake" },							
				combat_armor = 1, combat_def = 1,
				combat = { dam=resolvers.levelup(resolvers.mbonus(40, 15), 1, 1.2), atk=15, apr=15, dammod={wil=0.8}, damtype=DamageType.TEMPORAL },
				on_melee_hit = { [DamageType.TEMPORAL] = resolvers.mbonus(20, 10), },
			
				infravision = 10,
				no_breath = 1,
				fear_immune = 1,
				stun_immune = 1,
				confusion_immune = 1,
				silence_immune = 1,
				
				ai_target = {actor=target}
			}
			
			m.faction = self.faction
			m.summoner = self 
			m.summoner_gain_exp=true
			m.summon_time = t.getSummonTime(self, t)
			
			m:resolve() m:resolve(nil, true)
			m:forceLevelup(self.level)
			game.zone:addEntity(game.level, m, "actor", x, y)
			game.level.map:particleEmitter(x, y, 1, "summon")
			m:setEffect(m.EFF_TEMPORAL_DESTABILIZATION, 5, {src=self, dam=t.getDamage(self, t), explosion=self:spellCrit(t.getExplosion(self, t))})
			
		end
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Summons shards of explosive doom!]])
	end,
}