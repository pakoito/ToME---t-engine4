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

-- Ruysh Charred scar
name = "The Doom of the World!"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You were sent to the Charred Scar at the heart of which lies a huge volcano. In the Age of Pyre it destroyed the old Sher'Tul ruins that stood there, absorbing much of their latent magic."
	desc[#desc+1] = "This place is still full of that power and the orcs intend to absorb this power using the Staff of Absorption!"
	desc[#desc+1] = "Whatever their plan may be, they must be stopped at all cost."
	desc[#desc+1] = "The volcano is attacked by orcs. A few Sun Paladins made it there with you. They will hold the line at the cost of their lives to buy you some time."
	desc[#desc+1] = "Honor their sacrifice; do not let the orcs finish their work!"
	if self:isCompleted("not-stopped") then
		desc[#desc+1] = ""
		desc[#desc+1] = "You arrived too late. The place has been drained of its power and the sorcerers have left."
		desc[#desc+1] = "Use the portal to go back to the Far East. You *MUST* stop them, no matter the cost."
	elseif self:isCompleted("stopped") then
		desc[#desc+1] = ""
		desc[#desc+1] = "You arrived in time and interrupted the ritual. The sorcerers have departed."
		desc[#desc+1] = "Use the portal to go back to the Far East. You *MUST* stop them, no matter the cost."
	end
	return table.concat(desc, "\n")
end

start_fyrk = function(self)
	game.zone.on_turn = nil
	game.level.turn_counter = nil

	local elandar, argoniel
	for uid, e in pairs(game.level.entities) do
		if e.define_as == "ELANDAR" then elandar = e
		elseif e.define_as == "ARGONIEL" then argoniel = e end
	end

	if elandar then game.level:removeEntity(elandar) elandar.dead = true end
	if argoniel then game.level:removeEntity(argoniel) argoniel.dead = true end

	local portal = game.zone:makeEntityByName(game.level, "grid", "FAR_EAST_PORTAL")
	game.zone:addEntity(game.level, portal, "grid", 5, 455) game.nicer_tiles:updateAround(game.level, 5, 455)
	game.zone:addEntity(game.level, portal, "grid", 6, 455) game.nicer_tiles:updateAround(game.level, 6, 455)
	game.zone:addEntity(game.level, portal, "grid", 7, 455) game.nicer_tiles:updateAround(game.level, 7, 455)
	game.zone:addEntity(game.level, portal, "grid", 5, 454) game.nicer_tiles:updateAround(game.level, 6, 454)
	game.zone:addEntity(game.level, portal, "grid", 7, 454) game.nicer_tiles:updateAround(game.level, 7, 454)
	game.zone:addEntity(game.level, portal, "grid", 5, 453) game.nicer_tiles:updateAround(game.level, 5, 453)
	game.zone:addEntity(game.level, portal, "grid", 6, 453) game.nicer_tiles:updateAround(game.level, 6, 453)
	game.zone:addEntity(game.level, portal, "grid", 7, 453) game.nicer_tiles:updateAround(game.level, 7, 453)
	local portal = game.zone:makeEntityByName(game.level, "grid", "CFAR_EAST_PORTAL")
	game.zone:addEntity(game.level, portal, "grid", 6, 454)

	local fyrk = game.zone:makeEntityByName(game.level, "actor", "FYRK")
	game.zone:addEntity(game.level, fyrk, "actor", 6, 452)

	if self:isCompleted("not-stopped") then
		game.logPlayer(game.player, "#VIOLET#A portal activates in the distance. You hear the orcs shout, 'The Sorcerers have departed! Follow them!'")
	else
		game.logPlayer(game.player, "#VIOLET#The Sorcerers flee through a portal. As you prepare to follow them, a huge faeros appears to block the way.")
		world:gainAchievement("CHARRED_SCAR_SUCCESS", game.player)
	end
	game.player:setQuestStatus("charred-scar", engine.Quest.COMPLETED)
	game.state:storesRestock()
end
