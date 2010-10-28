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

-- Ruysh Charred scar
name = "The Doom of the World!"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You were sent to the Charred Scar at the haert of which lies a huge volcano. In the Age of Pyre it destroyed the old Sher'Tul ruins that stood there, absorbing much of their latent magic."
	desc[#desc+1] = "This place is still full of that power and the orcs intend to absorb this power using the Staff of Absorption!"
	desc[#desc+1] = "Whatever their plan may be, they must be stopped at all cost."
	desc[#desc+1] = "The volcano is attacked by orcs, a few Sun Paladins made it there with you, they will hold the line at the cost of their lives to buy you some time."
	desc[#desc+1] = "Honor their sacrifice, do not let the orcs finish their work!"
	if self:isCompleted("not-stopped") then
		desc[#desc+1] = ""
		desc[#desc+1] = "You arrived too late, the place has been drained of its power and the blue wizards have left."
		desc[#desc+1] = "Use the portal to go back to the Far East, you *MUST* stop them, no matter the cost."
	elseif self:isCompleted("stopped") then
		desc[#desc+1] = ""
		desc[#desc+1] = "You arrived in time and interrupted the ritual, the blue wizards have departed."
		desc[#desc+1] = "Use the portal to go back to the Far East, you *MUST* stop them, no matter the cost."
	end
	return table.concat(desc, "\n")
end

start_fyrk = function(self)
	game.zone.on_turn = nil
	game.level.turn_counter = nil

	local alatar, pallando
	for uid, e in pairs(game.level.entities) do
		if e.define_as == "ALATAR" then alatar = e
		elseif e.define_as == "PALLANDO" then pallando = e end
	end

	if alatar then game.level:removeEntity(alatar) alatar.dead = true end
	if pallando then game.level:removeEntity(pallando) pallando.dead = true end

	local portal = game.zone:makeEntityByName(game.level, "grid", "FAR_EAST_PORTAL")
	game.zone:addEntity(game.level, portal, "grid", 6, 455)

	local fyrk = game.zone:makeEntityByName(game.level, "actor", "FYRK")
	game.zone:addEntity(game.level, fyrk, "actor", 6, 455)

	if self:isCompleted("not-stopped") then
		game.logPlayer(game.player, "#VIOLET#A portal activates in the distance, you hear the orcs shout 'The Sorcerers have departed, follow them!'")
	else
		game.logPlayer(game.player, "#VIOLET#The Sorcerers flee through a portal, as you prepare to follow them a huge faeros appears to block the way.")
		world:gainAchievement("CHARRED_SCAR_SUCCESS", game.player)
	end
	game.player:setQuestStatus("charred-scar", engine.Quest.COMPLETED)
end
