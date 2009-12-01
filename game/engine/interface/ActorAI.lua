require "engine.class"

--- Handles actors artificial intelligence (or dumbness ... ;)
module(..., package.seeall, class.make)

function _M:init(t)
	self.ai_state = {}
	self.ai_target = {}
	-- Make the table with weak values, so that threat list does not prevent garbage collection
	setmetatable(self.ai_target, {__mode='v'})
end

function _M:aiFindTarget()
	self.target = game.player
end

function _M:onTakeHit(value, src)
end

--- Main entry point for AIs
function _M:doAI()
	local l = line.new(self.x, self.y, self.target.x, self.target.y)
	self:move()
end
