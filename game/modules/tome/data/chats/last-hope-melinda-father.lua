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
local q = game.player:hasQuest("kryl-feijan-escape")
local qs = game.player:hasQuest("shertul-fortress")
local ql = game.player:hasQuest("love-melinda")

if ql and ql:isStatus(q.COMPLETED, "death-beach") then

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*A man talks to you from inside, the door half open. His voice is sad.*#WHITE#
Sorry, the store is closed.]],
	answers = {
		{"[leave]"},
	}
}

elseif not q or not q:isStatus(q.DONE) then

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*A man talks to you from inside, the door half open. His voice is sad.*#WHITE#
Sorry, the store is closed.]],
	answers = {
		{"[leave]"},
	}
}

else

------------------------------------------------------------------
-- Saved
------------------------------------------------------------------

newChat{ id="welcome",
	text = [[@playername@! My daughter's savior!]],
	answers = {
		{"Hi, I was just checking in to see if Melinda is all right.", jump="reward", cond=function(npc, player) return not npc.rewarded_for_saving_melinda end, action=function(npc, player) npc.rewarded_for_saving_melinda = true end},
		{"Hi, I would like to talk to Melinda please.", jump="rewelcome", switch_npc={name="Melinda"}, cond=function(npc, player) return ql and not ql:isCompleted("moved-in") and not ql.inlove end},
		{"Hi, I would like to talk to Melinda please.", jump="rewelcome-love", switch_npc={name="Melinda"}, cond=function(npc, player) return ql and not ql:isCompleted("moved-in") and ql.inlove end},
		{"Sorry, I have to go!"},
	}
}

newChat{ id="reward",
	text = [[Please take this. It is nothing compared to the life of my child. Oh, and she wanted to thank you in person; I will call her.]],
	answers = {
		{"Thank you.", jump="melinda", switch_npc={name="Melinda"}, action=function(npc, player)
			local ro = game.zone:makeEntity(game.level, "object", {unique=true, not_properties={"lore"}}, nil, true)
			if ro then
				ro:identify(true)
				game.logPlayer(player, "Melinda's father gives you: %s", ro:getName{do_color=true})
				game.zone:addEntity(game.level, ro, "object")
				player:addObject(player:getInven("INVEN"), ro)
			end
			player:grantQuest("love-melinda")
			ql = player:hasQuest("love-melinda")
		end},
	}
}
newChat{ id="melinda",
	text = [[@playername@! #LIGHT_GREEN#*She jumps for joy and hugs you while her father returns to his shop.*#WHITE#]],
	answers = {
		{"I am glad to see you are fine. It seems your scars are healing quite well.", jump="scars", cond=function(npc, player)
			if player:attr("undead") then return false end
			return true
		end,},
		{"I am glad to see you well. Take care."},
	}
}

------------------------------------------------------------------
-- Flirting
------------------------------------------------------------------
newChat{ id="scars",
	text = [[Yes it has mostly healed, though I still do nightmares. I feel like something is still lurking.
Ah well, the bad dreams are still better than the fate you saved me from!]],
	answers = {
		{"Should I come across a way to help you during my travels, I will try to help.", quick_reply="Thank you, you are most welcome."},
		{"Most certainly, so what are your plans now?", jump="plans"},
	}
}
newChat{ id="rewelcome",
	text = [[Hi @playername@! I am feeling better now, even starting to grow restless...]],
	answers = {
		{"So what are your plans now?", jump="plans"},
		{"About that, I was thinking that maybe you'd like to go out with me sometime ...", jump="hiton", cond=function() return not ql.inlove and not ql.nolove end},
	}
}
newChat{ id="rewelcome-love",
	text = [[#LIGHT_GREEN#*Melinda appears at the door and kisses you*#WHITE#
Hi my dear, I'm so happy to see you!]],
	answers = {
		{"I am still looking out for an explanation of what happened at the beach."},
		{"About what happened on the beach, I think I have found something.", jump="home1", cond=function() return ql:isStatus(engine.Quest.COMPLETED, "can_come_fortress") end},
	}
}

local p = game:getPlayer(true)
local is_am = p:attr("forbid_arcane")
local is_mage = (p.faction == "angolwen") or p:isQuestStatus("mage-apprentice", engine.Quest.DONE)
newChat{ id="plans",
	text = [[I do not know yet, my father won't let me out until I'm fully healed. I've always wanted to do so many things.
That is why I got stuck in that crypt, I want to see the world.
My father gave me some funds so that I can take my future into my own hands. I have some friends in Derth, maybe I will open my own little shop there. ]]..(
is_am and
	[[I have seen how you fought those corruptors, the way you destroyed their magic. I want to learn to do the same, so that such horrors never happen again. To anyone.]]
or (is_mage and
	[[Or maybe, well I suppose I can trust you with this, I've always secretly dreamt of learning magic. Real magic I mean not alchemist tricks!
I've learnt about a secret place, Angolwen, where I could learn it.]]
or [[]])),
	answers = (not is_am and not is_mage) and {
		{"Derth has its up and downs but I think they could do with a smart girl yes.", action=function() ql.wants_to = "derth" end, quick_reply="Thanks!"},
	} or {
		{"Derth has its up and downs but I think they could do with a smart girl yes.", action=function() ql.wants_to = "derth" end, quick_reply="Thanks!"},
		{"You wish to join our noble crusade against magic? Wonderful! I will talk to them for you.", action=function() ql.wants_to = "antimagic" end, cond=function() return is_am end, quick_reply="That would be very nice!"},
		{"I happen to be welcome among the people of Angolwen, I could say a word for you.", action=function() ql.wants_to = "magic" end, cond=function() return is_mage end, quick_reply="That would be very nice!"},
	}
}

newChat{ id="hiton",
	text = [[What?!?  Just because you rescued me from a moderately-to-extremely gruesome death, you think that entitles you to take liberties?!]],
	answers = {
		{"WHY AREN'T WOMEN ATTRACTED TO ME I'M A NICE "..(p.female and "GIRL" or "GUY")..".", quick_reply="Uhh, sorry I hear my father calling, see you.", action=function() ql.nolove = true end},
		{"Just a minute, I was just ...", jump="reassurance"},
	}
}

newChat{ id="reassurance",
	text = [[#LIGHT_GREEN#*She looks at you cheerfully.*#WHITE#
Just kidding. I would love that!]],
	answers = {
		{"#LIGHT_GREEN#[walk away with her]#WHITE#What about a little trip to the south, from the coastline we can see the Charred Scar Volcano, it is a wonderous sight.", action=function() ql.inlove = true ql:toBeach() end},
		{"Joke's on you really, goodbye!", quick_reply="But... ok goodbye.", action=function() ql.nolove = true end},
	}
}

newChat{ id="hug",
	text = [[#LIGHT_GREEN#*You take Melinda in your arms and press her against you. The warmth of the contact lightens your heart.*#WHITE#
I feel safe in your arms. Please, I know you must leave, but promise to come back soon and hold me again.]],
	answers = {
		{"I think I would enjoy that very much. #LIGHT_GREEN#[kiss her]#WHITE#", action=function(npc, player)  end},
		{"That thought will carry me in the dark places I shall walk. #LIGHT_GREEN#[kiss her]#WHITE#", action=function(npc, player) player:grantQuest("love-melinda") end},
		{"Oh, I am sorry. I think you are mistaken. I was only trying to comfort you.", quick_reply="Oh, sorry, I was not myself. Goodbye, then. Farewell."},
	}
}

------------------------------------------------------------------
-- Moving in
------------------------------------------------------------------
newChat{ id="home1",
	text = [[#LIGHT_GREEN#*Melinda looks worried*#WHITE#
Please tell me you can help!]],
	answers = {
		{"Yes, I think so. Some time ago I assumed ownership of a very special home... #LIGHT_GREEN#[tell her the Fortress story]#WHITE#", jump="home2"},
	}
}

newChat{ id="home2",
	text = [[An ancient fortress of a mythical race?! How #{bold}#exciting#{normal}#!
And you say it could cure me?]],
	answers = {
		{"The Fortress seems to think so. I know this might sound a bit .. inappropriate .. but you would need to come live there, at least for a while.", jump="home3"},
	}
}

newChat{ id="home3",
	text = [[#LIGHT_GREEN#*She looks at you cheerfully*#WHITE#
Ah the plan to sleep with me is finally revealed!
Shhh you dummy, I thought we were past such silliness, I will come, both for my health and because I want to be with you.
#LIGHT_GREEN#*She kisses you tenderly*#WHITE#]],
	answers = {
		{"Then my lady, if you will follow me. #LIGHT_GREEN#[take her to the Fortress]", action=function(npc, player)
			game:changeLevel(1, "shertul-fortress", {direct_switch=true})
			player:hasQuest("love-melinda"):spawnFortress(player)
		end},
	}
}

end

return "welcome"
