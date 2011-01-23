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

newTalent{ short_name = "RITCH_FLAMESPITTER_BOLT",
	name = "Flamespit",
	type = {"wild-gift/other",1},
	points = 5,
	equilibrium = 2,
	mesage = "@Source@ spits flames!",
	range = 10,
	reflectable = true,
	requires_target = true,
	tactical = { ATTACK = 2 },
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIRE, self:spellCrit(self:combatTalentSpellDamage(t, 8, 120)), {type="flame"})
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		return ([[Conjures up a bolt of fire doing %0.2f fire damage.
		The damage will increase with the Magic stat]]):format(damDesc(self, DamageType.FIRE, self:combatTalentSpellDamage(t, 8, 120)))
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
	tactical = { ATTACKAREA = 2 },
	range = 5,
	requires_target = true,
	action = function(self, t)
		local tg = {type="cone", range=0, radius=self:getTalentRange(t), friendlyfire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.ACID, self:combatTalentStatDamage(t, "wil", 30, 430))
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
	name = "Lightning Breath", short_name = "LIGHTNING_BREATH_HYDRA",
	type = {"wild-gift/other",1},
	require = gifts_req1,
	points = 5,
	equilibrium = 10,
	cooldown = 8,
	message = "@Source@ breathes lightning!",
	tactical = { ATTACKAREA = 2 },
	range = 5,
	requires_target = true,
	action = function(self, t)
		local tg = {type="cone", range=0, radius=self:getTalentRange(t), friendlyfire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:combatTalentStatDamage(t, "wil", 30, 500)
		self:project(tg, x, y, DamageType.LIGHTNING, rng.avg(dam / 3, dam, 3))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_lightning", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
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
	tactical = { ATTACKAREA = 2 },
	range = 5,
	requires_target = true,
	action = function(self, t)
		local tg = {type="cone", range=0, radius=self:getTalentRange(t), friendlyfire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.POISON, self:combatTalentStatDamage(t, "wil", 30, 460))
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
	tactical = { ATTACK = 2 },
	action = function(self, t)
		if not self:canBe("summon") then game.logPlayer(self, "You can not summon, you are suppressed!") return end
		if checkMaxSummon(self) then return end
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
			display = "I", color=colors.LIGHT_RED,
			name = "ritch flamespitter", faction = self.faction,
			desc = [[]],
			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, },
			stats = { mag=15 + self:getWil() * self:getTalentLevel(t) / 5, wil=10 + self:getTalentLevel(t) * 2, con=10+ self:getTalentLevelRaw(self.T_RESILIENCE)*2, },
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(5,10),
			life_rating = 8,
			infravision = 20,

			combat_armor = 0, combat_def = 0,
			combat = { dam=1, atk=1, },

			resolvers.talents{
				[self.T_RITCH_FLAMESPITTER_BOLT]=self:getTalentLevelRaw(t),
			},
			inc_damage = table.clone(self.inc_damage, true),
			resists = { [DamageType.FIRE] = self:getTalentLevel(t)*10 },

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
			ai_target = {actor=target}
		}

		setupSummon(self, m, x, y)

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Summon a Ritch Flamespitter for %d turns to burn your foes to death. Flamespitters are really weak in melee and die easily, but they can burn your foes from afar.
		It will get %d magic, %d willpower and %d constitution.
		Magic stat will increase with your Willpower stat.]])
		:format(math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
		15 + self:getWil() * self:getTalentLevel(t) / 5,
		10 + self:getTalentLevel(t) * 2,
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
	cooldown = 10,
	range = 10,
	requires_target = true,
	tactical = { ATTACK = 2 },
	action = function(self, t)
		if not self:canBe("summon") then game.logPlayer(self, "You can not summon, you are suppressed!") return end
		if checkMaxSummon(self) then return end
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
			display = "M", color=colors.GREEN,
			name = "3-headed hydra", faction = self.faction,
			desc = [[A strange reptilian creature with three smouldering heads.]],
			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, },
			stats = { wil=15 + self:getWil() * self:getTalentLevel(t) / 5, str=18, con=10 + self:getTalentLevel(t) * 2 + self:getTalentLevelRaw(self.T_RESILIENCE)*2},
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(5,10),
			life_rating = 10,
			infravision = 20,

			combat_armor = 7, combat_def = 0,
			combat = { dam=12, atk=5, },

			resolvers.talents{
				[self.T_LIGHTNING_BREATH_HYDRA]=self:getTalentLevelRaw(t),
				[self.T_ACID_BREATH]=self:getTalentLevelRaw(t),
				[self.T_POISON_BREATH]=self:getTalentLevelRaw(t),
			},
			inc_damage = table.clone(self.inc_damage, true),

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
			ai_target = {actor=target}
		}

		setupSummon(self, m, x, y)

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Summon a 3-headed Hydra for %d turns to destroy your foes. 3-headed hydras are able to breathe poison, acid and lightning.
		It will get %d willpower and %d constitution and 18 strength.
		Willpower stat will increase with your Willpower stat.]])
		:format(math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
		15 + self:getWil() * self:getTalentLevel(t) / 5,
		10 + self:getTalentLevel(t) * 2 + self:getTalentLevelRaw(self.T_RESILIENCE)*2)
	end,
}

newTalent{
	name = "Warper",
	type = {"wild-gift/summon-distance", 3},
	require = gifts_req3,
	points = 5,
	random_ego = "attack",
	message = "@Source@ summons a Warper!",
	equilibrium = 8,
	cooldown = 10,
	range = 10,
	requires_target = true,
	tactical = { ATTACK = 1, DISABLE = 2 },
	action = function(self, t)
		if not self:canBe("summon") then game.logPlayer(self, "You can not summon, you are suppressed!") return end
		if checkMaxSummon(self) then return end
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
			type = "demon", subtype = "lesser",
			display = "u", color=colors.BLUE,
			name = "warper", faction = self.faction,
			desc = [[It looks like a hole in reality. The Warper disrupts the normal flow of space and time.]],
			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, },
			stats = { mag=15 + self:getWil() * self:getTalentLevel(t) / 5, wil=10 + self:getTalentLevel(t) * 2, con=10+self:getTalentLevelRaw(self.T_RESILIENCE) * 2, },
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(5,10),
			life_rating = 8,
			infravision = 20,

			combat_armor = 0, combat_def = 0,
			combat = { dam=1, atk=1, },

			resolvers.talents{
				[self.T_TIME_PRISON]=self:getTalentLevelRaw(t),
				[self.T_MANATHRUST]=self:getTalentLevelRaw(t),
				[self.T_PHASE_DOOR]=self:getTalentLevelRaw(t),
			},
			inc_damage = table.clone(self.inc_damage, true),

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
			ai_target = {actor=target}
		}

		setupSummon(self, m, x, y)

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Summon a Warper for %d turns to harass your foes. Warpers are really weak in melee and die easily, but they can blink around, throwing manathrusts and time prisons at your foes.
		It will get %d magic, %d willpower and %d constitution.
		Magic stat will increase with your Willpower stat.]])
		:format(math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
		15 + self:getWil() * self:getTalentLevel(t) / 5,
		10 + self:getTalentLevel(t) * 2,
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
	tactical = { ATTACK = 2, DISABLE = 2 },
	action = function(self, t)
		if not self:canBe("summon") then game.logPlayer(self, "You can not summon, you are suppressed!") return end
		if checkMaxSummon(self) then return end
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
			display = "D", color=colors.RED,
			name = "fire drake", faction = self.faction,
			desc = [[A mighty fire drake, an Uruloki.]],
			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, },
			stats = { str=15 + self:getWil() * self:getTalentLevel(t) / 5, wil=38, con=20 + self:getTalentLevel(t) * 3 + self:getTalentLevelRaw(self.T_RESILIENCE) * 2, },
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(100, 150),
			life_rating = 12,
			infravision = 20,

			combat_armor = 0, combat_def = 0,
			combat = { dam=15, atk=10, apr=15 },

			resists = { [DamageType.FIRE] = 100, },

			resolvers.talents{
				[self.T_FIRE_BREATH]=self:getTalentLevelRaw(t),
				[self.T_BELLOWING_ROAR]=self:getTalentLevelRaw(t),
				[self.T_WING_BUFFET]=self:getTalentLevelRaw(t),
				[self.T_DEVOURING_FLAME]=self:getTalentLevelRaw(t),
			},
			inc_damage = table.clone(self.inc_damage, true),

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 2 + self:getTalentLevelRaw(self.T_RESILIENCE),
			ai_target = {actor=target}
		}

		setupSummon(self, m, x, y)

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Summon a Fire Drake for %d turns to burn and crush your foes to death. Fire Drakes are behemoths that can burn your foes from afar with their fiery breath.
		It will get %d strength, %d constitution and 38 willpower.
		Strength stat will increase with your Willpower stat.]])
		:format(math.ceil(self:getTalentLevel(t)) + 2 + self:getTalentLevelRaw(self.T_RESILIENCE),
		15 + self:getWil() * self:getTalentLevel(t) / 5,
		20 + self:getTalentLevel(t) * 3 + self:getTalentLevelRaw(self.T_RESILIENCE) * 2)
	end,
}
