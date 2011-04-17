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

load("/data/general/grids/basic.lua")

for i = 1, 4 do
newEntity{
	define_as = "LORE"..i,
	name = "inscription", image = "terrain/maze_floor.png",
	display = '_', color=colors.GREEN, back_color=colors.DARK_GREY,
	add_displays = {class.new{image="terrain/signpost.png"}},
	always_remember = true,
	notice = true,
	lore = "infinite-dungeon-"..i,
	on_move = function(self, x, y, who)
		if not who.player then return end
		if self.lore == "infinite-dungeon-4" then
			game:setAllowedBuild("campaign_infinite_dungeon", true)
		end
		who:learnLore(self.lore)
	end,
}
end

newEntity{
	define_as = "INFINITE",
	name = "way into the infinite dungeon", image = "terrain/wall_hole.png",
	display = '>', color=colors.VIOLET, back_color=colors.DARK_GREY,
	always_remember = true,
	on_move = function(self, x, y, who)
		if not who.player then return end
		require("engine.ui.Dialog"):simplePopup("Infinite Dungeon", "You should not go there, there is no way back. Ever.")
	end,
}

newEntity{
	define_as = "LOCK",
	name = "sealed door", image = "terrain/sealed_door.png",
	display = '+', color=colors.WHITE, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
	block_sight = true,
	does_block_move = true,
}

newEntity{
	define_as = "PORTAL",
	name = "orb", image = "terrain/maze_teleport.png",
	display = '*', color=colors.VIOLET, back_color=colors.DARK_GREY,
	force_clone=true,
	always_remember = true,
	notice = true,
	on_move = function(self, x, y, who)
		if not who.player then return end
		if not game.level.data.touch_orb then return end
		local text = "???"
		if self.portal_type == "water" then text = "The orb seems to drip water."
		elseif self.portal_type == "earth" then text = "The orb is covered in dust."
		elseif self.portal_type == "wind" then text = "The orb is floating in the air."
		elseif self.portal_type == "nature" then text = "Small seeds seem to be growing inside the orb."
		elseif self.portal_type == "arcane" then text = "The orb swirls with magical energies."
		elseif self.portal_type == "fire" then text = "Flames burst out of the orb."
		end
		require("engine.ui.Dialog"):yesnoLongPopup("Strange Orb", text.."\nDo you touch it?", 400, function(ret)
			if ret then
				game.level.data.touch_orb(self.portal_type, x, y)
			end
		end)
	end,
}
