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

name = "Tutorial: combat stats"
desc = function(self, who)

	local desc = {}
--[=[
	if self:isCompleted("started-basic-gameplay") and not self:isCompleted("finished-basic-gameplay") then
		desc[#desc+1] = "You must venture in the heart of the forest and kill the Lone Wolf, who randomly attacks villagers."
	end
	if self:isCompleted("finished-basic-gameplay") then
		desc[#desc+1] = "#LIGHT_GREEN#You have defeated the Lone Wolf!#WHITE#"
	end
]=]
	if not self:isCompleted("finished-combat-stats") then
		desc[#desc+1] = "Explore the Dungeon of Adventurer Enlightenment to learn about ToME's combat mechanics."
	end
	if self:isCompleted("finished-combat-stats") then
		desc[#desc+1] = "#LIGHT_GREEN#You have navigated the Dungeon of Adventurer Enlightenment!#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		--world:gainAchievement("TUTORIAL_DONE", game.player)
	end
end

final_message = function(self)
	if self:isCompleted("finished-basic-gameplay") and self:isCompleted("finished-combat-stats") then
		game.player:resolveSource():setQuestStatus("tutorial", engine.Quest.COMPLETED)
		local d = require("engine.dialogs.ShowText").new("Tutorial Finished", "tutorial/done")
		game:registerDialog(d)
	end
end
--[=[
choose_basic_gameplay = function()
	game.player.combat_atk = 0
	game.player.combat_dam = 0
	game.player.combat_spellpower = 0
	game.player.combat_def = 0
	game.player.combat_physresist = 0
	game.player.combat_spellresist = 0
	game.player.combat_mentalresist = 0
	local d = require("engine.dialogs.ShowText").new("Basic gameplay", "tutorial/basic-intro")
	game:registerDialog(d)
end

choose_combat_stats = function(self, who, status, sub)
	game.player.combat_atk = 24
	game.player.combat_dam = 7
	game.player.combat_spellpower = 88
	game.player.combat_def = 18
	game.player.combat_physresist = 10
	game.player.combat_spellresist = 116
	game.player.combat_mentalresist = 62
	local d = require("engine.dialogs.ShowText").new("Combat stat mechanics", "tutorial/combat-stats-intro")
	game:registerDialog(d)
end
]=]
on_grant = function(self)
	game.player.combat_atk = 25
	game.player.combat_dam = 7
	game.player.combat_spellpower = 88
	game.player.combat_def = 18
	game.player.combat_physresist = 10
	game.player.combat_spellresist = 116
	game.player.combat_mentalresist = 62
--	local d = require("engine.dialogs.ShowText").new("Combat stat mechanics", "tutorial/combat-stats-intro")
--	game:registerDialog(d)
end
