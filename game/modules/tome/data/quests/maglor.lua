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

name = "The Guardian of the Sea"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Ukllmswwik asked you to take his portal to the caverns of Ossë and kill Maglor who has turned mad."
	if self:isCompleted("maglor-story") then
		desc[#desc+1] = "Maglor told you his side of the story, now you must decide, which of them is corrupt?"
	end

	if self:isCompleted("kill-maglor") and self:isCompleted("kill-drake") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have killed both Ukllmswwik and Maglor, betraying them both.#WHITE#"
	elseif self:isCompleted("kill-maglor") and not self:isCompleted("kill-drake") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have sided with Ukllmswwik and killed Maglor.#WHITE#"
	elseif not self:isCompleted("kill-maglor") and self:isCompleted("kill-drake") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have sided with Maglor and killed Ukllmswwik.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub and (sub == "kill-maglor" or sub == "kill-drake") then
		who:setQuestStatus(self.id, engine.Quest.DONE)
	end
end

on_grant = function(self, who)
	local g = mod.class.Grid.new{
		show_tooltip=true,
		name="Portal to the Caverns of Ossë",
		display='>', color=colors.VIOLET,
		notice = true,
		change_level=1, change_zone="caverns-osse"
	}
	g:resolve() g:resolve(nil, true)
	game.zone:addEntity(game.level, g, "terrain", 34, 6)

	game.logPlayer(game.player, "A portal opens behind Ukllmswwik.")
end

portal_back = function(self, who)
	if self:isCompleted("portal-back") then return end
	-- Do it on the quets object directly to not trigger a message to the player
	self:setStatus(engine.Quest.COMPLETED, "portal-back", who)

	local g = mod.class.Grid.new{
		show_tooltip=true,
		name="Portal to the Flooded Cave",
		display='>', color=colors.VIOLET,
		notice = true,
		change_level=2, change_zone="flooded-cave"
	}
	g:resolve() g:resolve(nil, true)
	game.zone:addEntity(game.level, g, "terrain", 15, 13)

	game.logPlayer(game.player, "A portal opens to the flooded cave.")
end
