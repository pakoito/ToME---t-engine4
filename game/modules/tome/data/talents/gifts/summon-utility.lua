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

newTalent{
	name = "Taunt",
	type = {"technique/other",1},
	points = 1,
	cooldown = 5,
	requires_target = false,
	tactical = { PROTECT = 2 },
	range = 0,
	radius = function(self, t) return 3 + self:getTalentLevelRaw(t) end,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
		self:project(tg, self.x, self.y, function(tx, ty)
			local a = game.level.map(tx, ty, Map.ACTOR)
			if a then
				a:setTarget(self)
			end
		end)
		return true
	end,
	info = function(self, t)
		return ([[Forces all hostile foes in radius %d to attack you.]]):format(self:getTalentRadius(t))
	end,
}


newTalent{
	name = "Shell Shield",
	type = {"technique/other",1},
	points = 5,
	cooldown = 10,
	tactical = { DEFEND = 2 },
	action = function(self, t)
		local dur = math.ceil(4 + self:getTalentLevel(t) * 0.7)
		local power = 34 + (math.min(6.3, self:getTalentLevel(t)) * 7)
		self:setEffect(self.EFF_SHELL_SHIELD, dur, {power=power})
		return true
	end,
	info = function(self, t)
		return ([[Under the cover of your shell you take %d%% less damage for %d turns]]):format(34 + (math.min(6.3, self:getTalentLevel(t)) * 7), math.ceil(4 + self:getTalentLevel(t) * 0.7))
	end,
}

newTalent{ short_name="SPIDER_WEB",
	name = "Web",
	type = {"wild-gift/other",1},
	points = 5,
	equilibrium = 5,
	cooldown = 3,
	range=7,
	tactical = { DISABLE = { pin = 2 } },
	requires_target = true,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if target and target:canBe("pin") then
				target:setEffect(target.EFF_PINNED, 3 + self:getTalentLevel(t), {apply_power=self:combatPhysicalpower()})
			end
		end)
		return true
	end,
	info = function(self, t)
		return ([[Spread a web and throw it toward your target. If caught, it won't be able to move for %d turns.]]):format(3 + self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Turtle",
	type = {"wild-gift/summon-utility", 1},
	require = gifts_req1,
	random_ego = "attack",
	points = 5,
	message = "@Source@ summons a Turtle!",
	equilibrium = 2,
	cooldown = 10,
	range = 10,
	is_summon = true,
	requires_target = true,
	tactical = { DEFEND = 2, PROTECT = 2 },
	on_pre_use = function(self, t, silent)
		if not self:canBe("summon") and not silent then game.logPlayer(self, "You can not summon, you are suppressed!") return end
		return not checkMaxSummon(self, silent)
	end,
	on_detonate = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target or self:reactionToward(target) < 0 then return end
			target:setEffect(target.EFF_SHELL_SHIELD, 4, {power=self:mindCrit(self:combatTalentMindDamage(t, 10, 35))})
		end, nil, {type="flame"})
	end,
	on_arrival = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target or self:reactionToward(target) < 0 then return end
			target:attr("allow_on_heal", 1)
			target:heal(30 + self:combatTalentMindDamage(t, 10, 350))
			target:attr("allow_on_heal", -1)
		end, nil, {type="acid"})
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
			type = "animal", subtype = "turtle",
			display = "R", color=colors.GREEN, image = "npc/summoner_turtle.png",
			name = "turtle", faction = self.faction,
			desc = [[]],
			autolevel = "none",
			ai = "summoned", ai_real = "tactical", ai_state = { talent_in=1, ally_compassion=10},
			ai_tactic = resolvers.tactic"default",
			stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
			inc_stats = {
				con=15 + (self:mindCrit(self:combatMindpower(2.1)) * self:getTalentLevel(t) / 5) + self:getTalentLevelRaw(self.T_RESILIENCE)*2,
				wil=18,
				dex=10 + self:getTalentLevel(t) * 2,
			},
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = 100,
			life_rating = 14,
			infravision = 10,

			combat_armor = 10, combat_def = 0,
			combat = { dam=1, atk=1, },

			wild_gift_detonate = t.id,

			resolvers.talents{
				[self.T_TAUNT]=self:getTalentLevelRaw(t),
				[self.T_SHELL_SHIELD]=self:getTalentLevelRaw(t),
			},

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
			ai_target = {actor=target}
		}
		if self:attr("wild_summon") and rng.percent(self:attr("wild_summon")) then
			m.name = m.name.." (wild summon)"
			m[#m+1] = resolvers.talents{ [self.T_BATTLE_CALL]=self:getTalentLevelRaw(t) }
		end
		if self:knowTalent(self.T_BLIGHTED_SUMMONING) then m:learnTalent(m.T_CURSE_OF_IMPOTENCE, true, 3) end

		setupSummon(self, m, x, y)

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Summon a Turtle for %d turns to distract your foes. Turtles are resilient, but not very powerful. However, they will periodically force any foes to attack them and can protect themselves with their shell.
		It will get %d constitution, %d dexterity and 18 willpower.
		Your summons inherit some of your stats: increased damage%%, stun/pin/confusion/blindness resistance, armour penetration.
		Constitution stat will increase with your Mindpower stat.]])
		:format(math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
		15 + (self:combatMindpower(2.1) * self:getTalentLevel(t) / 5) + self:getTalentLevelRaw(self.T_RESILIENCE)*2,
		10 + self:getTalentLevel(t) * 2)
	end,
}

newTalent{
	name = "Spider",
	type = {"wild-gift/summon-utility", 2},
	require = gifts_req2,
	points = 5,
	random_ego = "attack",
	message = "@Source@ summons a Spider!",
	equilibrium = 5,
	cooldown = 10,
	range = 10,
	is_summon = true,
	tactical = { ATTACK = 1, DISABLE = { pin = 2 } },
	on_pre_use = function(self, t, silent)
		if not self:canBe("summon") and not silent then game.logPlayer(self, "You can not summon, you are suppressed!") return end
		return not checkMaxSummon(self, silent)
	end,
	requires_target = true,
	on_detonate = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target or self:reactionToward(target) >= 0 then return end
			if target:canBe("pin") then
				target:setEffect(target.EFF_PINNED, 3, {apply_power=self:mindCrit(self:combatMindpower())})
			end
		end, nil, {type="flame"})
	end,
	on_arrival = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, DamageType.FEARKNOCKBACK, {dist=1+self:getTalentLevelRaw(t), x=m.x, y=m.y}, {type="acid"})
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
			type = "animal", subtype = "spider",
			display = "S", color=colors.LIGHT_DARK, image = "npc/spiderkin_spider_giant_spider.png",
			name = "giant spider", faction = self.faction,
			desc = [[]],
			autolevel = "none",
			ai = "summoned", ai_real = "tactical", ai_state = { talent_in=1, ally_compassion=10},
			ai_tactic = resolvers.tactic"ranged",
			stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
			inc_stats = {
				dex=15 + (self:mindCrit(self:combatMindpower(2)) * self:getTalentLevel(t) / 5),
				wil=18,
				str=10 + self:getTalentLevel(t) * 2,
				con=10 + self:getTalentLevelRaw(self.T_RESILIENCE)*2
			},
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = 50,
			life_rating = 10,
			infravision = 10,

			combat_armor = 0, combat_def = 0,
			combat = { dam=resolvers.rngavg(20,25), atk=16, apr=9, damtype=DamageType.NATURE, dammod={dex=1.2} },

			wild_gift_detonate = t.id,

			resolvers.talents{
				[self.T_SPIDER_WEB]=self:getTalentLevelRaw(t),
				[self.T_SPIT_POISON]=self:getTalentLevelRaw(t),
			},

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
			ai_target = {actor=target}
		}
		if self:attr("wild_summon") and rng.percent(self:attr("wild_summon")) then
			m.name = m.name.." (wild summon)"
			m[#m+1] = resolvers.inscription("INFUSION:_INSIDIOUS_POISON", {cooldown=12, range=6, heal_factor=0.6, power=self:getTalentLevel(t) * 60})
		end
		if self:knowTalent(self.T_BLIGHTED_SUMMONING) then m:learnTalent(m.T_CORROSIVE_WORM, true, 3) end

		setupSummon(self, m, x, y)

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Summon a Spider for %d turns to harass your foes. Spiders can poison your foes and throw webs to pin them to the ground.
		It will get %d dexterity, %d strength, 18 willpower and %d constitution.
		Your summons inherit some of your stats: increased damage%%, stun/pin/confusion/blindness resistance, armour penetration.
		Dexterity stat will increase with your Mindpower stat.]])
		:format(math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
		15 + (self:combatMindpower(2) * self:getTalentLevel(t) / 5),
		10 + self:getTalentLevel(t) * 2,
		10 + self:getTalentLevelRaw(self.T_RESILIENCE)*2)
	end,
}

newTalent{
	name = "Frantic Summoning",
	type = {"wild-gift/summon-utility", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 5,
	cooldown = 25,
	requires_target = true,
	no_energy = true,
	tactical = { BUFF = 0.2 },
	getReduc = function(self, t) return self:getTalentLevelRaw(t) * 15 end,
	getDuration = function(self, t) return 2 + math.floor(self:getTalentLevel(t) / 1.4) end,
	action = function(self, t)
		self:setEffect(self.EFF_FRANTIC_SUMMONING, t.getDuration(self, t), {power=t.getReduc(self, t)})
		return true
	end,
	info = function(self, t)
		local reduc = t.getReduc(self, t)
		return ([[You focus yourself on nature, allowing you to summon creatures much faster (%d%% of a normal summon time) and with no chance to fail from high equilibrium for %d turns.
		When activating this power a random summoning talent will come off cooldown.
		Each time you summon the duration of the frantic summoning effect will reduce by 1.]]):
		format(100 - reduc, t.getDuration(self, t))
	end,
}

newTalent{
	name = "Summon Control",
	type = {"wild-gift/summon-utility", 4},
	require = gifts_req4,
	mode = "passive",
	points = 5,
	info = function(self, t)
		return ([[Allows you to take direct control of any of your summons.
		The summons will appear on the interface, a simple click on them will let you switch control.
		You can also press control+tab to switch.
		When taking control, your summon has its lifetime increased by %d turns and takes %d%% less damage.
		The damage reduction is based on your Cunning.]]):format(2 + self:getTalentLevel(t) * 3, self:getCun(7, true) * self:getTalentLevelRaw(t))
	end,
}
