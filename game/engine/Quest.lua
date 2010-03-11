require "engine.class"

--- Handle quests
module(..., package.seeall, class.make)

PENDING = 0
COMPLETED = 1
DONE = 100
FAILED = 101

function _M:init(q)
	for k, e in pairs(q) do
		self[k] = e
	end
	self.status = PENDING
	self.objectives = {}
	self:check("on_grant", who)
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

--- Sets the quets status or sub-objective status
-- @param status one of the possible quest status (PENDING, COMPLETED, DONE, FAILED)
function _M:setStatus(status, sub, who)
	if sub then
		if self.objectives[sub] == status then return false end
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
