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

name = "Falling Toward Apotheosis"
desc = function(self, who)
	local desc = {}

	if not self:isCompleted() then
		desc[#desc+1] = "You have vanquished the masters of the Orc Pride, now you must venture inside the most dangerous place of this world, the High Peak."
		desc[#desc+1] = "Seek the Sorcerers and stop them before they bend the world to their will."
		desc[#desc+1] = "To enter you will need the four orbs of command to remove the shield over the peak."
		desc[#desc+1] = "The entrance to the peak passes through a place called 'the slime tunnels', probably located inside or near Grushnak Pride."
	else
		desc[#desc+1] = "You have reached the summit of the High Peak, entered the sanctum of the Sorcerers and destroyed them, freeing the world from the threat of evil."
		desc[#desc+1] = "You have won the game!"
	end

	if self:isCompleted("killed-aeryn") then desc[#desc+1] = "#LIGHT_GREEN#* You encountered Sun Paladin Aeryn who blamed you for the loss of the Sunwall and killed her.#LAST#" end
	if self:isCompleted("spared-aeryn") then desc[#desc+1] = "#LIGHT_GREEN#* You encountered Sun Paladin Aeryn who blamed you for the loss of the Sunwall and spared her.#LAST#" end

	if game.winner and game.winner == "full" then desc[#desc+1] = "#LIGHT_GREEN#* You defeated the Sorcerers before the Void portal could open.#LAST#" end
	if game.winner and game.winner == "aeryn-sacrifice" then desc[#desc+1] = "#LIGHT_GREEN#* You defeated the Sorcerers and Aeryn sacrified herself to close the Void portal.#LAST#" end
	if game.winner and game.winner == "self-sacrifice" then desc[#desc+1] = "#LIGHT_GREEN#* You defeated the Sorcerers and sacrified yourself to close the Void portal.#LAST#" end

	return table.concat(desc, "\n")
end

on_grant = function(self, who)
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("elandar-dead") and self:isCompleted("argoniel-dead") then
			who:setQuestStatus(self.id, engine.Quest.DONE)

			-- Remove all remaining hostiles
			for i = #game.level.e_array, 1, -1 do
				local e = game.level.e_array[i]
				if game.player:reactionToward(e) < 0 then game.level:removeEntity(e) end
			end

			self:end_end_combat()

			local Chat = require"engine.Chat"
			local chat = Chat.new("sorcerer-end", {name="Endgame"}, game.player)
			chat:invoke()
		end
	end
end

function start_end_combat(self)
	-- Allow teleporting inside
	for i = 11, 38 do for j = 1, 21 do
		game.level.map.lites(i, j, true)
		game.level.map.attrs(i, j, "no_teleport", false)
	end end
	-- Forbid teleporting outside
	for i = 0, game.level.map.w - 1 do for j = 22, game.level.map.h - 1 do
		game.level.map.attrs(i, j, "no_teleport", true)
	end end
	game.level.allow_portals = true
end

function end_end_combat(self)
	local floor = game.zone:makeEntityByName(game.level, "terrain", "FLOOR")
	for i = 8, 13 do
		game.level.map(i, 11, engine.Map.TERRAIN, floor)
	end
	for i = 36, 41 do
		game.level.map(i, 11, engine.Map.TERRAIN, floor)
	end
	game.level.allow_portals = false

	local nb_portal = 0
	if self:isCompleted("closed-portal-demon") then nb_portal = nb_portal + 1 end
	if self:isCompleted("closed-portal-dragon") then nb_portal = nb_portal + 1 end
	if self:isCompleted("closed-portal-elemental") then nb_portal = nb_portal + 1 end
	if self:isCompleted("closed-portal-undead") then nb_portal = nb_portal + 1 end
	if nb_portal == 0 then world:gainAchievement("SORCERER_NO_PORTAL", game.player)
	elseif nb_portal == 1 then world:gainAchievement("SORCERER_ONE_PORTAL", game.player)
	elseif nb_portal == 2 then world:gainAchievement("SORCERER_TWO_PORTAL", game.player)
	elseif nb_portal == 3 then world:gainAchievement("SORCERER_THREE_PORTAL", game.player)
	elseif nb_portal == 4 then world:gainAchievement("SORCERER_FOUR_PORTAL", game.player)
	end
end

function failed_charred_scar(self, level)
	local aeryn = game.zone:makeEntityByName(level, "actor", "FALLEN_SUN_PALADIN_AERYN")
	game.zone:addEntity(level, aeryn, "actor", level.default_down.x, level.default_down.y)
	game.logPlayer(game.player, "#LIGHT_RED#As you enter the level you hear a familiar voice.")
	game.logPlayer(game.player, "#LIGHT_RED#Fallen Sun Paladin Aeryn: '%s YOU BROUGHT ONLY DESTRUCTION TO THE SUNWALL! YOU WILL PAY!'", game.player.name:upper())

	local level = game.memory_levels["wilderness-1"]
	local spot = level:pickSpot{type="quest-pop", "ruined-gates-of-morning"}
	local wild = game.memory_levels["wilderness-1"].map(spot.x, spot.y, engine.Map.TERRAIN)
	wild.name = "Ruins of the Gates of Morning"
	wild.desc = "The sunwall was destroyed while you were trapped in the High Peak."
	wild.change_level = nil
	wild.change_zone = nil
	game.player:setQuestStatus(self.id, engine.Quest.COMPLETED, "gates-of-morning-destroyed")
end

function win(self, how)
	game:playMusic("Lords of the Sky.ogg")

	if how == "full" then world:gainAchievement("WIN_FULL", game.player)
	elseif how == "aeryn-sacrifice" then world:gainAchievement("WIN_AERYN", game.player)
	elseif how == "self-sacrifice" then world:gainAchievement("WIN_SACRIFICE", game.player)
	end

	game.player.winner = how
	game:registerDialog(require("engine.dialogs.ShowText").new("Winner", "win", {playername=game.player.name, how=how}, game.w * 0.6))
end

