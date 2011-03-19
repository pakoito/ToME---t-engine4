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
local Dialog = require "engine.ui.Dialog"

--- Handles player running
-- This should work for running inside tunnel, alongside walls, in open spaces.<br/>
module(..., package.seeall, class.make)

local sides =
{
	[1] = {hard_left=3, soft_left=2, soft_right=4, hard_right=7},
	[4] = {hard_left=2, soft_left=1, soft_right=7, hard_right=8},
	[7] = {hard_left=1, soft_left=4, soft_right=8, hard_right=9},
	[8] = {hard_left=4, soft_left=7, soft_right=9, hard_right=6},
	[9] = {hard_left=7, soft_left=8, soft_right=6, hard_right=3},
	[6] = {hard_left=8, soft_left=9, soft_right=3, hard_right=2},
	[3] = {hard_left=9, soft_left=6, soft_right=2, hard_right=1},
	[2] = {hard_left=6, soft_left=3, soft_right=1, hard_right=4},
}

local function checkDir(a, dir, dist)
	dist = dist or 1
	local dx, dy = dir_to_coord[dir][1], dir_to_coord[dir][2]
	local x, y = a.x + dx * dist, a.y + dy * dist
	-- don't treat other actors as terrain or as something to notice (let the module handle this)
	if game.level.map(x, y, game.level.map.ACTOR) and not game.level.map:checkEntity(x, y, game.level.map.TERRAIN, "block_move") then return false end
	return (game.level.map:checkAllEntities(x, y, "block_move", a) or not game.level.map:isBound(x, y)) and true or false
end

--- Initializes running
-- We check the direction sides to know if we are in a tunnel, along a wall or in open space.
function _M:runInit(dir)
	if checkDir(self, dir) then return end

	self.running = {
		dir = dir,
		block_left = false,
		block_right = false,
		block_hard_left = false,
		block_hard_right = false,
		cnt = 1,
		dialog = Dialog:simplePopup("Running...", "You are running, press Enter to stop.", function()
			self:runStop()
		end, false, true),
	}

	-- Check sides
	if checkDir(self, sides[dir].hard_left) then self.running.block_hard_left = true end
	if checkDir(self, sides[dir].hard_right) then self.running.block_hard_right = true end

	if checkDir(self, sides[dir].soft_left) then
		self.running.block_left = true
	else
		self.running.ignore_left = 2
	end

	if checkDir(self, sides[dir].soft_right) then
		self.running.block_right = true
	else
		self.running.ignore_right = 2
	end

	self.running.dialog.__showup = nil
	self.running.dialog.__hidden = true

	self:runStep()
end

--- Initializes running to a specific position using the given path
-- This does not use the normal running algorithm
function _M:runFollow(path)
	local found = false
	local runpath = {}

	-- Find ourself along the path
	for i, c in ipairs(path) do
		if found then runpath[#runpath+1] = c
		elseif c.x == self.x and c.y == self.y then found = true end
	end

	if #runpath == 0 then
		game.logPlayer(self, "Invalid running path.")
		return
	end

	self.running = {
		path = runpath,
		cnt = 1,
		dialog = Dialog:simplePopup("Running...", "You are running, press any key to stop.", function()
			self:runStop()
		end, false, true),
	}
	self.running.dialog.__showup = nil
	self.running.dialog.__hidden = true

	self:runStep()
end

--- Run a turn
-- For a turn based game you want in you player's act() something like that:<br/>
-- <pre>
-- if not self:runStep() then game.paused = true end
-- </pre><br/>
-- This will move the actor using the :move() method, this SHOULD have been redefined by the module
-- to use energy, otherwise running will be free.
-- @return true if we can continue to run, false otherwise
function _M:runStep()
	if not self.running then return false end

	local ret, msg = self:runCheck()
	if not ret and self.running.cnt > 1 then
		self:runStop(msg)
		return false
	else
		local oldx, oldy = self.x, self.y
		local dir_is_cardinal = self.running.dir == 2 or self.running.dir == 4 or self.running.dir == 6 or self.running.dir == 8
		if self.running.path then
			if not self.running.path[self.running.cnt] then self:runStop()
			else self:move(self.running.path[self.running.cnt].x, self.running.path[self.running.cnt].y) end
		else
			-- Try to move around known traps if possible
			local dx, dy = dir_to_coord[self.running.dir][1], dir_to_coord[self.running.dir][2]
			local x, y = self.x + dx, self.y + dy
			local trap = game.level.map(x, y, game.level.map.TRAP)
			if trap and trap:knownBy(self) then
				-- Take a phantom step forward and check path; backup current data first
				local running_bak = table.clone(self.running)
				self.x, self.y = x, y
				local ret2, msg2 = self:runCheck(true) -- don't remember other items or traps from phantom steps
				if self.running.dir == sides[running_bak.dir].hard_left then
					running_bak.dir = sides[running_bak.dir].soft_left
				elseif self.running.dir == sides[running_bak.dir].hard_right then
					running_bak.dir = sides[running_bak.dir].soft_right
				else
					ret2 = false
				end
				if self.running.ignore_left then
					running_bak.ignore_left = running_bak.ignore_left - 1
					if running_bak.ignore_left <= 0 then running_bak.ignore_left = nil end
					if checkDir(self, sides[self.running.dir].soft_left) and (not checkDir(self, self.running.dir) or not dir_is_cardinal) then running_bak.block_left = true end
				end
				if self.running.ignore_right then
					running_bak.ignore_right = running_bak.ignore_right - 1
					if running_bak.ignore_right <= 0 then running_bak.ignore_right = nil end
					if checkDir(self, sides[self.running.dir].soft_right) and (not checkDir(self, self.running.dir) or not dir_is_cardinal) then running_bak.block_right = true end
				end
				if self.running.block_left then running_bak.ignore_left = nil end
				if self.running.block_right then running_bak.ignore_right = nil end
				-- Put data back
				self.x, self.y = oldx, oldy
				self.running = running_bak
				-- Can't run around the trap
				if not ret2 then
					self:runStop("trap spotted")
					return false
				end
			end
			-- Move!
			self:moveDir(self.running.dir)
		end
		self:runMoved()

		-- Did not move ? no use in running
		if self.x == oldx and self.y == oldy then self:runStop() end

		if not self.running then return false end
		self.running.cnt = self.running.cnt + 1

		if self.running.block_left then self.running.ignore_left = nil end
		if self.running.ignore_left then
			self.running.ignore_left = self.running.ignore_left - 1
			if self.running.ignore_left <= 0 then self.running.ignore_left = nil end
			if checkDir(self, sides[self.running.dir].soft_left) and (not checkDir(self, self.running.dir) or not dir_is_cardinal) then self.running.block_left = true end
		end
		if self.running.block_right then self.running.ignore_right = nil end
		if self.running.ignore_right then
			self.running.ignore_right = self.running.ignore_right - 1
			if self.running.ignore_right <= 0 then self.running.ignore_right = nil end
			if checkDir(self, sides[self.running.dir].soft_right) and (not checkDir(self, self.running.dir) or not dir_is_cardinal) then self.running.block_right = true end
		end

		return true
	end
end

--- Can we continue running ?
-- Rewrite this method to hostiles, interesting terrain, whatever.
-- This method should be called by its submethod, it tries to detect changes in the terrain.<br/>
-- It will also try to follow tunnels when they simply change direction.
-- @return true if we can continue to run, false otherwise
function _M:runCheck()
	if not self.running.path then
		local dir_is_cardinal = self.running.dir == 2 or self.running.dir == 4 or self.running.dir == 6 or self.running.dir == 8
		local blocked_ahead = checkDir(self, self.running.dir)
		local blocked_soft_left = checkDir(self, sides[self.running.dir].soft_left)
		local blocked_hard_left = checkDir(self, sides[self.running.dir].hard_left)
		local blocked_soft_right = checkDir(self, sides[self.running.dir].soft_right)
		local blocked_hard_right = checkDir(self, sides[self.running.dir].hard_right)

		-- Do we change run direction ? We can only choose to change for left or right, never backwards.
		-- We must also be in a tunnel (both sides blocked)
		if (self.running.block_left or self.running.ignore_left) and (self.running.block_right or self.running.ignore_right) then
			if blocked_ahead then
				if blocked_soft_right and (blocked_hard_right or self.running.ignore_right) then
					local blocked_back_left = checkDir(self, sides[sides[self.running.dir].hard_left].soft_left)
					-- Turn soft left
					if not blocked_soft_left and (blocked_hard_left or not dir_is_cardinal) then
						if not dir_is_cardinal and not blocked_hard_left and not (checkDir(self, sides[self.running.dir].soft_left, 2) and blocked_back_left) then
							return false, "terrain changed ahead"
						end
						self.running.dir = sides[self.running.dir].soft_left
						self.running.block_right = true
						if blocked_hard_left then self.running.block_left = true end
						return true
					end
					-- Turn hard left
					if not blocked_hard_left and (not self.running.ignore_left or (self.running.block_hard_left and self.running.block_right)) then
						if dir_is_cardinal and not blocked_soft_left and not checkDir(self, sides[self.running.dir].hard_left, 2) then
							return false, "terrain change on the left"
						end
						if not dir_is_cardinal and not blocked_back_left then
							return false, "terrain ahead blocks"
						end
						self.running.dir = sides[self.running.dir].hard_left
						if self.running.block_hard_left and self.running.ignore_left and self.running.ignore_left == 1 then
							self.running.block_left = true
						end
						return true
					end
				end

				if blocked_soft_left and (blocked_hard_left or self.running.ignore_left) then
					local blocked_back_right = checkDir(self, sides[sides[self.running.dir].hard_right].soft_right)
					-- Turn soft right
					if not blocked_soft_right and (blocked_hard_right or not dir_is_cardinal) then
						if not dir_is_cardinal and not blocked_hard_right and not (checkDir(self, sides[self.running.dir].soft_right, 2) and blocked_back_right) then
							return false, "terrain changed ahead"
						end
						self.running.dir = sides[self.running.dir].soft_right
						self.running.block_left = true
						if blocked_hard_right then self.running.block_right = true end
						return true
					end
					-- Turn hard right
					if not blocked_hard_right and (not self.running.ignore_right or (self.running.block_hard_right and self.running.block_left)) then
						if dir_is_cardinal and not blocked_soft_right and not checkDir(self, sides[self.running.dir].hard_right, 2) then
							return false, "terrain change on the right"
						end
						if not dir_is_cardinal and not blocked_back_right then
							return false, "terrain ahead blocks"
						end
						self.running.dir = sides[self.running.dir].hard_right
						if self.running.block_hard_right and self.running.ignore_right and self.running.ignore_right == 1 then
							self.running.block_right = true
						end
						return true
					end
				end
			else
				-- Favor cardinal directions if possible, otherwise we may miss something interesting
				if not dir_is_cardinal then
					-- Turn soft left
					if blocked_soft_right and blocked_hard_left and not blocked_soft_left and checkDir(self, sides[self.running.dir].soft_left, 2) and (not self.running.ignore_left or self.running.ignore_left ~= 2) then
						self.running.dir = sides[self.running.dir].soft_left
						self.running.block_left = true
						self.running.block_right = true
						return true
					end
					-- Turn soft right
					if blocked_soft_left and blocked_hard_right and not blocked_soft_right and checkDir(self, sides[self.running.dir].soft_right, 2) and (not self.running.ignore_right or self.running.ignore_right ~= 2) then
						self.running.dir = sides[self.running.dir].soft_right
						self.running.block_left = true
						self.running.block_right = true
						return true
					end
				end
				if checkDir(self, self.running.dir, 2) then
					if not dir_is_cardinal and ((self.running.block_left and not blocked_hard_left and not self.running.ignore_left) or (self.running.block_right and not blocked_hard_right and not self.running.ignore_right)) then
						return false, "terrain changed ahead"
					end
					-- Continue forward so we may turn
					if (blocked_soft_left and not blocked_soft_right) or (blocked_soft_right and not blocked_soft_left) then return true end
				end
			end
		end
		
		if not self.running.ignore_left and (self.running.block_left ~= blocked_soft_left or self.running.block_left ~= blocked_hard_left) then
			return false, "terrain change on left side"
		end
		if not self.running.ignore_right and (self.running.block_right ~= blocked_soft_right or self.running.block_right ~= blocked_hard_right) then
			return false, "terrain change on right side"
		end
		if blocked_ahead then
			return false, "terrain ahead blocks"
		end
	end

	return true
end

--- Stops running
function _M:runStop(msg)
	if not self.running then return false end

	game:unregisterDialog(self.running.dialog)

	if msg then
		game.log("Ran for %d turns (stop reason: %s).", self.running.cnt, msg)
	end

	self.running = nil
	return true
end

--- Scan the run direction and sides with the given function
function _M:runScan(fct)
	fct(self.x, self.y, "self")
	if not self.running.path then
		-- Ahead
		local dx, dy = dir_to_coord[self.running.dir][1], dir_to_coord[self.running.dir][2]
		local x, y = self.x + dx, self.y + dy
		fct(x, y, "ahead")

		-- Ahead left
		local dx, dy = dir_to_coord[sides[self.running.dir].soft_left][1], dir_to_coord[sides[self.running.dir].soft_left][2]
		local x, y = self.x + dx, self.y + dy
		fct(x, y, "ahead left")

		-- Ahead right
		local dx, dy = dir_to_coord[sides[self.running.dir].soft_right][1], dir_to_coord[sides[self.running.dir].soft_right][2]
		local x, y = self.x + dx, self.y + dy
		fct(x, y, "ahead right")

		-- Left
		local dx, dy = dir_to_coord[sides[self.running.dir].hard_left][1], dir_to_coord[sides[self.running.dir].hard_left][2]
		local x, y = self.x + dx, self.y + dy
		fct(x, y, "left")

		-- Right
		local dx, dy = dir_to_coord[sides[self.running.dir].hard_right][1], dir_to_coord[sides[self.running.dir].hard_right][2]
		local x, y = self.x + dx, self.y + dy
		fct(x, y, "right")

	elseif self.running.path[self.running.cnt] then
		-- Ahead
		local x, y = self.running.path[self.running.cnt].x, self.running.path[self.running.cnt].y
		fct(x, y, "ahead")
	end
end

--- Called after running a step
function _M:runMoved()
end
