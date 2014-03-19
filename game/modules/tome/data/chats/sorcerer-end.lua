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

local p = game.party:findMember{main=true}

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


--------------------------------------------------------
-- Yeeks have a .. plan
--------------------------------------------------------
if p.descriptor.race == "Yeek" then
newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*The two Sorcerers lie dead before you.*#WHITE#
#LIGHT_GREEN#*Their bodies vanish in a small cloud of mist, quickly fading away.*#WHITE#
#LIGHT_GREEN#*You feel the Way reaching out to you, the whole yeek race speaks to you.*#WHITE#
You have done something incredible ]]..(p.female and "sister" or "brother")..[[! You also have created a unique opportunity for the yeek race!
The energies of those farportals are incredible, using them we could make the Way radiate all over Eyal, forcing it down on the other races, bringing them the same peace and happiness we feel in the Way.
You must go through the farportal and willingly sacrifice yourself inside. Your mind will embed itself into the farportal network, spreading the Way far and wide!
Even though you will die you will bring the world, and the yeeks, ultimate peace.
The Way will never forget you. Now go and make history!
]],
	answers = {
		{"#LIGHT_GREEN#[sacrifice yourself to bring the Way to every sentient creature.]", action=function(npc, player)
			player.no_resurrect = true
			player:die(player, {special_death_msg="sacrificing "..string.his_her_self(player).." to bring the Way to all"})
			player:setQuestStatus("high-peak", engine.Quest.COMPLETED, "yeek")
			player:hasQuest("high-peak"):win("yeek-sacrifice")
		end},
		{"But... I did so much, I could do so much more for the Way by staying alive!", jump="yeek-unsure"},
	}
}

newChat{ id="yeek-unsure",
	text = [[#LIGHT_GREEN#*You feel the Way taking over your mind, your body.*#WHITE#
You will do as asked, for the good of all Yeeks! The Way is always right.
]],
	answers = {
		{"#LIGHT_GREEN#[sacrifice yourself to bring the Way to every sentient creature.]", action=function(npc, player)
			player.no_resurrect = true
			player:die(player, {special_death_msg="sacrificing "..string.his_her_self(player).." to bring the Way to all"})
			player:setQuestStatus("high-peak", engine.Quest.COMPLETED, "yeek")
			player:hasQuest("high-peak"):win("yeek-sacrifice")
		end},
		{"#LIGHT_GREEN#[In a last incredible display of willpower you fight the Way for a few seconds, letting you project your thoughts to Aeryn.]#WHITE# High Lady! Kill me #{bold}#NOW#{normal}#",
			cond=function(npc, player) return not void_portal_open(nil, player) and aeryn_alive(npc, player) and player:getWil() >= 55 end, jump="yeek-stab"
		},
	}
}

newChat{ id="yeek-stab",
	text = [[#LIGHT_GREEN#*Through your mind Aeryn sees what the Way is planning.*#WHITE#
You were a precious ally and a friend. The world will remember your last act of selfless sacrifice. I swear it.
#LIGHT_GREEN#*As she says this she pierces your body with a mighty thrust of her sword, ending the plans of the Way.*#WHITE#
]],
	answers = {
		{"#LIGHT_GREEN#[slip peacefully into death.]", action=function(npc, player)
			player.no_resurrect = true
			player:die(player, {special_death_msg="sacrificing "..string.his_her_self(player).." to stop the Way"})
			player:setQuestStatus("high-peak", engine.Quest.COMPLETED, "yeek-stab")
			player:hasQuest("high-peak"):win("yeek-selfless")
		end},
	}
}

return "welcome"
end

--------------------------------------------------------
-- Default
--------------------------------------------------------

---------- If the void portal has been opened
if void_portal_open(nil, p) then
newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*The two Sorcerers lie dead before you.*#WHITE#
#LIGHT_GREEN#*Their bodies vanish in a small cloud of mist, quickly fading away.*#WHITE#
But the portal to the Void is already open. It must be closed before the Creator can come through or all will have been in vain!
After searching the remains of the Sorcerers you find a note explaining that the portal can only be closed with a sentient being's sacrifice.]],
	answers = {
		{"Aeryn, I am sorry but one of us needs to be sacrificed for the world to go on. #LIGHT_GREEN#[sacrifice Aeryn for the sake of the world]", jump="aeryn-sacrifice", cond=aeryn_alive},
		{"I will close it. #LIGHT_GREEN#[sacrifice yourself for the sake of the world]", action=function(npc, player)
			player.no_resurrect = true
			player:die(player, {special_death_msg="sacrificing "..string.his_her_self(player).." for the sake of the world"})
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
			game.level:removeEntity(aeryn, true)
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
