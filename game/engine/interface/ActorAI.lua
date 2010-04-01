-- TE4 - T-Engine 4
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

require "engine.class"
require "engine.Actor"
local Map = require "engine.Map"

--- Handles actors artificial intelligence (or dumbness ... ;)
module(..., package.seeall, class.make)

_M.ai_def = {}

--- Deinfe AI
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
	self.ai_target = {}
	self:autoLoadedAI()
end

function _M:autoLoadedAI()
	-- Make the table with weak values, so that threat list does not prevent garbage collection
	setmetatable(self.ai_target, {__mode='v'})
end

local coords = {
	[1] = { 4, 2, 7, 3 },
	[2] = { 1, 3, 4, 6 },
	[3] = { 2, 6, 1, 9 },
	[4] = { 7, 1, 8, 2 },
	[5] = {},
	[6] = { 9, 3, 8, 2 },
	[7] = { 4, 8, 1, 9 },
	[8] = { 7, 9, 4, 6 },
	[9] = { 8, 6, 7, 3 },
}

function _M:aiCanPass(x, y)
	-- Nothing blocks, just go on
	if not game.level.map:checkAllEntities(x, y, "block_move", self) then return true end

	-- If there is an otehr actor, check hostility, if hostile, we move to attack
	local target = game.level.map(x, y, Map.ACTOR)
	if target and self:reactionToward(target) < 0 then return true end

	-- If there is a target (not hostile) and we can move it, do so
	if target and self:attr("move_body") then return true end

	return false
end

--- Move one step to the given target if possible
-- This tries the most direct route, if not available it checks sides and always tries to get closer
function _M:moveDirection(x, y)
	local l = line.new(self.x, self.y, x, y)
	local lx, ly = l()
	if lx and ly then
		local target = game.level.map(lx, ly, Map.ACTOR)

		-- if we are blocked, try some other way
		if not self:aiCanPass(lx, ly) then
			local dirx = lx - self.x
			local diry = ly - self.y
			local dir = coord_to_dir[dirx][diry]

			local list = coords[dir]
			local l = {}
			-- Find posiblities
			for i = 1, #list do
				local dx, dy = self.x + dir_to_coord[list[i]][1], self.y + dir_to_coord[list[i]][2]
				if self:aiCanPass(dx, dy) then
					l[#l+1] = {dx,dy, (dx-x)^2 + (dy-y)^2}
				end
			end
			-- Move to closest
			if #l > 0 then
				table.sort(l, function(a,b) return a[3]<b[3] end)
				return self:move(l[1][1], l[1][2])
			end
		else
			return self:move(lx, ly)
		end
	end
end

--- Main entry point for AIs
function _M:doAI()
	if not self.ai then return end
--	if self.x < game.player.x - 10 or self.x > game.player.x + 10 or self.y < game.player.y - 10 or self.y > game.player.y + 10 then return end

	-- If we have a target but it is dead (it was not yet garbage collected but it'll come)
	-- we forget it
	if self.ai_target.actor and self.ai_target.actor.dead then self.ai_target.actor = nil end

	return self:runAI(self.ai)
end

function _M:runAI(ai)
	return _M.ai_def[ai](self)
end

--- Returns the current target
function _M:getTarget(typ)
	local tx, ty = self:aiSeeTargetPos(self.ai_target.actor)
	return tx, ty, self.ai_target.actor
end

--- Sets the current target
function _M:setTarget(target)
	self.ai_target.actor = target
end

--- Returns the seen coords of the target
-- This will usualy return the exact coords, but if the target is only partialy visible (or not at all)
-- it will return estimates, to throw the AI a bit off
-- @param target the target we are tracking
-- @return x, y coords to move/cast to
function _M:aiSeeTargetPos(target)
	local tx, ty = target.x, target.y
	local see, chance = self:canSee(target)

	-- Directly seeing it, no spread at all
	if see then
		return tx, ty
	-- Ok we can see it, spread coords around, the less chance to see it we had the more we spread
	else
		chance = math.floor((100 - chance) / 10)
		tx = tx + rng.range(0, chance * 2) - chance
		ty = ty + rng.range(0, chance * 2) - chance
		return tx, ty
	end
end
