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

-- Check for unidentified stuff
local function can_auto_id(npc, player)
	for inven_id, inven in pairs(player.inven) do
		for item, o in ipairs(inven) do
			if not o:isIdentified() then return true end
		end
	end
end
local function can_not_auto_id(npc, player)
	return not can_auto_id(npc, player)
end

local function auto_id(header, footer, done)
	return function(npc, player)
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
			text = header..table.concat(list, "\n")..footer,
			answers = { {done} }
		}

		-- Switch to that chat
		return "id_list"
	end
end

----------------------------------------------------------------------
-- Yeek version
----------------------------------------------------------------------
if version == "yeek" then

newChat{ id="welcome",
	text = [[You immerse your mind in the Way and let knowledge flow in.]],
	answers = {
		{"[Images and knowledge flow in.]", cond=can_auto_id,
			action=auto_id("", "", "[You mentally thank the Way.]")
		},
		{"[You do not gain any knowledge.]", cond=can_not_auto_id},
	}
}
return "welcome"

----------------------------------------------------------------------
-- Undead version
----------------------------------------------------------------------
elseif version == "undead" then

newChat{ id="welcome",
	text = [[You pause and recall past memories.]],
	answers = {
		{"[Images and knowledge flow in.]", cond=can_auto_id,
			action=auto_id("", "", "[done]")
		},
		{"[You do not recognize anything new.]", cond=can_not_auto_id},
	}
}
return "welcome"

----------------------------------------------------------------------
-- Elisa version
----------------------------------------------------------------------
else

newChat{ id="welcome",
	text = [[Oh, hi @playername@, have you got something new to show me?]],
	answers = {
		{"Yes, Elisa, could you have a look at these objects please? [show her the items the orb could not identify]", cond=can_auto_id,
			action=auto_id("Let's see what have you got here...\n", "\n\nThat is very nice, @playername@!", "Thank you, Elisa!")
		},
		{"Err, no... sorry, I just wanted to hear a friendly voice.", jump="friend"},
		{"Not yet sorry!"},
	}
}

newChat{ id="friend",
	text = [[#LIGHT_GREEN#*You hear something akin to a muffled giggle*#WHITE#
Oh, you are #{bold}#SOOOO#{normal}# cute!]],
	answers = {
		{"Goodbye, Elisa!"},
	}
}
return "welcome"

end
