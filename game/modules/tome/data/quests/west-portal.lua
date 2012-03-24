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

name = "There and back again"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Zemekkys in the Gates of Morning can build a portal back to Maj'Eyal for you."

	if self:isCompleted("athame") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have found a Blood-Runed Athame.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* Find a Blood-Runed Athame.#WHITE#"
	end
	if self:isCompleted("gem") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have found the Resonating Diamond.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* Find a Resonating Diamond.#WHITE#"
	end

	if self:isCompleted() then
		desc[#desc+1] = ""
		desc[#desc+1] = "#LIGHT_GREEN#* The portal to Maj'Eyal is now functional and can be used to go back, although, like all portals, it is one-way only.#WHITE#"
	end

	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	-- Reveal entrances
	game:onLevelLoad("wilderness-1", function(zone, level)
		local g = game.zone:makeEntityByName(level, "terrain", "VOR_ARMOURY")
		local spot = level:pickSpot{type="zone-pop", subtype="vor-armoury"}
		game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
		game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
		game.state:locationRevealAround(spot.x, spot.y)
	end)

	game.logPlayer(game.player, "Zemekkys points to the location of Vor Armoury on your map.")
end

wyrm_lair = function(self, who)
	-- Reveal entrances
	game:onLevelLoad("wilderness-1", function(zone, level)
		local g = game.zone:makeEntityByName(level, "terrain", "BRIAGH_LAIR")
		local spot = level:pickSpot{type="zone-pop", subtype="briagh"}
		game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
		game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
	end)

	game.logPlayer(game.player, "Zemekkys points to the location of Briagh lair on your map.")
end

create_portal = function(self, npc, player)
	-- Farportal
	local g1 = game.zone:makeEntityByName(game.level, "terrain", "WEST_PORTAL")
	local g2 = game.zone:makeEntityByName(game.level, "terrain", "CWEST_PORTAL")

	game.logPlayer(game.player, "#VIOLET#Zemekkys starts to draw runes on the floor using the athame and gem dust.")
	game.logPlayer(game.player, "#VIOLET#The whole area starts to shake!")
	game.logPlayer(game.player, "#VIOLET#Zemekkys says: 'The portal is done!'")

	-- Zemekkys is not in his home anymore
	npc.block_move = true

	-- Add Zemekkys near the portal
	local zemekkys = mod.class.NPC.new{
		type = "humanoid", subtype = "elf",
		display = "p", color=colors.AQUAMARINE,
		name = "High Chronomancer Zemekkys",
		size_category = 3, rank = 3,
		ai = "none",
		faction = "sunwall",
		can_talk = "zemekkys-done",
	}
	zemekkys:resolve() zemekkys:resolve(nil, true)

	local spot = game.level:pickSpot{type="pop-quest", subtype="farportal-npc"}
	game.zone:addEntity(game.level, zemekkys, "actor", spot.x, spot.y)

	local spot = game.level:pickSpot{type="pop-quest", subtype="farportal"}
	game.zone:addEntity(game.level, g1, "terrain", spot.x, spot.y)
	game.zone:addEntity(game.level, g1, "terrain", spot.x+1, spot.y)
	game.zone:addEntity(game.level, g1, "terrain", spot.x+2, spot.y)
	game.zone:addEntity(game.level, g1, "terrain", spot.x, spot.y+1)
	game.zone:addEntity(game.level, g2, "terrain", spot.x+1, spot.y+1)
	game.zone:addEntity(game.level, g1, "terrain", spot.x+2, spot.y+1)
	game.zone:addEntity(game.level, g1, "terrain", spot.x, spot.y+2)
	game.zone:addEntity(game.level, g1, "terrain", spot.x+1, spot.y+2)
	game.zone:addEntity(game.level, g1, "terrain", spot.x+2, spot.y+2)

	local spot = game.level:pickSpot{type="pop-quest", subtype="farportal-player"}
	player:move(spot.x, spot.y, true)

	player:setQuestStatus(self.id, engine.Quest.DONE)
	world:gainAchievement("WEST_PORTAL", game.player)
	player:grantQuest("east-portal")
end
