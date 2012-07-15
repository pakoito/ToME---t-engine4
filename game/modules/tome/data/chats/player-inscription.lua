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

local iname = iname
local idata = idata
local obj = obj
local inven = inven
local item = item
local replace_same = replace_same
local answers = {}

for i = 1, player.max_inscriptions do
	local name = player.inscriptions[i]
	if (not replace_same or replace_same.."_"..i == name) then
		local t = player:getTalentFromId("T_"..name)
		answers[#answers+1] = {t.name, action=function(npc, player)
			player:setInscription(i, iname, idata, true, true, {obj=obj}, replace_same)
			player:removeObject(inven, item)
		end, on_select=function(npc, player)
			game.tooltip_x, game.tooltip_y = 1, 1
			game:tooltipDisplayAtMap(game.w, game.h, "#GOLD#"..t.name.."#LAST#\n"..tostring(player:getTalentFullDescription(t)))
		end, }
	end
end

if not replace_same and player.inscriptions_slots_added < 2 and player.unused_talents_types > 0 then
	answers[#answers+1] = {"Buy a new slot with one #{bold}#talent category point#{normal}#.", action=function(npc, player)
		player.unused_talents_types = player.unused_talents_types - 1
		player.max_inscriptions = player.max_inscriptions + 1
		player.inscriptions_slots_added = player.inscriptions_slots_added + 1
		player:setInscription(nil, iname, idata, true, true, {obj=obj})
		player:removeObject(inven, item)
	end}
end

answers[#answers+1] = {"Cancel"}

newChat{ id="welcome",
	text = replace_same and [[You have too many of this type of inscription. You can only override an existing one. The old inscription will be lost.]]
	or [[You have reached your maximum number of inscriptions(infusions/runes).
If you have unassigned #{bold}#talent category point#{normal}# you can use one to create a new slot (up to 5).
You can replace an existing one or cancel.
The old inscription will be lost.]],
	answers = answers,
}

return "welcome"
