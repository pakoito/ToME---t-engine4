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
local q = game.player:hasQuest("kryl-feijan-escape")
local qs = game.player:hasQuest("shertul-fortress")
local ql = game.player:hasQuest("love-melinda")

if not q or not q:isStatus(q.DONE) then

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
		{"Hi, I would like to talk to Melinda please.", jump="home1", switch_npc={name="Melinda"}, cond=function(npc, player) return ql and not ql:isCompleted("moved-in") end},
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
	text = [[#LIGHT_GREEN#*She presses on her lower belly in a provocative way.*#WHITE#
See, you can touch it. It is fine. No pain any more! This is thanks to you, my... dear friend.]],
	answers = {
		{"I am sorry. I do not think your father would approve. Be well, my lady.", quick_reply="I think he would, but if this is what you wish, goodbye and farewell."},
		{"#LIGHT_GREEN#[touch the spot she indicates] Yes, it seems all right", jump="touch_male", cond=function(npc, player) return player.male end},
		{"#LIGHT_GREEN#[touch the spot she indicates] Yes, it seems all right", jump="touch_female", cond=function(npc, player) return player.female end},
	}
}

newChat{ id="touch_male",
	text = [[#LIGHT_GREEN#*She blushes a bit.*#WHITE#
Your touch feels soft, and yet I can sense so much power in you.
This feels good. I can try to forget what those... other men... did to me.]],
	answers = {
		{"I am here if you want to talk about it. I saw them; I saw what they did. I can understand.", jump="request_explain"},
		{"I am no demon worshipper. I will not hurt you.", jump="reassurance"},
		{"You will get over it. Do not worry. Goodbye, Melinda, farewell.", quick_reply="It will be hard, but I know I will. Goodbye."},
	}
}

newChat{ id="touch_female",
	text = [[#LIGHT_GREEN#*She blushes a bit.*#WHITE#
I... I did not know another woman's touch could feel so... soft on my skin.
This feels good. I can try to forget what those... men... did to me.]],
	answers = {
		{"I am here if you want to talk about it. I saw them; I saw what they did. I can understand.", jump="request_explain"},
		{"I am no demon worshipper. I will not hurt you.", jump="reassurance"},
		{"You will get over it. Do not worry. Goodbye, Melinda, farewell.", quick_reply="It will be hard, but I know I will. Goodbye."},
	}
}

newChat{ id="request_explain",
	text = [[#LIGHT_GREEN#*She seems lost in her thoughts for a while, her eyes reflecting the terror she knew.*#WHITE#
Thank you for your kindness, but I am not ready to talk about it yet. It is so fresh and vivid in my mind!
#LIGHT_GREEN#*She starts to cry.*#WHITE#]],
	answers = {
		{"#LIGHT_GREEN#[take her in your arms] Everything is all right now. You are safe.", jump="hug"},
		{"Snap out of it! You are safe here.", quick_reply="Yes, yes. Well, thank you, goodbye."},
	}
}

newChat{ id="reassurance",
	text = [[#LIGHT_GREEN#*She looks deeply into your eyes.*#WHITE#
I know you are not. When you rescued me from the horrors, I knew instantly I could trust you. You might say it was fear, but I like to think I touched you, and you touched me.]],
	answers = {
		{"#LIGHT_GREEN#[take her in your arms] Everything is all right now. You are safe.", jump="hug"},
		{"Woah, wait a minute. I am glad to have saved you, but that is all.", quick_reply="Oh, sorry, I was not myself. Goodbye."},
	}
}

newChat{ id="hug",
	text = [[#LIGHT_GREEN#*You take Melinda in your arms and press her against you. The warmth of the contact lightens your heart.*#WHITE#
I feel safe in your arms. Please, I know you must leave, but promise to come back soon and hold me again.]],
	answers = {
		{"I think I would enjoy that very much. #LIGHT_GREEN#[kiss her]#WHITE#", action=function(npc, player) player:grantQuest("love-melinda") end},
		{"That thought will carry me in the dark places I shall walk. #LIGHT_GREEN#[kiss her]#WHITE#", action=function(npc, player) player:grantQuest("love-melinda") end},
		{"Oh, I am sorry. I think you are mistaken. I was only trying to comfort you.", quick_reply="Oh, sorry, I was not myself. Goodbye, then. Farewell."},
	}
}

------------------------------------------------------------------
-- Moving in
------------------------------------------------------------------
newChat{ id="home1",
	text = [[#LIGHT_GREEN#*Melinda appears at the door and kisses you*#WHITE#
@playername@! I missed you!]],
	answers = {
		{"I am sorry, I was a bit busy I fear. You know, the usual: slaying cultists, looting treasures of old."},
		{"Actually I have thought about something, for us. Some time ago I assumed ownership of a very special home... #LIGHT_GREEN#[tell her the Fortress story]#WHITE#", jump="home2", cond=function(npc, player) return ql and qs and qs:isCompleted("farportal") and not ql:isCompleted("moved-in") end},
	}
}

newChat{ id="home2",
	text = [[An ancient fortress of a mythical race?! How #{bold}#exciting#{normal}#!]],
	answers = {
		{"Yes indeed, I will probably spend quite some time there and I wondered if, well maybe, if you would like to stay there with me, there is much free room and...", jump="home3"},
		{"But really dangerous... anyway, I must be on my way. I will try to stop by again soon. #LIGHT_GREEN#[kiss her]#WHITE#"},
	}
}

newChat{ id="home3",
	text = [[#LIGHT_GREEN#*Melinda hugs you fiercely, kisses you and rushes to the inside of the shop. While she runs you hear:*#WHITE#
Daddy, you won't have to fear for me anymore! I'm moving home!]],
	answers = {
		{"I take that as a yes. #LIGHT_GREEN#[wait for her return and go to the Fortress]#WHITE#", action=function(npc, player)
			game:changeLevel(1, "shertul-fortress", {direct_switch=true})
			player:hasQuest("love-melinda"):spawnFortress(player)
		end},
	}
}


end

return "welcome"
