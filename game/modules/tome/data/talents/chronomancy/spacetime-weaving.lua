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
	name = "Static History",
	type = {"chronomancy/spacetime-weaving", 1},
	require = temporal_req1,
	points = 5,
	message = "@Source@ fixes some of the damage caused in the past.",
	cooldown = 50,
	getReduction = function(self, t) return (20 + (self:getWil() * self:getTalentLevel(t)/2)) end,
	action = function(self, t)
		self:incParadox (- t.getReduction(self, t))
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		local reduction = t.getReduction (self, t)
		return ([[Reduce Paradox by %d by revising past damage you've inflicted on the spacetime continuum.
		The effect will increase with the Willpower stat.]]):
		format(reduction)
	end,
}

newTalent{
	name = "Backtrack",
	type = {"chronomancy/spacetime-weaving", 2},
	require = temporal_req2,
	points = 5,
	paradox = 3,
	cooldown = 10,
	tactical = {
		ESCAPE = 5,
		MOVEMENT = 5,
	},
	getRange = function(self, t) return 3 + math.ceil(self:getTalentLevel(t) * getParadoxModifier(self, pm)) end,
	requires_target = true,
	direct_hit = true,
	action = function(self, t)
		local tg = {type="hit", range=t.getRange(self, t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > t.getRange(self, t) then return nil end
		if not self:canBe("teleport") or game.level.map.attrs(x, y, "no_teleport") then
			game.logSeen(self, "The spell fizzles!")
			return true
		end
		if self:hasLOS(x, y) and not game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
			local tx, ty = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
			if tx and ty then
				self:move(tx, ty, true)
			end
			game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
			self:move(tx, ty, true)
			game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
			game:playSoundNear(self, "talents/teleport")
		else
			game.logSeen(self, "You cannot move there.")
			return nil
		end
		return true
	end,
	info = function(self, t)
		local range = t.getRange(self, t)
		return ([[Teleports you to up to %d tiles away to a location in line of sight.
		]]):format(range)
	end,
}

newTalent{
	name = "Temporal Reprieve",
	type = {"chronomancy/spacetime-weaving", 3},
	require = chrono_req3,
	points = 5,
	paradox = 5,
	cooldown = 50,
	tactical = {
		UTILITY = 10,
	},
	message = "@Source@ manipulates the flow of time.",
	getCooldownReduction = function(self, t) return 2 + math.ceil(self:getTalentLevel(t) * getParadoxModifier(self, pm)) end,
	action = function(self, t)
		for tid, cd in pairs(self.talents_cd) do
			self.talents_cd[tid] = cd - t.getCooldownReduction(self, t)
		end
			return true
	end,
	info = function(self, t)
		local reduction = t.getCooldownReduction(self, t)
		return ([[All your talents, runes, and infusions currently on cooldown are %d turns closer to being off cooldown.]]):
		format(reduction)
	end,
}

newTalent{
	name = "Wormhole",
	type = {"chronomancy/spacetime-weaving", 4},
	require = temporal_req4,
	points = 5,
	paradox = 10,
	cooldown = 20,
	tactical = {
		ESCAPE = 4,
	},
	requires_target = function(self, t) return self:getTalentLevel(t) >= 4 end,
	getRadius = function(self, t) return math.floor(7 - self:getTalentLevel(t)) end,
	getRange = function (self, t) return 10 + math.floor (self:getTalentLevel(t)/2) end,
	getDuration = function (self, t) return 5 + math.floor(self:getTalentLevel(t)*getParadoxModifier(self, pm)) end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local entrance_x, entrance_y = self:getTarget(tg)
		if not entrance_x or not entrance_y then return nil end
		local _ _, entrance_x, entrance_y = self:canProject(tg, entrance_x, entrance_y)
		local trap = game.level.map(entrance_x, entrance_y, engine.Map.TRAP)
		if trap then
			game.logPlayer(self, "You can't place a wormhole entrance on a trap.")
		return end
		if game.level.map.attrs(entrance_x, entrance_y, "no_teleport") or game.level.map:checkEntity(entrance_x, entrance_y, Map.TERRAIN, "block_move") then
			game.logPlayer(self, "You cannot place a wormhole here.")
			return false
		end
		-- Finding the exit location
		-- First, find the center possible exit locations
		local x, y, radius, minimum_distance
		if self:getTalentLevel(t) >= 4 then
			radius = t.getRadius(self, t)
			minimum_distance = 0
			local tg = {type="ball", nolock=true, pass_terrain=true, nowarning=true, range=t.getRange(self, t), radius=radius}
			x, y = self:getTarget(tg)
			if not x then return nil end
			-- See if we can actually project to the selected location
			if not self:canProject(tg, x, y) then
				game.logPlayer(self, "Pick a valid location")
				return false
			end
		else
			x, y = self.x, self.y
			radius = 15
			minimum_distance = 10
		end
		-- Second, select one of the possible exit locations
		local poss = {}
			for i = x - radius, x + radius do
				for j = y - radius, y + radius do
					if game.level.map:isBound(i, j) and
						core.fov.distance(x, y, i, j) <= radius and
						core.fov.distance(x, y, i, j) >= minimum_distance and
						self:canMove(i, j) and not game.level.map.attrs(i, j, "no_teleport") and not game.level.map(i, j, engine.Map.TRAP) then
						poss[#poss+1] = {i,j}
					end
				end
			end
			if #poss == 0 then
				game.logPlayer(self, "No exit location could be found.")
			return false end
			local pos = poss[rng.range(1, #poss)]
			exit_x, exit_y = pos[1], pos[2]
		print("[[wormhole]] entrance ", entrance_x, " :: ", entrance_y)
		print("[[wormhole]] exit ", exit_x, " :: ", exit_y)
		-- Adding the entrance wormhole
		local entrance = mod.class.Trap.new{
			name = "wormhole",
			type = "annoy", subtype="teleport", id_by_type=true, unided_name = "trap",
			image = "terrain/wormhole.png",
			display = '&', color_r=255, color_g=255, color_b=255, back_color=colors.STEEL_BLUE,
			message = "@Target@ moves through the wormhole.",
			triggered = function(self, x, y, who)
				local tx, ty = util.findFreeGrid(self.dest.x, self.dest.y, 5, true, {[engine.Map.ACTOR]=true})
				if not tx or not who:canBe("teleport") or game.level.map.attrs(tx, ty, "no_teleport") then
					game.logPlayer(who, "You try to enter the wormhole but a violent force pushes you back.")
					return true
				else
					who:move(tx, ty, true)
				end
				return true
			end,
			disarm = function(self, x, y, who) return false end,
			temporary = t.getDuration(self, t),
			x = entrance_x, y = entrance_y,
			canAct = false,
			energy = {value=0},
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.logSeen(self, "Reality asserts itself and forces the wormhole shut.")
					game.level.map:remove(self.x, self.y, engine.Map.TRAP)
					game.level:removeEntity(self)
				end
			end,
		}
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
		local radius = t.getRadius(self, t)
		return ([[You fold the space between two points, allowing travel back and forth between them for the next %d turns.
		At level 4 you may choose the exit location target area (radius %d).]])
		:format(duration, radius)
	end,
}
