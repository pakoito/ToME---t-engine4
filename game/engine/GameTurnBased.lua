require "engine.class"
require "engine.GameEnergyBased"

--- Defines a turn based game
-- If this class is not used the game is realtime.
-- This game type pauses the ticking as long as its paused property is true.<br/>
-- To use it make your player "act" method set the game property paused to true and when an action is made to false
-- @inherit engine.GameEnergyBased
module(..., package.seeall, class.inherit(engine.GameEnergyBased))

--- See engine.GameEnergyBased
function _M:init(keyhandler, energy_to_act, energy_per_tick)
	self.paused = false
	engine.GameEnergyBased.init(self, keyhandler, energy_to_act, energy_per_tick)
end

function _M:tick()
	while not self.paused do
		engine.GameEnergyBased.tick(self)
	end
end
