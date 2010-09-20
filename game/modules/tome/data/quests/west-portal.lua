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

name = "There and back again"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Zemekkys in the Gates of Morning can build a portal back to Middle-earth for you."

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
		desc[#desc+1] = "#LIGHT_GREEN#* The portal to Middle-earth is now functional and can be used to go back, although, as all portals, it is one-way only.#WHITE#"
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
	game.zone:addEntity(game.memory_levels["wilderness-arda-fareast-1"], g, "terrain", 62, 14)

	game.logPlayer(game.player, "Zemekkys points the location of Vor Armoury on your map.")
end

on_status_change = function(self, who, status, sub)
	if sub then
--		if self:isCompleted() then
--			who:setQuestStatus(self.id, engine.Quest.COMPLETED)
--			world:gainAchievement("ORC_PRIDE", game.player)
--		end
	end
end
