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

local src = version
local chance = src:knowTalent(src.T_BIAS_WEAVE) and src:callTalent(src.T_BIAS_WEAVE, "getBiasChance") or 0

local function set_bias(which)
	src.anomaly_bias = {}
	src.anomaly_bias = which
	state.set_bias = true
end

newChat{ id="welcome",
	text = [[What kind of anomaly do you prefer?]],
	answers = {
		{"Physical",
			action = function()
				game.level.map:particleEmitter(game.player.x, game.player.y, 1, "temporal_teleport")
			return set_bias({type = "physical", chance=chance}) 
			end,
		},
		{"Teleport", 
			action = function() 
				game.level.map:particleEmitter(game.player.x, game.player.y, 1, "temporal_teleport")
			return set_bias({type = "teleport", chance=chance})
			end,
		},
		{"Temporal",
			action = function()
				game.level.map:particleEmitter(game.player.x, game.player.y, 1, "temporal_teleport")
			return set_bias({type = "temporal", chance=chance})
			end,
		},
		{"Never mind"},
	}
}

return "welcome"