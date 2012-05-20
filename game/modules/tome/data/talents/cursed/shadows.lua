-- ToME - Tales of Middle-Earth
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
	short_name = "SHADOW_FADE",
	name = "Fade",
	type = {"spell/other",1},
	points = 5,
	cooldown = function(self, t)
		return math.max(3, 8 - self:getTalentLevelRaw(t))
	end,
	action = function(self, t)
		self:setEffect(self.EFF_FADED, 1, {})
		return true
	end,
	info = function(self, t)
		return ([[You fade from sight, making you invulnerable until the beginning of your next turn.]])
	end,
}

newTalent{
	short_name = "SHADOW_PHASE_DOOR",
	name = "Phase Door",
	type = {"spell/other",1},
	points = 5,
	range = 10,
	tactical = { ESCAPE = 2 },
	is_teleport = true,
	action = function(self, t)
		local x, y, range
		if self.ai_state.shadow_wall then
			x, y, range = self.ai_state.shadow_wall_target.x, self.ai_state.shadow_wall_target.y, 1
		elseif self.ai_target.x and self.ai_target.y then
			x, y, range = self.ai_target.x, self.ai_target.y, 1
		else
			x, y, range = self.summoner.x, self.summoner.y, self.ai_state.location_range
		end

		game.level.map:particleEmitter(self.x, self.y, 1, "teleport_out")
		self:teleportRandom(x, y, range)
		game.level.map:particleEmitter(x, y, 1, "teleport_in")
		return true
	end,
	info = function(self, t)
		return ([[Teleports you within a small range.]])
	end,
}

newTalent{
	short_name = "SHADOW_BLINDSIDE",
	name = "Blindside",
	type = {"spell/other", 1},
	points = 5,
	random_ego = "attack",
	range = 10,
	requires_target = true,
	tactical = { CLOSEIN = 2 },
	action = function(self, t)
		local tg = {type="hit", pass_terrain = true, range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end

		local start = rng.range(0, 8)
		for i = start, start + 8 do
			local x = target.x + (i % 3) - 1
			local y = target.y + math.floor((i % 9) / 3) - 1
			if game.level.map:isBound(x, y)
					and self:canMove(x, y)
					and not game.level.map.attrs(x, y, "no_teleport") then
				game.level.map:particleEmitter(self.x, self.y, 1, "teleport_out")
				self:move(x, y, true)
				game.level.map:particleEmitter(x, y, 1, "teleport_in")
				local multiplier = self:combatTalentWeaponDamage(t, 0.9, 1.9)
				self:attackTarget(target, nil, multiplier, true)
				return true
			end
		end

		return false
	end,info = function(self, t)
		local multiplier = self:combatTalentWeaponDamage(t, 1.1, 1.9)
		return ([[With blinding speed you suddenly appear next to a target up to %d spaces away and attack for %d%% damage.]]):format(self:getTalentRange(t), multiplier)
	end,
}

newTalent{
	short_name = "SHADOW_LIGHTNING",
	name = "Shadow Lightning",
	type = {"spell/other", 1},
	require = { },
	points = 5,
	random_ego = "attack",
	range = 1,
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 200) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
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
		return ([[Strikes the target with a spark of lightning doing %0.2f to %0.2f damage.
		The damage will increase with the Magic stat]]):
		format(damDesc(self, DamageType.LIGHTNING, damage / 3),
		damDesc(self, DamageType.LIGHTNING, damage))
	end,
}

newTalent{
	short_name = "SHADOW_FLAMES",
	name = "Shadow Flames",
	type = {"spell/other", 1},
	require = { },
	points = 5,
	random_ego = "attack",
	range = 6,
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 140) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:spellCrit(t.getDamage(self, t))
		self:project(tg, x, y, DamageType.FIRE, dam)
		game.level.map:particleEmitter(x, y, 1, "flame")
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Bathes the target in flames doing %0.2f damage
		The damage will increase with the Magic stat]]):
		format(damDesc(self, DamageType.FIREBURN, damage))
	end,
}

newTalent{
	short_name = "SHADOW_REFORM",
	name = "Reform",
	type = {"spell/other", 1},
	require = { },
	points = 5,
	getChance = function(self, t)
		return 50 --10 + self:getMag() * 0.25 + self:getTalentLevel(t) * 2
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		return ([[When a shadow is hit and killed, there is a %d%% chance it will reform unhurt.]]):format(chance)
	end,
}

local function createShadow(self, level, tCallShadows, tShadowWarriors, tShadowMages, duration, target)
	return require("mod.class.NPC").new{
		type = "undead", subtype = "shadow",
		name = "shadow",
		desc = [[]],
		display = 'b', color=colors.BLACK,

		never_anger = true,
		summoner = self,
		summoner_gain_exp=true,
		summon_time = duration,
		faction = self.faction,
		size_category = 2,
		rank = 2,
		autolevel = "none",
		level_range = {level, level},
		exp_worth=0,
		hate_regen = 1,

		max_life = resolvers.rngavg(3,12), life_rating = 5,
		stats = {
			str=5 + math.floor(level),
			dex=10 + math.floor(level * 1.5),
			mag=10 + math.floor(level * 1.5),
			wil=5 + math.floor(level),
			cun=5 + math.floor(level * 0.7),
			con=5 + math.floor(level * 0.7),
		},
		combat_armor = 0, combat_def = 3,
		combat = {
			dam=math.floor(level * 1.5),
			atk=10 + level,
			apr=8,
			dammod={str=0.5, dex=0.5}
		},
		mana = 100,
		spellpower = tShadowMages and tShadowMages.getSpellpowerChange(self, tShadowMages) or 0,
		summoner_hate_per_kill = self.hate_per_kill,
		resolvers.talents{
			[self.T_SHADOW_PHASE_DOOR]=tCallShadows.getPhaseDoorLevel(self, tCallShadows),
			[self.T_SHADOW_BLINDSIDE]=tCallShadows.getBlindsideLevel(self, tCallShadows),
			[self.T_HEAL]=tCallShadows.getHealLevel(self, tCallShadows),
			[self.T_DOMINATE]=tShadowWarriors and tShadowWarriors.getDominateLevel(self, tShadowWarriors) or 0,
			[self.T_SHADOW_FADE]=tShadowWarriors and tShadowWarriors.getFadeLevel(self, tShadowWarriors) or 0,
			[self.T_SHADOW_LIGHTNING]=tShadowMages and tShadowMages.getLightningLevel(self, tShadowMages) or 0,
			[self.T_SHADOW_FLAMES]=tShadowMages and tShadowMages.getFlamesLevel(self, tShadowMages) or 0,
			[self.T_SHADOW_REFORM]=tShadowMages and tShadowMages.getReformLevel(self, tShadowMages) or 0,
		},

		undead = 1,
		no_breath = 1,
		stone_immune = 1,
		confusion_immune = 1,
		fear_immune = 1,
		teleport_immune = 1,
		disease_immune = 1,
		poison_immune = 1,
		stun_immune = 1,
		blind_immune = 1,
		see_invisible = 80,
		resists = { [DamageType.LIGHT] = -100, [DamageType.DARKNESS] = 100 },
		resists_pen = { all=25 },

		ai = "shadow",
		ai_state = {
			summoner_range = 10,
			actor_range = 8,
			location_range = 4,
			target_time = 0,
			target_timeout = 10,
			focus_on_target = false,
			shadow_wall = false,
			shadow_wall_time = 0,

			blindside_chance = 15,
			phasedoor_chance = 5,
			close_attack_spell_chance = 0,
			far_attack_spell_chance = 0,
			can_reform = false,
			dominate_chance = 0,

			feed_level = 0
		},
		ai_target = {
			actor=target,
			x = nil,
			y = nil
		},

		healSelf = function(self)
			self:useTalent(self.T_HEAL)
		end,
		closeAttackSpell = function(self)
			return self:useTalent(self.T_SHADOW_LIGHTNING)
		end,
		farAttackSpell = function(self)
			return self:useTalent(self.T_SHADOW_FLAMES)
		end,
		dominate = function(self)
			return self:useTalent(self.T_DOMINATE)
		end,
		feed = function(self)
			if self.summoner:knowTalent(self.summoner.T_SHADOW_MAGES) then
				local tShadowMages = self.summoner:getTalentFromId(self.summoner.T_SHADOW_MAGES)
				self.ai_state.close_attack_spell_chance = tShadowMages.getCloseAttackSpellChance(self.summoner, tShadowMages)
				self.ai_state.far_attack_spell_chance = tShadowMages.getFarAttackSpellChance(self.summoner, tShadowMages)
				self.ai_state.can_reform = self.summoner:getTalentLevel(tShadowMages) >= 5
			else
				self.ai_state.close_attack_spell_chance = 0
				self.ai_state.far_attack_spell_chance = 0
				self.ai_state.can_reform = false
			end

			if self.ai_state.feed_temp1 then self:removeTemporaryValue("combat_atk", self.ai_state.feed_temp1) end
			self.ai_state.feed_temp1 = nil
			if self.ai_state.feed_temp2 then self:removeTemporaryValue("inc_damage", self.ai_state.feed_temp2) end
			self.ai_state.feed_temp2 = nil
			if self.summoner:knowTalent(self.summoner.T_SHADOW_WARRIORS) then
				local tShadowWarriors = self.summoner:getTalentFromId(self.summoner.T_SHADOW_WARRIORS)
				self.ai_state.feed_temp1 = self:addTemporaryValue("combat_atk", tShadowWarriors.getCombatAtk(self.summoner, tShadowWarriors))
				self.ai_state.feed_temp2 = self:addTemporaryValue("inc_damage", {all=tShadowWarriors.getIncDamage(self.summoner, tShadowWarriors)})
				self.ai_state.dominate_chance = tShadowWarriors.getDominateChance(self.summoner, tShadowWarriors)
			else
				self.ai_state.dominate_chance = 0
			end
		end,
		onTakeHit = function(self, value, src)
			if self:knowTalent(self.T_SHADOW_FADE) and not self:isTalentCoolingDown(self.T_SHADOW_FADE) then
				self:forceUseTalent(self.T_SHADOW_FADE, {ignore_energy=true})
			end

			return mod.class.Actor.onTakeHit(self, value, src)
		end,
	}
end

newTalent{
	name = "Call Shadows",
	type = {"cursed/shadows", 1},
	mode = "sustained",
	no_energy = true,
	require = cursed_cun_req1,
	points = 5,
	cooldown = 10,
	tactical = { BUFF = 5 },
	getLevel = function(self, t)
		return self.level
	end,
	getMaxShadows = function(self, t)
		return math.min(4, math.max(1, math.floor(self:getTalentLevel(t) * 0.55)))
	end,
	getPhaseDoorLevel = function(self, t)
		return self:getTalentLevelRaw(t)
	end,
	getBlindsideLevel = function(self, t)
		return self:getTalentLevelRaw(t)
	end,
	getHealLevel = function(self, t)
		return self:getTalentLevelRaw(t)
	end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		-- unsummon the shadows
		for _, e in pairs(game.level.entities) do
			if e.summoner and e.summoner == self and e.subtype == "shadow" then
				e.summon_time = 0
			end
		end

		return true
	end,
	do_callShadows = function(self, t)
		if not self.shadows then
			self.shadows = {
				remainingCooldown = 0
			}
		end

		if game.zone.wilderness then return false end

		self.shadows.remainingCooldown = self.shadows.remainingCooldown - 1
		if self.shadows.remainingCooldown > 0 then return false end
		self.shadows.remainingCooldown = 10

		local shadowCount = 0
		for _, e in pairs(game.level.entities) do
			if e.summoner and e.summoner == self and e.subtype == "shadow" then shadowCount = shadowCount + 1 end
		end

		if shadowCount >= t.getMaxShadows(self, t) then
			return false
		end

		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 8, true, {[Map.ACTOR]=true})
		if not x then
			return false
		end

		-- use hate
		if self.hate < 6 then
			-- not enough hate..just wait for another try
			game.logPlayer(self, "You hate is too low to call another shadow!", deflectDamage)
			return false
		end
		self:incHate(-6)

		level = t.getLevel(self, t)
		local tShadowWarriors = self:knowTalent(self.T_SHADOW_WARRIORS) and self:getTalentFromId(self.T_SHADOW_WARRIORS) or nil
		local tShadowMages = self:knowTalent(self.T_SHADOW_MAGES) and self:getTalentFromId(self.T_SHADOW_MAGES) or nil

		local shadow = createShadow(self, level, t, tShadowWarriors, tShadowMages, 1000, nil)

		shadow:resolve()
		shadow:resolve(nil, true)
		shadow:forceLevelup(level)
		game.zone:addEntity(game.level, shadow, "actor", x, y)
		shadow:feed()
		game.level.map:particleEmitter(x, y, 1, "teleport_in")

		shadow.no_party_ai = true
		shadow.unused_stats = 0
		shadow.unused_talents = 0
		shadow.unused_generics = 0
		shadow.unused_talents_types = 0
		shadow.no_points_on_levelup = true
		if game.party:hasMember(self) then
			shadow.remove_from_party_on_death = true
			game.party:addMember(shadow, { control="no", type="summon", title="Summon"})
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local maxShadows = t.getMaxShadows(self, t)
		local level = t.getLevel(self, t)
		local healLevel = t.getHealLevel(self, t)
		local blindsideLevel = t.getBlindsideLevel(self, t)
		return ([[While this ability is active you will continually call up to %d level %d shadows to aid you in battle. Each shadow costs 6 hate to summon. Shadows are weak combatants that can: Use Arcane Reconstruction to heal themselves (level %d), Blindside their opponents (level %d) and Phase Door from place to place.]]):format(maxShadows, level, healLevel, blindsideLevel)
	end,
}

newTalent{
	name = "Shadow Warriors",
	type = {"cursed/shadows", 2},
	mode = "passive",
	require = cursed_cun_req2,
	points = 5,
	getIncDamage = function(self, t)
		return math.floor((math.sqrt(self:getTalentLevel(t)) - 0.5) * 35)
	end,
	getCombatAtk = function(self, t)
		return math.floor((math.sqrt(self:getTalentLevel(t)) - 0.5) * 23)
	end,
	getDominateLevel = function(self, t)
		return self:getTalentLevelRaw(t)
	end,
	getFadeLevel = function(self, t)
		return self:getTalentLevelRaw(t)
	end,
	getDominateChance = function(self, t)
		if self:getTalentLevelRaw(t) > 0 then
			return math.min(100, math.sqrt(self:getTalentLevel(t)) * 7)
		else
			return 0
		end
	end,
	on_learn = function(self, t)
		if game and game.level and game.level.entities then
			for _, e in pairs(game.level.entities) do
				if e.summoner and e.summoner == self and e.subtype == "shadow" then
					e:feed(t)
				end
			end
		end

		return { }
	end,
	on_unlearn = function(self, t, p)
		if game and game.level and game.level.entities then
			for _, e in pairs(game.level.entities) do
				if e.summoner and e.summoner == self and e.subtype == "shadow" then
					e:feed(t)
				end
			end
		end

		return true
	end,
	info = function(self, t)
		local combatAtk = t.getCombatAtk(self, t)
		local incDamage = t.getIncDamage(self, t)
		local dominateChance = t.getDominateChance(self, t)
		local dominateLevel = t.getDominateLevel(self, t)
		local fadeCooldown = math.max(3, 8 - self:getTalentLevelRaw(t))
		return ([[Instill hate in your shadows, strengthening their attacks. They gain %d%% extra accuracy and %d%% extra damage. The fury of their attacks gives them the ability to try to Dominate their foes, increasing all damage taken by that foe for 4 turns (level %d, %d%% chance at range 1). They also gain the ability to Fade when hit, avoiding all damage until their next turn (%d turn cooldown).]]):format(combatAtk, incDamage, dominateLevel, dominateChance, fadeCooldown)
	end,
}

newTalent{
	name = "Shadow Mages",
	type = {"cursed/shadows", 3},
	mode = "passive",
	require = cursed_cun_req3,
	points = 5,
	getCloseAttackSpellChance = function(self, t)
		if math.floor(self:getTalentLevel(t)) > 0 then
			return math.min(100, math.sqrt(self:getTalentLevel(t)) * 7)
		else
			return 0
		end
	end,
	getFarAttackSpellChance = function(self, t)
		if math.floor(self:getTalentLevel(t)) >= 3 then
			return math.min(100, math.sqrt(self:getTalentLevel(t)) * 7)
		else
			return 0
		end
	end,
	getLightningLevel = function(self, t)
		return self:getTalentLevelRaw(t)
	end,
	getFlamesLevel = function(self, t)
		if self:getTalentLevel(t) >= 3 then
			return self:getTalentLevelRaw(t)
		else
			return 0
		end
	end,
	getReformLevel = function(self, t)
		if self:getTalentLevel(t) >= 5 then
			return self:getTalentLevelRaw(t)
		else
			return 0
		end
	end,
	canReform = function(self, t)
		return t.getReformLevel(self, t) > 0
	end,
	getSpellpowerChange = function(self, t)
		return math.floor(self:getTalentLevel(t) * 3)
	end,
	on_learn = function(self, t)
		if game and game.level and game.level.entities then
			for _, e in pairs(game.level.entities) do
				if e.summoner and e.summoner == self and e.subtype == "shadow" then
					e:feed(t)
				end
			end
		end

		return { }
	end,
	on_unlearn = function(self, t, p)
		if game and game.level and game.level.entities then
			for _, e in pairs(game.level.entities) do
				if e.summoner and e.summoner == self and e.subtype == "shadow" then
					e:feed(t)
				end
			end
		end

		return true
	end,
	info = function(self, t)
		local closeAttackSpellChance = t.getCloseAttackSpellChance(self, t)
		local farAttackSpellChance = t.getFarAttackSpellChance(self, t)
		local spellpowerChange = t.getSpellpowerChange(self, t)
		local lightningLevel = t.getLightningLevel(self, t)
		local flamesLevel = t.getFlamesLevel(self, t)
		return ([[Infuse magic into your shadows to give them fearsome spells. Your shadows receive a bonus of %d to their spellpower.
		Your shadows can strike adjacent foes with Lightning (level %d, %d%% chance at range 1).
		At level 3 your shadows can sear their enemies from a distance with Flames (level %d, %d%% chance at range 2 to 6).
		At level 5 when your shadows are struck down they will attempt to Reform, becoming whole again (50%% chance).]]):format(spellpowerChange, lightningLevel, closeAttackSpellChance, flamesLevel, farAttackSpellChance)
	end,
}

newTalent{
	name = "Focus Shadows",
	type = {"cursed/shadows", 4},
	require = cursed_cun_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	hate = 0,
	range = 6,
	requires_target = true,
	tactical = { ATTACK = 2 },
	getDefenseDuration = function(self, t)
		return 3 + math.floor(self:getTalentLevel(t) * 1.5)
	end,
	getBlindsideChance = function(self, t)
		return math.min(100, 30 + self:getTalentLevel(t) * 10)
	end,
	action = function(self, t)
		local range = self:getTalentRange(t)
		local target = { type="hit", range=range, nowarning=true }
		local x, y, target = self:getTarget(target)
		if not x or not y or not target or core.fov.distance(self.x, self.y, x, y) > range then return nil end

		if self:reactionToward(target) < 0 then
			-- attack the target
			local blindsideChance = t.getBlindsideChance(self, t)
			local shadowCount = 0
			for _, e in pairs(game.level.entities) do
				if e.summoner and e.summoner == self and e.subtype == "shadow" then
					-- reset target and set to focus
					e.ai_target.x = nil
					e.ai_target.y = nil
					e.ai_target.actor = target
					e.ai_target.focus_on_target = true
					e.ai_target.blindside_chance = blindsideChance

					shadowCount = shadowCount + 1
				end
			end

			if shadowCount > 0 then
				game.logPlayer(self, "#PINK#The shadows converge on %s!", target.name)
				return true
			else
				game.logPlayer(self, "Their are no shadows to heed the call!")
				return false
			end
		else
			-- defend the target
			local defenseDuration = t.getDefenseDuration(self, t)
			local shadowCount = 0
			for _, e in pairs(game.level.entities) do
				if e.summoner and e.summoner == self and e.subtype == "shadow" then
					e.ai_state.shadow_wall = true
					e.ai_state.shadow_wall_target = target
					e.ai_state.shadow_wall_time = defenseDuration

					shadowCount = shadowCount + 1
				end
			end

			if shadowCount > 0 then
				game.logPlayer(self, "#PINK#The shadows form around %s!", target.name)
				return true
			else
				game.logPlayer(self, "Their are no shadows to heed the call!")
				return false
			end
		end
	end,
	info = function(self, t)
		local defenseDuration = t.getDefenseDuration(self, t)
		local blindsideChance = t.getBlindsideChance(self, t)
		return ([[Focus your shadows on a single target. Friendly targets will be defended for %d turns. Hostile targets will be attacked with a %d%% chance they will blindside the target.
		This talent has no cost.]]):format(defenseDuration, blindsideChance)
	end,
}

