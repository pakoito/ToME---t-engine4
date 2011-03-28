-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

name = "Sher'Tul Fortress"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You found notes from an explorer inside the Old Forest. He spoke about Sher'Tul ruins sunken below the surface of the lake of Nur, at the forest's center."
	desc[#desc+1] = "With one of the notes there was a small gem that looks like a key."
	if self:isCompleted("entered") then
		desc[#desc+1] = "You used the key inside the ruins of Nur and found a way into the fortress of old."
	end
	if self:isCompleted("weirdling") then
		desc[#desc+1] = "The Weirdling Beast is dead, freeing the way into the fortress itself."
	end
	if self:isCompleted("butler") then
		desc[#desc+1] = "You have activated what seems to be a ... butler? with your rod of recall."
	end
	if self.shertul_energy > 0 then
		desc[#desc+1] = ("The Fortress current energy level is: %d."):format(self.shertul_energy)
	end
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	self.shertul_energy = 0
end

spawn_butler = function(self)
	local spot = game.level:pickSpot{type="spawn", subtype="butler"}
	local butler = game.zone:makeEntityByName(game.level, "actor", "BUTLER")
	game.zone:addEntity(game.level, butler, "actor", spot.x, spot.y)
	game.level.map:particleEmitter(spot.x, spot.y, 1, "demon_teleport")

	game.player:setQuestStatus(self.id, self.COMPLETED, "butler")

	world:gainAchievement("SHERTUL_FORTRESS", game.player)
end

spawn_transmo_chest = function(self, energy)
	local spot = game.level:pickSpot{type="spawn", subtype="butler"}
	local chest = game.zone:makeEntityByName(game.level, "object", "TRANSMO_CHEST")
	game.zone:addEntity(game.level, chest, "object", spot.x + 1, spot.y)
	game.level.map:particleEmitter(spot.x, spot.y, 1, "demon_teleport")
	game.player:setQuestStatus(self.id, self.COMPLETED, "transmo-chest")
end

gain_energy = function(self, energy)
	self.shertul_energy = self.shertul_energy + energy
end
