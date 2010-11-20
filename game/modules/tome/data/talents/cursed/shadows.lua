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

newTalent{ short_name = "SHADOW_PHASE_DOOR",
	name = "Phase Door",
	type = {"spell/other",1},
	points = 5,
	range = 20,
	action = function(self, t)
		local x, y, range
		if self.ai_state.shadow_wall then
			x, y, range = self.summoner.x, self.summoner.y, 1
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

newTalent{ short_name = "SHADOW_BLINDSIDE",
	name = "Blindside",
	type = {"spell/other", 1},
	points = 5,
	random_ego = "attack",
	range = 20,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > self:getTalentRange(t) then return nil end

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

local function createShadow(self, level, duration, target)
	return require("mod.class.NPC").new{
		type = "undead", subtype = "shadow",
		name = "shadow",
		desc = [[]],
		display = 'b', color=colors.BLACK,
		faction = self.faction,
		level_range = {level, level},
		exp_worth=0,
		autolevel = "none",
		max_life = resolvers.rngavg(5,10), life_rating = 2,
		infravision = 20,
		rank = 2,
		size_category = 2,
		energy = { mod=1 },
		blind_immune = 1,
		see_invisible = 30,
		undead = 1,
		combat_armor = 0, combat_def = 3 + level * 0.1,
		combat = { dam=resolvers.rngavg(1 * level, 4 + level), atk=10 + 1.5 * level, apr=10, dammod={dex=0.3, mag=0.3} },
		summoner = self,
		summoner_gain_exp=true,
		summon_time = duration,
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
			phasedoor_chance = 5
		},
		ai_target = {
			actor=target,
			x = nil,
			y = nil
		},
		stats = {
			str=10 + math.floor(level * 0.2),
			dex=15 + math.floor(level * 0.8),
			mag=15 + math.floor(level * 0.5),
			wil=10 + math.floor(level * 0.4),
			cun=10 + math.floor(level * 0.2),
			con=5,
		},
		resolvers.talents{
			[self.T_SHADOW_PHASE_DOOR]=math.max(5, math.floor(1 + level * 0.1)),
			[self.T_SHADOW_BLINDSIDE]=math.max(5, math.floor(1 + level * 0.1)),
		},
		feed = function(self, t)
			self.ai_state.feed_temp1 = self:addTemporaryValue("combat_atk", t.getCombatAtk(self.summoner, t))
			self.ai_state.feed_temp2 = self:addTemporaryValue("inc_damage", {all=t.getIncDamage(self.summoner, t)})
			self.ai_state.blindside_chance = t.getBlindsideChance(self.summoner, t)
		end,
		unfeed = function(self, t)
			if self.ai_state.feed_temp1 then self:removeTemporaryValue("combat_atk", self.ai_state.feed_temp1) end
			self.ai_state.feed_temp1 = nil
			if self.ai_state.feed_temp2 then self:removeTemporaryValue("inc_damage", self.ai_state.feed_temp2) end
			self.ai_state.feed_temp2 = nil
			self.ai_state.blindside_chance = 15
		end,
		shadowWall = function(self, t, duration)
			self.ai_state.shadow_wall = true
			self.ai_state.shadow_wall_time = duration
		end,
	}
end

newTalent{
	name = "Call Shadows",
	type = {"cursed/shadows", 1},
	mode = "sustained",
	require = cursed_mag_req1,
	points = 5,
	cooldown = 10,
	tactical = {
		DEFEND = 10,
	},
	getLevel = function(self, t)
		return math.max(1, self.level - 2 + self:getMag(4))
	end,
	getMaxShadows = function(self, t)
		return math.max(1, math.floor(self:getTalentLevel(t) * 0.55))
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
		self.shadows.remainingCooldown = 25
			
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
		if self.hate < 1 then
			-- not enough hate..just wait for another try
			game.logPlayer(self, "You hate is too low to call another shadow!", deflectDamage)
		end
		self:incHate(-1)

		level = t.getLevel(self, t)
		local shadow = createShadow(self, level, 100, nil)
		
		-- feed the shadow
		if self:isTalentActive(T_FEED_SHADOWS) then
			local t = self:getTalentFromId(T_FEED_SHADOWS)
			shadow:feed(t)
		end

		shadow:resolve()
		shadow:resolve(nil, true)
		shadow:forceLevelup(level)
		game.zone:addEntity(game.level, shadow, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "teleport_in")

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local maxShadows = t.getMaxShadows(self, t)
		local level = t.getLevel(self, t)
		return ([[Calls up to %d level %d shadow(s) to aid you in your battles. Each shadow costs 1 hate to summon.
		The level of the shadows will increase with the Magic stat.]]):format(maxShadows, level)
	end,
}

newTalent{
	name = "Focus Shadows",
	type = {"cursed/shadows", 2},
	require = cursed_mag_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	hate = 1,
	range = 10,
	requires_target = true,
	getDuration = function(self, t)
		return self:getTalentLevel(t)
	end,
	getBlindsideChance = function(self, t)
		return 15 + self:getTalentLevel(t) * 12
	end,
	action = function(self, t)
		local target = { type="hit", range=self:getTalentRange(t) }
		local x, y, target = self:getTarget(target)
		if not x or not y or not target then return nil end

		local duration = t.getDuration(self, t)
		local blindsideChance = t.getBlindsideChance(self, t)
		local shadowCount = 0
		for _, e in pairs(game.level.entities) do
			if e.summoner and e.summoner == self and e.subtype == "shadow" then
				-- reset target and set to focus
				e.ai_target.x = nil
				e.ai_target.y = nil
				e.ai_target.actor = target
				e.ai_target.focus_on_target = true
				e.ai_target.turns_on_target = duration
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
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local blindsideChance = t.getBlindsideChance(self, t)
		return ([[Focus your shadows on a single target for %d turns. There is a %d%% chance they will blindside the target.]]):format(duration, blindsideChance)
	end,
}

newTalent{
	name = "Feed Shadows",
	type = {"cursed/shadows", 3},
	mode = "sustained",
	require = cursed_mag_req3,
	points = 5,
	cooldown = 10,
	getBlindsideChance = function(self, t)
		return 15 + self:getTalentLevel(t) * 5
	end,
	getIncDamage = function(self, t)
		return 20 + self:getTalentLevel(t) * 7
	end,
	getCombatAtk = function(self, t)
		return 20 + self:getTalentLevel(t) * 5
	end,
	activate = function(self, t)
		for _, e in pairs(game.level.entities) do
			if e.summoner and e.summoner == self and e.subtype == "shadow" then
				e:feed(t)
			end
		end
		
		local regenId = self:addTemporaryValue("hate_regen", -0.035)
	
		return { regenId = regenId }
	end,
	deactivate = function(self, t, p)
		for _, e in pairs(game.level.entities) do
			if e.summoner and e.summoner == self and e.subtype == "shadow" then
				e:unfeed(t)
			end
		end
		
		self:removeTemporaryValue("hate_regen", p.regenId)
	
		return true
	end,
	info = function(self, t)
		local combatAtk = t.getCombatAtk(self, t)
		local incDamage = t.getIncDamage(self, t)
		local blindsideChance = t.getBlindsideChance(self, t)
		return ([[Feed your hate to your shadows increasing their attack by %d%%, damage by %d%% and chance of using blindside to %d%%. While active your hate loss will increase.]]):format(combatAtk, incDamage, blindsideChance)
	end,
}

newTalent{
	name = "Shadow Wall",
	type = {"cursed/shadows", 4},
	require = cursed_mag_req4,
	points = 5,
	cooldown = 10,
	hate = 1,
	getDuration = function(self, t)
		return 2 + self:getTalentLevel(t) * 2
	end,
	action = function(self, t)
		
		local duration = t.getDuration(self, t)
		local shadowCount = 0
		for _, e in pairs(game.level.entities) do
			if e.summoner and e.summoner == self and e.subtype == "shadow" then
				e:shadowWall(t, duration)
				
				shadowCount = shadowCount + 1
			end
		end
		
		if shadowCount > 0 then
			game.logPlayer(self, "#PINK#The shadows form around %s!", self.name)
			return true
		else
			game.logPlayer(self, "Their are no shadows to heed the call!")
			return false
		end
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[Summon your shadows to your side to form a wall against danger. Your shadows will stay beside you for %d turns and attack anyone nearby.]]):format(duration)
	end,
}
