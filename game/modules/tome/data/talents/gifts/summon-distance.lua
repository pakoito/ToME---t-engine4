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

newTalent{ short_name = "RITCH_FLAMESPITTER_BOLT",
	name = "Flamespit",
	type = {"wild-gift/other",1},
	points = 5,
	equilibrium = 2,
	mesage = "@Source@ spits flames!",
	range = 10,
	reflectable = true,
	requires_target = true,
	tactical = { ATTACK = { FIRE = 2 } },
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIRE, self:mindCrit(self:combatTalentMindDamage(t, 8, 120)), {type="flame"})
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		return ([[Spits a bolt of fire doing %0.2f fire damage.
		The damage will increase with mindpower.]]):format(damDesc(self, DamageType.FIRE, self:combatTalentMindDamage(t, 8, 120)))
	end,
}

newTalent{
	name = "Flame Fury", image = "talents/blastwave.png",
	type = {"wild-gift/other",1},
	points = 5,
	eqilibrium = 5,
	cooldown = 5,
	tactical = { ATTACKAREA = 2, DISABLE = 2, ESCAPE = 2 },
	direct_hit = true,
	requires_target = true,
	range = 0,
	radius = function(self, t) return 1 + self:getTalentLevelRaw(t) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 28, 180) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local grids = self:project(tg, self.x, self.y, DamageType.FIREKNOCKBACK_MIND, {dist=3, dam=self:mindCrit(t.getDamage(self, t))})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_fire", {radius=tg.radius})
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[A wave of fire emanates from you with radius %d, knocking back anything caught inside and setting them ablaze and doing %0.2f fire damage over 3 turns.
		The damage will increase with your Mindpower.]]):format(radius, damDesc(self, DamageType.FIRE, damage))
	end,
}

newTalent{
	name = "Acid Breath",
	type = {"wild-gift/other",1},
	require = gifts_req1,
	points = 5,
	equilibrium = 10,
	cooldown = 8,
	message = "@Source@ breathes acid!",
	tactical = { ATTACKAREA = { ACID = 2 } },
	range = 0,
	radius = 5,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.ACID, self:mindCrit(self:combatTalentStatDamage(t, "wil", 30, 430)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_acid", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[Breathe acid on your foes, doing %0.2f damage.
		The damage will increase with the Willpower stat]]):format(damDesc(self, DamageType.ACID, self:combatTalentStatDamage(t, "wil", 30, 430)))
	end,
}

newTalent{
	name = "Lightning Breath", short_name = "LIGHTNING_BREATH_HYDRA", image = "talents/lightning_breath.png",
	type = {"wild-gift/other",1},
	require = gifts_req1,
	points = 5,
	equilibrium = 10,
	cooldown = 8,
	message = "@Source@ breathes lightning!",
	tactical = { ATTACKAREA = { LIGHTNING = 2 } },
	range = 0,
	radius = 5,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:combatTalentStatDamage(t, "wil", 30, 500)
		self:project(tg, x, y, DamageType.LIGHTNING, self:mindCrit(rng.avg(dam / 3, dam, 3)))
		if core.shader.active() then game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_lightning", {radius=tg.radius, tx=x-self.x, ty=y-self.y}, {type="lightning"})
		else game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_lightning", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		end
		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		return ([[Breathe lightning on your foes, doing %d to %d damage.
		The damage will increase with the Willpower stat]]):
		format(
			damDesc(self, DamageType.LIGHTNING, (self:combatTalentStatDamage(t, "wil", 30, 500)) / 3),
			damDesc(self, DamageType.LIGHTNING, self:combatTalentStatDamage(t, "wil", 30, 500))
		)
	end,
}

newTalent{
	name = "Poison Breath",
	type = {"wild-gift/other",1},
	require = gifts_req1,
	points = 5,
	equilibrium = 10,
	cooldown = 8,
	message = "@Source@ breathes poison!",
	tactical = { ATTACKAREA = { NATURE = 1, poison = 1 } },
	range = 0,
	radius = 5,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.POISON, self:mindCrit(self:combatTalentStatDamage(t, "wil", 30, 460)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_slime", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[Breathe poison on your foes, doing %d damage over a few turns.
		The damage will increase with the Willpower stat]]):format(damDesc(self, DamageType.NATURE, self:combatTalentStatDamage(t, "wil", 30, 460)))
	end,
}

newTalent{
	name = "Winter's Fury",
	type = {"wild-gift/other",1},
	require = gifts_req4,
	points = 5,
	equilibrium = 10,
	cooldown = 4,
	tactical = { ATTACKAREA = { COLD = 2 }, DISABLE = { stun = 1 } },
	range = 0,
	radius = 3,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
	end,
	getDamage = function(self, t) return self:combatTalentStatDamage(t, "wil", 30, 120) end,
	getDuration = function(self, t) return 4 end,
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.ICE, t.getDamage(self, t),
			3,
			5, nil,
			{type="icestorm", only_one=true},
			function(e)
				e.x = e.src.x
				e.y = e.src.y
				return true
			end,
			false
		)
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[A furious ice storm rages around the user doing %0.2f cold damage in a radius of 3 each turn for %d turns.
		It has 25%% chance to freeze damaged targets.
		The damage and duration will increase with the Willpower stat]]):format(damDesc(self, DamageType.COLD, damage), duration)
	end,
}

newTalent{
	name = "Ritch Flamespitter",
	type = {"wild-gift/summon-distance", 1},
	require = gifts_req1,
	points = 5,
	random_ego = "attack",
	message = "@Source@ summons a Ritch Flamespitter!",
	equilibrium = 2,
	cooldown = 10,
	range = 10,
	requires_target = true,
	is_summon = true,
	tactical = { ATTACK = { FIRE = 2 } },
	on_pre_use = function(self, t, silent)
		if not self:canBe("summon") and not silent then game.logPlayer(self, "You can not summon, you are suppressed!") return end
		return not checkMaxSummon(self, silent)
	end,
	on_detonate = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, DamageType.FIREBURN, self:mindCrit(self:combatTalentMindDamage(t, 30, 300)), {type="flame"})
	end,
	on_arrival = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, DamageType.TEMP_EFFECT, {foes=true, eff=self.EFF_LOWER_FIRE_RESIST, dur=4+self:getTalentLevelRaw(t), p={power=self:combatTalentMindDamage(t, 15, 70)}}, {type="flame"})
	end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "insect", subtype = "ritch",
			display = "I", color=colors.LIGHT_RED, image = "npc/summoner_ritch.png",
			name = "ritch flamespitter", faction = self.faction,
			desc = [[]],
			autolevel = "none",
			ai = "summoned", ai_real = "tactical", ai_state = { talent_in=1, ally_compassion=10},
			ai_tactic = resolvers.tactic"ranged",
			stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
			inc_stats = {
				wil=15 + (self:mindCrit(self:combatMindpower(2)) * self:getTalentLevel(t) / 5),
				cun=15 + (self:mindCrit(self:combatMindpower(1.7)) * self:getTalentLevel(t) / 5),
				con=10 + self:getTalentLevelRaw(self.T_RESILIENCE)*2,
			},
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(5,10),
			life_rating = 8,
			infravision = 10,

			combat_armor = 0, combat_def = 0,
			combat = { dam=1, atk=1, },

			wild_gift_detonate = t.id,

			resolvers.talents{
				[self.T_RITCH_FLAMESPITTER_BOLT]=self:getTalentLevelRaw(t),
			},
			resists = { [DamageType.FIRE] = self:getTalentLevel(t)*10 },

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
			ai_target = {actor=target}
		}
		if self:attr("wild_summon") and rng.percent(self:attr("wild_summon")) then
			m.name = m.name.." (wild summon)"
			m[#m+1] = resolvers.talents{ [self.T_FLAME_FURY]=self:getTalentLevelRaw(t) }
		end
		if self:knowTalent(self.T_BLIGHTED_SUMMONING) then m:learnTalent(m.T_DRAIN, true, 3) end

		setupSummon(self, m, x, y)

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Summon a Ritch Flamespitter for %d turns to burn your foes to death. Flamespitters are really weak in melee and die easily, but they can burn your foes from afar.
		It will get %d willpower, %d cunning and %d constitution.
		Your summons inherit some of your stats: increased damage%%, stun/pin/confusion/blindness resistance, armour penetration.
		Willpower stat will increase with your Mindpower stat.]])
		:format(math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
		15 + (self:combatMindpower(2) * self:getTalentLevel(t) / 5),
		15 + (self:combatMindpower(1.7) * self:getTalentLevel(t) / 5),
		10 + self:getTalentLevelRaw(self.T_RESILIENCE)*2)
	end,
}

newTalent{
	name = "Hydra",
	type = {"wild-gift/summon-distance", 2},
	require = gifts_req2,
	points = 5,
	random_ego = "attack",
	message = "@Source@ summons a 3-headed hydra!",
	equilibrium = 5,
	cooldown = 18,
	range = 10,
	requires_target = true,
	is_summon = true,
	tactical = { ATTACK = { ACID = 1, LIGHTING = 1, NATURE = 1 } },
	on_pre_use = function(self, t, silent)
		if not self:canBe("summon") and not silent then game.logPlayer(self, "You can not summon, you are suppressed!") return end
		return not checkMaxSummon(self, silent)
	end,
	on_detonate = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, rng.table{DamageType.LIGHTNING,DamageType.ACID,DamageType.POISON}, self:mindCrit(self:combatTalentMindDamage(t, 30, 250)), {type="flame"})
	end,
	on_arrival = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		game.level.map:addEffect(self,
			m.x, m.y, 6,
			DamageType.POISON, {dam=self:combatTalentMindDamage(t, 10, 40), apply_power=self:combatMindpower()},
			self:getTalentRadius(t),
			5, nil,
			{type="vapour"},
			nil, false
		)
	end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "hydra", subtype = "3head",
			display = "M", color=colors.GREEN, image = "npc/summoner_hydra.png",
			name = "3-headed hydra", faction = self.faction,
			desc = [[A strange reptilian creature with three smouldering heads.]],
			autolevel = "none",
			ai = "summoned", ai_real = "tactical", ai_state = { talent_in=1, ally_compassion=10},

			stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
			inc_stats = {
				wil=15 + (self:mindCrit(self:combatMindpower(1.6)) * self:getTalentLevel(t) / 5),
				str=18,
				con=10 + self:getTalentLevel(t) * 2 + self:getTalentLevelRaw(self.T_RESILIENCE)*2
			},
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(5,10),
			life_rating = 10,
			infravision = 10,

			combat_armor = 7, combat_def = 0,
			combat = { dam=12, atk=5, },

			resolvers.talents{
				[self.T_LIGHTNING_BREATH_HYDRA]=self:getTalentLevelRaw(t),
				[self.T_ACID_BREATH]=self:getTalentLevelRaw(t),
				[self.T_POISON_BREATH]=self:getTalentLevelRaw(t),
			},

			wild_gift_detonate = t.id,

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
			ai_target = {actor=target}
		}
		if self:attr("wild_summon") and rng.percent(self:attr("wild_summon")) then
			m.name = m.name.." (wild summon)"
			m[#m+1] = resolvers.talents{ [self.T_DISENGAGE]=self:getTalentLevelRaw(t) }
		end
		if self:knowTalent(self.T_BLIGHTED_SUMMONING) then m:learnTalent(m.T_BLOOD_SPRAY, true, 3) end

		setupSummon(self, m, x, y)

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Summon a 3-headed Hydra for %d turns to destroy your foes. 3-headed hydras are able to breathe poison, acid and lightning.
		It will get %d willpower and %d constitution and 18 strength.
		Your summons inherit some of your stats: increased damage%%, stun/pin/confusion/blindness resistance, armour penetration.
		Willpower stat will increase with your Mindpower stat.]])
		:format(math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
		15 + (self:combatMindpower(1.6) * self:getTalentLevel(t) / 5),
		10 + self:getTalentLevel(t) * 2 + self:getTalentLevelRaw(self.T_RESILIENCE)*2)
	end,
}

newTalent{
	name = "Rimebark",
	type = {"wild-gift/summon-distance", 3},
	require = gifts_req3,
	points = 5,
	random_ego = "attack",
	message = "@Source@ summons a Rimebark!",
	equilibrium = 8,
	cooldown = 10,
	range = 10,
	requires_target = true,
	is_summon = true,
	tactical = { ATTACK =  { COLD = 1 }, DISABLE = { stun = 2 } },
	on_pre_use = function(self, t, silent)
		if not self:canBe("summon") and not silent then game.logPlayer(self, "You can not summon, you are suppressed!") return end
		return not checkMaxSummon(self, silent)
	end,
	on_detonate = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, DamageType.ICE, self:mindCrit(self:combatTalentMindDamage(t, 30, 300)), {type="freeze"})
	end,
	on_arrival = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, DamageType.TEMP_EFFECT, {foes=true, eff=self.EFF_LOWER_COLD_RESIST, dur=4+self:getTalentLevelRaw(t), p={power=self:combatTalentMindDamage(t, 15, 70)}}, {type="flame"})
	end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		target = game.level.map(tx, ty, Map.ACTOR)
		local _ _, tx, ty = self:canProject(tg, tx, ty)

		if target == self then target = nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "immovable", subtype = "plants",
			display = "#", color=colors.WHITE,
			name = "rimebark", faction = self.faction, image = "npc/immovable_plants_rimebark.png",
			resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/immovable_plants_rimebark.png", display_h=2, display_y=-1}}},
			desc = [[This huge treant like being is embedded with the fury of winter itself.]],
			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, ally_compassion=10},
			ai_tactic = resolvers.tactic"ranged",
			stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
			inc_stats = {
				wil=15 + (self:mindCrit(self:combatMindpower(2)) * self:getTalentLevel(t) / 5),
				cun=15 + (self:mindCrit(self:combatMindpower(1.6)) * self:getTalentLevel(t) / 5),
				con=10+self:getTalentLevelRaw(self.T_RESILIENCE) * 2,
			},
			level_range = {self.level, self.level}, exp_worth = 0,
			never_move = 1,

			max_life = resolvers.rngavg(120,150),
			life_rating = 16,
			infravision = 10,

			combat_armor = 15, combat_def = 0,
			combat = { dam=resolvers.levelup(resolvers.rngavg(15,25), 1, 1.3), atk=resolvers.levelup(resolvers.rngavg(15,25), 1, 1.3), dammod={cun=1.1} },

			wild_gift_detonate = t.id,

			resolvers.talents{
				[self.T_WINTER_S_FURY]=self:getTalentLevelRaw(t),
			},

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
			ai_target = {actor=target}
		}
		if self:attr("wild_summon") and rng.percent(self:attr("wild_summon")) then
			m.name = m.name.." (wild summon)"
			m[#m+1] = resolvers.talents{ [self.T_RESOLVE]=self:getTalentLevelRaw(t) }
		end
		if self:knowTalent(self.T_BLIGHTED_SUMMONING) then m:learnTalent(m.T_POISON_STORM, true, 3) end

		setupSummon(self, m, x, y)

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Summon a Rimebark for %d turns to harass your foes. Rimebarks can not move but they have a permanent ice storm around them, damaging and freezing anything coming close in a radius of 3.
		It will get %d willpower, %d cunning and %d constitution.
		Your summons inherit some of your stats: increased damage%%, stun/pin/confusion/blindness resistance, armour penetration.
		Willpower stat will increase with your Mindpower stat.]])
		:format(math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
		15 + (self:combatMindpower(2) * self:getTalentLevel(t) / 5),
		15 + (self:combatMindpower(1.6) * self:getTalentLevel(t) / 5),
		10 + self:getTalentLevelRaw(self.T_RESILIENCE) * 2)
	end,
}

newTalent{
	name = "Fire Drake",
	type = {"wild-gift/summon-distance", 4},
	require = gifts_req4,
	points = 5,
	random_ego = "attack",
	message = "@Source@ summons a Fire Drake!",
	equilibrium = 15,
	cooldown = 10,
	range = 10,
	requires_target = true,
	is_summon = true,
	tactical = { ATTACK = { FIRE = 2 }, DISABLE = { knockback = 2 } },
	on_pre_use = function(self, t, silent)
		if not self:canBe("summon") and not silent then game.logPlayer(self, "You can not summon, you are suppressed!") return end
		return not checkMaxSummon(self, silent)
	end,
	on_detonate = function(self, t, m)
		game.level.map:addEffect(self,
			m.x, m.y, 6,
			DamageType.FIRE, self:mindCrit(self:combatTalentMindDamage(t, 10, 70)),
			self:getTalentRadius(t),
			5, nil,
			{type="inferno"},
			nil, true
		)
	end,
	on_arrival = function(self, t, m)
		for i = 1, math.max(1, math.floor(self:getTalentLevel(t) / 2)) do
			-- Find space
			local x, y = util.findFreeGrid(m.x, m.y, 5, true, {[Map.ACTOR]=true})
			if not x then return end

			local NPC = require "mod.class.NPC"
			local mh = NPC.new{
				type = "dragon", subtype = "fire",
				display = "d", color=colors.RED, image = "npc/dragon_fire_fire_drake_hatchling.png",
				name = "fire drake hatchling", faction = self.faction,
				desc = [[A mighty fire drake.]],
				autolevel = "none",
				ai = "summoned", ai_real = "tactical", ai_state = { talent_in=1, ally_compassion=10},
				stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
				inc_stats = { str=15 + self:getWil() * self:getTalentLevel(t) / 6, wil=38, con=20 + self:getTalentLevel(t) * 3 + self:getTalentLevelRaw(self.T_RESILIENCE) * 2, },
				level_range = {self.level, self.level}, exp_worth = 0,

				max_life = resolvers.rngavg(40, 60),
				life_rating = 10,
				infravision = 10,

				combat_armor = 0, combat_def = 0,
				combat = { dam=resolvers.levelup(resolvers.rngavg(25,40), 1, 0.6), atk=resolvers.rngavg(25,60), apr=25, dammod={str=1.1} },
				on_melee_hit = {[DamageType.FIRE]=resolvers.mbonus(7, 2)},

				resists = { [DamageType.FIRE] = 100, },

				summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
				summon_time = m.summon_time,
				ai_target = {actor=m.ai_target.actor}
			}
			setupSummon(self, mh, x, y)
		end
	end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "dragon", subtype = "fire",
			display = "D", color=colors.RED, image = "npc/dragon_fire_fire_drake.png",
			name = "fire drake", faction = self.faction,
			desc = [[A mighty fire drake.]],
			autolevel = "none",
			ai = "summoned", ai_real = "tactical", ai_state = { talent_in=1, ally_compassion=10},
			stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
			inc_stats = {
				str=15 + (self:mindCrit(self:combatMindpower(2)) * self:getTalentLevel(t) / 5),
				wil=38,
				con=20 + (self:mindCrit(self:combatMindpower(1.5)) * self:getTalentLevel(t) / 5) + self:getTalentLevelRaw(self.T_RESILIENCE) * 2,
			},
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(100, 150),
			life_rating = 12,
			infravision = 10,

			combat_armor = 0, combat_def = 0,
			combat = { dam=15, atk=10, apr=15 },

			resists = { [DamageType.FIRE] = 100, },

			wild_gift_detonate = t.id,

			resolvers.talents{
				[self.T_FIRE_BREATH]=self:getTalentLevelRaw(t),
				[self.T_BELLOWING_ROAR]=self:getTalentLevelRaw(t),
				[self.T_WING_BUFFET]=self:getTalentLevelRaw(t),
				[self.T_DEVOURING_FLAME]=self:getTalentLevelRaw(t),
			},

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 2 + self:getTalentLevelRaw(self.T_RESILIENCE),
			ai_target = {actor=target}
		}
		if self:attr("wild_summon") and rng.percent(self:attr("wild_summon")) then
			m.name = m.name.." (wild summon)"
			m[#m+1] = resolvers.talents{ [self.T_AURA_OF_SILENCE]=self:getTalentLevelRaw(t) }
		end
		if self:knowTalent(self.T_BLIGHTED_SUMMONING) then m:learnTalent(m.T_DARKFIRE, true, 3) end

		setupSummon(self, m, x, y)

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Summon a Fire Drake for %d turns to burn and crush your foes to death. Fire Drakes are behemoths that can burn your foes from afar with their fiery breath.
		It will get %d strength, %d constitution and 38 willpower.
		Your summons inherit some of your stats: increased damage%%, stun/pin/confusion/blindness resistance, armour penetration.
		Strength stat will increase with your Mindpower stat.]])
		:format(math.ceil(self:getTalentLevel(t)) + 2 + self:getTalentLevelRaw(self.T_RESILIENCE),
		15 + (self:combatMindpower(2) * self:getTalentLevel(t) / 5),
		20 + (self:combatMindpower(1.5) * self:getTalentLevel(t) / 5) + self:getTalentLevelRaw(self.T_RESILIENCE) * 2)
	end,
}
