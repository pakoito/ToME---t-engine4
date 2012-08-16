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

local Astar = require "engine.Astar"

local function clearTarget(self)
	self.ai_target.actor, self.ai_target.x, self.ai_target.y, self.ai_target.blindside_chance, self.ai_target.attack_spell_chance, self.turns_on_target, self.focus_on_target = nil, nil, nil, nil, nil, 0, false
end

local function shadowChooseActorTarget(self)

	-- taken from "target_simple" but selects a target the summoner can see within the shadow's max range from the summoner
	local arr = self.summoner.fov.actors_dist
	local act
	local sqsense = self.ai_state.actor_range
	sqsense = sqsense * sqsense
	local actors = {}
	for i = 1, #arr do
		act = self.summoner.fov.actors_dist[i]
		if act and act ~= self.summoner and self.summoner:reactionToward(act) < 0 and not act.dead and
			(
				-- If it has lite we can always see it
				((act.lite or 0) > 0)
				or
				-- Otherwise check if we can see it with our "senses"
				(self.summoner:canSee(act) and self.summoner.fov.actors[act].sqdist <= sqsense)
			) then

			actors[#actors+1] = act
		end
	end

	if #actors > 0 then
		--game.logPlayer(self.summoner, "#PINK#%s has chosen an actor.", self.name:capitalize())
		self.ai_target.actor = actors[rng.range(1, #actors)]
		self:check("on_acquire_target", act)
		act:check("on_targeted", self)

		return true
	end

	return false
end

local function shadowMoveToActorTarget(self)
	local range = core.fov.distance(self.x, self.y, self.ai_target.actor.x, self.ai_target.actor.y)

	if range <= 1 and self.ai_state.close_attack_spell_chance and rng.percent(self.ai_state.close_attack_spell_chance) then
		-- chance for close spell
		if self:closeAttackSpell() then return true end
	elseif range <= 6 and self.ai_state.far_attack_spell_chance and rng.percent(self.ai_state.far_attack_spell_chance) then
		-- chance for a far spell
		if self:farAttackSpell() then return true end
	end

	if range <= 1 and self.ai_state.dominate_chance and rng.percent(self.ai_state.dominate_chance) then
		if self:dominate() then return true end
	end

	-- use the target blindside chance if it was assigned; otherwise, use the normal chance
	local blindsideChance = self.ai_target.blindside_chance or self.ai_state.blindside_chance
	self.ai_target.blindside_chance = nil
	if rng.percent(blindsideChance) then
		--game.logPlayer(self.summoner, "#PINK#%s is about to blindside.", self.name:capitalize())
		-- try a blindside attack
		local t = self:getTalentFromId(self.T_SHADOW_BLINDSIDE)
		if self:getTalentRange(t) and self:preUseTalent(t, true, true) then
			if self:useTalent(self.T_SHADOW_BLINDSIDE) then
				self.ai_state.target_time = self.ai_state.target_timeout

				--game.logPlayer(self.summoner, "#PINK#%s -> blindside", self.name:capitalize())
				return true
			end
		end
	end

	-- chance to reset target next turn if we are attacking (unless we have been focused)
	if range <= 1 and rng.percent(20) then
		--game.logPlayer(self.summoner, "#PINK#%s is about to attack.", self.name:capitalize())
		if not self.ai_state.focus_on_target then
			self.ai_state.target_time = self.ai_state.target_timeout
		end
	end

	-- move to target
	if self:runAI("move_dmap") then
		self.turns_on_target = (self.turns_on_target or 0) + 1

		--game.logPlayer(self.summoner, "#PINK#%s -> move_dmap", self.name:capitalize())
		return true
	end

	return false
end

local function shadowChooseLocationTarget(self)

	local locations = {}
	local range = math.floor(self.ai_state.location_range)
	local x, y = self.summoner.x, self.summoner.y

	for i = x - range, x + range do
		for j = y - range, y + range do
			if game.level.map:isBound(i, j)
					and core.fov.distance(x, y, i, j) <= range
					and self:canMove(i, j) then
				locations[#locations+1] = {i,j}
			end
		end
	end

	if #locations > 0 then
		local location = locations[rng.range(1, #locations)]
		self.ai_target.x, self.ai_target.y = location[1], location[2]

		return true
	end

	return false
end

local function shadowMoveToLocationTarget(self)
	if self.x == self.ai_target.x and self.y == self.ai_target.x then
		-- already at target
		return false
	end

	if rng.percent(self.ai_state.phasedoor_chance) then
		--game.logPlayer(self.summoner, "#PINK#%s is about to phase door.", self.name:capitalize())
		-- try a phase door
		local t = self:getTalentFromId(self.T_SHADOW_PHASE_DOOR)
		if self:getTalentRange(t) and self:preUseTalent(t, true, true) then
			if self:useTalent(self.T_SHADOW_PHASE_DOOR) then
				--game.logPlayer(self.summoner, "#PINK#%s -> phase door", self.name:capitalize())

				return true
			end
		end
	end

	local tx, ty = self.ai_target.x, self.ai_target.y
	local path = self.shadow_path
	if not path or #path == 0 then
		local a = Astar.new(game.level.map, self)
		path = a:calc(self.x, self.y, tx, ty)
	end

	if path then
		self.shadow_path = {}
		tx, ty = path[1].x, path[1].y

		-- try to move around actors..if we fail we will just try a a new target
		if not self:canMove(tx, ty, false) then
			local dir = util.getDir(tx, ty, self.x, self.y)
			tx, ty = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).left)
			if not self:canMove(tx, ty, false) then
				tx, ty = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).right)
				if not self:canMove(tx, ty, false) then
					--game.logPlayer(self.summoner, "#PINK#%s move fails", self.name:capitalize())
					return false
				end
			end
		end

		self:move(tx, ty)
		self.turns_on_target = (self.turns_on_target or 0) + 1

		--game.logPlayer(self.summoner, "#PINK#%s -> move", self.name:capitalize())
		return true
	end

	return false
end

newAI("shadow", function(self)
	--game.logPlayer(self.summoner, "#PINK#%s BEGINS.", self.name:capitalize())

	-- out of summon time? summoner gone?
	if self.summon_time <= 0 or self.summoner.dead then
		game.logPlayer(self.summoner, "#PINK#%s returns to the shadows.", self.name:capitalize())
		self:die()
	end
	self.summon_time = self.summon_time - 1

	-- make sure no one has turned us against our summoner
	if self.ai_target.actor == self.summoner then
		clearTarget(self)
	end

	-- shadow wall
	if self.ai_state.shadow_wall then

		clearTarget(self)

		local defendant = self.ai_state.shadow_wall_target

		if self.ai_state.shadow_wall_time <= 0 or defendant.dead then
			self.ai_state.shadow_wall = false
		else
			self.ai_state.shadow_wall_time = self.ai_state.shadow_wall_time - 1

			local range = core.fov.distance(self.x, self.y, defendant.x, defendant.y)
			if range >= 3 then
				-- phase door into range
				self:useTalent(self.T_SHADOW_PHASE_DOOR)
				return true
			elseif range > 1 then
				self.ai_target.x = defendant.x
				self.ai_target.y = defendant.y
				if shadowMoveToLocationTarget(self) then return true end
			end
			-- no action..look for a target to attack
			local newX, newY
			local start = rng.range(0, 8)
			for i = start, start + 8 do
				local x = self.x + (i % 3) - 1
				local y = self.y + math.floor((i % 9) / 3) - 1
				local target = game.level.map(x, y, Map.ACTOR)
				if target and self.summoner:reactionToward(target) < 0 and not target.dead then
					self:attackTarget(target, nil, 1, true)
					return true
				end
				if not newX and core.fov.distance(x, y, defendant.x, defendant.y) <= 1 and self:canMove(x, y, false) then
					newX, newY = x, y
				end
			end

			if newX and newY then
				self:move(newX, newY)
			end
			return true
		end
	end

	-- out of summoner range?
	if core.fov.distance(self.x, self.y, self.summoner.x, self.summoner.y) > self.ai_state.summoner_range then
		--game.logPlayer(self.summoner, "#PINK#%s is out of range.", self.name:capitalize())

		clearTarget(self)

		-- phase door into range
		self:useTalent(self.T_SHADOW_PHASE_DOOR)
		--game.logPlayer(self.summoner, "#PINK#%s -> phase door", self.name:capitalize())
		return true
	end

	-- out of time on current target?
	if (self.turns_on_target or 0) >= 10 then
		--game.logPlayer(self.summoner, "#PINK#%s is out of time for target.", self.name:capitalize())

		clearTarget(self)
	end

	-- chance to heal
	if self.life < self.max_life * 0.75 and rng.percent(5) then
		self:healSelf()
		return true
	end

	-- move to live target?
	if self.ai_target.actor and not self.ai_target.actor.dead then
		if shadowMoveToActorTarget(self) then
			return true
		end
	end

	-- move to location target?
	if self.ai_target.x and self.ai_target.y then
		if shadowMoveToLocationTarget(self) then
			return true
		end
	end

	-- no current target..start a new action
	clearTarget(self)

	-- choose an actor target? this determines their aggressiveness
	if rng.percent(65) and shadowChooseActorTarget(self) then
		--game.logPlayer(self.summoner, "#PINK#%s choose an actor.", self.name:capitalize())

		-- start moving to the target
		if shadowMoveToActorTarget(self) then
			return true
		end
	end

	-- choose a location target?
	if shadowChooseLocationTarget(self) then
		--game.logPlayer(self.summoner, "#PINK#%s choose a location.", self.name:capitalize())

		if shadowMoveToLocationTarget(self) then
			return true
		end
	end

	-- fail
	--game.logPlayer(self.summoner, "#PINK#%s -> failed to make a move.", self.name:capitalize())
	return true
end)

