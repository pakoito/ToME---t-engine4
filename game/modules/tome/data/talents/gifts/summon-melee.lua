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
	name = "War Hound",
	type = {"wild-gift/summon-melee", 1},
	require = gifts_req1,
	points = 5,
	random_ego = "attack",
	message = "@Source@ summons a War Hound!",
	equilibrium = 3,
	cooldown = 15,
	range = 10,
	requires_target = true,
	is_summon = true,
	tactical = { ATTACK = { PHYSICAL = 2 } },
	on_pre_use = function(self, t, silent)
		if not self:canBe("summon") and not silent then game.logPlayer(self, "You can not summon, you are suppressed!") return end
		return not checkMaxSummon(self, silent)
	end,
	on_detonate = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, DamageType.PHYSICAL, self:mindCrit(self:combatTalentMindDamage(t, 30, 250)), {type="flame"})
	end,
	on_arrival = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, DamageType.TEMP_EFFECT, {foes=true, eff=self.EFF_LOWER_PHYSICAL_RESIST, dur=4+self:getTalentLevelRaw(t), p={power=self:combatTalentMindDamage(t, 15, 70)}}, {type="flame"})
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
			type = "animal", subtype = "canine",
			display = "C", color=colors.LIGHT_DARK, image = "npc/summoner_wardog.png",
			name = "war hound", faction = self.faction,
			desc = [[]],
			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=5, },
			stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
			inc_stats = {
				str=15 + (self:mindCrit(self:combatMindpower(2)) * self:getTalentLevel(t) / 5) + (self:getTalentLevel(t) * 2),
				dex=15 + (self:mindCrit(self:combatMindpower(2)) * self:getTalentLevel(t) / 5) + (self:getTalentLevel(t) * 2),
				con=15 + self:getTalentLevelRaw(self.T_RESILIENCE)*2
			},
			level_range = {self.level, self.level}, exp_worth = 0,
			global_speed_base = 1.2,

			max_life = resolvers.rngavg(25,50),
			life_rating = 6,
			infravision = 10,

			combat_armor = 2, combat_def = 4,
			combat = { dam=self:getTalentLevel(t) * 10 + rng.avg(12,25), atk=10, apr=10, dammod={str=0.8} },

			wild_gift_detonate = t.id,

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
			ai_target = {actor=target}
		}
		if self:attr("wild_summon") and rng.percent(self:attr("wild_summon")) then
			m.name = m.name.." (wild summon)"
			m[#m+1] = resolvers.talents{ [self.T_TOTAL_THUGGERY]=self:getTalentLevelRaw(t) }
		end
		if self:knowTalent(self.T_BLIGHTED_SUMMONING) then m:learnTalent(m.T_CURSE_OF_DEFENSELESSNESS, true, 3) end

		setupSummon(self, m, x, y)

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Summon a War Hound for %d turns to attack your foes. War hounds are good basic melee attackers.
		It will get %d strength, %d dexterity and %d constitution.
		Your summons inherit some of your stats: increased damage%%, stun/pin/confusion/blindness resistance, armour penetration.
		Strength stat will increase with your Mindpower stat.]])
		:format(math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
		15 + (self:combatMindpower(2) * self:getTalentLevel(t) / 5) + (self:getTalentLevel(t) * 2),
		15 + (self:combatMindpower(2) * self:getTalentLevel(t) / 5) + (self:getTalentLevel(t) * 2),
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
	equilibrium = 2,
	cooldown = 10,
	range = 10,
	requires_target = true,
	is_summon = true,
	tactical = { ATTACK = { NATURE = 1 }, EQUILIBRIUM = 1, },
	on_pre_use = function(self, t, silent)
		if not self:canBe("summon") and not silent then game.logPlayer(self, "You can not summon, you are suppressed!") return end
		return not checkMaxSummon(self, silent)
	end,
	on_detonate = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, DamageType.SLIME, self:mindCrit(self:combatTalentMindDamage(t, 30, 200)), {type="flame"})
	end,
	on_arrival = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, DamageType.TEMP_EFFECT, {foes=true, eff=self.EFF_LOWER_NATURE_RESIST, dur=4+self:getTalentLevelRaw(t), p={power=self:combatTalentMindDamage(t, 15, 70)}}, {type="flame"})
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
			type = "immovable", subtype = "jelly", image = "npc/jelly-darkgrey.png",
			display = "j", color=colors.BLACK,
			desc = "A strange blob on the dungeon floor.",
			name = "black jelly",
			autolevel = "none", faction=self.faction,
			stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
			inc_stats = {
				con=10 + (self:mindCrit(self:combatMindpower(1.8)) * self:getTalentLevel(t) / 5) + self:getTalentLevelRaw(self.T_RESILIENCE) * 3,
				str=10 + self:getTalentLevel(t) * 2
			},
			resists = { [DamageType.LIGHT] = -50 },
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=5, },
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(25,50),
			life_rating = 15,
			infravision = 10,

			combat_armor = 1, combat_def = 1,
			never_move = 1,

			combat = { dam=8, atk=15, apr=5, damtype=DamageType.ACID, dammod={str=0.7} },

			wild_gift_detonate = t.id,

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
			ai_target = {actor=target},

			on_takehit = function(self, value, src)
				local p = value * 0.10
				if self.summoner and not self.summoner.dead then
					self.summoner:incEquilibrium(-p)
					game.logSeen(self, "#GREEN#%s absorbs part of the blow. %s is closer to nature.", self.name:capitalize(), self.summoner.name:capitalize())
				end
				return value - p
			end,
		}
		if self:attr("wild_summon") and rng.percent(self:attr("wild_summon")) then
			m.name = m.name.." (wild summon)"
			m[#m+1] = resolvers.talents{ [self.T_SWALLOW]=self:getTalentLevelRaw(t) }
		end
		if self:knowTalent(self.T_BLIGHTED_SUMMONING) then m:learnTalent(m.T_VIMSENSE, true, 3) end

		setupSummon(self, m, x, y)

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Summon a Jelly for %d turns to attack your foes. Jellies do not move, but your equilibrium will be reduced by 10%% of all damage received by the jelly.
		It will get %d constitution and %d strength.
		Your summons inherit some of your stats: increased damage%%, stun/pin/confusion/blindness resistance, armour penetration.
		Constitution stat will increase with your Mindpower stat.]])
		:format(math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
		10 + (self:combatMindpower(1.8) * self:getTalentLevel(t) / 5) + self:getTalentLevelRaw(self.T_RESILIENCE) * 3,
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
	range = 10,
	is_summon = true,
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 2 }, DISABLE = { confusion = 1, stun = 1 } },
	on_pre_use = function(self, t, silent)
		if not self:canBe("summon") and not silent then game.logPlayer(self, "You can not summon, you are suppressed!") return end
		return not checkMaxSummon(self, silent)
	end,
	on_detonate = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, DamageType.BLEED, self:mindCrit(self:combatTalentMindDamage(t, 30, 350)), {type="flame"})
	end,
	on_arrival = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, DamageType.TEMP_EFFECT, {foes=true, eff=self.EFF_SLOW_MOVE, dur=4+self:getTalentLevelRaw(t), p={power=0.1+self:combatTalentMindDamage(t, 5, 500)/1000}}, {type="flame"})
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
			type = "giant", subtype = "minotaur",
			display = "H",
			name = "minotaur", color=colors.UMBER, resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_minotaur_minotaur.png", display_h=2, display_y=-1}}},

			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

			max_stamina = 100,
			life_rating = 13,
			max_life = resolvers.rngavg(50,80),
			infravision = 10,

			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2, },
			global_speed_base=1.2,
			stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
			inc_stats = {
				str=25 + (self:mindCrit(self:combatMindpower(2.1)) * self:getTalentLevel(t) / 5) + (self:getTalentLevel(t) * 2),
				dex=10 + (self:mindCrit(self:combatMindpower(1.8)) * self:getTalentLevel(t) / 5) + (self:getTalentLevel(t) * 2),
				con=10 + self:getTalentLevel(t) * 2 + self:getTalentLevelRaw(self.T_RESILIENCE)*2,
			},

			desc = [[It is a cross between a human and a bull.]],
			resolvers.equip{ {type="weapon", subtype="battleaxe", auto_req=true}, },
			level_range = {self.level, self.level}, exp_worth = 0,

			combat_armor = 13, combat_def = 8,
			resolvers.talents{ [Talents.T_WARSHOUT]=3, [Talents.T_STUNNING_BLOW]=3, [Talents.T_SUNDER_ARMOUR]=2, [Talents.T_SUNDER_ARMS]=2, },

			wild_gift_detonate = t.id,

			faction = self.faction,
			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = self:getTalentLevel(t) + 2 + self:getTalentLevelRaw(self.T_RESILIENCE),
			ai_target = {actor=target}
		}
		if self:attr("wild_summon") and rng.percent(self:attr("wild_summon")) then
			m.name = m.name.." (wild summon)"
			m[#m+1] = resolvers.talents{ [self.T_RUSH]=self:getTalentLevelRaw(t) }
		end
		if self:knowTalent(self.T_BLIGHTED_SUMMONING) then m:learnTalent(m.T_LIFE_TAP, true, 3) end

		setupSummon(self, m, x, y)

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Summon a Minotaur for %d turns to attack your foes. Minotaurs cannot stay summoned for long, but they deal a lot of damage.
		It will get %d strength, %d constitution and %d dexterity.
		Your summons inherit some of your stats: increased damage%%, stun/pin/confusion/blindness resistance, armour penetration.
		Strength stat will increase with your Mindpower stat.]])
		:format(self:getTalentLevel(t) + 2 + self:getTalentLevelRaw(self.T_RESILIENCE),
		25 + (self:combatMindpower(2.1) * self:getTalentLevel(t) / 5) + (self:getTalentLevel(t) * 2),
		10 + self:getTalentLevel(t) * 2 + self:getTalentLevelRaw(self.T_RESILIENCE)*2,
		10 + (self:combatMindpower(1.8) * self:getTalentLevel(t) / 5) + (self:getTalentLevel(t) * 2))
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
	range = 10,
	is_summon = true,
	tactical = { ATTACK = { PHYSICAL = 3 }, DISABLE = { knockback = 1 } },
	on_pre_use = function(self, t, silent)
		if not self:canBe("summon") and not silent then game.logPlayer(self, "You can not summon, you are suppressed!") return end
		return not checkMaxSummon(self, silent)
	end,
	on_detonate = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, DamageType.PHYSKNOCKBACK, {dam=self:mindCrit(self:combatTalentMindDamage(t, 30, 150)), dist=4}, {type="flame"})
	end,
	on_arrival = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, DamageType.TEMP_EFFECT, {foes=true, eff=self.EFF_DAZED, check_immune="stun", dur=1+self:getTalentLevelRaw(t)/2, p={}}, {type="flame"})
	end,
	requires_target = true,
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
			type = "golem", subtype = "stone",
			display = "g",
			name = "stone golem", color=colors.WHITE, image = "npc/summoner_golem.png",

			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

			max_stamina = 800,
			life_rating = 13,
			max_life = resolvers.rngavg(50,80),
			infravision = 10,

			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2, },
			stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
			inc_stats = {
				str=15 + (self:mindCrit(self:combatMindpower(2)) * self:getTalentLevel(t) / 5) + (self:getTalentLevel(t) * 2),
				dex=15 + (self:mindCrit(self:combatMindpower(1.9)) * self:getTalentLevel(t) / 5) + (self:getTalentLevel(t) * 2),
				con=10 + self:getTalentLevel(t) * 2 + self:getTalentLevelRaw(self.T_RESILIENCE)*2,
			},

			desc = [[It is a massive animated statue.]],
			level_range = {self.level, self.level}, exp_worth = 0,

			combat_armor = 25, combat_def = -20,
			combat = { dam=25 + self:getWil(), atk=20, apr=5, dammod={str=0.9} },
			resolvers.talents{ [Talents.T_UNSTOPPABLE]=3, [Talents.T_STUN]=3, },

			poison_immune=1, cut_immune=1, fear_immune=1, blind_immune=1,

			wild_gift_detonate = t.id,

			faction = self.faction,
			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
			ai_target = {actor=target},
			resolvers.sustains_at_birth(),
		}
		if self:attr("wild_summon") and rng.percent(self:attr("wild_summon")) then
			m.name = m.name.." (wild summon)"
			m[#m+1] = resolvers.talents{ [self.T_SHATTERING_IMPACT]=self:getTalentLevelRaw(t) }
		end
		if self:knowTalent(self.T_BLIGHTED_SUMMONING) then m:learnTalent(m.T_BONE_SPEAR, true, 3) end

		setupSummon(self, m, x, y)

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Summon a Stone Golem for %d turns to attack your foes. Stone golems are formidable foes that can become unstoppable foes.
		It will get %d strength, %d constitution and %d dexterity.
		Your summons inherit some of your stats: increased damage%%, stun/pin/confusion/blindness resistance, armour penetration.
		Strength stat will increase with your Mindpower stat.]])
		:format(math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
		15 + (self:combatMindpower(2) * self:getTalentLevel(t) / 5) + (self:getTalentLevel(t) * 2),
		10 + self:getTalentLevel(t) * 2 + self:getTalentLevelRaw(self.T_RESILIENCE)*2,
		15 + (self:combatMindpower(1.9) * self:getTalentLevel(t) / 5) + (self:getTalentLevel(t) * 2))
	end,
}
