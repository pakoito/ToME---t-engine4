-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

-- Quest for the the breeding pits
name = "Desperate Measures"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You have encountered a dying sun paladin that told you about the orcs breeding pit, a true abomination."
	if self:isStatus(engine.Quest.COMPLETED, "wuss-out") then
		desc[#desc+1] = "You have decided to report the information to Aeryn so she can deal with it."
		if self:isStatus(engine.Quest.COMPLETED, "wuss-out-done") then
			desc[#desc+1] = "Aeryn said she would send troops to deal with it."
		end
	else
		desc[#desc+1] = "You have taken upon yourself to cleanse it and deal a crippling blow to the orcs."
		if self:isStatus(engine.Quest.COMPLETED, "genocide") then
			desc[#desc+1] = "The abominable task is done."
		end
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
	end
end

reveal = function(self)
	local spot = game.level:pickSpot{type="world-encounter", subtype="orc-breeding-pits-spawn"}
	if not spot then return end

	local g = game.level.map(spot.x, spot.y, engine.Map.TERRAIN):cloneFull()
	g.name = "Entrance to the orc breeding pit"
	g.display='>' g.color_r=colors.GREEN.r g.color_g=colors.GREEN.g g.color_b=colors.GREEN.b g.notice = true
	g.change_level=1 g.change_zone="orc-breeding-pit" g.glow=true
	g.add_displays = g.add_displays or {}
	g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/ladder_down.png"}
	g:altered()
	g:initGlow()
	game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)
	return true
end
