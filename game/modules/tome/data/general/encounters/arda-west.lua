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

newEntity{
	name = "Novice mage",
	type = "harmless", subtype = "quest", unique = true,
	level_range = {1, 10},
	rarity = 4,
	coords = {{ x=10, y=23, likelymap={
		[[    11111111   ]],
		[[ 1111122222211 ]],
		[[111111222222111]],
		[[111111222222211]],
		[[111111232222211]],
		[[111111222222211]],
		[[111111222222111]],
		[[111111222222111]],
		[[111111111111111]],
		[[ 1111111111111 ]],
		[[   111111111   ]],
	}}},
	-- Spawn the novice mage near the player
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = mod.class.NPC.new{
			name="Novice mage",
			type="humanoid", subtype="elf", faction="players",
			display='@', color=colors.RED,
			can_talk = "mage-apprentice-quest",
		}
		g:resolve() g:resolve(nil, true)
		game.zone:addEntity(game.level, g, "actor", x, y)
		return true
	end,
}

newEntity{
	name = "Lost merchant",
	type = "harmless", subtype = "quest", unique = true,
	level_range = {10, 20},
	rarity = 4,
	coords = {{ x=0, y=0, w=40, h=40}},
	on_encounter = function(self, who)

		return true
	end,
}
