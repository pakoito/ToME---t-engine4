-- ToME - Tales of Maj'Eyal
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

defineTile('.', "FLOOR")
defineTile('#', "WALL")
defineTile('+', "DOOR")
defineTile('>', "DOOR")
quickEntity('>', {
	always_remember = true,
	show_tooltip=true,
	name="Long tunnel to the island of Rel",
	display='>',
	image = "terrain/marble_floor.png", add_displays = {mod.class.Grid.new{image="terrain/stair_down.png"}},
	color=colors.VIOLET,
	change_level_check = function()
		local p = game.party:findMember{main=true}
		-- Only yeeks can pass
		if p.descriptor and p.descriptor.race and p.descriptor.race == "Yeek" then
			game:onLevelLoad("wilderness-1", function(zone, level)
				local p = game:getPlayer(true)
				local spot = level:pickSpot{type="zone-pop", subtype="rel-tunnel"}
				p.wild_x = spot.x
				p.wild_y = spot.y
			end)
			return
		end
		require("engine.ui.Dialog"):simplePopup("Long tunnel", "As you enter the tunnel you feel a strange compulsion to go backward.")
		return true
	end,
	notice = true,
	change_level=1,
	change_zone="wilderness"
})
defineTile('Z', "FLOOR", nil, "SUBJECT_Z")
defineTile('Y', "FLOOR", nil, "YEEK_WAYIST")

subGenerator{
	x = 0, y = 0, w = 50, h = 43,
	generator = "engine.generator.map.Roomer",
	data = {
		nb_rooms = 10,
		rooms = {"random_room"},
		['.'] = "FLOOR",
		['#'] = "WALL",
		up = "UP",
		door = "DOOR",
		force_tunnels = {
			{"random", {26, 43}, id=-500},
		},
	},
	define_up = true,
}

endx = 48
endy = 46

checkConnectivity({26,44}, "entrance", "boss-area", "boss-area")

return {
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[                                                  ]],
[[#########################+########################]],
[[##..............................................##]],
[[#........................Z.......................#]],
[[#...............................................>#]],
[[#........................Y.......................#]],
[[##..............................................##]],
[[##################################################]]
}
