require "engine.class"
require "engine.GameEnergyBased"
module(..., package.seeall, class.inherit(engine.GameEnergyBased))

function _M:init(keyhandler, energy_to_act, energy_per_tick)
	self.paused = false
	engine.GameEnergyBased.init(self, keyhandler, energy_to_act, energy_per_tick)
end

function _M:tick()
	while not self.paused do
		engine.GameEnergyBased.tick(self)
	end
end
