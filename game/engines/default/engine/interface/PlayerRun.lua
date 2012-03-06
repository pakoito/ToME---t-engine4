-- TE4 - T-Engine 4
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

require "engine.class"
local Dialog = require "engine.ui.Dialog"

--- Handles player running
-- This should work for running inside tunnel, alongside walls, in open spaces.<br/>
module(..., package.seeall, class.make)

local function checkDir(a, dir, dist)
	dist = dist or 1
	local x, y = a.x, a.y
	for i = 1, dist do x, y = util.coordAddDir(x, y, dir) end
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
	local sides = util.dirSides(dir, self.x, self.y)
	if sides then
		if checkDir(self, sides.hard_left) then self.running.block_hard_left = true end
		if checkDir(self, sides.hard_right) then self.running.block_hard_right = true end

		if checkDir(self, sides.left) then
			self.running.block_left = true
		else
			self.running.ignore_left = 2
		end

		if checkDir(self, sides.right) then
			self.running.block_right = true
		else
			self.running.ignore_right = 2
		end
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
		game.logPlayer(self, "You don't see how to get there...")
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
	if not ret and (self.running.cnt > 1 or self.running.busy) then
		self:runStop(msg)
		return false
	else
		local oldx, oldy = self.x, self.y
		if self.running.path then
			if self.running.explore and self.checkAutoExplore and not self:checkAutoExplore() then
				self:runStop()
			elseif not self.running.path[self.running.cnt] then
				self:runStop()
			else
				-- Allow auto-explore to perform actions other than movement, which should be performed
				-- or setup in "checkAutoExplore".  Hence, modules can make auto-explore borg-like if desired.
				-- For example, non-move actions can be picking up an item, using a talent, resting, etc.
				-- Some actions can require moving into a tile, such as opening a door or bump-attacking an enemy.
				-- "self.running.cnt" is not incremented while "self.running.busy" exists.
				if not self.running.busy or self.running.busy.do_move then
					self:move(self.running.path[self.running.cnt].x, self.running.path[self.running.cnt].y)
				end
				self:runMoved()
				-- Did not move ? no use in running unless we were busy
				if self.running and not self.running.busy and self.x == oldx and self.y == oldy then
					self:runStop("didn't move")
				end
			end
			if not self.running then return false end
		else
			-- Try to move around known traps if possible
			local dir_is_cardinal = self.running.dir == 2 or self.running.dir == 4 or self.running.dir == 6 or self.running.dir == 8
			local sides = util.dirSides(self.running_dir, self.x, self.y)
			local dx, dy = util.dirToCoord(self.running.dir, self.x, self.y)
			local x, y = util.coordAddDir(self.x, self.y, self.running.dir)
			local trap = game.level.map(x, y, game.level.map.TRAP)
			if trap and trap:knownBy(self) then
				-- Take a phantom step forward and check path; backup current data first
				local running_bak = table.clone(self.running)
				self.x, self.y = x, y
				local ret2, msg2 = self:runCheck(true) -- don't remember other items or traps from phantom steps
				local sides_bak = util.dirSides(running_bak.dir, self.x, self.y)
				local sides_dir = util.dirSides(self.running.dir, self.x, self.y)
				if self.running.dir == sides_bak.hard_left then
					running_bak.dir = sides_bak.left
				elseif self.running.dir == sides_bak.hard_right then
					running_bak.dir = sides_bak.right
				else
					ret2 = false
				end
				if self.running.ignore_left then
					running_bak.ignore_left = running_bak.ignore_left - 1
					if running_bak.ignore_left <= 0 then running_bak.ignore_left = nil end
					if checkDir(self, sides_dir.left) and (not checkDir(self, self.running.dir) or not dir_is_cardinal) then running_bak.block_left = true end
				end
				if self.running.ignore_right then
					running_bak.ignore_right = running_bak.ignore_right - 1
					if running_bak.ignore_right <= 0 then running_bak.ignore_right = nil end
					if checkDir(self, sides_dir.right) and (not checkDir(self, self.running.dir) or not dir_is_cardinal) then running_bak.block_right = true end
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
			self:runMoved()
			-- Did not move ? no use in running
			if self.x == oldx and self.y == oldy then self:runStop() end
			if not self.running then return false end

			local sides = util.dirSides(self.running.dir, self.x, self.y)
			if self.running.block_left then self.running.ignore_left = nil end
			if self.running.ignore_left then
				self.running.ignore_left = self.running.ignore_left - 1
				if self.running.ignore_left <= 0 then
					self.running.ignore_left = nil
					-- We do this check here because it is path/time dependent, not terrain configuration dependent
					if dir_is_cardinal and checkDir(self, sides.left) and checkDir(self, self.running.dir, 2) then
						self:runStop("terrain change on the left")
						return false
					end
				end
				if checkDir(self, sides.left) and (not checkDir(self, self.running.dir) or not dir_is_cardinal) then self.running.block_left = true end
			end
			if self.running.block_right then self.running.ignore_right = nil end
			if self.running.ignore_right then
				self.running.ignore_right = self.running.ignore_right - 1
				if self.running.ignore_right <= 0 then
					self.running.ignore_right = nil
					-- We do this check here because it is path/time dependent, not terrain configuration dependent
					if dir_is_cardinal and checkDir(self, sides.right) and checkDir(self, self.running.dir, 2) then
						self:runStop("terrain change on the right")
						return false
					end
				end
				if checkDir(self, sides.right) and (not checkDir(self, self.running.dir) or not dir_is_cardinal) then self.running.block_right = true end
			end

		end
		if not self.running then return false end
		if not self.running.busy then
			self.running.cnt = self.running.cnt + 1
		elseif self.running.busy.no_energy then
			return self:runStep()
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
		local sides = util.dirSides(self.running.dir, self.x, self.y)
		local blocked_left = checkDir(self, sides.left)
		local blocked_hard_left = checkDir(self, sides.hard_left)
		local blocked_right = checkDir(self, sides.right)
		local blocked_hard_right = checkDir(self, sides.hard_right)

		-- Do we change run direction ? We can only choose to change for left or right, never backwards.
		-- We must also be in a tunnel (both sides blocked)
		if (self.running.block_left or self.running.ignore_left) and (self.running.block_right or self.running.ignore_right) then
			if blocked_ahead then
				if blocked_right and (blocked_hard_right or self.running.ignore_right) then
					local back_left_x, back_left_y = util.coordAddDir(self.x, self.y, sides.hard_left)
					local blocked_back_left = checkDir(self, util.dirSides(sides.hard_left, back_left_x, back_left_y).left)
					-- Turn soft left
					if not blocked_left and (blocked_hard_left or not dir_is_cardinal) then
						if not dir_is_cardinal and not blocked_hard_left and not (checkDir(self, sides.left, 2) and blocked_back_left) then
							return false, "terrain changed ahead"
						end
						self.running.dir = util.dirSides(self.running.dir, self.x, self.y).left
						self.running.block_right = true
						if blocked_hard_left then self.running.block_left = true end
						return true
					end
					-- Turn hard left
					if not blocked_hard_left and (not self.running.ignore_left or (self.running.block_hard_left and self.running.block_right)) then
						if dir_is_cardinal and not blocked_left and not checkDir(self, sides.hard_left, 2) then
							return false, "terrain change on the left"
						end
						if not dir_is_cardinal and not blocked_back_left then
							return false, "terrain ahead blocks"
						end
						self.running.dir = sides.hard_left
						if self.running.block_hard_left and self.running.ignore_left and self.running.ignore_left == 1 then
							self.running.block_left = true
						end
						return true
					end
				end

				if blocked_left and (blocked_hard_left or self.running.ignore_left) then
					local back_right_x, back_right_y = util.coordAddDir(self.x, self.y, sides.hard_right)
					local blocked_back_right = checkDir(self, util.dirSides(sides.hard_right, back_right_x, back_right_y).right)
					-- Turn soft right
					if not blocked_right and (blocked_hard_right or not dir_is_cardinal) then
						if not dir_is_cardinal and not blocked_hard_right and not (checkDir(self, sides.right, 2) and blocked_back_right) then
							return false, "terrain changed ahead"
						end
						self.running.dir = sides.right
						self.running.block_left = true
						if blocked_hard_right then self.running.block_right = true end
						return true
					end
					-- Turn hard right
					if not blocked_hard_right and (not self.running.ignore_right or (self.running.block_hard_right and self.running.block_left)) then
						if dir_is_cardinal and not blocked_right and not checkDir(self, sides.hard_right, 2) then
							return false, "terrain change on the right"
						end
						if not dir_is_cardinal and not blocked_back_right then
							return false, "terrain ahead blocks"
						end
						self.running.dir = sides.hard_right
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
					if blocked_right and blocked_hard_left and not blocked_left and (blocked_hard_right or self.running.ignore_right) and (not self.running.ignore_left or self.running.ignore_left ~= 2) then
						if checkDir(self, sides.left, 2) then
							self.running.dir = sides.left
							self.running.block_left = true
							self.running.block_right = true
							return true
						else
							return false, "terrain changed ahead"
						end
					end
					-- Turn soft right
					if blocked_left and blocked_hard_right and not blocked_right and (blocked_hard_left or self.running.ignore_left) and (not self.running.ignore_right or self.running.ignore_right ~= 2) then
						if checkDir(self, sides.right, 2) then
							self.running.dir = sides.right
							self.running.block_left = true
							self.running.block_right = true
							return true
						else
							return false, "terrain changed ahead"
						end
					end
				end
				if checkDir(self, self.running.dir, 2) then
					if not dir_is_cardinal and ((self.running.block_left and not blocked_hard_left and not self.running.ignore_left) or (self.running.block_right and not blocked_hard_right and not self.running.ignore_right)) then
						return false, "terrain changed ahead"
					end
					-- Continue forward so we may turn
					if (blocked_left and not blocked_right) or (blocked_right and not blocked_left) then return true end
				end
			end
		end

		if not self.running.ignore_left and (self.running.block_left ~= blocked_left or self.running.block_left ~= blocked_hard_left) then
			return false, "terrain change on left side"
		end
		if not self.running.ignore_right and (self.running.block_right ~= blocked_right or self.running.block_right ~= blocked_hard_right) then
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

	if not msg and self.running.explore and self.running.path and self.running.cnt == #self.running.path + 1 then
		msg = "at " .. self.running.explore
	end
	if msg then
		game.log("Ran for %d turns (stop reason: %s).", self.running.cnt, msg)
	end

	self:runStopped(self.running.cnt, msg)
	self.running = nil
	return true
end

--- Scan the run direction and sides with the given function
function _M:runScan(fct)
	fct(self.x, self.y, "self")
	if not self.running.path then
		-- Ahead
		local dx, dy = util.dirToCoord(self.running.dir, self.x, self.y)
		local x, y = self.x + dx, self.y + dy
		fct(x, y, "ahead")

		local sides = util.dirSides(self.running.dir, self.x, self.y)
		if sides then 
			-- Ahead left
			local dx, dy = util.dirToCoord(sides.left, self.x, self.y)
			local x, y = self.x + dx, self.y + dy
			fct(x, y, "ahead left")

			-- Ahead right
			local dx, dy = util.dirToCoord(sides.right, self.x, self.y)
			local x, y = self.x + dx, self.y + dy
			fct(x, y, "ahead right")

			-- Left
			local dx, dy = util.dirToCoord(sides.hard_left, self.x, self.y)
			local x, y = self.x + dx, self.y + dy
			fct(x, y, "left")

			-- Right
			local dx, dy = util.dirToCoord(sides.hard_right, self.x, self.y)
			local x, y = self.x + dx, self.y + dy
			fct(x, y, "right")
		end

	elseif self.running.path[self.running.cnt] then
		-- Ahead
		local x, y = self.running.path[self.running.cnt].x, self.running.path[self.running.cnt].y
		fct(x, y, "ahead")
	end
end

--- Called after running a step
function _M:runMoved()
end

--- Called after stopping running
function _M:runStopped()
end
