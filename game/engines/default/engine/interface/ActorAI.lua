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
		local tx, ty = self:aiSeeTargetPos(self.ai_target.actor)
		print("======")table.print(self.ai_state.target_last_seen or {})print("======")
		self.ai_state.target_last_seen=table.merge(self.ai_state.target_last_seen or {}, {x=tx, y=ty, turn=self.fov_last_turn}) -- Merge to keep obfuscation data
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
		print("===============+SETTING LAST SEEN ON", self.name, self.uid, " to last seen ", last_seen)
		util.show_traceback()
		self.ai_state.target_last_seen = last_seen
	else
		local target_pos = target and self.fov and self.fov.actors and self.fov.actors[self.ai_target.actor] or {x=self.x, y=self.y}
		self.ai_state.target_last_seen=table.merge(self.ai_state.target_last_seen or {}, {x=target_pos.x, y=target_pos.y, turn=game.turn}) -- Merge to keep obfuscation data
	end
end

--- Returns the seen coords of the target
-- This will usually return the exact coords, but if the target is only partially visible (or not at all)
-- it will return estimates, to throw the AI a bit off (up to 10 tiles error)
-- @param target the target we are tracking
-- @return x, y coords to move/cast to
function _M:aiSeeTargetPos(target)
	if not target then return self.x, self.y end
	local tx, ty = target.x, target.y
	local LSeen = self.ai_state.target_last_seen
	if type(LSeen) ~= "table" then return tx, ty end
	local spread = 0
	LSeen.GCache_turn = LSeen.GCache_turn or game.turn -- Guess Cache turn to update position guess (so it's consistent during a turn)
	LSeen.GCknown_turn = LSeen.GCknown_turn or game.turn -- Guess Cache known turn for spread calculation (self.ai_state.target_last_seen.turn can't be used because it's needed by FOV code)

	-- Check if target is currently seen
	local see, chance = self:canSee(target)
	if see and self:hasLOS(target.x, target.y) then -- canSee doesn't check LOS
		LSeen.GCache_x, LSeen.GCache_y = nil, nil
		LSeen.GCknown_turn = game.turn
		LSeen.GCache_turn = game.turn
	else
		if target == self.ai_target.actor and (LSeen.GCache_turn or 0) + 10 <= game.turn and LSeen.x then
			spread = spread + math.min(10, math.floor((game.turn - (LSeen.GCknown_turn or game.turn)) / (game.energy_to_act / game.energy_per_tick))) -- Limit spread to 10 tiles
			tx, ty = util.bound(tx + rng.range(-spread, spread), 0, game.level.map.w - 1), util.bound(ty + rng.range(-spread, spread), 0, game.level.map.h - 1)
			-- Inertial average with last guess: can specify another method here to make the targeting position less random
			if LSeen.GCache_x then -- update guess with new random position. Could use util.findFreeGrid here at cost of speed
				tx = math.floor(LSeen.GCache_x + (tx-LSeen.GCache_x)/2)
				ty = math.floor(LSeen.GCache_y + (ty-LSeen.GCache_y)/2)
			end
			LSeen.GCache_x, LSeen.GCache_y = tx, ty
			LSeen.GCache_turn = game.turn
		end
		if LSeen.GCache_x then return LSeen.GCache_x, LSeen.GCache_y end
	end
	return tx, ty -- Fall through to correct coords
end