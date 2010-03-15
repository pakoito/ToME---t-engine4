require "engine.class"
local ActorAI = require "engine.interface.ActorAI"
local ActorFOV = require "engine.interface.ActorFOV"
require "mod.class.Actor"

module(..., package.seeall, class.inherit(mod.class.Actor, engine.interface.ActorAI, engine.interface.ActorFOV))

function _M:init(t, no_default)
	mod.class.Actor.init(self, t, no_default)
	ActorAI.init(self, t)
	ActorFOV.init(self, t)
end

function _M:act()
	-- Do basic actor stuff
	if not mod.class.Actor.act(self) then return end

	-- Let the AI think .... beware of Shub !
	-- If AI did nothing, use energy anyway
	self:doAI()
	if not self.energy.used then self:useEnergy() end

	-- Compute FOV, if needed
	self:computeFOV(self.sight or 20)
end

--- Called by ActorLife interface
-- We use it to pass aggression values to the AIs
function _M:onTakeHit(value, src)
	if not self.ai_target.actor then
		self.ai_target.actor = src
	end

	return mod.class.Actor.onTakeHit(self, value, src)
end

function _M:tooltip()
	local str = mod.class.Actor.tooltip(self)
	return str..("\nTarget: %s\nUID: %d"):format(self.ai_target.actor and self.ai_target.actor.name or "none", self.uid)
end
