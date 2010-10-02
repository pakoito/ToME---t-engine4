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
	[1] = {left=2, right=4},
	[2] = {left=3, right=1},
	[3] = {left=6, right=2},
	[4] = {left=1, right=7},
	[6] = {left=9, right=3},
	[7] = {left=4, right=8},
	[8] = {left=7, right=9},
	[9] = {left=8, right=6},
}

local turn =
{
	[1] = {left=3, right=7},
	[2] = {left=6, right=4},
	[3] = {left=9, right=1},
	[4] = {left=2, right=8},
	[6] = {left=8, right=2},
	[7] = {left=1, right=9},
	[8] = {left=4, right=6},
	[9] = {left=7, right=3},
}

local function checkDir(a, dir, dist)
	dist = dist or 1
	local dx, dy = dir_to_coord[dir][1], dir_to_coord[dir][2]
	local x, y = a.x + dx * dist, a.y + dy * dist
	return game.level.map:checkAllEntities(x, y, "block_move", a) and true or false
end
local function isEdge(a, dir, dist)
	dist = dist or 1
	local dx, dy = dir_to_coord[dir][1], dir_to_coord[dir][2]
	local x, y = a.x + dx * dist, a.y + dy * dist
	return not game.level.map:isBound(x, y) and true or false
end

--- Initializes running
-- We check the direction sides to know if we are in a tunnel, along a wall or in open space.
function _M:runInit(dir)
	local block_left, block_right = false, false

	-- Check sides
	if checkDir(self, sides[dir].left) then block_left = true end
	if checkDir(self, sides[dir].right) then block_right = true end

	self.running = {
		dir = dir,
		block_left = block_left,
		block_right = block_right,
		cnt = 1,
		dialog = Dialog:simplePopup("Running...", "You are running, press any key to stop.", function()
			self:runStop()
		end),
	}
	self.running.dialog.__showup = nil

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
		end),
	}
	self.running.dialog.__showup = nil

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
		if self.running.path then
			if not self.running.path[self.running.cnt] then self:runStop()
			else self:move(self.running.path[self.running.cnt].x, self.running.path[self.running.cnt].y) end
		else
			if isEdge(self, self.running.dir) then self:runStop()
			else self:moveDir(self.running.dir) end
		end
		self:runMoved()

		-- Did not move ? no use in running
		if self.x == oldx and self.y == oldy then self:runStop() end

		if not self.running then return false end
		self.running.cnt = self.running.cnt + 1

		if self.running.newdir then
			self.running.dir = self.running.newdir
			self.running.newdir = nil
		end
		if self.running.ignore_left then
			self.running.ignore_left = self.running.ignore_left - 1
			if self.running.ignore_left <= 0 then self.running.ignore_left = nil end
		end
		if self.running.ignore_right then
			self.running.ignore_right = self.running.ignore_right - 1
			if self.running.ignore_right <= 0 then self.running.ignore_right = nil end
		end

		return true
	end
end

--- Can we continue running ?
-- Rewrite this method to hostiles, interresting terrain, whatever.
-- This method should be called by its submethod, it tries to detect changes in the terrain.<br/>
-- It will also try to follow tunnels when they simply change direction.
-- @return true if we can continue to run, false otherwise
function _M:runCheck()
	if not self.running.path then
		-- Do we change run direction ? We can only choose to change for left or right, never backwards.
		-- We must also be in a tunnel (both sides blocked)
		if self.running.block_left and self.running.block_right then
			-- Turn left
			if not checkDir(self, self.running.dir) and checkDir(self, self.running.dir, 2) and not checkDir(self, sides[self.running.dir].left) and checkDir(self, sides[self.running.dir].right) then
				self.running.newdir = turn[self.running.dir].left
				self.running.ignore_left = 2
				return true
			end

			-- Turn right
			if not checkDir(self, self.running.dir) and checkDir(self, self.running.dir, 2) and checkDir(self, sides[self.running.dir].left) and not checkDir(self, sides[self.running.dir].right) then
				self.running.newdir = turn[self.running.dir].right
				self.running.ignore_right = 2
				return true
			end
		end

		if not self.running.ignore_left and self.running.block_left ~= checkDir(self, sides[self.running.dir].left) then return false, "terrain change on left side" end
		if not self.running.ignore_right and self.running.block_right ~= checkDir(self, sides[self.running.dir].right) then return false, "terrain change on right side" end
		if checkDir(self, self.running.dir) then return false, "terrain ahead blocks" end
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
	fct(self.x, self.y)
	if not self.running.path then
		-- Ahead
		local dx, dy = dir_to_coord[self.running.dir][1], dir_to_coord[self.running.dir][2]
		local x, y = self.x + dx, self.y + dy
		fct(x, y)

		-- Ahead left
		local dx, dy = dir_to_coord[sides[self.running.dir].left][1], dir_to_coord[sides[self.running.dir].left][2]
		local x, y = self.x + dx, self.y + dy
		fct(x, y)

		-- Ahead right
		local dx, dy = dir_to_coord[sides[self.running.dir].right][1], dir_to_coord[sides[self.running.dir].right][2]
		local x, y = self.x + dx, self.y + dy
		fct(x, y)
	elseif self.running.path[self.running.cnt] then
		-- Ahead
		local x, y = self.running.path[self.running.cnt].x, self.running.path[self.running.cnt].y
		fct(x, y)
	end
end

--- Called after running a step
function _M:runMoved()
end
