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

local Astar = require "engine.Astar"

-- Find an hostile target on the worldmap
newAI("target_world", function(self)
	if self.ai_target.actor and not self.ai_target.actor.dead and rng.percent(90) then return true end

	-- Find closer enemy and target it
	-- Get list of actors ordered by distance
	local arr = self.fov.actors_dist
	local act
	local sqsense = self.sight or 4
	sqsense = sqsense * sqsense
	for i = 1, #arr do
		act = self.fov.actors_dist[i]
--		print("AI looking for target", self.uid, self.name, "::", act.uid, act.name, self.fov.actors[act].sqdist)
		-- find the closest enemy
		if act and self:reactionToward(act) < 0 and not act.dead and
				-- Otherwise check if we can see it with our "senses"
				self.fov.actors[act].sqdist <= sqsense
				then

			self.ai_target.actor = act
			self:check("on_acquire_target", act)
			act:check("on_targeted", self)
			print("AI took for target", self.uid, self.name, "::", act.uid, act.name, self.fov.actors[act].sqdist, "<", sqsense)
			return true
		end
	end
end)

newAI("world_patrol", function(self)
	if not self.energy.used and self.x and self.y then
		if self:runAI("target_world") and self:reactionToward(self.ai_target.actor) < 0 and game.level.map:isBound(self.ai_target.actor.x, self.ai_target.actor.y) then
			self:runAI("move_dmap")
		else
			self:runAI("move_world_patrol")
		end
	end
	return true
end)

newAI("move_world_patrol", function(self)
	if not self.ai_state.route then
		self.ai_state.route = game.level:pickSpot{type="patrol", subtype=self.ai_state.route_kind}
		local a = Astar.new(game.level.map, self)
		self.ai_state.route_path = a:calc(self.x, self.y, self.ai_state.route.x, self.ai_state.route.y)
--		print(self.name, "Selecting route!", self.ai_state.route_path, "from", self.x, self.y, "to", self.ai_state.route.x, self.ai_state.route.y)
	else
		local path = self.ai_state.route_path
--		print("Using route", self.ai_state.route_path)
		if not path or not path[1] or (path[1] and core.fov.distance(self.x, self.y, path[1].x, path[1].y)) > 1 then
			self.ai_state.route_path = nil self.ai_state.route = nil
--			print("Nulling!", path, path and path[1], path and path[1] and core.fov.distance(self.x, self.y, path[1].x, path[1].y))
			return true
		else
			local ret = self:move(path[1].x, path[1].y)
			table.remove(path, 1)
			return ret
		end
	end
end)

newAI("world_hostile", function(self)
	if not self.energy.used and self.x and self.y then
		if self:runAI("target_world") and self:reactionToward(self.ai_target.actor) < 0 and core.fov.distance(self.x, self.y, self.ai_target.actor.x, self.ai_target.actor.y) <= self.ai_state.chase_distance then
			self:runAI("move_dmap")
		else
			self:runAI("move_world_hostile")
		end
	end
	return true
end)

newAI("move_world_hostile", function(self)
	local tx, ty = self.ai_state.wander_x, self.ai_state.wander_y
	if not tx or not ty then
		local grids = core.fov.circle_grids(self.x, self.y, 4, true)
		local gs = {}
		for x, yy in pairs(grids) do for y, _ in pairs(yy) do
			if not game.level.map:checkEntity(x, y, game.level.map.TERRAIN, "block_move") then
				gs[#gs+1] = {x, y}
			end
		end end
		local g = rng.table(gs)
		if g then
			self.ai_state.wander_x, self.ai_state.wander_y = g[1], g[2]
			tx, ty = self.ai_state.wander_x, self.ai_state.wander_y
--			print("Hostile selected random wander", tx, ty)
		end
	end

	if tx and ty then
		if (tx == self.x and ty == self.y) or rng.percent(10) then self.ai_state.wander_x, self.ai_state.wander_y = nil, nil return true end
		pcall(self.moveDirection, self, tx, ty)
	end
	return true
end)

