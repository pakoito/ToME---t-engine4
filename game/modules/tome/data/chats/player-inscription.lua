-- ToME - Tales of Maj'Eyal
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

local iname = iname
local idata = idata
local inven = inven
local item = item
local answers = {}

for i = 1, player.max_inscriptions do
	local name = player.inscriptions[i]
	local t = player:getTalentFromId("T_"..name)
	answers[#answers+1] = {t.name, action=function(npc, player)
		player:setInscription(i, iname, idata, true, true)
		player:removeObject(inven, item)
	end}
end
answers[#answers+1] = {"Cancel"}

newChat{ id="welcome",
	text = [[You have reached your maximun number of inscriptions(infusions/runes).
You can replace an existing one or cancel.]],
	answers = answers,
}

return "welcome"
