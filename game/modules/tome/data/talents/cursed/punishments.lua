-- ToME - Tales of Middle-Earth
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
	name = "Reproach",
	type = {"cursed/punishments", 1},
	require = cursed_cun_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 5,
	hate =  5,
	range = 2,
	tactical = { ATTACKAREA = { MIND = 2 } },
	getDamage = function(self, t)
		return self:combatTalentMindDamage(t, 0, 280)
	end,
	getSpreadFactor = function(self, t)
		return 0.80
	end,
	action = function(self, t)
		local targets = {}
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
		for x, yy in pairs(grids) do
			for y, _ in pairs(grids[x]) do
				local target = game.level.map(x, y, Map.ACTOR)
				if target and self:reactionToward(target) < 0 then
					targets[#targets + 1] = target
				end
			end
		end

		if #targets == 0 then return false end

		local damage = self:mindCrit(t.getDamage(self, t))
		if #targets > 1 then
			local spreadFactor = t.getSpreadFactor(self, t)
			damage = damage * math.pow(spreadFactor, #targets - 1)
		end
		for i, t in ipairs(targets) do
			self:project({type="hit", x=t.x,y=t.y}, t.x, t.y, DamageType.MIND, { dam=damage, crossTierChance=25 })
			game.level.map:particleEmitter(t.x, t.y, 1, "reproach", { dx = self.x - t.x, dy = self.y - t.y })
		end

		game:playSoundNear(self, "talents/fire")

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local spreadFactor = t.getSpreadFactor(self, t)
		return ([[You unleash your hateful mind on any who dare approach you, inflicing %d mind damage. The attack will hit multiple targets, but each additional target will further reduce damage by %d%%.
		25%% chance of cross tier effects. The damage increases with your Mindpower.]]):format(damDesc(self, DamageType.MIND, damage), (1 - spreadFactor) * 100)
	end,
}

newTalent{
	name = "Hateful Whisper",
	type = {"cursed/punishments", 2},
	require = cursed_cun_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	hate =  12,
	range = 5,
	tactical = { ATTACK = { MIND = 2 } },
	direct_hit = true,
	requires_target = true,
	getDuration = function(self, t)
		return 4
	end,
	getDamage = function(self, t)
		return self:combatTalentMindDamage(t, 0, 300)
	end,
	getJumpRange = function(self, t)
		return math.min(6, math.sqrt(self:getTalentLevel(t) * 2))
	end,
	getJumpCount = function(self, t)
		return math.min(3, self:getTalentLevelRaw(t))
	end,
	getJumpChance = function(self, t)
		return math.min(40, 15 * math.sqrt(self:getTalentLevel(t)))
	end,
	getJumpDuration = function(self, t)
		return 30
	end,
	getHateGain = function(self, t)
		return 2
	end,
	action = function(self, t)
		local range = self:getTalentRange(t)
		local tg = {type="hit", range=range}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target or core.fov.distance(self.x, self.y, x, y) > range or target:hasEffect(target.EFF_HATEFUL_WHISPER) then return nil end

		local duration = t.getDuration(self, t)
		local damage = self:mindCrit(t.getDamage(self, t))
		local mindpower = self:combatMindpower()
		local jumpRange = t.getJumpRange(self, t)
		local jumpCount = t.getJumpCount(self, t)
		local jumpChance = t.getJumpChance(self, t)
		local jumpDuration = t.getJumpDuration(self, t)
		local hateGain = t.getHateGain(self, t)
		target:setEffect(target.EFF_HATEFUL_WHISPER, duration, {
			source = self,
			damage = damage,
			duration = duration,
			mindpower = mindpower,
			jumpRange = jumpRange,
			jumpCount = jumpCount,
			jumpChance = jumpChance,
			jumpDuration = jumpDuration,
			hateGain = hateGain
		})
		game.level.map:particleEmitter(target.x, target.y, 1, "reproach", { dx = self.x - target.x, dy = self.y - target.y })

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local jumpRange = t.getJumpRange(self, t)
		local jumpCount = t.getJumpCount(self, t)
		local jumpChance = t.getJumpChance(self, t)
		local hateGain = t.getHateGain(self, t)
		return ([[Send a whisper filled with hate to spread throughout your foes. When first heard they will suffer %d mind damage and feed you %d hate. For the first %d turns the whisper will travel from the original victim to a new one within a range of %0.1f. Every victim of the whisper has a %d%% chance of spreading it to another victim every turn.
		25%% chance of cross tier effects. The damage increases with your Mindpower.]]):format(damDesc(self, DamageType.MIND, damage), hateGain, jumpCount, jumpRange, jumpChance)
	end,
}

--[[
newTalent{
	name = "Cursed Ground",
	type = {"cursed/punishments", 2},
	require = cursed_cun_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	hate =  5,
	getDamage = function(self, t)
		return combatTalentDamage(self, t, 20, 200)
	end,
	getMindpower = function(self, t)
		return combatPower(self, t)
	end,
	getDuration = function(self, t)
		return 8 + math.floor(self:getTalentLevel(t) * 2)
	end,
	getStunDuration = function(self, t)
		return 2 + math.floor(self:getTalentLevel(t) / 2)
	end,
	getMaxTriggerCount = function(self, t)
		return 3
	end,
	action = function(self, t)
		--local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, friendly_fire=true, talent=t}
		--local x, y, target = self:getTarget(tg)
		--if not x or not y then return nil end
		--local _ _, x, y = self:canProject(tg, x, y)
		local x, y  = self.x, self.y

		local damage = t.getDamage(self, t)
		local mindpower = t.getMindpower(self, t)
		local duration = t.getDuration(self, t)
		local stunDuration = t.getStunDuration(self, t)
		local maxTriggerCount = t.getMaxTriggerCount(self, t)

		local existingTrap = game.level.map:checkAllEntities(x, y, "cursedGround")
		if existingTrap then
			existingTrap.triggerCount = 0
			existingTrap.maxTriggerCount = maxTriggerCount
			existingTrap.duration = duration
			existingTrap.damage = damage
			game.logPlayer(self, "You renew the cursed mark.")
			return true
		end

		local Trap = require "mod.class.Trap"
		local tr = Trap.new{
			type = "elemental",
			id_by_type=true,
			unided_name = "trap",
			name = "cursed ground",
			color={48,48,132},
			display = '^',
			faction = self.faction,
			x = x, y = y,
			disarmable = false,
			summoner = self,
			summoner_gain_exp = true,
			damage = damage,
			mindpower = mindpower,
			duration = duration,
			stunDuration = stunDuration,
			triggerCount = 0,
			maxTriggerCount = maxTriggerCount,
			canAct = false,
			energy = {value=0},
			canTrigger = function(self, x, y, who)
				if who:reactionToward(self.summoner) < 0 then return mod.class.Trap.canTrigger(self, x, y, who) end
				return false
			end,
			triggered = function(self, x, y, who)
				local damage = damage * (self.maxTriggerCount - self.triggerCount) / self.maxTriggerCount
				self.summoner:project({type="ball", x=x,y=y, radius=0}, x, y, engine.DamageType.MIND, { dam=damage, mindpower=mindpower })
				game.level.map:particleEmitter(x, y, 1, "cursed_ground", {})
				self.triggerCount = self.triggerCount + 1

				if self.stunDuration > self.triggerCount and not who.dead and who:checkHit(self.mindpower, who:combatMentalResist(), 0, 95, 5) and who:canBe("stun") then
					who:setEffect(who.EFF_STUNNED, self.stunDuration - self.triggerCount, {})
				else
					game.logSeen(who, "%s resists the stun!", who.name:capitalize())
				end

				return true, self.triggerCount >= self.maxTriggerCount
			end,
			act = function(self)
				self:useEnergy()
				self.duration = self.duration - 1
				if self.duration <= 0 then
					if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
					game.level:removeEntity(self)
				end
			end,
		}
		tr.cursedGround = tr
		tr:identify(true)

		tr:resolve()
		tr:resolve(nil, true)
		tr:setKnown(self, true)
		game.level:addEntity(tr)
		game.zone:addEntity(game.level, tr, "trap", x, y)
		--game.level.map:particleEmitter(x, y, 1, "summon")

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local mindpower = t.getMindpower(self, t)
		local duration = t.getDuration(self, t)
		local stunDuration = t.getStunDuration(self, t)
		return ([You mark the ground at your feet with a terrible curse. Anyone passing the mark suffers %d mind damage and has a chance to be stunned for %d turns. The mark lasts for %d turns but the will weaken each time it is triggered. (%d mindpower vs mental resistance)
		The damage and mindpower will increase with the Willpower stat.]):format(damDesc(self, DamageType.MIND, damage), stunDuration, duration, mindpower)
	end,
}
]]

newTalent{
	name = "Agony",
	type = {"cursed/punishments", 3},
	require = cursed_cun_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 3,
	hate =  5,
	range = 7,
	tactical = { ATTACK = { MIND = 2 } },
	direct_hit = true,
	requires_target = true,
	getDuration = function(self, t)
		return 5
	end,
	getDamage = function(self, t)
		return self:combatTalentMindDamage(t, 0, 160)
	end,
	action = function(self, t)
		local range = self:getTalentRange(t)
		local tg = {type="hit", range=range}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target or core.fov.distance(self.x, self.y, x, y) > range then return nil end

		local damage = self:mindCrit(t.getDamage(self, t))
		local mindpower = self:combatMindpower()
		local duration = t.getDuration(self, t)
		target:setEffect(target.EFF_AGONY, duration, {
			source = self,
			mindpower = mindpower,
			damage = damage,
			duration = duration,
		})

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local maxDamage = t.getDamage(self, t)
		local minDamage = maxDamage / duration
		return ([[Unleash agony upon your target. The pain will grow over the course of %d turns. The first turn will inflict %d damage and slowly increase to %d on the last turn (%d total).
		25%% chance of cross tier effects. The damage will increase with your Mindpower.]]):format(duration, damDesc(self, DamageType.MIND, minDamage), damDesc(self, DamageType.MIND, maxDamage), maxDamage * (duration + 1) / 2)
	end,
}

newTalent{
	name = "Madness",
	type = {"cursed/punishments", 4},
	mode = "passive",
	require = cursed_cun_req4,
	points = 5,
	getChance = function(self, t)
		return math.sqrt(self:getTalentLevel(t)) * 8
	end,
	getMindResistChange = function(self, t)
		return -math.min(5, self:getTalentLevelRaw(t)) * 10
	end,
	doMadness = function(target, t, src)
		local chance = t.getChance(src, t)
		if target and src and target:reactionToward(src) < 0 and src:checkHit(src:combatMindpower(), target:combatMentalResist(), 0, chance, 5) then
			local mindResistChange = t.getMindResistChange(src, t)
			local effect = rng.range(1, 3)
			if effect == 1 then
				-- confusion
				if target:canBe("confusion") and not target:hasEffect(target.EFF_MADNESS_CONFUSED) then
					target:setEffect(target.EFF_MADNESS_CONFUSED, 3, {power=70, mindResistChange=mindResistChange})
					hit = true
				end
			elseif effect == 2 then
				-- stun
				if target:canBe("stun") and not target:hasEffect(target.EFF_MADNESS_STUNNED) then
					target:setEffect(target.EFF_MADNESS_STUNNED, 3, {mindResistChange=mindResistChange})
					hit = true
				end
			elseif effect == 3 then
				-- slow
				if target:canBe("slow") and not target:hasEffect(target.EFF_MADNESS_SLOW) then
					target:setEffect(target.EFF_MADNESS_SLOW, 3, {power=0.3, mindResistChange=mindResistChange})
					hit = true
				end
			end
		end
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		local mindResistChange = t.getMindResistChange(self, t)
		return ([[Every time you inflict mental damage there is a %d%% chance that your foe must save against your Mindpower or go mad. Madness can cause them to become confused, slowed or stunned for 3 turns and lowers resistance to mental damage by %d%%.]]):format(chance, -mindResistChange)
	end,
}

--[[
newTalent{
	name = "Tortured Sanity",
	type = {"cursed/punishments", 4},
	require = cursed_cun_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 30,
	hate =  20,
	range = function(self, t)
		return 3 + math.floor(self:getTalentLevel(t))
	end,
	getMindpower = function(self, t)
		return combatPower(self, t)
	end,
	getDuration = function(self, t)
		return 4
	end,
	getChance = function(self, t)
		return math.min(100, 55 + self:getTalentLevel(t) * 6)
	end,
	action = function(self, t)
		local tg = {type="ball", x=self.x, y=self.y, radius=self:getTalentRange(t)}
		local mindpower = t.getMindpower(self, t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)

		local grids = self:project(tg, self.x, self.y,
			function(x, y, target, self)
				local target = game.level.map(x, y, Map.ACTOR)
				if target and self:reactionToward(target) < 0 then
					if target:canBe("stun") and rng.percent(chance) then
						if target:checkHit(mindpower, target:combatMentalResist(), 0, 95, 5) then
							target:setEffect(target.EFF_DAZED, duration, {src=self})
							game.level.map:particleEmitter(x, y, 1, "cursed_ground", {})
						else
							game.logSeen(self, "%s holds on to its sanity.", self.name:capitalize())
						end
					end
				end
			end,
			nil, nil)

		return true
	end,
	info = function(self, t)
		local mindpower = t.getMindpower(self, t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		return ([Your will reaches into the minds of all nearby enemies and tortures their sanity. Anyone within range who fails a mental save has a %d%% chance of being dazed for %d turns (%d mindpower vs mental resistance).
		The mindpower will increase with the Willpower stat.]):format(chance, duration, mindpower)
	end,
}
]]
