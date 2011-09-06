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
newTalentType{ no_silence=true, is_spell=true, type="corruption/horror", name = "horror spells", hide = true, description = "Spell talents of the various horrors of the world." }
newTalentType{ type="other/horror", name = "horror powers", hide = true, description = "Unclassified talents of the various horrors of the world." }

local oldTalent = newTalent
local newTalent = function(t) if type(t.hide) == "nil" then t.hide = true end return oldTalent(t) end
-- Bloated Horror Powers
-- Ideas; Mind Shriek (confusion, plus mental damge each turn), Hallucination (Clones that die on hit if the target makes a mental save)

-- Devourer Powers
newTalent{
	name = "Frenzied Bite",
	type = {"technique/horror", 3},
	points = 5,
	cooldown = 12,
	stamina = 24,
	tactical = { ATTACK = 1, DISABLE = 2 },
	message = "In a frenzy @Source@ bites at @Target@!",
	on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_FRENZY) then return false end return true end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end

		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 1, 1.7), true)
		if hit then
			if target:checkHit(self:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 5) and target:canBe("cut") then
				target:setEffect(target.EFF_DEEP_WOUND, 5, {src=self, heal_factor=self:getTalentLevel(t) * 10, power=self:combatTalentWeaponDamage(t, 1.5, 3)/5})
			end
		end
		return true
	end,
	info = function(self, t)
		return ([[A nasty bite that causes a deep wound, only usable in a frenzy.]])
	end,
}

newTalent{
	name = "Frenzied Leap", -- modified ghoulish leap, only usable while in a frenzy
	type = {"technique/horror", 1},
	points = 5,
	cooldown = 5,
	tactical = { CLOSEIN = 3 },
	direct_hit = true,
	message = "@Source@ leaps forward in a frenzy!",
	range = function(self, t) return math.floor(2 + self:getTalentLevel(t)) end,
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_FRENZY) or self:attr("encased_in_ice") or self:attr("never_move") then return false end return true end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > self:getTalentRange(t) then return nil end

		local l = line.new(self.x, self.y, x, y)
		local lx, ly = l()
		local tx, ty = lx, ly
		lx, ly = l()
		while lx and ly do
			if game.level.map:checkEntity(lx, ly, Map.TERRAIN, "block_move", self) then break end
			tx, ty = lx, ly
			lx, ly = l()
		end

		-- Find space
		if game.level.map:checkEntity(tx, ty, Map.TERRAIN, "block_move", self) then return nil end
		local fx, fy = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not fx then
			return
		end
		self:move(fx, fy, true)

		return true
	end,
	info = function(self, t)
		return ([[Leap toward your target.]])
	end,
}

newTalent{
	name = "Gnashing Teeth",
	type = {"technique/horror", 1},
	points = 5,
	cooldown = 3,
	stamina = 8,
	message = "@Source@ tries to bite @Target@ with razor sharp teeth!",
	requires_target = true,
	tactical = { ATTACK = 2 },
	do_devourer_frenzy = function(self, target, t)
		game.logSeen(self, "The scent of blood sends the %ss into a frenzy!", self.name:capitalize())
		-- frenzy devourerers
		local tg = {type="ball", range=0, radius=3, selffire=true, talent=t}
		self:project(tg, target.x, target.y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			local reapplied = false
			if target then
				local actor_frenzy = false
				if target.name == "devourer" then
					actor_frenzy = true
				end
				if actor_frenzy then
					-- silence the apply message if the target already has the effect
					for eff_id, p in pairs(target.tmp) do
						local e = target.tempeffect_def[eff_id]
						if e.name == "Frenzy" then
							reapplied = true
						end
					end
					target:setEffect(target.EFF_FRENZY, math.floor(2 + self:getTalentLevel(t)), {crit = self:getTalentLevel(t) * 3, power=self:getTalentLevel(t) * 0.2, dieat=self:getTalentLevel(t) * 0.2}, reapplied)
				end
			end
		end)
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.5, 1), true)

		if target:checkHit(self:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 8 - self:getTalentLevel(t) / 2) and target:canBe("cut") then
			target:setEffect(target.EFF_CUT, 5, {power=self:combatTalentWeaponDamage(t, 0.8, 1.5), src=self})
			t.do_devourer_frenzy(self, target, t)
		else
			game.logSeen(target, "%s resists the cut!", target.name:capitalize())
		end

		return true
	end,
	info = function(self, t)
		return ([[Bites the target, potentially causing it to bleed.  The blood will send the devourer into a frenzy (which in turn will frenzy nearby devourers).]])
	end,
}

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
-- Temporal Stalker Powers
-- Ideas; Damage Shift >:)  Give more temporal effects, especially Warden effects, raise AP and add Temporal Damage on hit to mimic weapon folding, give invis rune
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

		if target:checkHit(self:combatMindpower(), target:combatMentalResist(), 0, 95, 15) and target:canBe("fear") then
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

-- Worm that Walks Powers
newTalent{
	name = "Worm Rot",
	type = {"corruption/horror", 1},
	points = 5,
	cooldown = 8,
	vim = 10,
	range = 6,
	requires_target = true,
	tactical = { ATTACK = 2, DISABLE = 4 },
	getBurstDamage = function(self, t) return self:combatTalentSpellDamage(t, 30, 300) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 5, 50) end,
	getHealReduction = function(self, t) return self:combatTalentSpellDamage(t, 20, 70) end,
	getDuration = function(self, t) return 4 + math.ceil(self:getTalentLevel(t)) end,
	proj_speed = 6,
	spawn_carrion_worm = function (self, target, t)
		local x, y = util.findFreeGrid(target.x, target.y, 10, true, {[Map.ACTOR]=true})
		if not x then return nil end

		local worm = {type="vermin", subtype="worms", name="carrion worm mass"}
		local list = mod.class.NPC:loadList("/data/general/npcs/vermin.lua")
		local m = list.CARRION_WORM_MASS
		if not m then return nil end

		m:resolve() m:resolve(nil, true)
		m.faction = self.faction
		game.zone:addEntity(game.level, m, "actor", x, y)
	end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_slime"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end
			if target:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 12 - self:getTalentLevel(t)) and target:canBe("disease") then
				target:setEffect(target.EFF_WORM_ROT, 5, {src=self, dam=t.getDamage(self, t), burst=t.getBurstDamage(self, t)})
			else
				game.logSeen(target, "%s resists the worm rot!", target.name:capitalize())
			end
			game.level.map:particleEmitter(px, py, 1, "slime")
		end)
		game:playSoundNear(self, "talents/slime")

		return true
	end,
	info = function(self, t)
		return ([[A terrible rotting disease that removes a beneficial physical effect and deals acid and blight damage each turn.  If not cleared after a full five turn duration it will inflict extra damage and spawn a carrion worm mass.]])
	end,
}
