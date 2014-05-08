-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

return {
	frag = "crystalineaura",
	vert = nil,
	args = {
		displMapTex = { texture = 0 },
		normalMapTex = { texture = 1 },

		spikeLength = spikeLength or 1.0, -- 1.0 means normal length, 0.5 is half-sized spikes, 2.0 is double-sized, etc
		spikeWidth = spikeWidth or 1.0, -- use different values for different effects. 1.0 is normal width
		spikeOffset = spikeOffset or 0.0, -- use different values for different effects. such as offset = 0.0 for ice spikes and 0.123123 for rock spikes

		growthSpeed = growthSpeed or 1.0, -- 1.0 is normal growth speed

		time_factor = time_factor or 500,

		color = color or {0.624, 0.820, 0.933},
	},
	resetargs = {
		tick_start = function() return core.game.getTime() end,
	},		
	clone = false,
}
