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

name = "The Temple of Creation"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Ukllmswwik asked you to take his portal to the temple of Creation and kill Slasul who has turned mad."
	if self:isCompleted("slasul-story") then
		desc[#desc+1] = "Slasul told you his side of the story. Now you must decide: which of them is corrupt?"
	end

	if self:isCompleted("kill-slasul") and self:isCompleted("kill-drake") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have killed both Ukllmswwik and Slasul, betraying them both.#WHITE#"
	elseif self:isCompleted("kill-slasul") and not self:isCompleted("kill-drake") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have sided with Ukllmswwik and killed Slasul.#WHITE#"
	elseif not self:isCompleted("kill-slasul") and self:isCompleted("kill-drake") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have sided with Slasul and killed Ukllmswwik.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub and (sub == "kill-slasul" or sub == "kill-drake") then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		if sub == "kill-slasul" then world:gainAchievement("SLASUL_DEAD", game.player)
		elseif sub == "kill-drake" then world:gainAchievement("UKLLMSWWIK_DEAD", game.player) end
	end
end

on_grant = function(self, who)
	local g = mod.class.Grid.new{
		show_tooltip=true,
		name="Portal to the temple of Creation",
		display='>', color=colors.VIOLET,
		notice = true,
		change_level=1, change_zone="temple-of-creation",
		image = "terrain/underwater/subsea_floor_02.png",
		add_displays = {mod.class.Grid.new{z=18, image="terrain/naga_portal.png", display_h=2, display_y=-1, embed_particles = {
			{name="naga_portal_smoke", rad=2, args={smoke="particles_images/smoke_whispery_bright"}},
			{name="naga_portal_smoke", rad=2, args={smoke="particles_images/smoke_heavy_bright"}},
			{name="naga_portal_smoke", rad=2, args={smoke="particles_images/smoke_dark"}},
		}}},
	}
	g:resolve() g:resolve(nil, true)
	game.zone:addEntity(game.level, g, "terrain", 34, 6)

	game.logPlayer(game.player, "A portal opens behind Ukllmswwik.")
end

portal_back = function(self, who)
	if self:isCompleted("portal-back") then return end
	-- Do it on the quests object directly to not trigger a message to the player
	self:setStatus(engine.Quest.COMPLETED, "portal-back", who)

	local g = mod.class.Grid.new{
		show_tooltip=true,
		name="Portal to the Flooded Cave",
		display='>', color=colors.VIOLET,
		notice = true,
		change_level=2, change_zone="flooded-cave",
		image = "terrain/underwater/subsea_floor_02.png",
		add_displays = {mod.class.Grid.new{z=18, image="terrain/naga_portal.png", display_h=2, display_y=-1, embed_particles = {
			{name="naga_portal_smoke", rad=2, args={smoke="particles_images/smoke_whispery_bright"}},
			{name="naga_portal_smoke", rad=2, args={smoke="particles_images/smoke_heavy_bright"}},
			{name="naga_portal_smoke", rad=2, args={smoke="particles_images/smoke_dark"}},
		}}},
	}
	g:resolve() g:resolve(nil, true)
	game.zone:addEntity(game.level, g, "terrain", 15, 13)

	game.logPlayer(game.player, "A portal opens to the flooded cave.")
end
