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

name = "Falling Toward Apotheosis"
desc = function(self, who)
	local desc = {}

	if not self:isCompleted() then
		desc[#desc+1] = "You have vanquished the masters of the Orc Pride, now you must venture inside the most dangerous place of this world, the High Peak."
		desc[#desc+1] = "Seek the Blue Wizards and stop them before they bend the world to their will."
		desc[#desc+1] = "To enter you will need the four orbs of command to remove the shield over the peak."
		desc[#desc+1] = "The entrance to the peak passes through a place called 'the slime tunnels', probably located inside or near Grushnak Pride."
	else
		desc[#desc+1] = "You have reached the summit of the High Peak, entered the sanctum of the Istari and destroyed them, freeing the world from the threat of evil."
		desc[#desc+1] = "You have won the game!"
	end

	if self:isCompleted("killed-aeryn") then desc[#desc+1] = "#LIGHT_GREEN#* You encountered Sun Paladin Aeryn who blamed you for the loss of the Sunwall and killed her.#LAST#" end
	if self:isCompleted("spared-aeryn") then desc[#desc+1] = "#LIGHT_GREEN#* You encountered Sun Paladin Aeryn who blamed you for the loss of the Sunwall and spared her.#LAST#" end

	if game.winner and game.winner == "full" then desc[#desc+1] = "#LIGHT_GREEN#* You defeated the blue wizards before the Void portal could open.#LAST#" end
	if game.winner and game.winner == "aeryn-sacrifice" then desc[#desc+1] = "#LIGHT_GREEN#* You defeated the blue wizards and Aeryn sacrified herself to close the Void portal.#LAST#" end
	if game.winner and game.winner == "self-sacrifice" then desc[#desc+1] = "#LIGHT_GREEN#* You defeated the blue wizards and sacrified yourself to close the Void portal.#LAST#" end

	return table.concat(desc, "\n")
end

on_grant = function(self, who)
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("alatar-dead") and self:isCompleted("pallando-dead") then
			who:setQuestStatus(self.id, engine.Quest.DONE)

			-- Remove all remaining hostiles
			for i = #game.level.e_array, 1, -1 do
				local e = game.level.e_array[i]
				if game.player:reactionToward(e) < 0 then game.level:removeEntity(e) end
			end

			local Chat = require"engine.Chat"
			local chat = Chat.new("istari-end", {name="Endgame"}, game.player)
			chat:invoke()
		end
	end
end

function failed_mount_doom(self, level)
	local aeryn = game.zone:makeEntityByName(level, "actor", "FALLEN_SUN_PALADIN_AERYN")
	game.zone:addEntity(level, aeryn, "actor", level.default_down.x, level.default_down.y)
	game.logPlayer(game.player, "#LIGHT_RED#As you enter the level you hear a familiar voice.")
	game.logPlayer(game.player, "#LIGHT_RED#Fallen Sun Paladin Aeryn: '%s YOU BROUGHT ONLY DESTRUCTION TO THE SUNWALL! YOU WILL PAY!'", game.player.name:upper())

	local wild = game.memory_levels["wilderness-arda-fareast-1"].map(66, 35, engine.Map.TERRAIN)
	wild.name = "Ruins of the Gates of Morning"
	wild.desc = "The sunwall was destroyed while you were trapped in the High Peak."
	wild.change_level = nil
	wild.change_zone = nil
	game.player:setQuestStatus(self.id, engine.Quest.COMPLETED, "gates-of-morning-destroyed")
end

function win(self, how)
	if how == "full" then world:gainAchievement("WIN_FULL", game.player)
	elseif how == "aeryn-sacrifice" then world:gainAchievement("WIN_AERYN", game.player)
	elseif how == "self-sacrifice" then world:gainAchievement("WIN_SACRIFICE", game.player)
	end

	game.player.winner = how
	game:registerDialog(require("engine.dialogs.ShowText").new("Winner", "win", {playername=game.player.name, how=how}, game.w * 0.6))
end
