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

name = "Eight legs of wonder"
desc = function(self, who)
	local desc = {}
	if not self:isCompleted() and not self:isEnded() then
		desc[#desc+1] = "Enter the caverns of Ardhungol and look for Sun Paladin Rashim."
		desc[#desc+1] = "But be careful; those are not small spiders..."
	else
		desc[#desc+1] = "#LIGHT_GREEN#You have killed Ungolë in Ardhungol and saved the Sun Paladin."
	end
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	-- Reveal entrance
	game:onLevelLoad("wilderness-1", function(zone, level)
		local g = game.zone:makeEntityByName(level, "terrain", "ARDHUNGOL")
		g:resolve() g:resolve(nil, true)
		local spot = level:pickSpot{type="zone-pop", subtype="ardhungol"}
		game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
		game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
		game.state:locationRevealAround(spot.x, spot.y)
	end)
	game.logPlayer(game.player, "She marks the location of Ardhungol on your map.")
end

portal_back = function(self, who)
	who:setQuestStatus(self.id, engine.Quest.COMPLETED)

	-- Reveal entrance
	local g = mod.class.Grid.new{
		show_tooltip=true, always_remember = true,
		name="Portal back to the Gates of Morning",
		display='>', color=colors.GOLD,
		notice = true,
		change_level=1, change_zone="town-gates-of-morning",
		image = "terrain/granite_floor1.png", add_mos={{image="terrain/demon_portal.png"}},
	}
	g:resolve() g:resolve(nil, true)
	game.zone:addEntity(game.level, g, "terrain", who.x, who.y)
	game.logPlayer(who, "A portal appears right under you, and Rashim rushes through.")
end
