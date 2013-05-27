-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

require "engine.class"
require "engine.Actor"
local Map = require "engine.Map"

--- Handles actors artificial intelligence (or dumbness ... ;)
module(..., package.seeall, class.make)

_M.ai_def = {}

--- Define AI
function _M:newAI(name, fct)
	_M.ai_def[name] = fct
end

--- Defines AIs
-- Static!
function _M:loadDefinition(dir)
	for i, file in ipairs(fs.list(dir)) do
		if file:find("%.lua$") then
			local f, err = loadfile(dir.."/"..file)
			if not f and err then error(err) end
			setfenv(f, setmetatable({
				Map = require("engine.Map"),
				newAI = function(name, fct) self:newAI(name, fct) end,
			}, {__index=_G}))
			f()
		end
	end
end

function _M:init(t)
	self.ai_state = self.ai_state or {}
	self.ai_target = self.ai_target or {}
	self:autoLoadedAI()
end

function _M:autoLoadedAI()
	-- Make the table with weak values, so that threat list does not prevent garbage collection
	setmetatable(self.ai_target, {__mode='v'})
end

function _M:aiCanPass(x, y)
	-- Nothing blocks, just go on
	if not game.level.map:checkAllEntities(x, y, "block_move", self, true) then return true end

	-- If there is an other actor, check hostility, if hostile, we move to attack
	local target = game.level.map(x, y, Map.ACTOR)
	if target and self:reactionToward(target) < 0 then return true end

	-- If there is a target (not hostile) and we can move it, do so
	if target and self:attr("move_body") then return true end

	return false
end

--- Move one step to the given target if possible
-- This tries the most direct route, if not available it checks sides and always tries to get closer
function _M:moveDirection(x, y, force)
	if not self.x or not self.y or not x or not y then return false end
	local l = line.new(self.x, self.y, x, y)
	local lx, ly = l()
	if lx and ly then
		local target = game.level.map(lx, ly, Map.ACTOR)

		-- if we are blocked, try some other way
		if not self:aiCanPass(lx, ly) then
			local dir = util.getDir(lx, ly, self.x, self.y)
			local list = util.dirSides(dir, self.x, self.y)
			local l = {}
			-- Find possibilities
			for _, dir in pairs(list) do
				local dx, dy = util.coordAddDir(self.x, self.y, dir)
				if self:aiCanPass(dx, dy) then
					l[#l+1] = {dx,dy, core.fov.distance(x,y,dx,dy)^2}
				end
			end
			-- Move to closest
			if #l > 0 then
				table.sort(l, function(a,b) return a[3]<b[3] end)
				return self:move(l[1][1], l[1][2], force)
			end
		else
			return self:move(lx, ly, force)
		end
	end
end

--- Responsible for clearing ai target if needed
function _M:clearAITarget()
	if self.ai_target.actor and self.ai_target.actor.dead then self.ai_target.actor = nil end
end

--- Main entry point for AIs
function _M:doAI()
	if not self.ai then return end
	if self.dead then return end
--	if self.x < game.player.x - 10 or self.x > game.player.x + 10 or self.y < game.player.y - 10 or self.y > game.player.y + 10 then return end

	-- If we have a target but it is dead (it was not yet garbage collected but it'll come)
	-- we forget it
	self:clearAITarget()

	-- Update the ai_target table
	local target_pos = self.ai_target.actor and self.fov and self.fov.actors and self.fov.actors[self.ai_target.actor]
	if target_pos then
		self.ai_state.target_last_seen = {x=target_pos.x, y=target_pos.y, turn=self.fov_last_turn}
	end

	return self:runAI(self.ai)
end

function _M:runAI(ai, ...)
	if not ai or not self.x then return end
	return _M.ai_def[ai](self, ...)
end

--- Returns the current target
function _M:getTarget(typ)
	local tx, ty = self:aiSeeTargetPos(self.ai_target.actor)
	local target = game.level.map(tx, ty, Map.ACTOR)
	return tx, ty, target
end

--- Sets the current target
function _M:setTarget(target, last_seen)
	self.ai_target.actor = target
	if last_seen then
		self.ai_state.target_last_seen = last_seen
	else
		local target_pos = target and self.fov and self.fov.actors and self.fov.actors[self.ai_target.actor] or {x=self.x, y=self.y}
		self.ai_state.target_last_seen = {x=target_pos.x, y=target_pos.y, turn=game.turn}
	end
end

--- Returns the seen coords of the target
-- This will usually return the exact coords, but if the target is only partially visible (or not at all)
-- it will return estimates, to throw the AI a bit off
-- @param target the target we are tracking
-- @return x, y coords to move/cast to
function _M:aiSeeTargetPos(target)
	if not target then return self.x, self.y end
	local tx, ty = target.x, target.y
	local spread = 0

	-- Adding some type-safety checks, but this isn't fixing the source of the errors
	if target == self.ai_target.actor and self.ai_state.target_last_seen and type(self.ai_state.target_last_seen) == "table" and self.ai_state.target_last_seen.x and not self:hasLOS(self.ai_state.target_last_seen.x, self.ai_state.target_last_seen.y) then
		tx, ty = self.ai_state.target_last_seen.x, self.ai_state.target_last_seen.y
		spread = spread + math.floor((game.turn - (self.ai_state.target_last_seen.turn or game.turn)) / (game.energy_to_act / game.energy_per_tick))
	end
	
	local see, chance = self:canSee(target)

	-- Compute the maximum spread if we need to obfuscate 
	local spread = see and 0 or math.floor((100 - chance) / 10)
	

	-- We don't know the exact position, so we obfuscate
	if spread > 0 then
		tx = tx + rng.range(0, spread * 2) - spread
		ty = ty + rng.range(0, spread * 2) - spread
		return util.bound(tx, 0, game.level.map.w - 1), util.bound(ty, 0, game.level.map.h - 1)
	-- Directly seeing it, no spread at all
	else
		return util.bound(tx, 0, game.level.map.w - 1), util.bound(ty, 0, game.level.map.h - 1)
	end
end
