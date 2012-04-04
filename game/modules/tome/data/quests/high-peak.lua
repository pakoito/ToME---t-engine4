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

name = "Falling Toward Apotheosis"
desc = function(self, who)
	local desc = {}

	if not self:isCompleted() then
		desc[#desc+1] = "You have vanquished the masters of the Orc Pride. Now you must venture inside the most dangerous place of this world: the High Peak."
		desc[#desc+1] = "Seek the Sorcerers and stop them before they bend the world to their will."
		desc[#desc+1] = "To enter, you will need the four orbs of command to remove the shield over the peak."
		desc[#desc+1] = "The entrance to the peak passes through a place called 'the slime tunnels', probably located inside or near Grushnak Pride."
	else
		desc[#desc+1] = "You have reached the summit of the High Peak, entered the sanctum of the Sorcerers and destroyed them, freeing the world from the threat of evil."
		desc[#desc+1] = "You have won the game!"
	end

	if self:isCompleted("killed-aeryn") then desc[#desc+1] = "#LIGHT_GREEN#* You encountered Sun Paladin Aeryn who blamed you for the loss of the Sunwall. You were forced to kill her.#LAST#" end
	if self:isCompleted("spared-aeryn") then desc[#desc+1] = "#LIGHT_GREEN#* You encountered Sun Paladin Aeryn who blamed you for the loss of the Sunwall, but you spared her.#LAST#" end

	if game.winner and game.winner == "full" then desc[#desc+1] = "#LIGHT_GREEN#* You defeated the Sorcerers before the Void portal could open.#LAST#" end
	if game.winner and game.winner == "aeryn-sacrifice" then desc[#desc+1] = "#LIGHT_GREEN#* You defeated the Sorcerers and Aeryn sacrificed herself to close the Void portal.#LAST#" end
	if game.winner and game.winner == "self-sacrifice" then desc[#desc+1] = "#LIGHT_GREEN#* You defeated the Sorcerers and sacrificed yourself to close the Void portal.#LAST#" end

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
			local chat = Chat.new("sorcerer-end", {name="Endgame"}, game:getPlayer(true))
			chat:invoke()
		end
	end
end

function start_end_combat(self)
	local p = game.party:findMember{main=true}
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
	if not game.state:isUniqueDead("High Sun Paladin Aeryn") then
		local aeryn = game.zone:makeEntityByName(level, "actor", "FALLEN_SUN_PALADIN_AERYN")
		game.zone:addEntity(level, aeryn, "actor", level.default_down.x, level.default_down.y)
		game.logPlayer(game.player, "#LIGHT_RED#As you enter the level you hear a familiar voice.")
		game.logPlayer(game.player, "#LIGHT_RED#Fallen Sun Paladin Aeryn: '%s YOU BROUGHT ONLY DESTRUCTION TO THE SUNWALL! YOU WILL PAY!'", game.player.name:upper())
	end

	game:onLevelLoad("wilderness-1", function(zone, level)
		local spot = level:pickSpot{type="zone-pop", subtype="ruined-gates-of-morning"}
		local wild = level.map(spot.x, spot.y, engine.Map.TERRAIN)
		wild.name = "Ruins of the Gates of Morning"
		wild.desc = "The Sunwall was destroyed while you were trapped in the High Peak."
		wild.change_level = nil
		wild.change_zone = nil
	end)
	game.player:setQuestStatus(self.id, engine.Quest.COMPLETED, "gates-of-morning-destroyed")
end

function win(self, how)
	game:playAndStopMusic("Lords of the Sky.ogg")
	game.player:learnLore("closing-farportal")

	if how == "full" then world:gainAchievement("WIN_FULL", game.player)
	elseif how == "aeryn-sacrifice" then world:gainAchievement("WIN_AERYN", game.player)
	elseif how == "self-sacrifice" then world:gainAchievement("WIN_SACRIFICE", game.player)
	elseif how == "yeek-sacrifice" then world:gainAchievement("YEEK_SACRIFICE", game.player)
	end

	local p = game:getPlayer(true)
	p.winner = how
	game:registerDialog(require("engine.dialogs.ShowText").new("Winner", "win", {playername=p.name, how=how}, game.w * 0.6))
end

function onWin(self, who)
	local desc = {}

	desc[#desc+1] = "#GOLD#Well done! You have won the Tales of Maj'Eyal: The Age of Ascendancy#WHITE#"
	desc[#desc+1] = ""
	desc[#desc+1] = "The Sorcerers are dead, and the Orc Pride lies in ruins, thanks to your efforts."
	desc[#desc+1] = ""

	-- Yeeks are special
	if who:isQuestStatus("high-peak", engine.Quest.COMPLETED, "yeek") then
		desc[#desc+1] = "Your sacrifice worked. Your mental energies were imbued with farportal energies. The Way radiated from the High Peak toward the rest of Eyal like a mental tidal wave."
		desc[#desc+1] = "Every sentient being in Eyal is now part of the Way. Peace and happiness are enforced for all."
		desc[#desc+1] = "Only the mages of Angolwen were able to withstand the mental shock and thus are the only unsafe people left. But what can they do against the might of the Way?"
		return 0, desc
	end

	if who.winner == "full" then
		desc[#desc+1] = "You have prevented the portal to the Void from opening and thus stopped the Creator from bringing about the end of the world."
	elseif who.winner == "aeryn-sacrifice" then
		desc[#desc+1] = "In a selfless act, High Sun Paladin Aeryn sacrificed herself to close the portal to the Void and thus stopped the Creator from bringing about the end of the world."
	elseif who.winner == "self-sacrifice" then
		desc[#desc+1] = "In a selfless act, you sacrificed yourself to close the portal to the Void and thus stopped the Creator from bringing about the end of the world."
	end

	if who:isQuestStatus("high-peak", engine.Quest.COMPLETED, "gates-of-morning-destroyed") then
		desc[#desc+1] = ""
		desc[#desc+1] = "The Gates of Morning have been destroyed and the Sunwall has fallen. The last remnants of the free people in the Far East will surely diminish, and soon only orcs will inhabit this land."
	else
		desc[#desc+1] = ""
		desc[#desc+1] = "The orc presence in the Far East has greatly been diminished by the loss of their leaders and the destruction of the Sorcerers. The free people of the Sunwall will be able to prosper and thrive on this land."
	end

	desc[#desc+1] = ""
	desc[#desc+1] = "Maj'Eyal will once more know peace. Most of its inhabitants will never know they even were on the verge of destruction, but then this is what being a true hero means: to do the right thing even though nobody will know about it."

	if who.winner ~= "self-sacrifice" then
		desc[#desc+1] = ""
		desc[#desc+1] = "You may continue playing and enjoy the rest of the world."
	end
	return 0, desc
end
