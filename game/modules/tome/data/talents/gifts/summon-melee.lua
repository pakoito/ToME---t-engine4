newTalent{
	name = "War Hound",
	type = {"gift/summon-melee", 1},
	require = gifts_req1,
	points = 5,
	message = "@Source@ summons a War Hound!",
	equilibrium = 2,
	cooldown = 10,
	range = 20,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		tx, ty = game.target:pointAtRange(self.x, self.y, tx, ty, self:getTalentRange(t))
		if target == self then target = nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "animal", subtype = "canine",
			display = "C", color=colors.LIGHT_DARK,
			name = "war hound", faction = self.faction,
			desc = [[]],
			autolevel = "warrior",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=5, },
			stats = { str=18, dex=13, mag=5, con=15 },
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(25,50),
			life_rating = 10,

			combat_armor = 2, combat_def = 4,
			combat = { dam=resolvers.rngavg(12,25), atk=10, apr=10, dammod={str=0.8} },

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
		return ([[Summon a War Hound to attack your foes.]])
	end,
}

newTalent{
	name = "Jelly",
	type = {"gift/summon-melee", 2},
	require = gifts_req2,
	points = 5,
	message = "@Source@ summons a Jelly!",
	equilibrium = 4,
	cooldown = 10,
	range = 20,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		tx, ty = game.target:pointAtRange(self.x, self.y, tx, ty, self:getTalentRange(t))
		if target == self then target = nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "immovable", subtype = "jelly",
			display = "j", color=colors.BLACK,
			desc = "A strange blob on the dungeon floor.",
			name = "black jelly",
			autolevel = "tank", faction=self.faction,
			stats = { str=12, dex=15, mag=3, con=15 },
			resists = { [DamageType.LIGHT] = -50 },
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=5, },
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(25,50),
			life_rating = 10,

			combat_armor = 1, combat_def = 1,
			never_move = 1,

			combat = { dam=8, atk=15, apr=5, damtype=DamageType.POISON, dammod={str=0.8} },

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
		return ([[Summon a Jelly to attack your foes. Jellies do not move, but are great to block a passage.]])
	end,
}

newTalent{
	name = "Minotaur",
	type = {"gift/summon-melee", 3},
	require = gifts_req3,
	points = 5,
	message = "@Source@ summons a Minotaur!",
	equilibrium = 10,
	cooldown = 10,
	range = 20,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		tx, ty = game.target:pointAtRange(self.x, self.y, tx, ty, self:getTalentRange(t))
		if target == self then target = nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "immovable", subtype = "jelly",
			display = "j", color=colors.BLACK,
			desc = "A strange blob on the dungeon floor.",
			name = "black jelly",
			autolevel = "tank", faction=self.faction,
			stats = { str=12, dex=15, mag=3, con=15 },
			resists = { [DamageType.LIGHT] = -50 },
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=5, },
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(25,50),
			life_rating = 10,

			combat_armor = 1, combat_def = 1,
			never_move = 1,

			combat = { dam=8, atk=15, apr=5, damtype=DamageType.POISON, dammod={str=0.8} },

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
		return ([[Summon a Minotaur to attack your foes. Minotaurs can not stay summoned for long but they deal lots of damage.]])
	end,
}
