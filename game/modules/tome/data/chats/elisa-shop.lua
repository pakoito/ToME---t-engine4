-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
	local do_quest = false
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

That is very nice, @playername@!]],
		answers = {
			{"Thank you, Elisa!", jump=do_quest and "quest" or nil},
		}
	}

	-- Switch to that chat
	return "id_list"
end

newChat{ id="welcome",
	text = [[Hello friend, what can I do for you?]],
	answers = {
		{"Could you have a look at these objects, please? [show her your unidentified items]", cond=can_auto_id, action=auto_id},
		{"Nothing, goodbye."},
	}
}

newChat{ id="quest",
	text = [[Wait, @playername@, you seem to be quite the adventurer. Maybe we can help one another.
You see, I #{bold}#LOOOVVVEEEE#{normal}# learning new lore and finding old artifacts of power, but I am not exactly an adventurer and I would surely get killed out there.
So take this orb (#LIGHT_GREEN#*she gives you an orb of scrying*#WHITE#). You can use it to talk to me from anywhere in the world! This way you can show me your new shiny findings!
I get to see many interesting things, and you get to know what your items do. We both win! Isn't it sweet?
Oh yes, the orb will also identify mundane items for you, as long as you carry it.]],
	answers = {
		{"Woah, thanks, Elisa. This is really nice!", action=function(npc, player)
			player:setQuestStatus("first-artifact", engine.Quest.COMPLETED)

			local orb = game.zone:makeEntityByName(game.level, "object", "ORB_SCRYING")
			if orb then player:addObject(player:getInven("INVEN"), orb) orb:added() orb:identify(true) end
		end},
	}
}

return "welcome"
