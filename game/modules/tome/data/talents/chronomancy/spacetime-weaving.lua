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

-- EDGE TODO: Icons, Particles, Timed Effect Particles

newTalent{
	name = "Dimensional Step",
	type = {"chronomancy/spacetime-weaving", 1},
	require = chrono_req1,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 10,
	tactical = { CLOSEIN = 2, ESCAPE = 2 },
	range = function(self, t) return math.floor(self:combatTalentScale(t, 5, 10, 0.5, 0, 1)) end,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), nolock=true, nowarning=true}
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
		return ([[Teleports you to up to %d tiles away, to a targeted location in line of sight.  Additional talent points increase the range.
		This spell takes no time to cast.]]):format(range)
	end,
}

newTalent{
	name = "Displace Damage",
	type = {"chronomancy/spacetime-weaving", 2},
	mode = "sustained",
	require = chrono_req2,
	sustain_paradox = 50,
	cooldown = 10,
	tactical = { BUFF = 2 },
	points = 5,
	-- called by _M:onTakeHit function in mod\class\Actor.lua to perform the damage displacment
	getchance = function(self, t) return self:combatTalentLimit(t, 50, 10, 30) end, -- Limit < 50%
	getrange = function(self, t) return math.floor(self:combatTalentScale(t, 5, 10, 0.5, 0, 1)) end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Space bends around you, giving you a %d%% chance to displace half of any damage you receive onto a random enemy within a radius of %d.
		]]):format(t.getchance(self, t), t.getrange(self, t))
	end,
}

newTalent{
	name = "Wormhole",
	type = {"chronomancy/spacetime-weaving", 3},
	require = chrono_req3,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 10,
	tactical = { ESCAPE = 2 },
	range = 10,
	radius = function(self, t) return math.floor(self:combatTalentLimit(t, 0, 7, 3)) end, -- Limit to radius 0
	requires_target = true,
	getDuration = function (self, t) return math.floor(self:combatTalentScale(self:getTalentLevel(t), 6, 10)) end,
	no_npc_use = true,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=1, nolock=true, simple_dir_request=true, talent=t}
		local entrance_x, entrance_y = self:getTarget(tg)
		if not entrance_x or not entrance_y then return nil end
		local _ _, entrance_x, entrance_y = self:canProject(tg, entrance_x, entrance_y)
		local trap = game.level.map(entrance_x, entrance_y, engine.Map.TRAP)
		if trap or game.level.map:checkEntity(entrance_x, entrance_y, Map.TERRAIN, "block_move") then game.logPlayer(self, "You can't place a wormhole entrance here.") return end

		-- Finding the exit location
		-- First, find the center possible exit locations
		local x, y, radius, minimum_distance
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
		local exit_x, exit_y = pos[1], pos[2]
		print("[[wormhole]] entrance ", entrance_x, " :: ", entrance_y)
		print("[[wormhole]] exit ", exit_x, " :: ", exit_y)

		--checks for spacetime mastery hit bonus
		local power = getParadoxSpellpower(self)
		if self:knowTalent(self.T_SPACETIME_MASTERY) then
			power = power * (1 + self:callTalent(self.T_SPACETIME_MASTERY, "getPower"))
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
			power = power,
			summoned_by = self, -- "summoner" is immune to it's own traps
			triggered = function(self, x, y, who)
				if who == self.summoned_by or who:checkHit(self.power, who:combatSpellResist()+(who:attr("continuum_destabilization") or 0), 0, 95) and who:canBe("teleport") then -- Bug fix, Deprecrated checkhit call
					-- since we're using a precise teleport we'll look for a free grid first
					local tx, ty = util.findFreeGrid(self.dest.x, self.dest.y, 5, true, {[engine.Map.ACTOR]=true})
					if tx and ty then
						game.level.map:particleEmitter(who.x, who.y, 1, "temporal_teleport")
						if not who:teleportRandom(tx, ty, 0) then
							game.logSeen(who, "%s tries to enter the wormhole but a violent force pushes it back.", who.name:capitalize())
						elseif who ~= self.summoned_by then
							who:setEffect(who.EFF_CONTINUUM_DESTABILIZATION, 100, {power=self.destabilization_power})
							game.level.map:particleEmitter(who.x, who.y, 1, "temporal_teleport")
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
		game.level.map:particleEmitter(entrance_x, entrance_y, 1, "temporal_teleport")
		game:playSoundNear(self, "talents/heal")

		-- Adding the exit wormhole
		local exit = entrance:clone()
		exit.x = exit_x
		exit.y = exit_y
		game.level:addEntity(exit)
		exit:identify(true)
		exit:setKnown(self, true)
		game.zone:addEntity(game.level, exit, "trap", exit_x, exit_y)
		game.level.map:particleEmitter(exit_x, exit_y, 1, "temporal_teleport")

		-- Linking the wormholes
		entrance.dest = exit
		exit.dest = entrance

		game.logSeen(self, "%s folds the space between two points.", self.name)
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		return ([[You fold the space between yourself and a second point within range (radius %d accuracy), creating a pair of wormholes.  Any creature stepping on either wormhole will be teleported to the other.  The wormholes will last %d turns.
		The chance of teleportation will scale with your Spellpower.]])
		:format(radius, duration)
	end,
}

newTalent{
	name = "Phase Shift",
	type = {"chronomancy/spacetime-weaving", 4},
	mode = "passive",
	require = chrono_req4,
	points = 5,
	getChance = function(self, t) return 10 + self:combatTalentSpellDamage(t, 10, 50, getParadoxSpellpower(self)) end,
	doPhaseShift = function(self, t)
		local effs = {}
		-- Go through all effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" and e.type ~= "other" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		-- Roll to remove each one
		for i = 1, #effs do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)
			if eff[1] == "effect" and rng.percent(t.getChance(self, t)) then
				self:removeEffect(eff[2])
			end
		end
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		return ([[When you teleport you have a %d%% chance to remove each detrimental status effect currently affecting you.
		Each effect is checked individually and the chance scales with your Spellpower.]]):
		format(chance)
	end,
}
