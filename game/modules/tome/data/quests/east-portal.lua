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

name = "Back and there again"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You have created a portal back to Maj'Eyal. You should try to talk to someone in Last Hope about establishing a link back."

	if self:isCompleted("talked-elder") then
		desc[#desc+1] = "You talked to the Elder in Last Hope who in turn told you to talk to Tannen, who lives in the north of the city."
	end

	if self:isCompleted("gave-orb") then
		desc[#desc+1] = "You gave the Orb of Many Ways to Tannen for study while you look for the athame and diamond in Reknor."
	end
	if self:isCompleted("withheld-orb") then
		desc[#desc+1] = "You kept the Orb of Many Ways despite Tannen's request to study it. You must now look for the athame and diamond in Reknor."
	end
	if self:isCompleted("open-telmur") then
		desc[#desc+1] = "You brought back the diamond and athame to Tannen who asked you to check the tower of Telmur, looking for a text of portals, although he is not sure it is even there. He told you to come back in a few days."
	end
	if self:isCompleted("ask-east") then
		desc[#desc+1] = "You brought back the diamond and athame to Tannen who asked you to check contact Zemekkys to ask some delicate questions."
	end
	if self:isCompleted("just-wait") then
		desc[#desc+1] = "You brought back the diamond and athame to Tannen who asked you to come back in a few days."
	end
	if self:isCompleted("tricked-demon") then
		desc[#desc+1] = "Tannen has tricked you! He swapped the orb for a false one that brought you to a demonic plane. Find the exit, and get revenge!"
	end
	if self:isCompleted("trapped") then
		desc[#desc+1] = "Tannen revealed himself as the vile scum he really is and trapped you in his tower."
	end

	if self:isCompleted() then
		desc[#desc+1] = ""
		desc[#desc+1] = "#LIGHT_GREEN#* The portal to the Far East is now functional and can be used to go back.#WHITE#"
	end

	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("orb-back") and self:isCompleted("diamon-back") and self:isCompleted("athame-back") then
			self:tannen_exit(who)
		end
	end
end

create_portal = function(self, npc, player)
	self:remove_materials(player)

	-- Farportal
	local g = mod.class.Grid.new{
		name = "Farportal: Gates of Morning",
		display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET,
		notice = true,
		always_remember = true,
		show_tooltip = true,
		desc = [[A farportal is a way to travel incredible distances in the blink of an eye. They usually require an external item to use.
This one seems to go near the Gates of Morning in the Far East.]],

		orb_portal = {
			change_level = 1,
			change_zone = "wilderness",
			change_wilderness = {
				spot = {type="farportal-end", subtype="gates-of-morning"},
			},
			message = "#VIOLET#You enter the swirling portal and in the blink of an eye you set foot in sight of the Gates of Morning, with no trace of the portal...",
			on_use = function(self, who)
			end,
		},
	}
	g:resolve() g:resolve(nil, true)

	game.zone:addEntity(game.level, g, "terrain", 13, 43)
	game.level.map:particleEmitter(13, 43, 3, "farportal_lightning")
	game.level.map:particleEmitter(13, 43, 3, "farportal_lightning")
	game.level.map:particleEmitter(13, 43, 3, "farportal_lightning")

	player:setQuestStatus(self.id, engine.Quest.DONE)
	world:gainAchievement("EAST_PORTAL", game.player)
end

give_orb = function(self, player)
	player:setQuestStatus(self.id, engine.Quest.COMPLETED, "gave-orb")

	local orb_o, orb_item, orb_inven_id = player:findInAllInventories("Orb of Many Ways")
	player:removeObject(orb_inven_id, orb_item, true)
	orb_o:removed()
end

withheld_orb = function(self, player)
	player:setQuestStatus(self.id, engine.Quest.COMPLETED, "withheld-orb")
end

remove_materials = function(self, player)
	local gem_o, gem_item, gem_inven_id = player:findInAllInventories("Resonating Diamond")
	player:removeObject(gem_inven_id, gem_item, true)
	gem_o:removed()

	local athame_o, athame_item, athame_inven_id = player:findInAllInventories("Blood-Runed Athame")
	player:removeObject(athame_inven_id, athame_item, true)
	athame_o:removed()
end

open_telmur = function(self, player)
	self:remove_materials(player)

	-- Reveal entrances
	local g = mod.class.Grid.new{
		show_tooltip=true, always_remember = true,
		name="Entrance into Telmur, tower of Telos",
		display='>', color=colors.RED,
		notice = true,
		change_level=1, change_zone="telmur"
	}
	g:resolve() g:resolve(nil, true)
	local level = game.memory_levels["wilderness-1"]
	local spot = level:pickSpot{type="zone-pop", subtype="telmur"}
	game.zone:addEntity(level, g, "terrain", spot.x, spot.y)

	game.logPlayer(game.player, "Tannen points to the location of Telmur on your map.")
	player:setQuestStatus(self.id, engine.Quest.COMPLETED, "open-telmur")
	self.wait_turn = game.turn + game.calendar.DAY * 3
end

ask_east = function(self, player)
	self:remove_materials(player)

	-- Swap the orbs! Tricky bastard!
	local orb_o, orb_item, orb_inven_id = player:findInAllInventories("Orb of Many Ways")
	player:removeObject(orb_inven_id, orb_item, true)
	orb_o:removed()

	local demon_orb = game.zone:makeEntityByName(game.level, "object", "ORB_MANY_WAYS_DEMON")
	player:addObject(orb_inven_id, demon_orb)
	demon_orb:added()

	player:setQuestStatus(self.id, engine.Quest.COMPLETED, "ask-east")
end

tannen_tower = function(self, player)
	game:changeLevel(1, "tannen-tower")
	player:setQuestStatus(self.id, engine.Quest.COMPLETED, "trapped")
end

tannen_exit = function(self, player)
	require("engine.ui.Dialog"):simplePopup("Back and there again", "A portal appears in the center of the tower!")
	local g = game.zone:makeEntityByName(game.level, "terrain", "PORTAL_BACK")
	game.zone:addEntity(game.level, g, "terrain", 12, 12)
end

back_to_last_hope = function(self)
	-- TP last hope
	game:changeLevel(1, "town-last-hope")
	-- Move to the portal spot
	game.player:move(12, 43, true)
	-- Remove tannen
	game.level.map(10, 6, engine.Map.TERRAIN, game.level.map(10, 5, engine.Map.TERRAIN))

	-- Add the mage
	local g = mod.class.NPC.new{
		name="Meranas, Herald of Angolwen",
		type="humanoid", subtype="human", faction="angolwen",
		display='p', color=colors.RED,
	}
	g:resolve() g:resolve(nil, true)
	game.zone:addEntity(game.level, g, "actor", 12, 42)
	game.level.map:particleEmitter(12, 42, 1, "teleport")

	local Chat = require("engine.Chat")
	local chat = Chat.new("east-portal-end", g, game.player)
	chat:invoke()
	game.logPlayer(who, "#VIOLET#You enter the swirling portal and in the blink of an eye you are back to Last Hope.")
end
