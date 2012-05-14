-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
require "engine.GameEnergyBased"

--- Defines a turn based game
-- If this class is not used the game is realtime.
-- This game type pauses the ticking as long as its paused property is true.<br/>
-- To use it make your player "act" method set the game property paused to true and when an action is made to false
-- @inherit engine.GameEnergyBased
module(..., package.seeall, class.inherit(engine.GameEnergyBased))

can_pause = true

--- See engine.GameEnergyBased
function _M:init(keyhandler, energy_to_act, energy_per_tick)
	self.paused = false
	engine.GameEnergyBased.init(self, keyhandler, energy_to_act, energy_per_tick)
end

function _M:tick()
	if self.paused then
		-- Auto unpause if the player has no energy to act
		if self:getPlayer() and not self:getPlayer():enoughEnergy() then self.paused = false end

		-- If we are paused do not get energy, but still process frames if needed
		engine.Game.tick(self)
	else
		engine.GameEnergyBased.tick(self)
	end
end
