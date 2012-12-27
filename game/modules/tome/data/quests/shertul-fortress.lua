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

name = "Sher'Tul Fortress"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You found notes from an explorer inside the Old Forest. He spoke about Sher'Tul ruins sunken below the surface of the lake of Nur, at the forest's center."
	desc[#desc+1] = "With one of the notes there was a small gem that looks like a key."
	if self:isCompleted("entered") then
		desc[#desc+1] = "#LIGHT_GREEN#* You used the key inside the ruins of Nur and found a way into the fortress of old.#WHITE#"
	end
	if self:isCompleted("weirdling") then
		desc[#desc+1] = "#LIGHT_GREEN#* The Weirdling Beast is dead, freeing the way into the fortress itself.#WHITE#"
	end
	if self:isCompleted("butler") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have activated what seems to be a ... butler? with your rod of recall.#WHITE#"
	end
	if self:isCompleted("transmo-chest") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have bound the transmogrification chest to the Fortress power system.#WHITE#"
	end
	if self:isCompleted("transmo-chest-extract-gems") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have upgraded the transmogrification chest to automatically transmute metallic items into gems before transmogrifying them.#WHITE#"
	end
	if self:isCompleted("recall") then
		if self:isCompleted("recall-done") then
			desc[#desc+1] = "#LIGHT_GREEN#* You have upgraded your rod of recall to transport you to the fortress.#WHITE#"
		else
			desc[#desc+1] = "#SLATE#* The fortress shadow has asked that you come back as soon as possible.#WHITE#"
		end
	end
	if self:isCompleted("farportal") then
		if self:isCompleted("farportal-broken") then
			desc[#desc+1] = "#RED#* You have forced a recall while in an exploratory farportal zone. The farportal was rendered unusable in the process.#WHITE#"
		elseif self:isCompleted("farportal-done") then
			desc[#desc+1] = "#LIGHT_GREEN#* You have entered the exploratory farportal room and defeated the horror lurking there. You can now use the farportal.#WHITE#"
		else
			desc[#desc+1] = "#SLATE#* The fortress shadow has asked that you come back as soon as possible.#WHITE#"
		end
	end
	if self:isCompleted("flight") then
		if self:isCompleted("flight-done") then
			desc[#desc+1] = "#LIGHT_GREEN#* You have re-enabled the fortress flight systems. You can now fly around in your fortress!#WHITE#"
		else
			desc[#desc+1] = "#SLATE#* The fortress shadow has asked that you find an Ancient Storm Saphir, along with at least 250 energy, to re-enable the fortress flight systems.#WHITE#"
		end
	end
	if self.shertul_energy > 0 then
		desc[#desc+1] = ("\nThe fortress's current energy level is: #LIGHT_GREEN#%d#WHITE#."):format(self.shertul_energy)
	end
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	self.shertul_energy = 0
	self.explored = 0
end

break_farportal = function(self)
	game.player:setQuestStatus(self.id, self.COMPLETED, "farportal-broken")
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

	game:setAllowedBuild("birth_transmo_chest", true)
end

gain_energy = function(self, energy)
	self.shertul_energy = self.shertul_energy + energy

	if self.shertul_energy >= 15 and not self:isCompleted("recall") then
		game.player:setQuestStatus(self.id, self.COMPLETED, "recall")
		local Dialog = require "engine.ui.Dialog"
		Dialog:simpleLongPopup("Fortress Shadow", "Master, you have sent enough energy to improve your rod of recall. Please return to the fortress.", 400)
	end

	if self.shertul_energy >= 45 and not self:isCompleted("farportal") then
		game.player:setQuestStatus(self.id, self.COMPLETED, "farportal")
		local Dialog = require "engine.ui.Dialog"
		Dialog:simpleLongPopup("Fortress Shadow", "Master, you have sent enough energy to activate the exploratory farportal.\nHowever, there seems to be a disturbance in that room. Please return as soon as possible.", 400)
	end

	if self.shertul_energy >= 250 and not self:isCompleted("flight") then
--		game.player:setQuestStatus(self.id, self.COMPLETED, "flight")
--		local Dialog = require "engine.ui.Dialog"
--		Dialog:simpleLongPopup("Fortress Shadow", "Master, you have sent enough energy to activate the flight systems.\nHowever, one control crystal is broken. You need to find an #GOLD#Ancient Storm Saphir#WHITE#.", 400)
	end
end

exploratory_energy = function(self, check_only)
	if self.shertul_energy < 45 then return false end
	if not self:isCompleted("farportal-done") then return false end
	if check_only then return true end

	self.shertul_energy = self.shertul_energy - 45
	self.explored = self.explored + 1
	if self.explored == 7 then world:gainAchievement("EXPLORER", game.player) end
	return true
end

spawn_farportal_guardian = function(self)
	game.player:setQuestStatus("shertul-fortress", self.COMPLETED, "farportal-spawn")

	-- Pop a random boss
	local spot = game.level:pickSpot{type="spawn", subtype="farportal"}
	local boss = game.zone:makeEntity(game.level, "actor", {type="horror", not_properties={"unique"}, random_boss=true}, nil, true)
	boss.shertul_on_die = boss.on_die
	boss.on_die = function(self, ...)
		game.player:setQuestStatus("shertul-fortress", engine.Quest.COMPLETED, "farportal-done")
		self:check("shertul_on_die", ...)
	end
	game.zone:addEntity(game.level, boss, "actor", spot.x, spot.y)

	-- Open the door, destroy the stairs
	local g = game.zone:makeEntityByName(game.level, "terrain", "OLD_FLOOR")
	local spot = game.level:pickSpot{type="door", subtype="farportal"}
	game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)
end

upgrade_rod = function(self)
	if self.shertul_energy < 15 then
		local Dialog = require "engine.ui.Dialog"
		Dialog:simplePopup("Fortress Shadow", "The energy is too low. It needs to be at least 15.")
		return
	end
	self.shertul_energy = self.shertul_energy - 15

	local rod = game.player:findInAllInventoriesBy("define_as", "ROD_OF_RECALL")
	if not rod then return end

	game.player:setQuestStatus("shertul-fortress", self.COMPLETED, "recall-done")
	rod.shertul_fortress = true
	game.log("#VIOLET#Your rod of recall glows brightly for a moment.")
end

upgrade_transmo_gems = function(self)
	if self.shertul_energy < 25 then
		local Dialog = require "engine.ui.Dialog"
		Dialog:simplePopup("Fortress Shadow", "The energy is too low. It needs to be at least 25.")
		return
	end
	self.shertul_energy = self.shertul_energy - 25

	game.player:setQuestStatus("shertul-fortress", self.COMPLETED, "transmo-chest-extract-gems")
	game.log("#VIOLET#Your transmogrification chest glows brightly for a moment.")
end

fly = function(self)
	if self:isStatus(self.COMPLETED, "flying") then
		game:changeLevel(1, "wilderness", {direct_switch=true})

		local f = nil
		for uid, e in pairs(game.level.entities) do
			if e.is_fortress then f = e break end
		end

		if not f then
			game.log("The fortress is not found!")
			return
		end

		f:takeControl(game.player)
	else
		game.party:learnLore("shertul-fortress-takeoff")

		local f = require("mod.class.FortressPC").new{}
		game:changeLevel(1, "wilderness", {direct_switch=true})
		game.party:addMember(f, {temporary_level=1, control="full"})
		f.x = game.player.x
		f.y = game.player.y
		game.party:setPlayer(f, true)
		game.level:addEntity(f)
		game.level.map:remove(f.x, f.y, engine.Map.ACTOR)
		f:move(f.x, f.y, true)

		game.player:setQuestStatus("shertul-fortress", self.COMPLETED, "flying")
	end
end
