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

local function void_portal_open(npc, player)
	-- Mount doom was succesfull
	if player:hasQuest("mount-doom") and player:hasQuest("mount-doom"):isCompleted("stopped") then return false end
	return true
end
local function aeryn_alive(npc, player)
	for uid, e in pairs(game.level.entities) do
		if e.define_as and e.define_as == "HIGH_SUN_PALADIN_AERYN" then return e end
	end
end

---------- If the void portal has been openned
if void_portal_open(nil, game.player) then
newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*The two istari stand dead before you.*#WHITE#
#LIGHT_GREEN#*Their body vanishes in small cloud of mist, quickly fading away.*#WHITE#
But the portal to the Void is already open, it must be closed before Morgoth can come through or all will have been in vain!
After searching the remains of the Istari you find a note explaining that the portal can only be closed with a sentient being sacrifice.]],
	answers = {
		{"Aeryn, I am sorry but one of us needs to be sacrified for the world to go on. #LIGHT_GREEN#[sacrifice Aeryn for the sake of the world]", jump="aeryn-sacrifice", cond=aeryn_alive},
		{"I will close it #LIGHT_GREEN#[sacrifice yourself for the sake of the world]", action=function(npc, player)
			player:die(player)
			player:hasQuest("high-peak"):win("self-sacrifice")
		end},
	}
}

newChat{ id="aeryn-sacrifice",
	text = [[I can not believe we succeeded, I was prepared to die and it seems I will die, but at least I will do so knowing my sacrifice is not in vain.
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
	text = [[#LIGHT_GREEN#*The two istari stand dead before you.*#WHITE#
#LIGHT_GREEN#*Their body vanishes in some immaterial mist.*#WHITE#
You have won the game!
Both Middle-earth and the Far East are safe from the return of Morgoth.]],
	answers = {
		{"Aeryn, are you alright?", jump="aeryn-ok", cond=aeryn_alive},
		{"[leave]", action=function(npc, player) player:hasQuest("high-peak"):win("full") end},
	}
}

newChat{ id="aeryn-ok",
	text = [[I can not believe we succceeded, I was prepared to die and yet I live.
I might have underestimanted you, you did more than we could have hoped for!]],
	answers = {
		{"We both did.", action=function(npc, player) player:hasQuest("high-peak"):win("full") end},
	}
}
end


return "welcome"
