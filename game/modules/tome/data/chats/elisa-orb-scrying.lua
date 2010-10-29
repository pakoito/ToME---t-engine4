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

-- Check for unidentified stuff
local function can_auto_id(npc, player)
	for inven_id, inven in pairs(player.inven) do
		for item, o in ipairs(inven) do
			if not o:isIdentified() then return true end
		end
	end
end

local function auto_id(npc, player)
	local list = {}
	for inven_id, inven in pairs(player.inven) do
		for item, o in ipairs(inven) do
			if not o:isIdentified() then
				o:identify(true)
				list[#list+1] = o:getName{do_color=true}
			end
		end
	end

	-- Create the chat
	newChat{ id="id_list",
		text = [[Let's see what have you got here...
]]..table.concat(list, "\n")..[[

That is very nice @playername@!]],
		answers = {
			{"Thank you Elisa!"},
		}
	}

	-- Switch to that chat
	return "id_list"
end

newChat{ id="welcome",
	text = [[Oh, hi @playername@, have you got something new to show me?]],
	answers = {
		{"Yes Elisa, could you have a look at those objects please? [show her the items the orb could not identify]", cond=can_auto_id, action=auto_id},
		{"Err, no sorry, I just wanted to hear a friendly voice.", jump="friend"},
		{"Not yet sorry!"},
	}
}

newChat{ id="friend",
	text = [[#LIGHT_GREEN#*You hear something akin to a muffled giggle*#WHITE#
Oh you are #{bold}#SOOOO#{normal}# cute!]],
	answers = {
		{"Goodbye Elisa!"},
	}
}

return "welcome"
