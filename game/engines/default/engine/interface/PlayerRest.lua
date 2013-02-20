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
local Dialog = require "engine.ui.Dialog"

--- Handles player resting
module(..., package.seeall, class.make)

--- Initializes resting
function _M:restInit(turns, what, past, on_end, on_very_end)
	what = what or "resting"
	past = past or "rested"
	self.resting = {
		rest_turns = turns,
		past = past,
		on_end = on_end,
		on_very_end = on_very_end,
		cnt = 0,
		dialog = Dialog:simplePopup(what:capitalize().."...", "You are "..what..", press Enter to stop.", function()
			self:restStop()
		end),
	}
	self.resting.dialog.__showup = nil

	game.log(what:capitalize().." starts...")

	self:onRestStart()

	local ret, msg = self:restCheck()
	if ret and self.resting and self.resting.rest_turns and self.resting.cnt > self.resting.rest_turns then ret = false msg = nil end
	if not ret then
		self:restStop(msg)
	else
		self:useEnergy()
		self.resting.cnt = self.resting.cnt + 1
	end
end

--- We started resting
-- Rewrite this method to do whatever you need
function _M:onRestStart()
end

--- We stopped resting
-- Rewrite this method to do whatever you need
function _M:onRestStop()
end

--- Rest a turn
-- For a turn based game you want in you player's act() something like that:<br/>
-- <pre>
-- if not self:restStep() then game.paused = true end
-- </pre>
-- @return true if we can continue to rest, false otherwise
function _M:restStep()
	if not self.resting then return false end

	local ret, msg = self:restCheck()
	if ret and self.resting and self.resting.rest_turns and self.resting.cnt > self.resting.rest_turns then ret = false msg = nil end
	if not ret then
		self:restStop(msg)
		return false
	else
		self:useEnergy()
		self.resting.cnt = self.resting.cnt + 1
		return true
	end
end

--- Can we continue resting ?
-- Rewrite this method to check for mana, life, whatever. By default we always return false so resting will never work
-- @return true if we can continue to rest, false otherwise
function _M:restCheck()
	return false, "player:restCheck() method not defined"
end

--- Stops resting
function _M:restStop(msg)
	if not self.resting then return false end

	game:unregisterDialog(self.resting.dialog)

	if msg then
		game.log(self.resting.past:capitalize().." for %d turns (stop reason: %s).", self.resting.cnt, msg)
	else
		game.log(self.resting.past:capitalize().." for %d turns.", self.resting.cnt)
	end

	local finish = self.resting.cnt and self.resting.rest_turns and self.resting.cnt > self.resting.rest_turns
	local on_very_end = self.resting.on_very_end
	if self.resting.on_end then self.resting.on_end(self.resting.cnt, self.resting.rest_turns) end
	self:onRestStop()
	self.resting = nil
	if on_very_end then on_very_end(finish) end
	return true
end
