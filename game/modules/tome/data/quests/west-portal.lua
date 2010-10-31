-- ToME - Tales of Maj'Eyal
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
		desc[#desc+1] = "#LIGHT_GREEN#* The portal to Maj'Eyal is now functional and can be used to go back, although, as all portals, it is one-way only.#WHITE#"
	end

	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	-- Reveal entrances
	local g = mod.class.Grid.new{
		show_tooltip=true,
		name="Backdoor to the Vor Armoury",
		display='>', color=colors.UMBER,
		notice = true,
		change_level=1, change_zone="vor-armoury"
	}
	g:resolve() g:resolve(nil, true)
	local level = game.memory_levels["wilderness-1"]
	local spot = level:pickSpot{type="quest-pop", "vor-armoury"}
	game.zone:addEntity(level, g, "terrain", spot.x, spot.y)

	game.logPlayer(game.player, "Zemekkys points the location of Vor Armoury on your map.")
end

wyrm_lair = function(self, who)
	-- Reveal entrances
	local g = mod.class.Grid.new{
		show_tooltip=true,
		name="Entrance into the sandpit of Briagh",
		display='>', color=colors.YELLOW,
		notice = true,
		change_level=1, change_zone="briagh-lair"
	}
	g:resolve() g:resolve(nil, true)
	local level = game.memory_levels["wilderness-1"]
	local spot = level:pickSpot{type="quest-pop", "briagh"}
	game.zone:addEntity(level, g, "terrain", spot.x, spot.y)

	game.logPlayer(game.player, "Zemekkys points the location of Briagh lair on your map.")
end

create_portal = function(self, npc, player)
	-- Farportal
	local g = mod.class.Grid.new{
		name = "Farportal: Last Hope",
		display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET,
		notice = true,
		always_remember = true,
		show_tooltip = true,
		desc = [[A farportal is a way to travel incredible distances in the blink of an eye. They usually require an external item to use.
This one seems to go near the town of Last Hope in Maj'Eyal.]],

		orb_portal = {
			change_level = 1,
			change_zone = "wilderness",
			change_wilderness = {
				x = 60, y = 54,
			},
			message = "#VIOLET#You enter the swirling portal and in the blink of an eye you set foot on the outskirts of Last Hope, with no trace of the portal...",
			on_use = function(self, who)
			end,
		},
	}
	g:resolve() g:resolve(nil, true)

	game.logPlayer(game.player, "#VIOLET#Zemekkys starts to draw runes on the floor using the athame and gem dust.")
	game.logPlayer(game.player, "#VIOLET#The whole area starts to shake!")
	game.logPlayer(game.player, "#VIOLET#Zemekkys says: 'The portal is done!'")

	-- Zemekkys is not in his home anymore
	npc.on_move = nil

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

	game.zone:addEntity(game.level, zemekkys, "actor", 41, 17)
	game.zone:addEntity(game.level, g, "terrain", 41, 16)
	game.level.map:particleEmitter(41, 16, 3, "farportal_lightning")
	game.level.map:particleEmitter(41, 16, 3, "farportal_lightning")
	game.level.map:particleEmitter(41, 16, 3, "farportal_lightning")
	player:move(40, 16, true)

	player:setQuestStatus(self.id, engine.Quest.DONE)
	world:gainAchievement("WEST_PORTAL", game.player)
	player:grantQuest("east-portal")
end
