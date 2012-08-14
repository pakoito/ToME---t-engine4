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
	name = "Dimensional Step",
	type = {"chronomancy/spacetime-weaving", 1},
	require = temporal_req1,
	points = 5,
	paradox = 5,
	cooldown = 10,
	tactical = { CLOSEIN = 2, ESCAPE = 2 },
	range = function(self, t)
		return 2 + math.floor(self:getTalentLevel(t))
	end,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t)}
	end,
	direct_hit = true,
	no_energy = true,
	is_teleport = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		if not self:hasLOS(x, y) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
			game.logSeen(self, "You do not have line of sight.")
			return nil
		end
		x, y = checkBackfire(self, x, y)
		local __, x, y = self:canProject(tg, x, y)

		game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")

		-- since we're using a precise teleport we'll look for a free grid first
		local tx, ty = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
		if tx and ty then
			if not self:teleportRandom(tx, ty, 0) then
				game.logSeen(self, "The spell fizzles!")
			end
		end

		game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
		game:playSoundNear(self, "talents/teleport")

		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[Teleports you to up to %d tiles away to a targeted location in line of sight.  Additional talent points increase the range.
		This spell takes no time to cast.]]):format(range)
	end,
}

newTalent{
	name = "Banish",
	type = {"chronomancy/spacetime-weaving", 2},
	require = temporal_req2,
	points = 5,
	paradox = 10,
	cooldown = 10,
	tactical = { ESCAPE = 2 },
	range = 0,
	radius = function(self, t)
		return 2 + math.floor(self:getTalentLevel(t)/2)
	end,
	getTeleport = function(self, t) return 6 + math.floor(self:getTalentLevel(t)/2 * getParadoxModifier(self, pm) * 4) end,
	target = function(self, t)
		return {type="ball", range=0, radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	requires_target = true,
	direct_hit = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local actors = {}

		--checks for spacetime mastery hit bonus
		local power = self:combatSpellpower()
		if self:knowTalent(self.T_SPACETIME_MASTERY) then
			power = self:combatSpellpower() * (1 + self:getTalentLevel(self.T_SPACETIME_MASTERY)/10)
		end

		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target or target == self then return end
			if self:checkHit(power, target:combatSpellResist() + (target:attr("continuum_destabilization") or 0)) and target:canBe("teleport") then
				actors[#actors+1] = target
			else
				game.logSeen(target, "%s resists the banishment!", target.name:capitalize())
			end
		end)

		local do_fizzle = false
		for i, a in ipairs(actors) do
			game.level.map:particleEmitter(a.x, a.y, 1, "teleport")
			if not a:teleportRandom(a.x, a.y, self:getTalentRadius(t) * 4, self:getTalentRadius(t) * 2) then
				do_fizzle = true
			end
			a:setEffect(a.EFF_CONTINUUM_DESTABILIZATION, 100, {power=self:combatSpellpower(0.3)})
			game.level.map:particleEmitter(a.x, a.y, 1, "teleport")
		end

		if do_fizzle == true then
			game.logSeen(self, "The spell fizzles!")
		end

		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_teleport", {radius=tg.radius})
		game:playSoundNear(self, "talents/teleport")

		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local range = t.getTeleport(self, t)
		return ([[Randomly teleports all targets with in a radius of %d around you.  Targets will be teleported between %d and %d tiles from their current location.
		The teleport range will scale with your Paradox.]]):format(radius, range / 2, range)
	end,
}

newTalent{
	name = "Wormhole",
	type = {"chronomancy/spacetime-weaving", 3},
	require = temporal_req3,
	points = 5,
	paradox = 20,
	cooldown = 20,
	tactical = { ESCAPE = 2 },
	range = function (self, t)
		return 10 + math.floor(self:getTalentLevel(t)/2)
	end,
	radius = function(self, t)
		return 8 - math.floor(self:getTalentLevel(t))
	end,
	requires_target = true,
	getDuration = function (self, t) return 5 + math.floor(self:getTalentLevel(t)*getParadoxModifier(self, pm)) end,
	no_npc_use = true,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=1, nolock=true, talent=t}
		local entrance_x, entrance_y = self:getTarget(tg)
		if not entrance_x or not entrance_y then return nil end
		local _ _, entrance_x, entrance_y = self:canProject(tg, entrance_x, entrance_y)
		local trap = game.level.map(entrance_x, entrance_y, engine.Map.TRAP)
		if trap or game.level.map:checkEntity(entrance_x, entrance_y, Map.TERRAIN, "block_move") then game.logPlayer(self, "You can't place a wormhole entrance here.") return end

		-- Finding the exit location
		-- First, find the center possible exit locations
		local x, y, radius, minimum_distance
		if self:getTalentLevel(t) >= 4 then
			radius = self:getTalentRadius(t)
			minimum_distance = 0
			local tg = {type="ball", nolock=true, pass_terrain=true, nowarning=true, range=self:getTalentRange(t), radius=radius}
			x, y = self:getTarget(tg)
			print("[Target]", x, y)
			if not x then return nil end
			-- Make sure the target is within range
			if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then
				game.logPlayer(self, "Pick a valid location.")
				return false
			end
		else
			x, y = self.x, self.y
			radius = self:getTalentRange(t)
			minimum_distance = 10
		end
		-- Second, select one of the possible exit locations
		local poss = {}
		for i = x - radius, x + radius do
			for j = y - radius, y + radius do
				if game.level.map:isBound(i, j) and
					core.fov.distance(x, y, i, j) <= radius and
					core.fov.distance(x, y, i, j) >= minimum_distance and
					self:canMove(i, j) and not game.level.map(i, j, engine.Map.TRAP) then
					poss[#poss+1] = {i,j}
				end
			end
		end
		if #poss == 0 then game.logPlayer(self, "No exit location could be found.")	return false end
		local pos = poss[rng.range(1, #poss)]
		exit_x, exit_y = pos[1], pos[2]
		print("[[wormhole]] entrance ", entrance_x, " :: ", entrance_y)
		print("[[wormhole]] exit ", exit_x, " :: ", exit_y)

		--checks for spacetime mastery hit bonus
		local power = self:combatSpellpower()
		if self:knowTalent(self.T_SPACETIME_MASTERY) then
			power = self:combatSpellpower() * (1 + self:getTalentLevel(self.T_SPACETIME_MASTERY)/10)
		end

		-- Adding the entrance wormhole
		local entrance = mod.class.Trap.new{
			name = "wormhole",
			type = "annoy", subtype="teleport", id_by_type=true, unided_name = "trap",
			image = "terrain/wormhole.png",
			display = '&', color_r=255, color_g=255, color_b=255, back_color=colors.STEEL_BLUE,
			message = "@Target@ moves onto the wormhole.",
			temporary = t.getDuration(self, t),
			x = entrance_x, y = entrance_y,
			canAct = false,
			energy = {value=0},
			disarm = function(self, x, y, who) return false end,
			check_hit = power,
			destabilization_power = self:combatSpellpower(0.3),
			summoned_by = self, -- "summoner" is immune to it's own traps
			triggered = function(self, x, y, who)
				if who == self.summoned_by or who:checkHit(self.check_hit, who:combatSpellResist(), 0, 95, 15) and who:canBe("teleport") then
					-- since we're using a precise teleport we'll look for a free grid first
					local tx, ty = util.findFreeGrid(self.dest.x, self.dest.y, 5, true, {[engine.Map.ACTOR]=true})
					if tx and ty then
						if not who:teleportRandom(tx, ty, 0) then
							game.logSeen(who, "%s tries to enter the wormhole but a violent force pushes it back.", who.name:capitalize())
						elseif who ~= self.summoned_by then
							who:setEffect(who.EFF_CONTINUUM_DESTABILIZATION, 100, {power=self.destabilization_power})
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
		game.zone:addEntity(game.level, entrance, "trap", entrance_x, entrance_y)
		game.level.map:particleEmitter(entrance_x, entrance_y, 1, "teleport")
		game:playSoundNear(self, "talents/heal")

		-- Adding the exit wormhole
		local exit = entrance:clone()
		exit.x = exit_x
		exit.y = exit_y
		game.level:addEntity(exit)
		exit:identify(true)
		exit:setKnown(self, true)
		game.zone:addEntity(game.level, exit, "trap", exit_x, exit_y)
		game.level.map:particleEmitter(exit_x, exit_y, 1, "teleport")

		-- Linking the wormholes
		entrance.dest = exit
		exit.dest = entrance

		game.logSeen(self, "%s folds the space between two points.", self.name)
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		return ([[You fold the space between yourself and a random point within range, creating a pair of wormholes.  Any creature stepping on either wormhole will be teleported to the other.  The wormholes will last %d turns.
		At level 4 you may choose the exit location target area (radius %d).  The duration will scale with your Paradox.]])
		:format(duration, radius)
	end,
}

newTalent{
	name = "Spacetime Mastery",
	type = {"chronomancy/spacetime-weaving", 4},
	mode = "passive",
	require = temporal_req4,
	points = 5,
	on_learn = function(self, t)
		self.talent_cd_reduction[self.T_BANISH] = (self.talent_cd_reduction[self.T_BANISH] or 0) + 1
		self.talent_cd_reduction[self.T_DIMENSIONAL_STEP] = (self.talent_cd_reduction[self.T_DIMENSIONAL_STEP] or 0) + 1
		self.talent_cd_reduction[self.T_SWAP] = (self.talent_cd_reduction[self.T_SWAP] or 0) + 1
		self.talent_cd_reduction[self.T_TEMPORAL_WAKE] = (self.talent_cd_reduction[self.T_TEMPORAL_WAKE] or 0) + 1
		self.talent_cd_reduction[self.T_WORMHOLE] = (self.talent_cd_reduction[self.T_WORMHOLE] or 0) + 2
	end,
	on_unlearn = function(self, t)
		self.talent_cd_reduction[self.T_BANISH] = self.talent_cd_reduction[self.T_BANISH] - 1
		self.talent_cd_reduction[self.T_DIMENSIONAL_STEP] = self.talent_cd_reduction[self.T_DIMENSIONAL_STEP] - 1
		self.talent_cd_reduction[self.T_SWAP] = self.talent_cd_reduction[self.T_SWAP] - 1
		self.talent_cd_reduction[self.T_TEMPORAL_WAKE] = self.talent_cd_reduction[self.T_TEMPORAL_WAKE] - 1
		self.talent_cd_reduction[self.T_WORMHOLE] = self.talent_cd_reduction[self.T_WORMHOLE] - 2
	end,
	info = function(self, t)
		local cooldown = self:getTalentLevelRaw(t)
		local wormhole = self:getTalentLevelRaw(t) * 2
		local power = self:getTalentLevel(t) * 10
		return ([[Your mastery of spacetime reduces the cooldown of banish, dimensional step, swap, and temporal wake by %d and the cooldown of wormhole by %d.  Also improves your chances of hitting targets with chronomancy effects that may cause continuum destablization (Banish, Time Skip, etc.) as well as your chance of overcoming continuum destabilization by %d%%.]]):
		format(cooldown, wormhole, power)
	end,
}