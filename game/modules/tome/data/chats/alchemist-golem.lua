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

local change_weapon = function(npc, player)
	local inven = player:getInven("INVEN")
	player:showInventory("Select a two handed weapon for your golem.", inven, function(o) return o.type == "weapon" and o.twohanded end, function(o, item)
		player:removeObject(inven, item, true)
		local ro = npc:wearObject(o, true, true)
		if ro then
			if type(ro) == "table" then player:addObject(inven, ro) end
		elseif not ro then
			player:addObject(inven, o)
		else
			game.logPlayer(player, "Your golem equips: %s.", o:getName{do_color=true, no_count=true})
		end
		player:sortInven()
		player:useEnergy()
		return true
	end)
end

local change_armour = function(npc, player)
	local inven = player:getInven("INVEN")
	player:showInventory("Select a two handed armour for your golem.", inven, function(o) return o.type == "armor" and o.slot == "BODY" end, function(o, item)
		player:removeObject(inven, item, true)
		local ro = npc:wearObject(o, true, true)
		if ro then
			if type(ro) == "table" then player:addObject(inven, ro) end
		elseif not ro then
			player:addObject(inven, o)
		else
			game.logPlayer(player, "Your golem equips: %s.", o:getName{do_color=true, no_count=true})
		end
		player:sortInven()
		player:useEnergy()
		return true
	end)
end

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*The golem talks in a monotonous voice*#WHITE#
Yes master.]],
	answers = {
		{"I want to change your weapon.", action=change_weapon},
		{"I want to change your armour.", action=change_armour},
		{"Nothing, let's go."},
	}
}

return "welcome"
