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
	desc[#desc+1] = "Investigate the bastions of the Pride."

	if self:isCompleted("rak-shor") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have destroyed Rak'shor.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* Rak'shor Pride, in the south west of the High Peek#WHITE#"
	end
	if self:isCompleted("eastport") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have killed the master of Easport.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* A group of corrupted humans live in Eastport on the southern costline, they have contact with the Pride#WHITE#"
	end
	if self:isCompleted("vor") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have destroyed Vor.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* Vor Pride, in the north east#WHITE#"
	end
	if self:isCompleted("grushnak") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have destroyed Grushnak.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* Grushnak Pride, whose location remains unknown#WHITE#"
	end
	if self:isCompleted("gorbat") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have destroyed Gorbat.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* Gorbat Pride, in the southern desert#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	-- Reveal entrances
	local g = mod.class.Grid.new{
		show_tooltip=true,
		name="Entrance to Rak'shor Pride bastion",
		display='>', color=colors.UMBER,
		notice = true,
		change_level=1, change_zone="rak-shor-pride"
	}
	g:resolve() g:resolve(nil, true)
	game.zone:addEntity(game.memory_levels["wilderness-arda-fareast-1"], g, "terrain", 38, 49)
	game.logPlayer(game.player, "Aeryn points the known locations on your map.")
end
