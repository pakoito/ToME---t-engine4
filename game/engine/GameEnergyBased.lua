require "engine.class"
require "engine.Game"

--- A game type that gives each entities energy
-- When an entity reaches an energy level it is allowed to act (it calls the entity"s "act" method)
-- @inherit engine.Game
module(..., package.seeall, class.inherit(engine.Game))

--- Setup the game
-- @param keyhandler the default keyhandler for this game
-- @energy_to_act how much energy does an entity need to act
-- @energy_per_tick how much energy does an entity recieves per game tick. This is multiplied by the entity energy.mod property
function _M:init(keyhandler, energy_to_act, energy_per_tick)
	self.energy_to_act, self.energy_per_tick = energy_to_act, energy_per_tick
	engine.Game.init(self, keyhandler)
end

--- Gives energy and act if needed
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
