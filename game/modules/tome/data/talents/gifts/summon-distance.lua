newTalent{ short_name = "FIRE_IMP_BOLT",
	name = "Fire Bolt",
	type = {"spell/other",1},
	points = 5,
	mana = 10,
	range = 20,
	reflectable = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIRE, self:spellCrit(8 + self:combatSpellpower(0.2) * self:getTalentLevel(t)), {type="flame"})
		return true
	end,
	info = function(self, t)
		return ([[Conjures up a bolt of fire doing %0.2f fire damage.
		The damage will increase with the Magic stat]]):format(8 + self:combatSpellpower(0.2) * self:getTalentLevel(t))
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
	tactical = {
		ATTACKAREA = 10,
	},
	range = 4,
	action = function(self, t)
		local tg = {type="cone", range=0, radius=5, friendlyfire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.ACID, 30 + self:getWil(50) * self:getTalentLevel(t), {type="acid"})
		return true
	end,
	info = function(self, t)
		return ([[Breath acid on your foes, doing %d damage.
		The damage will increase with the Willpower stat]]):format(30 + self:getWil(50) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Lightning Breath",
	type = {"wild-gift/other",1},
	require = gifts_req1,
	points = 5,
	equilibrium = 10,
	cooldown = 8,
	message = "@Source@ breathes lightning!",
	tactical = {
		ATTACKAREA = 10,
	},
	range = 4,
	action = function(self, t)
		local tg = {type="cone", range=0, radius=5, friendlyfire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.LIGHTNING, rng.range(1, 30 + self:getWil(80) * self:getTalentLevel(t)), {type="lightning"})
		return true
	end,
	info = function(self, t)
		return ([[Breath lightning on your foes, doing 1 to %d damage.
		The damage will increase with the Willpower stat]]):format(30 + self:getWil(70) * self:getTalentLevel(t))
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
	tactical = {
		ATTACKAREA = 10,
	},
	range = 4,
	action = function(self, t)
		local tg = {type="cone", range=0, radius=5, friendlyfire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.POISON, 30 + self:getWil(70) * self:getTalentLevel(t), {type="slime"})
		return true
	end,
	info = function(self, t)
		return ([[Breath poison on your foes, doing %d damage over a few turns.
		The damage will increase with the Willpower stat]]):format(10 + self:getWil(70) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Fire Imp",
	type = {"wild-gift/summon-distance", 1},
	require = gifts_req1,
	points = 5,
	message = "@Source@ summons a Fire Imp!",
	equilibrium = 2,
	cooldown = 10,
	range = 20,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
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
			display = "u", color=colors.RED,
			name = "fire imp", faction = self.faction,
			desc = [[]],
			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, },
			stats = { mag=15 + self:getWil() * self:getTalentLevel(t) / 5, wil=18, con=10 + self:getTalentLevel(t) * 2, },
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(5,10),
			life_rating = 8,

			combat_armor = 0, combat_def = 0,
			combat = { dam=1, atk=1, },

			max_mana = 150,
			resolvers.talents{
				[self.T_FIRE_IMP_BOLT]=self:getTalentLevelRaw(t),
			},

			summoner = self, summoner_gain_exp=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5,
			ai_target = {actor=target}
		}

		m:resolve() m:resolve(nil, true)
		m:forceLevelup(self.level)
		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "summon")

		return true
	end,
	info = function(self, t)
		return ([[Summon a Fire Imp to burn your foes to death. Fire Imps are really weak in melee and die easily, but they can burn your foes from afar.
		It will get %d magic and %d willpower.]]):format(15 + self:getWil() * self:getTalentLevel(t) / 5, 10 + self:getTalentLevel(t) * 2)
	end,
}

newTalent{
	name = "Hydra",
	type = {"wild-gift/summon-distance", 2},
	require = gifts_req2,
	points = 5,
	message = "@Source@ summons a 5-headed hydra!",
	equilibrium = 5,
	cooldown = 10,
	range = 20,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
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
			type = "hydra", subtype = "3head",
			display = "M", color=colors.GREEN,
			name = "3-headed hydra", faction = self.faction,
			desc = [[A strange reptilian creature with three smouldering heads.]],
			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, },
			stats = { wil=15 + self:getWil() * self:getTalentLevel(t) / 5, str=18, },
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(5,10),
			life_rating = 10,

			combat_armor = 7, combat_def = 0,
			combat = { dam=12, atk=5, },

			max_mana = 150,
			resolvers.talents{
				[self.T_LIGHTNING_BREATH]=self:getTalentLevelRaw(t),
				[self.T_ACID_BREATH]=self:getTalentLevelRaw(t),
				[self.T_POISON_BREATH]=self:getTalentLevelRaw(t),
			},

			summoner = self, summoner_gain_exp=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5,
			ai_target = {actor=target}
		}

		m:resolve() m:resolve(nil, true)
		m:forceLevelup(self.level)
		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "summon")

		return true
	end,
	info = function(self, t)
		return ([[Summon a 3-headed Hydra to destroy your foes. 3-headed hydras are able to breath poison, acid and lightning.
		It will get %d magic and %d willpower.]]):format(15 + self:getWil() * self:getTalentLevel(t) / 5, 10 + self:getTalentLevel(t) * 2)
	end,
}

newTalent{
	name = "Warper",
	type = {"wild-gift/summon-distance", 3},
	require = gifts_req3,
	points = 5,
	message = "@Source@ summons a Warper!",
	equilibrium = 8,
	cooldown = 10,
	range = 20,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
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
			desc = [[It looks like a hole in reality, the Warper disrupts the normal flow of space and time.]],
			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, },
			stats = { mag=15 + self:getWil() * self:getTalentLevel(t) / 5, wil=18, con=10 + self:getTalentLevel(t) * 2, },
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(5,10),
			life_rating = 8,

			combat_armor = 0, combat_def = 0,
			combat = { dam=1, atk=1, },

			max_mana = 150,
			resolvers.talents{
				[self.T_TIME_PRISON]=self:getTalentLevelRaw(t),
				[self.T_MANATHRUST]=self:getTalentLevelRaw(t),
				[self.T_PHASE_DOOR]=self:getTalentLevelRaw(t),
			},

			summoner = self, summoner_gain_exp=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5,
			ai_target = {actor=target}
		}

		m:resolve() m:resolve(nil, true)
		m:forceLevelup(self.level)
		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "summon")

		return true
	end,
	info = function(self, t)
		return ([[Summon a Fire Imp to burn your foes to death. Fire Imps are really weak in melee and die easily, but they can burn your foes from afar.
		It will get %d magic and %d willpower.]]):format(15 + self:getWil() * self:getTalentLevel(t) / 5, 10 + self:getTalentLevel(t) * 2)
	end,
}

newTalent{
	name = "Fire Drake",
	type = {"wild-gift/summon-distance", 4},
	require = gifts_req4,
	points = 5,
	message = "@Source@ summons a Fire Drake!",
	equilibrium = 15,
	cooldown = 10,
	range = 20,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
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
			type = "dragon", subtype = "fire",
			display = "D", color=colors.RED,
			name = "fire drake", faction = self.faction,
			desc = [[A mighty fire drake, an Uruloki.]],
			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, },
			stats = { str=15 + self:getWil() * self:getTalentLevel(t) / 5, wil=38, con=20 + self:getTalentLevel(t) * 3, },
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(100, 150),
			life_rating = 8,

			combat_armor = 0, combat_def = 0,
			combat = { dam=15, atk=10, apr=15 },

			resolvers.talents{
				[self.T_FIRE_BREATH]=self:getTalentLevelRaw(t),
				[self.T_BELLOWING_ROAR]=self:getTalentLevelRaw(t),
				[self.T_WING_BUFFET]=self:getTalentLevelRaw(t),
				[self.T_DEVOURING_FLAME]=self:getTalentLevelRaw(t),
			},

			summoner = self, summoner_gain_exp=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 2,
			ai_target = {actor=target}
		}

		m:resolve() m:resolve(nil, true)
		m:forceLevelup(self.level)
		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "summon")

		return true
	end,
	info = function(self, t)
		return ([[Summon a Fire Drake to burn and crush your foes to death. Fire Drakes a behemoths that can burn your foes from afar with their fiery breath.
		It will get %d strenght and %d willpower.]]):format(15 + self:getWil() * self:getTalentLevel(t) / 5, 10 + self:getTalentLevel(t) * 2)
	end,
}
