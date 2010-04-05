-- ToME - Tales of Middle-Earth
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
	name = "Summon End",
	type = {"wild-gift/other",1},
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
	name = "Taunt",
	type = {"technique/other",1},
	points = 1,
	cooldown = 5,
	action = function(self, t)
		local tg = {type="ball", range=0, radius=3 + self:getTalentLevelRaw(t), friendlyfire=false, talent=t}
		self:project(tg, self.x, self.y, function(tx, ty)
			local a = game.level.map(tx, ty, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				a:setTarget(self)
			end
		end)
		return true
	end,
	info = function(self, t)
		return ([[Forces hostile foes to attack you.]])
	end,
}

newTalent{ short_name="SPIDER_WEB",
	name = "Web",
	type = {"wild-gift/other",1},
	points = 5,
	equilibrium = 5,
	cooldown = 3,
	range=10,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if target and target:checkHit(self:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 7) then
				target:setEffect(target.EFF_PINNED, 3 + self:getTalentLevel(t), {})
			end
		end)
		return true
	end,
	info = function(self, t)
		return ([[Spread a web and throw it toward your target. If caught it wont be able to move for %d turns.]]):format(3 + self:getTalentLevel(t))
	end,
}

newTalent{ short_name="HEAL_OTHER",
	name = "Heal Other",
	type = {"wild-gift/other",1},
	points = 5,
	equilibrium = 5,
	cooldown = 4,
	range=14,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if target then
				target:heal(15 + self:getMag(40) * self:getTalentLevel(t))
			end
		end)
		return true
	end,
	info = function(self, t)
		return ([[Heal your target for %d life.]]):format(15 + self:getMag(40) * self:getTalentLevel(t))
	end,
}

newTalent{ short_name="REGENERATE_OTHER",
	name = "Regenerate Other",
	type = {"wild-gift/other",1},
	points = 5,
	equilibrium = 5,
	cooldown = 10,
	range=14,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if target then
				target:setEffect(target.EFF_REGENERATION, 10, {power=(15 + self:getMag(40) * self:getTalentLevel(t)) / 10})
			end
		end)
		return true
	end,
	info = function(self, t)
		return ([[Regenerate your target for %d life over 10 turns.]]):format(15 + self:getMag(40) * self:getTalentLevel(t))
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
		if checkMaxSummon(self) then return end
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
			type = "animal", subtype = "turle",
			display = "R", color=colors.GREEN,
			name = "turtle", faction = self.faction,
			desc = [[]],
			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, },
			stats = { con=15 + self:getWil() * self:getTalentLevel(t) / 5 + self:getTalentLevelRaw(self.T_RESILIENCE)*2, wil=18, dex=10 + self:getTalentLevel(t) * 2, },
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = 100,
			life_rating = 14,

			combat_armor = 10, combat_def = 0,
			combat = { dam=1, atk=1, },

			resolvers.talents{
				[self.T_TAUNT]=self:getTalentLevelRaw(t),
			},

			summoner = self, summoner_gain_exp=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
			ai_target = {actor=target}
		}

		m:resolve() m:resolve(nil, true)
		m:forceLevelup(self.level)
		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "summon")

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Summon a Turtle to distract your foes. Turtles are resilient but not very powerful. However they will periodicaly force any foes to attack them.
		It will get %d constitution and %d dexterity.]]):format(15 + self:getWil() * self:getTalentLevel(t) / 5, 10 + self:getTalentLevel(t) * 2)
	end,
}

newTalent{
	name = "Spider",
	type = {"wild-gift/summon-utility", 2},
	require = gifts_req2,
	points = 5,
	message = "@Source@ summons a Spider!",
	equilibrium = 5,
	cooldown = 10,
	range = 20,
	action = function(self, t)
		if checkMaxSummon(self) then return end
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
			type = "animal", subtype = "spider",
			display = "S", color=colors.LIGHT_DARK,
			name = "giant spider", faction = self.faction,
			desc = [[]],
			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, },
			stats = { str=15 + self:getWil() * self:getTalentLevel(t) / 5, wil=18, dex=10 + self:getTalentLevel(t) * 2, con=10 + self:getTalentLevelRaw(self.T_RESILIENCE)*2 },
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = 50,
			life_rating = 10,

			combat_armor = 0, combat_def = 0,
			combat = { dam=10, atk=16, },

			resolvers.talents{
				[self.T_SPIDER_WEB]=self:getTalentLevelRaw(t),
				[self.T_BITE_POISON]=self:getTalentLevelRaw(t),
			},

			summoner = self, summoner_gain_exp=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
			ai_target = {actor=target}
		}

		m:resolve() m:resolve(nil, true)
		m:forceLevelup(self.level)
		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "summon")

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Summon a Spider to harass your foes. Spiders can poison your foes and throw webs to pin them to the ground.
		It will get %d strength and %d dexterity.]]):format(15 + self:getWil() * self:getTalentLevel(t) / 5, 10 + self:getTalentLevel(t) * 2)
	end,
}

newTalent{
	name = "Benevolent Spirit",
	type = {"wild-gift/summon-utility", 3},
	require = gifts_req3,
	points = 5,
	message = "@Source@ summons a Benevolent Spirit!",
	equilibrium = 8,
	cooldown = 18,
	range = 20,
	action = function(self, t)
		if checkMaxSummon(self) then return end
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
			type = "spirit", subtype = "lesser",
			display = "G", color=colors.LIGHT_GREEN,
			name = "benevolent spirit", faction = self.faction,
			desc = [[]],
			autolevel = "none",
			ai = "summoned", ai_real = "dumb_heal_simple", ai_state = { talent_in=1, },
			stats = { mag=15 + self:getWil() * self:getTalentLevel(t) / 5,  wil=10 + self:getTalentLevel(t) * 2, con=10 + self:getTalentLevelRaw(self.T_RESILIENCE)*2 },
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(5,10),
			life_rating = 8,

			combat_armor = 0, combat_def = 0,
			combat = { dam=1, atk=1, },

			resolvers.talents{
				[self.T_HEAL_OTHER]=self:getTalentLevelRaw(t),
				[self.T_REGENERATE_OTHER]=self:getTalentLevelRaw(t),
			},

			summoner = self, summoner_gain_exp=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5 + self:getTalentLevelRaw(self.T_RESILIENCE),
			ai_target = {actor=target}
		}

		m:resolve() m:resolve(nil, true)
		m:forceLevelup(self.level)
		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "summon")

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Summon a Benevolent Spirit to heal your allies and yourself.
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

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Take direct control of one of your summons.
		When taking control your summon gets its life time increase by %d turns.]]):format(2 + self:getTalentLevel(t) * 3)
	end,
}
