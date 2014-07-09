-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

-- TODO
-- Singularity (major))
-- Lost in Space (major)

local Object = require "engine.Object"
local Trap = require "mod.class.Trap"

-- All anomaly damage functions come from here with a bit of randomness thrown in to mix it up
getAnomalyDamage = function(self)
	local dam = self:combatScale(getParadoxSpellpower(self), 20, 10, 220, 100, 0.75)
	return rng.avg(dam / 3, dam, 3)
end

getAnomalyDamageAoE = function(self)
	local dam = self:combatScale(getParadoxSpellpower(self), 10, 10, 50, 100, 0.75)
	return rng.avg(dam / 3, dam, 3)
end

-- Here we have Effect Power and Anomaly duration, similar to damage but less random
getAnomalyEffectPower = function(self)
	local dam = self:combatScale(getParadoxSpellpower(self), 10, 10, 50, 100, 0.75)
	return math.ceil(rng.avg(dam / 2, dam, 3))
end

getAnomalyDuration = function(self)
	local dam = self:combatScale(getParadoxSpellpower(self), 4, 10, 12, 100, 0.75)
	return math.ceil(rng.avg(dam / 2, dam, 3))
end

-- Determines the anomaly range based on current spellpower
-- Generally we just use range = 10 for anomalies, this is for stuff with much longer range (such as teleports)
getAnomalyRange = function(self)
	local range = math.floor(self:combatLimit(getParadoxSpellpower(self), 80, 20, 20, 40, 100))
	return range
end

-- Determines the anomaly radius based on current spellpower
getAnomalyRadius = function(self)
	local radius = math.floor(self:combatLimit(getParadoxSpellpower(self),8, 2, 20, 6, 100))
	return radius
end

-- Gets targets
-- @type: an entity type
-- @range: the area to search for targets in, generally uses talent radius or range
-- @no_self: don't target the caster
getAnomalyTargets = function(self, t, x, y, type, range, no_self)
	local tgts = {}
	local grids = core.fov.circle_grids(x, y, range, true)
	for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
		local target_type = Map.ACTOR
		if type == "PROJECTILE" then target_type = Map.PROJECTILE end
		if type == "TERRAIN" then target_type = Map.TERRAIN end
		local a = game.level.map(x, y, target_type)
		if a and not (no_self and a == self) then
			tgts[#tgts+1] = a
		end
	end end
	return tgts
end

-- Randomly find a start location for projectiles, wormholes, etc.
getAnomalyPosition = function(self, range)
	local x, y = self.x, self.y
	local poss = {}
	for i = x - range, x + range do
		for j = y - range, y + range do
			if game.level.map:isBound(i, j) and
				core.fov.distance(x, y, i, j) <= range and
				core.fov.distance(x, y, i, j) >= range/2 and
				self:canMove(i, j) and not game.level.map(i, j, engine.Map.TRAP) then
				poss[#poss+1] = {i,j}
			end
		end
	end
	if #poss == 0 then return x, y  end
	local pos = poss[rng.range(1, #poss)]
	x, y = pos[1], pos[2]
	return x, y
end

-- Allows the caster to target the anomaly
-- For this to work all anomalies have to have no_energy set to true in the talent table, otherwise it will use two turns
checkAnomalyTargeting = function(self, t, tg)
	local x, y = self.x, self.y
	if self:knowTalent(self.T_PULL_SKEIN) and rng.percent(self:callTalent(self.T_PULL_SKEIN, "getTargetChance")) then
		x, y = self:getTarget(tg)
		-- If the player cancels target them anyway
		if not x or not y then
			x, y = self.x, self.y
		end
	end
	local _ _, _, _, x, y = self:canProject(tg, x, y)
	return x, y
end

-- Check for effects when hit by an anomaly
-- This is called before immunity is checked
checkAnomalyTriggers = function(self, target)
	if target:knowTalent(target.T_WEBS_OF_FATE) then
		target:forceUseTalent(target.T_WEBS_OF_FATE, {ignore_cd=true, ignore_energy=true, ignore_ressources=true})
	end
	if target:knowTalent(target.T_SEAL_FATE) then
		target:forceUseTalent(target.T_SEAL_FATE, {ignore_cd=true, ignore_energy=true, ignore_ressources=true})
	end
	if target.summoner and target.summoner:knowTalent(target.summoner.T_TEMPORAL_VIGOUR) then
		local t = target.summoner:getTalentFromId(target.summoner.T_TEMPORAL_VIGOUR)
		t.doAnomaly(target.summoner, target, t)
	end
end

-- Teleportation 
newTalent{
	name = "Anomaly Rearrange",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "teleport",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true, 
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ causes a spacetime hiccup.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		local tgts = getAnomalyTargets(self, t, x, y, "ACTOR", self:getTalentRadius(t))

		-- Randomly take targets
		for i = 1, rng.avg(1, 5, 3) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			checkAnomalyTriggers(self, a)
			
			if a:canBe("teleport") and a:canBe("anomaly") then
				game.level.map:particleEmitter(a.x, a.y, 1, "temporal_teleport")
				a:teleportRandom(a.x, a.y, 10, 1)
				game.level.map:particleEmitter(a.x, a.y, 1, "temporal_teleport")
			end
		end
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Teleports up to five targets in a radius of %d up to ten tiles away.]]):format(radius)
	end,
}

newTalent{
	name = "Anomaly Teleport",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "teleport",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = function(self, t) return getAnomalyRange(self) end,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true, 
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=10, radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ shifts reality.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		local tgts = getAnomalyTargets(self, t, x, y, "ACTOR", self:getTalentRadius(t))

		-- Randomly take targets
		for i = 1, rng.avg(1, 5, 3) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			checkAnomalyTriggers(self, a)
			
			if a:canBe("teleport") and a:canBe("anomaly") then
				game.level.map:particleEmitter(a.x, a.y, 1, "temporal_teleport")
				a:teleportRandom(a.x, a.y, self:getTalentRange(t), self:getTalentRange(t)/2)
				game.level.map:particleEmitter(a.x, a.y, 1, "temporal_teleport")
			end
		end
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local radius = self:getTalentRadius(t)
		return ([[Teleports up to five targets in a radius of %d up to %d tiles away.]]):format(radius, range)
	end,
}

newTalent{
	name = "Anomaly Swap",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "teleport",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true, 
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ swaps places with a nearby target.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		local tgts = getAnomalyTargets(self, t, x, y, "ACTOR", self:getTalentRadius(t), true)

		-- Randomly take targets
		if #tgts <= 0 then return nil end
		local a, id = rng.table(tgts)
		table.remove(tgts, id)
		checkAnomalyTriggers(self, a)
		checkAnomalyTriggers(self, self)
		
		if a:canBe("teleport") and a:canBe("anomaly") and self:canBe("teleport") and self:canBe("anomaly") then
			-- first remove the target so the destination tile is empty
			game.level.map:remove(a.x, a.y, Map.ACTOR)
			local px, py 
			px, py = self.x, self.y
			if self:teleportRandom(a.x, a.y, 0) then
				-- return the target at the casters old location
				game.level.map(px, py, Map.ACTOR, a)
				self.x, self.y, a.x, a.y = a.x, a.y, px, py
				game.level.map:particleEmitter(a.x, a.y, 1, "temporal_teleport")
				game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
			else
				-- return the target without effect
				game.level.map(a.x, a.y, Map.ACTOR, a)
				game.logSeen(self, "The spell fizzles!")
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[You swap locations with a random target.]]):format()
	end,
}

newTalent{
	name = "Anomaly Displacement Shield",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "teleport",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true, 
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ transfers damage to a nearby target.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		local tgts = getAnomalyTargets(self, t, x, y, "ACTOR", self:getTalentRadius(t), true)

		-- Randomly take targets
		if #tgts <= 0 then return nil end
		local a, id = rng.table(tgts)
		table.remove(tgts, id)
		checkAnomalyTriggers(self, a)
		checkAnomalyTriggers(self, self)
		
		if a:canBe("anomaly") then
			self:setEffect(self.EFF_DISPLACEMENT_SHIELD, getAnomalyDuration(self)*2, {power=getAnomalyDamage(self)*4, target=a, chance=50})
		end
		
		game.level.map:particleEmitter(a.x, a.y, 1, "temporal_teleport")
		game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")

		return true
	end,
	info = function(self, t)
		return ([[50%% chance that damage the caster takes will be warped to a set target.
		Once the maximum damage (%d) is absorbed, the time runs out, or the target dies, the shield will crumble.]]):format(getAnomalyDamage(self)*2)
	end,
}

newTalent{
	name = "Anomaly Wormhole",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "teleport",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	direct_hit = true,
	no_energy = true, 
	requires_target = true,
	target = function(self, t)
		return {type="bolt", nowarning=true, range=10, nolock=true, simple_dir_request=true, talent=t}
	end,
	message = "@Source@ folds the space between two points.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		if (x == self.x and y == self.y) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move")then
			x, y = getAnomalyPosition(self, self:getTalentRange(t))
		end
		local start_x, start_y = getAnomalyPosition(self, 1)
		if not x and not y and not start_x and not start_y then return false end
		
		-- Adding the entrance wormhole
		local entrance = mod.class.Trap.new{
			name = "wormhole",
			type = "annoy", subtype="teleport", id_by_type=true, unided_name = "trap",
			image = "terrain/wormhole.png",
			display = '&', color_r=255, color_g=255, color_b=255, back_color=colors.STEEL_BLUE,
			message = "@Target@ moves onto the wormhole.",
			temporary = getAnomalyDuration(self),
			x = start_x, y = start_y,
			canAct = false,
			energy = {value=0},
			disarm = function(self, x, y, who) return false end,
			summoned_by = self, -- "summoner" is immune to it's own traps
			triggered = function(self, x, y, who)
				if who == self.summoned_by or who:canBe("teleport") then
					-- since we're using a precise teleport we'll look for a free grid first
					local tx, ty = util.findFreeGrid(self.dest.x, self.dest.y, 5, true, {[engine.Map.ACTOR]=true})
					if tx and ty then
						if not who:teleportRandom(tx, ty, 0) then
							game.logSeen(who, "%s tries to enter the wormhole but a violent force pushes it back.", who.name:capitalize())
						end
					end
				else
					game.logSeen(who, "%s ignores the wormhole.", who.name:capitalize())
				end
				return true
			end,
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.logSeen(self, "Reality asserts itself and forces the wormhole shut.")
					if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
					game.level:removeEntity(self)
				end
			end,
		}
		entrance.faction = nil
		game.level:addEntity(entrance)
		entrance:identify(true)
		entrance:setKnown(self, true)
		game.zone:addEntity(game.level, entrance, "trap", start_x, start_y)
		game.level.map:particleEmitter(start_x, start_y, 1, "temporal_teleport")
		game:playSoundNear(self, "talents/heal")

		-- Adding the exit wormhole
		local exit = entrance:clone()
		exit.x = x
		exit.y = y
		game.level:addEntity(exit)
		exit:identify(true)
		exit:setKnown(self, true)
		game.zone:addEntity(game.level, exit, "trap", x, y)
		game.level.map:particleEmitter(x, y, 1, "temporal_teleport")

		-- Linking the wormholes
		entrance.dest = exit
		exit.dest = entrance

		return true
	end,
	info = function(self, t)
		return ([[Creates a wormhole nearby and a second wormhole up to ten tiles away.]]):format()
	end,
}

newTalent{
	name = "Anomaly Probability Travel",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "teleport",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true, 
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ places several targets out of phase.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		local tgts = getAnomalyTargets(self, t, x, y, "ACTOR", self:getTalentRadius(t))

		for i = 1, rng.avg(1, 5, 3) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			checkAnomalyTriggers(self, a)

			a:setEffect(a.EFF_PROBABILITY_TRAVEL, getAnomalyDuration(self)*2, {power=getAnomalyDuration(self)})
			game.level.map:particleEmitter(a.x, a.y, 1, "temporal_teleport")

			game:playSoundNear(self, "talents/spell_generic")
		end
		
		return true
	end,
	info = function(self, t)
		return ([[Allows up to five targets in a radius of %d to travel up to %d tiles through walls.]]):
		format(getAnomalyDuration(self)*2, getAnomalyDuration(self))
	end,
}

newTalent{
	name = "Anomaly Blink",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "teleport",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true, 
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ makes several targets blink uncontrollably.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		local tgts = getAnomalyTargets(self, t, x, y, "ACTOR", self:getTalentRadius(t))

		for i = 1, rng.avg(1, 5, 3) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			checkAnomalyTriggers(self, a)

			a:setEffect(a.EFF_BLINK, getAnomalyDuration(self)*2, {power=getAnomalyDuration(self)})
			game.level.map:particleEmitter(a.x, a.y, 1, "temporal_teleport")

			game:playSoundNear(self, "talents/spell_generic")
		end
		
		return true
	end,
	info = function(self, t)
		return ([[Up to five targets in a radius of %d are teleporting %d tiles every turn.]]):
		format(self:getTalentRadius(t), getAnomalyDuration(self))
	end,
}

newTalent{
	name = "Anomaly Summon Townsfolk",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "teleport",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	requires_target = true,
	no_energy = true, 
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getSummonTime = function(self, t) return math.ceil(getAnomalyDuration(self)*2) end,
	message = "Some innocent bystanders have been teleported into the fight.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		
		-- Randomly pick a race
		local race = rng.range(1, 4)
		-- Find space
		for i = 1, 4 do
			local x, y = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "Not enough space to summon!")
				return
			end

			local NPC = require "mod.class.NPC"
			local m = NPC.new{
				type = "humanoid", display = "p",
				color=colors.WHITE,

				combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

				body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
				lite = 3,

				life_rating = 10,
				rank = 2,
				size_category = 3,

				open_door = true,

				autolevel = "warrior",
				stats = { str=12, dex=8, mag=6, con=10 },
				ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2, },
				level_range = {1, 3},

				max_life = resolvers.rngavg(30,40),
				combat_armor = 2, combat_def = 0,

			--	summoner = self,
				summoner_gain_exp=false,
				summon_time = t.getSummonTime(self, t),
			}

			m.level = 1

			if race == 1 then
				m.name = "human farmer"
				m.subtype = "human"
				m.image = "npc/humanoid_human_human_farmer.png"
				m.desc = [[A weather-worn Human farmer, looking at a loss as to what's going on.]]
				m.faction = "allied-kingdoms"
				m.resolvers.inscriptions(1, "infusion")
			elseif race == 2 then
				m.name = "halfling gardener"
				m.subtype = "halfling"
				m.desc = [[A rugged Halfling gardener, looking quite confused as to what he's doing here.]]
				m.faction = "allied-kingdoms"
				m.image = "npc/humanoid_halfling_halfling_gardener.png"
				m.resolvers.inscriptions(1, "infusion")
			elseif race == 3 then
				m.name = "shalore scribe"
				m.subtype = "shalore"
				m.desc = [[A scrawny Elven scribe, looking bewildered at his surroundings.]]
				m.faction = "shalore"
				m.image = "npc/humanoid_shalore_shalore_rune_master.png"
				m.resolvers.inscriptions(1, "rune")
			elseif race == 4 then
				m.name = "dwarven lumberjack"
				m.subtype = "dwarf"
				m.desc = [[A brawny Dwarven lumberjack, looking a bit upset at his current situation.]]
				m.faction = "iron-throne"
				m.image = "npc/humanoid_dwarf_lumberjack.png"
				m.resolvers.inscriptions(1, "rune")
			end

			m:resolve() m:resolve(nil, true)
			m:forceLevelup(self.level)
			game.zone:addEntity(game.level, m, "actor", x, y)
			game.level.map:particleEmitter(x, y, 1, "summon")
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Pulls innocent people into the fight.]])
	end,
}

-- Temporal
newTalent{
	name = "Anomaly Slow",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "temporal",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true, 
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getSlow = function(self, t) return 1 - 1 / (1 + (getAnomalyEffectPower(self)) / 100) end,
	message = "@Source@ creates a bubble of slow time.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		local tgts = getAnomalyTargets(self, t, x, y, "ACTOR", self:getTalentRadius(t))

		for i = 1, rng.avg(1, 5, 3) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			checkAnomalyTriggers(self, a)
			
			if a:canBe("anomaly") then
				a:setEffect(a.EFF_SLOW, getAnomalyDuration(self), {power=t.getSlow(self, t), no_ct_effect=true})
			end
			game.level.map:particleEmitter(x, y, tg.radius, "ball_temporal", {radius=self:getTalentRadius(t), tx=x, ty=y})
			game:playSoundNear(self, "talents/spell_generic")
		end
		return true
	end,
	info = function(self, t)
		return ([[Slows up to five targets in a radius %d ball by %d%%.]]):
		format(self:getTalentRadius(t), t.getSlow(self, t)*100)
	end,
}

newTalent{
	name = "Anomaly Haste",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "temporal",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true, 
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getHaste = function(self, t) return 1 - 1 / (1 + (getAnomalyEffectPower(self)) / 100) end,
	message = "@Source@ creates a bubble of fast time.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		local tgts = getAnomalyTargets(self, t, x, y, "ACTOR", self:getTalentRadius(t))

		for i = 1, rng.avg(1, 5, 3) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			checkAnomalyTriggers(self, a)

			a:setEffect(a.EFF_SPEED, getAnomalyDuration(self), {power=t.getHaste(self, t)})
			game.level.map:particleEmitter(x, y, tg.radius, "ball_temporal", {radius=self:getTalentRadius(t), tx=x, ty=y})
			game:playSoundNear(self, "talents/spell_generic")
		end
		
		return true
	end,
	info = function(self, t)
		return ([[Increases global speed of up to five targets in a radius %d ball by %d%%.]]):
		format(self:getTalentRadius(t), t.getHaste(self, t)*100)
	end,
}

newTalent{
	name = "Anomaly Stop",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "temporal",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true, 
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ creates a bubble of nul time.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		local tgts = getAnomalyTargets(self, t, x, y, "ACTOR", self:getTalentRadius(t))

		for i = 1, rng.avg(1, 5, 3) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			checkAnomalyTriggers(self, a)

			if a:canBe("anomaly") and a:canBe("stun") then
				a:setEffect(a.EFF_STUNNED, getAnomalyDuration(self)/2, {no_ct_effect=true, apply_power=getParadoxSpellpower(self)})
			end
			game.level.map:particleEmitter(x, y, tg.radius, "ball_temporal", {radius=self:getTalentRadius(t), tx=x, ty=y})
			game:playSoundNear(self, "talents/spell_generic")
		end
		
		return true
	end,
	info = function(self, t)
		return ([[Stuns up to five targets in a radius %d ball.]]):
		format(self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Anomaly Temporal Bubble",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "temporal",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true, 
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ removes several targets from time.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		local tgts = getAnomalyTargets(self, t, x, y, "ACTOR", self:getTalentRadius(t))

		for i = 1, rng.avg(1, 5, 3) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			checkAnomalyTriggers(self, a)

			if a:canBe("anomaly") then
				a:setEffect(a.EFF_TIME_PRISON, getAnomalyDuration(self), {no_ct_effect=true})
			end
			game.level.map:particleEmitter(x, y, tg.radius, "ball_temporal", {radius=self:getTalentRadius(t), tx=x, ty=y})
			game:playSoundNear(self, "talents/spell_generic")
		end
		
		return true
	end,
	info = function(self, t)
		return ([[Time Prisons up to five targets in a radius %d ball.]]):
		format(self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Anomaly Temporal Shield",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "temporal",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true, 
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ smears several targets.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		local tgts = getAnomalyTargets(self, t, x, y, "ACTOR", self:getTalentRadius(t))

		for i = 1, rng.avg(1, 5, 3) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			checkAnomalyTriggers(self, a)

			a:setEffect(a.EFF_TIME_SHIELD, getAnomalyDuration(self), {power=getAnomalyDamage(self)*4, dot_dur=5, time_reducer=40})
			game.level.map:particleEmitter(x, y, tg.radius, "ball_temporal", {radius=self:getTalentRadius(t), tx=x, ty=y})
			game:playSoundNear(self, "talents/spell_generic")
		end
		
		return true
	end,
	info = function(self, t)
		return ([[Time Shields up to five targets in a radius of %d.]]):
		format(self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Anomaly Invigorate",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "temporal",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true, 
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ energizes several targets.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		local tgts = getAnomalyTargets(self, t, x, y, "ACTOR", self:getTalentRadius(t))

		for i = 1, rng.avg(1, 5, 3) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			checkAnomalyTriggers(self, a)

			a:setEffect(a.EFF_INVIGORATE, getAnomalyDuration(self), {power=getAnomalyEffectPower(self)/10})
			game.level.map:particleEmitter(x, y, tg.radius, "ball_temporal", {radius=self:getTalentRadius(t), tx=x, ty=y})
			game:playSoundNear(self, "talents/spell_generic")
		end
		
		return true
	end,
	info = function(self, t)
		return ([[Invigorates up to five targets in a radius of %d.]]):
		format(self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Anomaly Temporal Clone",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "temporal",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true, 
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ clones a nearby creature.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		local tgts = getAnomalyTargets(self, t, x, y, "ACTOR", self:getTalentRadius(t))

		-- Randomly take targets
		if #tgts <= 0 then return end
		local a, id = rng.table(tgts)
		table.remove(tgts, id)
		checkAnomalyTriggers(self, a)
		
		local x, y = util.findFreeGrid(a.x, a.y, 3, true, {[Map.ACTOR]=true})
		if not x then
			return
		end
		if a:attr("summon_time") then return end
		local m = makeParadoxClone(self, a, getAnomalyDuration(self)*2)
		m.ai_state = { talent_in=2, ally_compassion=10}
		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "generic_teleport", {rm=60, rM=130, gm=20, gM=110, bm=90, bM=130, am=70, aM=180})
	end,
	info = function(self, t)
		return ([[Clones a random creature within range.]]):format()
	end,
}

newTalent{
	name = "Anomaly Temporal Storm",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "temporal",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true, 
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ creates a temporal storm.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, getAnomalyDuration(self),
			DamageType.TEMPORAL, getAnomalyDamageAoE(self),
			tg.radius,
			5, nil,
			engine.MapEffect.new{alpha=85, color_br=200, color_bg=200, color_bb=0, effect_shader="shader_images/paradox_effect.png"},
			nil, false
		)
		return true
	end,
	info = function(self, t)
		return ([[Creates a temporal storm for %d turns that deals %d temporal damage each turn.]])
		:format(getAnomalyDuration(self), damDesc(self, DamageType.TEMPORAL, getAnomalyDamageAoE(self)))
	end,
}

-- Physical
newTalent{
	name = "Anomaly Gravity Pull",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "physical",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true, 
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ increases local gravity.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)

		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			local tx, ty = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
			checkAnomalyTriggers(self, target)
			
			if tx and ty and target:canBe("knockback") and target:canBe("anomaly") then
				target:move(tx, ty, true)
				game.logSeen(target, "%s is drawn in by gravity!", target.name:capitalize())
			end
		end)

		game.level.map:particleEmitter(x, y, tg.radius, "gravity_spike", {radius=self:getTalentRadius(t), grids=grids, tx=x, ty=y, allow=core.shader.allow("distort")})
		game:playSoundNear(self, "talents/earth")

		return true
	end,
	info = function(self, t)
		return ([[Increases localized gravity, pulling in targets in a radius of %d.]]):format(self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Anomaly Dig",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "physical",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true, 
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ turns matter to dust.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)

		self:project(tg, x, y, DamageType.DIG, 1)
		game.level.map:particleEmitter(x, y, tg.radius, "ball_earth", {radius=tg.radius})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[Digs out all terrain in a radius %d ball.]]):format(self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Anomaly Entomb",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "physical",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = 1,
	direct_hit = true,
	no_energy = true, 
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ creates a stone wall.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		
		for i = -1, 1 do for j = -1, 1 do if game.level.map:isBound(x + i, y + j) then
			local oe = game.level.map(x + i, y + j, Map.TERRAIN)
			if oe and not oe:attr("temporary") and not game.level.map:checkAllEntities(x + i, y + j, "block_move") and not oe.special then
				-- Ok some explanation, we make a new *OBJECT* because objects can have energy and act
				-- it stores the current terrain in "old_feat" and restores it when it expires
				-- We CAN set an object as a terrain because they are all entities

				local e = Object.new{
					old_feat = oe,
					name = "stone wall", image = "terrain/granite_wall1.png",
					display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
					desc = "a summoned wall of stone",
					type = "wall", --subtype = "floor",
					always_remember = true,
					can_pass = {pass_wall=1},
					does_block_move = true,
					show_tooltip = true,
					block_move = true,
					block_sight = true,
					temporary = getAnomalyDuration(self),
					x = x + i, y = y + j,
					canAct = false,
					act = function(self)
						self:useEnergy()
						self.temporary = self.temporary - 1
						if self.temporary <= 0 then
							game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
							game.nicer_tiles:updateAround(game.level, self.x, self.y)
							game.level:removeEntity(self)
--							game.level.map:redisplay()
						end
					end,
					dig = function(src, x, y, old)
						game.level:removeEntity(old)
--						game.level.map:redisplay()
						return nil, old.old_feat
					end,
					summoner_gain_exp = true,
					summoner = self,
				}
				e.tooltip = mod.class.Grid.tooltip
				game.level:addEntity(e)
				game.level.map(x + i, y + j, Map.TERRAIN, e)
			end
		end end end

		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		return ([[Entombs a single target in a wall of stone.]]):format()
	end,
}

newTalent{
	name = "Anomaly Entropy",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "physical",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ increases local entropy.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		local tgts = getAnomalyTargets(self, t, x, y, "ACTOR", self:getTalentRadius(t))

		-- Randomly take targets
		for i = 1, rng.avg(1, 5, 3) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			checkAnomalyTriggers(self, a)
			
			if a:canBe("anomaly") then
				self:project(tg, a.x, a.y, function(px, py)
					local target = game.level.map(px, py, engine.Map.ACTOR)
					if not target then return end

					local tids = {}
					for tid, lev in pairs(target.talents) do
						local t = target:getTalentFromId(tid)
						if not target.talents_cd[tid] and t.mode == "activated" and not t.innate then tids[#tids+1] = t end
					end
					for i = 1, rng.avg(3, 6, 3) do
						local power = getAnomalyDuration(self)
						local t = rng.tableRemove(tids)
						if not t then break end
						target.talents_cd[t.id] = rng.range(2, power)
						game.logSeen(target, "%s's %s is disrupted!", target.name:capitalize(), t.name)
					end
					target.changed = true
				end, nil)
			end
		end
		return true
	end,
	info = function(self, t)
		return ([[Places between three and six talents of up to 5 targets in a radius %d ball on cooldown for up to %d turns.]]):
		format(getAnomalyRadius(self), getAnomalyDuration(self))
	end,
}

newTalent{
	name = "Anomaly Gravity Well",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "physical",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true, 
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ increases local gravity.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		local tgts = getAnomalyTargets(self, t, x, y, "ACTOR", self:getTalentRadius(t))

		-- Randomly take targets
		for i = 1, rng.avg(1, 5, 3) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			checkAnomalyTriggers(self, a)
			
			if a:canBe("anomaly") and a:canBe("pin") then
				a:setEffect(self.EFF_PINNED, getAnomalyDuration(self), {apply_power=getParadoxSpellpower(self)})
			end
		end
		
		game.level.map:particleEmitter(x, y, tg.radius, "gravity_spike", {radius=self:getTalentRadius(t), grids=grids, tx=x, ty=y, allow=core.shader.allow("distort")})
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		return ([[Creates a gravity well in a radius %d ball, pinning up to five targets.]]):format(self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Anomaly Quake",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "physical",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ causes an earthquake.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		
		-- Don't bury the player
		if self ~= game.player and not game.player:knowTalent(game.player.T_DIG_OBJECT) then
			return
		end

		self:doQuake(tg, x, y)
		return true
	end,
	info = function(self, t)
		return ([[Causes an earthquake in a radius of %d.]]):
		format(getAnomalyRadius(self))
	end,
}

newTalent{
	name = "Anomaly Calcify",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "physical",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ calcifies several targets.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		local tgts = getAnomalyTargets(self, t, x, y, "ACTOR", self:getTalentRadius(t))

		-- Randomly take targets
		for i = 1, rng.avg(1, 5, 3) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			checkAnomalyTriggers(self, a)
			
			if a:canBe("anomaly") and a:canBe("stun") and a:canBe("stone") and a:canBe("instakill")then
				a:setEffect(a.EFF_STONED, getAnomalyDuration(self), {apply_power=getParadoxSpellpower(self)})
				game.level.map:particleEmitter(a.x, a.y, 1, "archery")
			end
		end
		return true
	end,
	info = function(self, t)
		return ([[Turns up to 5 targets in a radius %d ball to stone for %d turns.]]):
		format(getAnomalyRadius(self), getAnomalyDuration(self))
	end,
}

newTalent{
	name = "Anomaly Flawed Design",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "physical",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ crumbles the resistances of several targets.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		local tgts = getAnomalyTargets(self, t, x, y, "ACTOR", self:getTalentRadius(t))

		-- Randomly take targets
		for i = 1, rng.avg(1, 5, 3) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			checkAnomalyTriggers(self, a)

			a:setEffect(self.EFF_FLAWED_DESIGN, getAnomalyDuration(self), {power=getAnomalyEffectPower(self)})
			game.level.map:particleEmitter(a.x, a.y, 1, "temporal_teleport")
			game:playSoundNear(self, "talents/spell_generic")
		end
		return true
	end,
	info = function(self, t)
		return ([[Reduces the resistances of up to five targets in a ball of radius %d by %d%%.]]):format(self:getTalentRadius(t), getAnomalyEffectPower(self))
	end,
}

newTalent{
	name = "Anomaly Dust Storm",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "physical",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ causes a dust storm.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = checkAnomalyTargeting(self, t, tg)
		local tgts = getAnomalyTargets(self, t, x, y, "ACTOR", self:getTalentRange(t))
		
		local dam = getAnomalyRadius(self) -- not a typo, very low damage since this isn't a major anomaly

		-- Randomly take targets
		for i = 1, rng.avg(3, 6, 3) do
			if #tgts <= 0 then break end
			local target, id = rng.table(tgts)
			table.remove(tgts, id)
			local orig_x, orig_y = getAnomalyPosition(self, self:getTalentRange(t))
						
			local proj = require("mod.class.Projectile"):makeHoming(
				self,
				{particle="bolt_earth", trail="lightningtrail"},
				{speed=2, name="Dust Storm", start_x=orig_x, start_y=orig_y, dam=dam, movedam=dam},
				target,
				self:getTalentRange(t),
				function(self, src)
				--	local DT = require("engine.DamageType")
					--src:project({type="ball", radius=1, x=self.x, y=self.y}, self.x, self.y, DT.SPELLKNOCKBACK, self.def.dam)
				end,
				function(self, src, target)
					checkAnomalyTriggers(src, target)
					if target:canBe("anomaly") then
						local DT = require("engine.DamageType")
						src:project({type="ball", radius=1, x=self.x, y=self.y}, self.x, self.y, DT.SPELLKNOCKBACK, self.def.dam)
					end
				end
			)
			
			game.zone:addEntity(game.level, proj, "projectile", orig_x, orig_y)
			game:playSoundNear(self, "talents/earth")
		end
		return true
	end,
	info = function(self, t)
		return ([[Summons three to six dust storms.]]):format()
	end,
}

-- Major
newTalent{
	name = "Anomaly Blazing Fire",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "major",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ causes a fire.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tgts = getAnomalyTargets(self, t, self.x, self.y, "ACTOR", self:getTalentRange(t))
		
		local movedam = self:spellCrit(getAnomalyDamageAoE(self))

		-- Randomly take targets
		for i = 1, rng.avg(3, 6, 3) do
			if #tgts <= 0 then break end
			local target, id = rng.table(tgts)
			table.remove(tgts, id)
			local orig_x, orig_y = getAnomalyPosition(self, self:getTalentRange(t))
						
			local proj = require("mod.class.Projectile"):makeHoming(
				self,
				{particle="inferno"},
				{speed=1, name="Blazing Fire", start_x=orig_x, start_y=orig_y, dam=movedam, movedam=movedam},
				target,
				self:getTalentRange(t),
				function(self, src)
					local DT = require("engine.DamageType")
					game.level.map:addEffect(src, self.x, self.y, 4, DT.FIRE, self.def.movedam, 1, 5, nil, {type="inferno"}, nil, nil)
				end,
				function(self, src, target)
					local DT = require("engine.DamageType")
					checkAnomalyTriggers(src, target)
					game.level.map:addEffect(src, self.x, self.y, 4, DT.FIRE, self.def.movedam, 1, 5, nil, {type="inferno"}, nil, nil)
				end
			)
			
			game.zone:addEntity(game.level, proj, "projectile", orig_x, orig_y)
			game:playSoundNear(self, "talents/earth")
		end
		return true
	end,
	info = function(self, t)
		return ([[Summons three to six blazing fires.]]):format()
	end,
}

newTalent{
	name = "Anomaly Call",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "major",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 50,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	message = "@Source@ teleports several targets to @Source@'s location.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tgts = getAnomalyTargets(self, t, self.x, self.y, "ACTOR", self:getTalentRange(t), true)

		-- Randomly take targets
		for i = 1, rng.avg(3, 6, 3) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			checkAnomalyTriggers(self, a)
			
			if a:canBe("teleport") and a:canBe("anomaly") then
				game.level.map:particleEmitter(a.x, a.y, 1, "temporal_teleport")
				a:teleportRandom(self.x, self.y, self:getTalentRadius(t)*2, self:getTalentRadius(t))
				game.level.map:particleEmitter(a.x, a.y, 1, "temporal_teleport")
			end
		end
		return true
	end,
	info = function(self, t)
		return ([[Teleports between 3 and 6 targets to the caster.]]):
		format()
	end,
}

newTalent{
	name = "Anomaly Deus Ex",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "major",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	getHaste = function(self, t) return 1 - 1 / (1 + (getAnomalyEffectPower(self)) / 100) end,
	message = "The odds have tilted.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tgts = getAnomalyTargets(self, t, self.x, self.y, "ACTOR", self:getTalentRange(t))

		-- Randomly take targets
		if #tgts <= 0 then return end
		local a, id = rng.table(tgts)
		table.remove(tgts, id)
		checkAnomalyTriggers(self, a)

		a:setEffect(self.EFF_SPEED, getAnomalyDuration(self), {power=t.getHaste(self, t)})
		a:setEffect(self.EFF_REGENERATION,  getAnomalyDuration(self), {power=getAnomalyEffectPower(self)})
		a:setEffect(self.EFF_PAIN_SUPPRESSION,  getAnomalyDuration(self), {power=getAnomalyEffectPower(self)})
		game.level.map:particleEmitter(a.x, a.y, 1, "temporal_teleport")
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Substantially toughens and hastes one target for %d turns.]]):format(getAnomalyDuration(self))
	end,
}

newTalent{
	name = "Anomaly Evil Twin",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "major",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	message = "@Source@'s evil twin has come from another timeline.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)

		local x, y = util.findFreeGrid(self.x, self.y, 3, true, {[Map.ACTOR]=true})
		if not x then
			return
		end
		if self:attr("summon_time") then return end
		local m = makeParadoxClone(self, self, getAnomalyDuration(self)*2)
		game.zone:addEntity(game.level, m, "actor", x, y)
		m.faction = "enemies"
		m.summoner = nil
		m.target = self
		checkAnomalyTriggers(self, self)
		game.level.map:particleEmitter(x, y, 1, "generic_teleport", {rm=60, rM=130, gm=20, gM=110, bm=90, bM=130, am=70, aM=180})

		return true
	end,
	info = function(self, t)
		return ([[Clones the caster.]]):format(getAnomalyDuration(self))
	end,
}

newTalent{
	name = "Anomaly Intersecting Threads",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "major",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	message = "@Source@ has caused two threads to merge.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tgts = getAnomalyTargets(self, t, self.x, self.y, "ACTOR", self:getTalentRange(t))

		-- Randomly take targets
		for i = 1, #tgts do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			checkAnomalyTriggers(self, a)
			
			local x, y = util.findFreeGrid(a.x, a.y, 3, true, {[Map.ACTOR]=true})
			if not x then
				return
			end
			if a:attr("summon_time") then return end
			local m = makeParadoxClone(self, a, getAnomalyDuration(self)*2)
			game.zone:addEntity(game.level, m, "actor", x, y)
			m.ai_state = { talent_in=1, ally_compassion=10}
			game.level.map:particleEmitter(x, y, 1, "generic_teleport", {rm=60, rM=130, gm=20, gM=110, bm=90, bM=130, am=70, aM=180})
		end

		return true
	end,
	info = function(self, t)
		return ([[Clones all creatures in a radius of 10.]]):format(getAnomalyDuration(self))
	end,
}

newTalent{
	name = "Anomaly Mass Dig",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "major",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true, 
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ digs out a huge area.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		for i = 1, rng.avg(3, 6, 3) do
			local orig_x, orig_y = getAnomalyPosition(self, self:getTalentRange(t))

			self:project(tg, orig_x, orig_y, DamageType.DIG, 1)
			game.level.map:particleEmitter(orig_x, orig_y, tg.radius, "ball_earth", {radius=tg.radius})
		end
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[Digs out all terrain in between three and six radius %d balls.]]):format(self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Anomaly Sphere of Destruction",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "major",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ creates a sphere of destruction.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tgts = getAnomalyTargets(self, t, self.x, self.y, "ACTOR", self:getTalentRange(t))
		
		local movedam = self:spellCrit(getAnomalyDamage(self)) -- High damage

		-- Randomly take targets
		if #tgts <= 0 then return end
		local target, id = rng.table(tgts)
		table.remove(tgts, id)
		local orig_x, orig_y = getAnomalyPosition(self, self:getTalentRange(t))
					
		local proj = require("mod.class.Projectile"):makeHoming(
			self,
			{particle = "bolt_dark", trail = "darktrail"},
			{speed=1, name="Sphere of Destruction", start_x=orig_x, start_y=orig_y, dam=movedam, movedam=movedam},
			target,
			self:getTalentRange(t),
			function(self, src)
				local DT = require("engine.DamageType")
				DT:get(DT.TEMPORAL).projector(src, self.x, self.y, DT.TEMPORAL, self.def.movedam)
				DT:get(DT.DARKNESS).projector(src, self.x, self.y, DT.DARKNESS, self.def.movedam)
			end,
			function(self, src, target)
				checkAnomalyTriggers(src, target)
				local DT = require("engine.DamageType")
				DT:get(DT.TEMPORAL).projector(src, self.x, self.y, DT.TEMPORAL, self.def.movedam)
				DT:get(DT.DARKNESS).projector(src, self.x, self.y, DT.DARKNESS, self.def.movedam)
			end
		)
		
		game.zone:addEntity(game.level, proj, "projectile", orig_x, orig_y)
		game:playSoundNear(self, "talents/distortion")
		return true
	end,
	info = function(self, t)
		return ([[Summons a sphere of destruction.]]):format()
	end,
}

newTalent{
	name = "Anomaly Tornado",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "major",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ causes a tornado storm.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tgts = getAnomalyTargets(self, t, self.x, self.y, "ACTOR", self:getTalentRange(t))

		local movedam = self:spellCrit(getAnomalyDamageAoE(self))
		local dam = self:spellCrit(getAnomalyDamage(self)/2)

		-- Randomly take targets
		for i = 1, rng.avg(3, 6, 3) do
			if #tgts <= 0 then break end
			local target, id = rng.table(tgts)
			table.remove(tgts, id)
			local orig_x, orig_y = getAnomalyPosition(self, self:getTalentRange(t))
						
			local proj = require("mod.class.Projectile"):makeHoming(
				self,
				{particle="bolt_lightning", trail="lightningtrail"},
				{speed=2, name="Tornado", dam=dam, movedam=movedam, start_x=orig_x, start_y=orig_y},
				target,
				self:getTalentRange(t),
				function(self, src)
					local DT = require("engine.DamageType")
					DT:get(DT.LIGHTNING).projector(src, self.x, self.y, DT.LIGHTNING, self.def.movedam)
				end,
				function(self, src, target)
					checkAnomalyTriggers(src, target)
					local DT = require("engine.DamageType")
					src:project({type="ball", radius=1, x=self.x, y=self.y}, self.x, self.y, DT.LIGHTNING, self.def.dam)
					src:project({type="ball", radius=1, x=self.x, y=self.y}, self.x, self.y, DT.MINDKNOCKBACK, self.def.dam)
					if target:canBe("stun") then
						target:setEffect(target.EFF_STUNNED, 4, {apply_power=getParadoxSpellpower(src)})
					else
						game.logSeen(target, "%s resists the tornado!", target.name:capitalize())
					end

					-- Lightning ball gets a special treatment to make it look neat
					local sradius = (1 + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
					local nb_forks = 16
					local angle_diff = 360 / nb_forks
					for i = 0, nb_forks - 1 do
						local a = math.rad(rng.range(0+i*angle_diff,angle_diff+i*angle_diff))
						local tx = self.x + math.floor(math.cos(a) * 1)
						local ty = self.y + math.floor(math.sin(a) * 1)
						game.level.map:particleEmitter(self.x, self.y, 1, "lightning", {radius=1, tx=tx-self.x, ty=ty-self.y, nb_particles=25, life=8})
					end
					game:playSoundNear(self, "talents/lightning")
				end
			)
			game.zone:addEntity(game.level, proj, "projectile", orig_x, orig_y)
			game:playSoundNear(self, "talents/lightning")
		end
		return true
	end,
	info = function(self, t)
		return ([[Summons three to six tornados.]]):format()
	end,
}

newTalent{
	name = "Anomaly Meteor",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "major",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ causes a meteor to fall from the sky.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = getAnomalyPosition(self, self:getTalentRange(t))

		local terrains = t.terrains or mod.class.Grid:loadList("/data/general/grids/lava.lua")
		t.terrains = terrains -- cache

		local meteor = function(src, x, y, dam)
			game.level.map:particleEmitter(x, y, 10, "meteor", {x=x, y=y}).on_remove = function(self)
				local x, y = self.args.x, self.args.y
				game.level.map:particleEmitter(x, y, 10, "fireflash", {radius=tg.radius})
				game:playSoundNear(game.player, "talents/fireflash")

				local grids = {}
				for i = x-tg.radius, x+tg.radius do for j = y-tg.radius, y+tg.radius do
					local oe = game.level.map(i, j, engine.Map.TERRAIN)
					if oe and not oe:attr("temporary") and
					(core.fov.distance(x, y, i, j) < 1 or rng.percent(40)) and (game.level.map:checkEntity(i, j, engine.Map.TERRAIN, "dig") or game.level.map:checkEntity(i, j, engine.Map.TERRAIN, "grow")) then
						local g = terrains.LAVA_FLOOR:clone()
						g:resolve() g:resolve(nil, true)
						game.zone:addEntity(game.level, g, "terrain", i, j)
						grids[#grids+1] = {x=i,y=j,oe=oe}
					end
				end end
				for i = x-tg.radius, x+tg.radius do for j = y-tg.radius, y+tg.radius do
					game.nicer_tiles:updateAround(game.level, i, j)
				end end
				for _, spot in ipairs(grids) do
					local i, j = spot.x, spot.y
					local g = game.level.map(i, j, engine.Map.TERRAIN)
					g.temporary = 8
					g.x = i g.y = j
					g.canAct = false
					g.energy = { value = 0, mod = 1 }
					g.old_feat = spot.oe
					g.useEnergy = mod.class.Trap.useEnergy
					g.act = function(self)
						self:useEnergy()
						self.temporary = self.temporary - 1
						if self.temporary <= 0 then
							game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
							game.level:removeEntity(self)
							game.nicer_tiles:updateAround(game.level, self.x, self.y)
						end
					end
					game.level:addEntity(g)
				end

				src:project({type="ball", radius=tg.radius}, x, y, engine.DamageType.FIRE, dam/2)
				src:project({type="ball", radius=tg.radius}, x, y, engine.DamageType.PHYSICAL, dam/2)
				src:project({type="ball", radius=tg.radius}, x, y, function(px, py)
					local target = game.level.map(px, py, engine.Map.ACTOR)
					if target then
						checkAnomalyTriggers(src, target)
						if target:canBe("stun") then
							target:setEffect(target.EFF_STUNNED, 3, {apply_power=src:combatSpellpower()})
						else
							game.logSeen(target, "%s resists the stun!", target.name:capitalize())
						end
					end
				end)
				if core.shader.allow("distort") then game.level.map:particleEmitter(x, y, tg.radius, "shockwave", {radius=tg.radius}) end
				game:getPlayer(true):attr("meteoric_crash", 1)
			end
		end

		local dam = self:spellCrit(getAnomalyDamage(self))
		meteor(self, x, y, dam)

		return true
	end,
	info = function(self, t)
		return ([[Causes a meteor to fall from the sky.]]):
		format()
	end,
}

newTalent{
	name = "Anomaly Spacetime Tear",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "major",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "@Source@ tears a hole in the fabric of spacetime.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tx, ty = getAnomalyPosition(self, self:getTalentRange(t))

		-- Make a trap so the player can shut it
		local npcs = mod.class.NPC:loadList{"/data/general/npcs/horror_temporal.lua"}
		local trap = Trap.new{
			name = "Spacetime Tear",
			type = "time", id_by_type=true, unided_name = "trap",
			display = '^', color=colors.GOLD, image = "object/temporal_instability.png",
			npc_type = npcs,
			canTrigger = function(self, x, y, who)
				if who == self.summoned_by then return mod.class.Trap.canTrigger(self, x, y, who) end
				return false
			end,
			triggered = function(self, x, y, who)
				if who == self.summoned_by then
					if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
					game.level:removeEntity(self)
					game.logPlayer(who, "%s forces the tear shut!", who.name:capitalize())
				end
				return true
			end,
			temporary = getAnomalyDuration(self)*10,
			x = tx, y = ty,
			canAct = false,
			energy = {value=0},
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
					game.level:removeEntity(self)
				end
				-- Summon Temporal Horrors each turn
				local m = game.zone:makeEntity(game.level, "actor", {base_list=self.npc_type}, nil, true)
				if self.temporary%4 == 0 and m then
					local i, j = util.findFreeGrid(self.x, self.y, 5, true, {[engine.Map.ACTOR]=true})
					if not i then
						return
					end
					m.exp_worth = 0
					game.zone:addEntity(game.level, m, "actor", i, j)
					game.level.map:particleEmitter(i, j, 1, "temporal_teleport")
					game:playSoundNear(m, "distortion")
				end
			end,
			summoned_by = self, -- 'summoner' can't trigger own traps
		}
		
		game.level:addEntity(trap)
		trap:identify(true)
		trap:setKnown(self, true)
		game.zone:addEntity(game.level, trap, "trap", tx, ty)
		game:playSoundNear(self, "talents/arcane")
		
		return true
	end,
	info = function(self, t)
		return ([[Tears a hole in the fabric of spacetime.]]):
		format()
	end,
}

newTalent{
	name = "Anomaly Summon Time Elemental",
	type = {"chronomancy/anomalies", 1},
	anomaly_type = "major",
	type_no_req = true,
	no_unlearn_last = true,
	points = 1,
	paradox = 0,
	cooldown = 1,
	range = 10,
	radius = function(self, t) return getAnomalyRadius(self) end,
	direct_hit = true,
	no_energy = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = "Some Time Elementals have been attracted by @Source@'s meddling.",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tgts = getAnomalyTargets(self, t, self.x, self.y, "ACTOR", self:getTalentRadius(t))

		-- Randomly take targets
		for i = 1, rng.avg(3, 6, 3) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			-- Find space
			local i, j = util.findFreeGrid(a.x, a.y, 5, true, {[Map.ACTOR]=true})
			if not i then
				return
			end
			local npcs = mod.class.NPC:loadList{"/data/general/npcs/telugoroth.lua"}
			local m = game.zone:makeEntity(game.level, "actor", {base_list=npcs}, nil, true)
			if m then
				m.exp_worth = 0
				game.zone:addEntity(game.level, m, "actor", i, j)
				game.level.map:particleEmitter(i, j, 1, "temporal_teleport")
				game:playSoundNear({x=i,y=j}, "talents/thunderstorm")
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Time elementals have been attracted to the timeline.]]):
		format()
	end,
}

--[[newTalent{
	name = "Anomaly Terrain Change",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	no_unlearn_last = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return (Random Terrain in a ball.)
	end,
}

newTalent{
	name = "Anomaly Stat Reorder",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	no_unlearn_last = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return (Target loses stats.)
	end,
}

newTalent{
	name = "Anomaly Heal",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	no_unlearn_last = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return (Target is healed to full life.)
	end,
}


newTalent{
	name = "Anomaly Vertigo",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	no_npc_use = true,
	no_unlearn_last = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ()
	end,
}

}]]
