require "engine.class"
local ActorAI = require "engine.interface.ActorAI"
require "mod.class.Actor"

module(..., package.seeall, class.inherit(mod.class.Actor, engine.interface.ActorAI))

function _M:init(t)
	mod.class.Actor.init(self, t)
	ActorAI(self, t)
end

function _M:act()
	mod.class.Actor.act(self)
	ActorAI:doAI()
end

--- Called by ActorLife interface
-- We use it to pass aggression values to the AIs
function _M:onTakeHit(value, src)
	self:aiAddThreat(value, src)
end
