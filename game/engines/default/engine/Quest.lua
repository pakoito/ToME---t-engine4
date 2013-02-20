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

--- Handle quests
module(..., package.seeall, class.make)

PENDING = 0
COMPLETED = 1
DONE = 100
FAILED = 101

status_text = {
	[PENDING] = "active",
	[COMPLETED] = "completed",
	[DONE] = "done",
	[FAILED] = "failed",
}

function _M:init(q, who)
	for k, e in pairs(q) do
		self[k] = e
	end
	self.status = PENDING
	self.objectives = {}
	if self:check("on_grant", who) then self.do_not_gain = true end
end

--- Checks if the quest (or sub-objective) is complete
-- @param sub a subobjective id or nil for the whole quest
-- @return true or false
function _M:isCompleted(sub)
	if sub then
		if self.objectives[sub] and self.objectives[sub] == COMPLETED then return true else return false end
	end
	if self.status == COMPLETED then return true else return false end
end

--- Checks if the quest is ended (DONE or FAILED)
-- @return true or false
function _M:isEnded()
	if self.status == DONE or self.status == FAILED then return true else return false end
end

--- Check for an quest property
-- If not a function it returns it directly, otherwise it calls the function
-- with the extra parameters
-- @param prop the property name to check
function _M:check(prop, ...)
	if type(self[prop]) == "function" then return self[prop](self, ...)
	else return self[prop]
	end
end

--- Sets the quests status or sub-objective status
-- @param status one of the possible quest status (PENDING, COMPLETED, DONE, FAILED)
function _M:setStatus(status, sub, who)
	if sub then
		if self.objectives[sub] and self.objectives[sub] == status then return false end
		self.objectives[sub] = status
		self:check("on_status_change", who, status, sub)
		return true
	else
		if self.status == status then return false end
		self.status = status
		self:check("on_status_change", who, status)
		return true
	end
end

--- Checks the quests status or sub-objective status
-- @param status one of the possible quest status (PENDING, COMPLETED, DONE, FAILED)
function _M:isStatus(status, sub)
	if sub then
		if self.objectives[sub] and self.objectives[sub] == status then return true end
		return false
	else
		if self.status == status then return true end
		return false
	end
end
