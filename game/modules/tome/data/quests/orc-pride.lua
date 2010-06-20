-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

name = "The many Prides of the Orcs"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "The known bastions of the Pride are:"
	desc[#desc+1] = "- Rak'shor Pride, in the south west of the High Peek"
	desc[#desc+1] = "- Gorbat Pride, in the southern desert"
	desc[#desc+1] = "- Vor Pride, in the north east"
	desc[#desc+1] = "- Grushnak Pride, which we could never locate, we only heard evasive rumours about it"
	desc[#desc+1] = "- A group of corrupted humans live in Eastport on the southen costline, they have contact wit the Pride"
	return table.concat(desc, "\n")
end

--[[
on_grant = function(self, who)
	-- Reveal moria entrance
	local g = mod.class.Grid.new{
		show_tooltip=true,
		name="A gate into the mines of Moria",
		display='>', color=colors.UMBER,
		notice = true,
		change_level=1, change_zone="moria"
	}
	g:resolve() g:resolve(nil, true)
	game.zone:addEntity(game.memory_levels["wilderness-1"], g, "terrain", 44, 28)
	game.logPlayer(game.player, "The elder points the mines on your map, to the north on the western side of the misty mountains.")
end
]]
