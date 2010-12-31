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

local function void_portal_open(npc, player)
	-- Charred scar was successful
	if player:hasQuest("charred-scar") and player:hasQuest("charred-scar"):isCompleted("stopped") then return false end
	return true
end
local function aeryn_alive(npc, player)
	for uid, e in pairs(game.level.entities) do
		if e.define_as and e.define_as == "HIGH_SUN_PALADIN_AERYN" then return e end
	end
end

---------- If the void portal has been opened
if void_portal_open(nil, game.player) then
newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*The two Sorcerers lie dead before you.*#WHITE#
#LIGHT_GREEN#*Their bodies vanish in small cloud of mist, quickly fading away.*#WHITE#
But the portal to the Void is already open. It must be closed before the Creator can come through or all will have been in vain!
After searching the remains of the Sorcerers you find a note explaining that the portal can only be closed with a sentient being's sacrifice.]],
	answers = {
		{"Aeryn, I am sorry but one of us needs to be sacrificed for the world to go on. #LIGHT_GREEN#[sacrifice Aeryn for the sake of the world]", jump="aeryn-sacrifice", cond=aeryn_alive},
		{"I will close it #LIGHT_GREEN#[sacrifice yourself for the sake of the world]", action=function(npc, player)
			player.no_resurrect = true
			player:die(player)
			player:hasQuest("high-peak"):win("self-sacrifice")
		end},
	}
}

newChat{ id="aeryn-sacrifice",
	text = [[I cannot believe we succeeded. I was prepared to die and it seems I will die, but at least I will do so knowing my sacrifice is not in vain.
Please, make sure the world is safe.]],
	answers = {
		{"You will never be forgotten.", action=function(npc, player)
			local aeryn = aeryn_alive(npc, player)
			game.level:removeEntity(aeryn)
			player:hasQuest("high-peak"):win("aeryn-sacrifice")
		end},
	}
}

----------- If the void portal is still closed
else
newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*The two Sorcerers lie dead before you.*#WHITE#
#LIGHT_GREEN#*Their bodies vanish in some immaterial mist.*#WHITE#
You have won the game!
Both Maj'Eyal and the Far East are safe from the dark schemes of the Sorcerers and their God.]],
	answers = {
		{"Aeryn, are you well?", jump="aeryn-ok", cond=aeryn_alive},
		{"[leave]", action=function(npc, player) player:hasQuest("high-peak"):win("full") end},
	}
}

newChat{ id="aeryn-ok",
	text = [[I cannot believe we succeeded. I was prepared to die and yet I live.
I might have underestimated you. You did more than we could have hoped for!]],
	answers = {
		{"We both did.", action=function(npc, player) player:hasQuest("high-peak"):win("full") end},
	}
}
end


return "welcome"
