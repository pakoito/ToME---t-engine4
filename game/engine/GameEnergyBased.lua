require "engine.class"
require "engine.Game"
module(..., package.seeall, class.inherit(engine.Game))

function _M:init(keyhandler, energy_to_act, energy_per_tick)
	self.energy_to_act, self.energy_per_tick = energy_to_act, energy_per_tick
	engine.Game.init(self, keyhandler)
end

function _M:tick()
	engine.Game.tick(self)

	-- Give some energy to entities
	if self.level then
		for uid, e in pairs(self.level.entities) do
			if e.energy and e.energy.value < self.energy_to_act then
				e.energy.value = (e.energy.value or 0) + self.energy_per_tick * (e.energy.mod or 1)
--				print(e.uid, e.energy.value)
				if e.energy.value >= self.energy_to_act and e.act then
					e:act(self)
				end
			end
		end
	end
end
