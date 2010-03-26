newTalent{
	name = "Summon End",
	type = {"wild-gift/other",1},
	require = gifts_req1,
	points = 1,
	action = function(self, t)
		self:die()
		return true
	end,
	info = function(self, t)
		return ([[Cancels the control of your summon, this will return your will into your body and destroy the summon.]])
	end,
}

newTalent{
	name = "Turtle",
	type = {"wild-gift/summon-utility", 1},
	require = gifts_req1,
	points = 5,
	message = "@Source@ summons a Turtle!",
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
	name = "Spider",
	type = {"wild-gift/summon-utility", 2},
	require = gifts_req2,
	points = 5,
	message = "@Source@ summons a Qpider!",
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
	name = "Benevolent Spirit",
	type = {"wild-gift/summon-utility", 3},
	require = gifts_req3,
	points = 5,
	message = "@Source@ summons a Benevolent Spirit!",
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
	name = "Summon Control",
	type = {"wild-gift/summon-utility", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 2,
	cooldown = 10,
	range = 20,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty or not target then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		if target == self then target = nil end
		if not target.summoner == game.player then return nil end

		local ot = target
		target = mod.class.Player.new(target)
		target.changed = true
		target.energy.value = 0
		target:hotkeyAutoTalents()
		target.talents[self.T_SUMMON_END] = 1
		target.hotkey[10] = {"talent",self.T_SUMMON_END}
		target.summon_time = target.summon_time + 2 + self:getTalentLevel(t) * 3
		ot:replaceWith(target)
		game.player.player = nil
		game.paused = false
		game.player = ot
		game.hotkeys_display.actor = ot
		game.target.source_actor = ot
		Map:setViewerActor(ot)
		game.level.map:moveViewSurround(ot.x, ot.y, 8, 8)

		ot.die = function(self)
			game.level:removeEntity(self)
			self.dead = true
			game.player = self.summoner
			game.player.player = true
			game.hotkeys_display.actor = self.summoner
			game.target.source_actor = self.summoner
			engine.Map:setViewerActor(self.summoner)
			game.paused = false
			game.level.map:moveViewSurround(self.summoner.x, self.summoner.y, 8, 8)
		end

		return true
	end,
	info = function(self, t)
		return ([[Take direct control of one of your summons.
		When taking control your summon gets its life time increase by %d turns.]]):format(2 + self:getTalentLevel(t) * 3)
	end,
}
