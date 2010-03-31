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
	self.turn = 0
	self.paused = false
	engine.GameEnergyBased.init(self, keyhandler, energy_to_act, energy_per_tick)
end

function _M:tick()
	if self.paused then
		-- Auto unpause if the player has no energy to act
		if game:getPlayer() and not game:getPlayer():enoughEnergy() then game.paused = false end

		-- If we are paused do not get energy, but still process frames if needed
		engine.Game.tick(self)
	else
		engine.GameEnergyBased.tick(self)
		self.turn = self.turn + 1
		self:onTurn()
	end
end

--- Called every game turns
-- Does nothing, you can override it
function _M:onTurn()
end
