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

name = "The many Prides of the Orcs"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Investigate the bastions of the Pride."

	if self:isCompleted("rak-shor") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have destroyed Rak'shor.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* Rak'shor Pride, in the west of the southern desert.#WHITE#"
	end
--[[
	if self:isCompleted("eastport") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have killed the master of Eastport.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* A group of corrupted Humans live in Eastport on the southern coastline. They have contact with the Pride.#WHITE#"
	end
]]
	if self:isCompleted("vor") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have destroyed Vor.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* Vor Pride, in the north east.#WHITE#"
	end
	if self:isCompleted("grushnak") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have destroyed Grushnak.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* Grushnak Pride, near a small mountain range in the north west.#WHITE#"
	end
	if self:isCompleted("gorbat") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have destroyed Gorbat.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* Gorbat Pride, in a mountain range in the southern desert.#WHITE#"
	end

	if self:isCompleted() then
		desc[#desc+1] = ""
		desc[#desc+1] = "#LIGHT_GREEN#* All the bastions of the Pride lie in ruins, their masters destroyed. High Sun Paladin Aeryn would surely be glad of the news!#WHITE#"
	end

	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	-- Reveal entrances
	game:onLevelLoad("wilderness-1", function(zone, level)
		local g = game.zone:makeEntityByName(level, "terrain", "RAK_SHOR_PRIDE")
		local spot = level:pickSpot{type="zone-pop", subtype="rak-shor-pride"}
		game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
		game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
		game.state:locationRevealAround(spot.x, spot.y)

		g = game.zone:makeEntityByName(level, "terrain", "VOR_PRIDE")
		local spot = level:pickSpot{type="zone-pop", subtype="vor-pride"}
		game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
		game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
		game.state:locationRevealAround(spot.x, spot.y)

		g = game.zone:makeEntityByName(level, "terrain", "GORBAT_PRIDE")
		local spot = level:pickSpot{type="zone-pop", subtype="gorbat-pride"}
		game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
		game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
		game.state:locationRevealAround(spot.x, spot.y)

		g = game.zone:makeEntityByName(level, "terrain", "GRUSHNAK_PRIDE")
		local spot = level:pickSpot{type="zone-pop", subtype="grushnak-pride"}
		game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
		game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
		game.state:locationRevealAround(spot.x, spot.y)
	end)
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("rak-shor") and self:isCompleted("vor") and self:isCompleted("grushnak") and self:isCompleted("gorbat") then
			who:setQuestStatus(self.id, engine.Quest.COMPLETED)
			world:gainAchievement("ORC_PRIDE", game.player)
		end
	end
end
