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
	name = "Revision",
	type = {"chronomancy/weaving", 1},
	require = temporal_req1,
	points = 5,
	message = "@Source@ makes a minor revision to the spacetime continuum.",
	cooldown = 50,
	action = function(self, t)
		self:incParadox(-20 - (self:getWil() * self:getTalentLevel(t)/2))
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		return ([[Reduce Paradox by %d by making a minor revision to the damage you've inflicted on the spacetime continuum.
		The effect will increase with the Willpower stat.]]):
		format(20 + (self:getWil() * self:getTalentLevel(t)/2), 10 - self:getTalentLevel(t))
	end,
}

  newTalent{
	name = "Wormhole",
	type = {"chronomancy/weaving", 2},
	require = temporal_req2,
	points = 5,
	random_ego = "utility",
	paradox = 10,
	cooldown = 30,
	tactical = {
		ESCAPE = 4,
	},
	requires_target = function(self, t) return self:getTalentLevel(t) >= 4 end,
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
			radius = math.floor(7 - self:getTalentLevel(t))
			minimum_distance = 0
			local tg = {type="ball", nolock=true, pass_terrain=true, nowarning=true, range=10 + self:combatSpellpower(0.1), radius=radius}
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
			image = "talents/wormhole.png",
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
			temporary = ((5 + self:getTalentLevel(t)) *getParadoxModifier(self, pm)),
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
		game.logSeen(self, "%s folds the space between two points", self.name)
		return true
	end,
	info = function(self, t)
		return ([[You fold the space between two points, allowing travel back and forth between them for the next %d turns.
		At level 4 you may choose the exit location target area (radius %d).]])
		:format((5 + self:getTalentLevel(t)) *getParadoxModifier(self, pm), 7 - self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Damage Smearing",
	type = {"chronomancy/weaving",3},
	require = temporal_req3,
	points = 5,
	paradox = 25,
	cooldown = 50,
	tactical = {
		DEFENSE = 10,
	},
	range = 20,
	action = function(self, t)
		local dur = util.bound(5 + math.floor(self:getTalentLevel(t)), 5, 15)*getParadoxModifier(self, pm)
		self:setEffect(self.EFF_DAMAGE_SMEARING, dur, {power=10})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[For the next %d turns you spread all damage that deals 10 or more points out over several turns rather then taking it all at once.
		]]):format (util.bound(5 + math.floor(self:getTalentLevel(t)), 5, 15)*getParadoxModifier(self, pm))
	end,
}

newTalent{
	name = "Static History",
	type = {"chronomancy/weaving", 4},
	require = temporal_req4,
	points = 5,
	message = "@Source@ rearranges history to make it more consistant.",
	cooldown = 200,
	action = function(self, t)
		local percent = ((self:getWil()/10) * self:getTalentLevel(t))
		self:incParadox (-(100 - percent)/100 * self:getParadox())
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		return ([[Rewrite history, removing all but %d%% of your Paradox.
		The amount of Paradox lost will decrease with a higher Willpower score.
		]]):format ((self:getWil()/10) * self:getTalentLevel(t))
	end,
}
