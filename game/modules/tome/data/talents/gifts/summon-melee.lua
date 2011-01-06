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

newTalent{
	name = "War Hound",
	type = {"wild-gift/summon-melee", 1},
	require = gifts_req1,
	points = 5,
	random_ego = "attack",
	message = "@Source@ summons a War Hound!",
	equilibrium = 3,
	cooldown = 15,
	range = 20,
	requires_target = true,
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
			type = "animal", subtype = "canine",
			display = "C", color=colors.LIGHT_DARK,
			name = "war hound", faction = self.faction,
			desc = [[]],
			autolevel = "warrior",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=5, },
			stats = { str=10 + self:getWil() * self:getTalentLevel(t) / 5, dex=10 + self:getTalentLevel(t) * 2, mag=5, con=15 + self:getTalentLevelRaw(self.T_RESILIENCE)*2 },
			level_range = {self.level, self.level}, exp_worth = 0,
			energy = { mod=1.2 },

			max_life = resolvers.rngavg(25,50),
			life_rating = 6,
			infravision = 20,

			combat_armor = 2, combat_def = 4,
			combat = { dam=self:getTalentLevel(t) * 10 + rng.avg(12,25), atk=10, apr=10, dammod={str=0.8} },

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
		return ([[Summon a War Hound for %d turns to attack your foes. War hounds are good basic melee attackers.
		It will get %d strength, %d dexterity, 5 magic and %d constitution.
		Strength stat will increase with your Willpower stat.]])
		:format(math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
		10 + self:getWil() * self:getTalentLevel(t) / 5,
		10 + self:getTalentLevel(t) * 2,
		15 + self:getTalentLevelRaw(self.T_RESILIENCE)*2)
	end,
}

newTalent{
	name = "Jelly",
	type = {"wild-gift/summon-melee", 2},
	require = gifts_req2,
	points = 5,
	random_ego = "attack",
	message = "@Source@ summons a Jelly!",
	equilibrium = 5,
	cooldown = 10,
	range = 20,
	requires_target = true,
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
			type = "immovable", subtype = "jelly",
			display = "j", color=colors.BLACK,
			desc = "A strange blob on the dungeon floor.",
			name = "black jelly",
			autolevel = "none", faction=self.faction,
			stats = { con=10 + self:getWil() * self:getTalentLevel(t) / 5 + self:getTalentLevelRaw(self.T_RESILIENCE) * 3, str=10 + self:getTalentLevel(t) * 2 },
			resists = { [DamageType.LIGHT] = -50 },
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=5, },
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(25,50),
			life_rating = 15,
			infravision = 20,

			combat_armor = 1, combat_def = 1,
			never_move = 1,

			inc_damage = table.clone(self.inc_damage, true),

			combat = { dam=8, atk=15, apr=5, damtype=DamageType.ACID, dammod={str=0.7} },

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
			ai_target = {actor=target}
		}

		setupSummon(self, m, x, y)

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Summon a Jelly for %d turns to attack your foes. Jellies do not move, but are great to block a passage.
		It will get %d constitution and %d strength.
		Constitution stat will increase with your Willpower stat.]])
		:format(math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
		10 + self:getWil() * self:getTalentLevel(t) / 5 + self:getTalentLevelRaw(self.T_RESILIENCE) * 3,
		10 + self:getTalentLevel(t) * 2)
       end,
}

newTalent{
	name = "Minotaur",
	type = {"wild-gift/summon-melee", 3},
	require = gifts_req3,
	points = 5,
	random_ego = "attack",
	message = "@Source@ summons a Minotaur!",
	equilibrium = 10,
	cooldown = 15,
	range = 20,
	requires_target = true,
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
			type = "giant", subtype = "minotaur",
			display = "H",
			name = "minotaur", color=colors.UMBER,

			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

			max_stamina = 100,
			life_rating = 13,
			max_life = resolvers.rngavg(50,80),
			infravision = 20,

			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2, },
			energy = { mod=1.2 },
			stats = { str=25 + self:getWil() * self:getTalentLevel(t) / 5, dex=18, con=10 + self:getTalentLevel(t) * 2 + self:getTalentLevelRaw(self.T_RESILIENCE)*2, },

			desc = [[It is a cross between a human and a bull.]],
			resolvers.equip{ {type="weapon", subtype="battleaxe", auto_req=true}, },
			level_range = {self.level, self.level}, exp_worth = 0,

			combat_armor = 13, combat_def = 8,
			resolvers.talents{ [Talents.T_WARSHOUT]=3, [Talents.T_STUNNING_BLOW]=3, [Talents.T_SUNDER_ARMOUR]=2, [Talents.T_SUNDER_ARMS]=2, },

			inc_damage = table.clone(self.inc_damage, true),

			faction = self.faction,
			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = self:getTalentLevel(t) + 2 + self:getTalentLevelRaw(self.T_RESILIENCE),
			ai_target = {actor=target}
		}

		setupSummon(self, m, x, y)

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Summon a Minotaur for %d turns to attack your foes. Minotaurs cannot stay summoned for long, but they deal a lot of damage.
		It will get %d strength, %d constitution and 18 dexterity.
		Strength stat will increase with your Willpower stat.]])
		:format(self:getTalentLevel(t) + 2 + self:getTalentLevelRaw(self.T_RESILIENCE),
		25 + self:getWil() * self:getTalentLevel(t) / 5,
		10 + self:getTalentLevel(t) * 2 + self:getTalentLevelRaw(self.T_RESILIENCE)*2)
	end,
}

newTalent{
	name = "Stone Golem",
	type = {"wild-gift/summon-melee", 4},
	require = gifts_req4,
	points = 5,
	random_ego = "attack",
	message = "@Source@ summons an Stone Golem!",
	equilibrium = 15,
	cooldown = 20,
	range = 20,
	requires_target = true,
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
			type = "golem", subtype = "stone",
			display = "g",
			name = "stone golem", color=colors.WHITE,

			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

			max_stamina = 800,
			life_rating = 13,
			max_life = resolvers.rngavg(50,80),
			infravision = 20,

			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2, },
			stats = { str=25 + self:getWil() * self:getTalentLevel(t) / 5, dex=18, con=10 + self:getTalentLevel(t) * 2 + self:getTalentLevelRaw(self.T_RESILIENCE)*2, },

			desc = [[It is a massive animated statue.]],
			level_range = {self.level, self.level}, exp_worth = 0,

			combat_armor = 25, combat_def = -20,
			combat = { dam=resolvers.rngavg(25,50), atk=20, apr=5, dammod={str=0.9} },
			resolvers.talents{ [Talents.T_UNSTOPPABLE]=3, [Talents.T_STUN]=3, },

			inc_damage = table.clone(self.inc_damage, true),

			poison_immune=1, cut_immune=1, fear_immune=1, blind_immune=1,

			faction = self.faction,
			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
			ai_target = {actor=target}
		}

		setupSummon(self, m, x, y)

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Summon a Stone Golem for %d turns to attack your foes. Stone golems are formidable foes that can become unstoppable foes.
		It will get %d strength, %d constitution and 18 dexterity.
		Strength stat will increase with your Willpower stat.]])
		:format(math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
		25 + self:getWil() * self:getTalentLevel(t) / 5,
		10 + self:getTalentLevel(t) * 2 + self:getTalentLevelRaw(self.T_RESILIENCE)*2)
	end,
}
