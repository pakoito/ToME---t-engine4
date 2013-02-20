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

local entershop = function (self, player)
	local arenashop = game:getStore("ARENA_SHOP")
	arenashop:loadup(game.level, game.zone)
	arenashop:interact(player, "Gladiator's wares")
	arenashop = nil
end

newChat{ id="ryal-entry",
text = [[#LIGHT_GREEN#*A gigantic bone giant walks through the main gate.
#LIGHT_GREEN#Its shape is intricate and sharp, resembling a drake, but with countless
#LIGHT_GREEN#spikes instead of wings.
#LIGHT_GREEN#The massive undead stares at you with unusual...intellect.
#LIGHT_GREEN#You have heard of him. Ryal the Towering, your first obstacle!
#LIGHT_GREEN#As an eerie blue glow fills where its eyes should be, the undead giant
#LIGHT_GREEN#roars and multiple bones fly in your general direction!*
]],
	answers = {
		{"Have at you!!"},
	}
}

newChat{ id="ryal-defeat",
text = [[#LIGHT_GREEN#*After taking several hits, the undead giant finally succumbs
#LIGHT_GREEN#to your attacks*
#LIGHT_GREEN#Suddenly, Ryal's body starts to regenerate!
#LIGHT_GREEN#Standing tall again, you can almost feel its emotionless skull staring
#LIGHT_GREEN#at you with...satisfaction.
#WHITE#Hehehe...well done, @playerdescriptor.race@.
#LIGHT_GREEN#*Ryal quietly turns towards the gate and leaves, seemingly unharmed*
]],
	answers = {
		{"It was fun, bone giant!", action=entershop},
		{"...what? unharmed?", action=entershop}
	}
}

newChat{ id="fryjia-entry",
text = [[#LIGHT_GREEN#*The wind chills as a young girl walks calmly through the gate.
#LIGHT_GREEN#She looks surprisingly young, with extremely pale skin and contrasting
#LIGHT_GREEN#long black hair. She examines you with eerie calmness*#WHITE#
I am known as Fryjia the Hailstorm. That's all you need to know, @playerdescriptor.race@. Let us begin.
#LIGHT_GREEN#*The whole arena starts to get colder as she speaks, and the audience
#LIGHT_GREEN#starts wearing their finest winter cloaks*]],
	answers = {
		{"Bring it!"},
	}
}

newChat{ id="fryjia-defeat",
text = [[#LIGHT_GREEN#*With your final blow, Fryjia falls, unable to continue*
#LIGHT_GREEN#*She awkwardly stands up, but doesn't seem critically injured*
#WHITE# I...I admit defeat.
#LIGHT_GREEN#*The audience "oooohs" in awe. Fryjia has turned her back to you*
#WHITE# @playerdescriptor.race@. You are not the person I am looking for...
#LIGHT_GREEN#*Leaving you wondering what she was talking about, the young girl walks
#LIGHT_GREEN#towards the gate. As it closes, you realize her eyes are wet with tears.
]],
	answers = {
		{"...", action=entershop},
		{"w...what was that about?", action=entershop}
	}
}

newChat{ id="riala-entry",
text = [[#LIGHT_GREEN#*The gate opens, revealing a mature human woman in crimson robes.
#LIGHT_GREEN#She looks at you with a wide smile*
#WHITE# My, my, what a fine @playerdescriptor.race@ you are. What was your name again, @playername@? I am soo delighted to be your rival today.
#LIGHT_GREEN#*She speaks quietly as if telling a secret* #WHITE#You know, so few get past the little one as of late, it's such a bore.#LIGHT_GREEN#*She giggles*#WHITE#
So! I am Reala, the Crimson. I came directly from Angolwen. Despite, you know, the whole thing with the Spellblaze, people still enjoy a few magic tricks!
#LIGHT_GREEN#*She snaps her fingers, and then flames start dancing around her!*#WHITE#
Fryjia told me about you, the poor thing, so I will not underestimate such a promising aspirant #LIGHT_GREEN#*She smiles warmly* #WHITE#So, let's make haste my dear!
There is a battle to fight here!]],
	answers = {
		{"Let's go!"},
	}
}

newChat{ id="riala-defeat",
text = [[#LIGHT_GREEN#*With the final blow, Reala falls...to suddenly burst in flames!!
#LIGHT_GREEN#You stare at the blazing inferno with understandable confusion,
#LIGHT_GREEN#until you hear her voice from behind*#WHITE#
Oh, my dear! That was quite the fight, wasn't it? I concede you the honor of victory.
#LIGHT_GREEN#*She bows politely*
Fryjia was right about you: you seem to be a champion in the works!
Oh, and please forgive her behavior. You will understand when you meet her father.
And, if you keep fighting like this, it will be really soon.
So, it's been my pleasure, @playername@. #LIGHT_GREEN#*She vanishes in a spiral of flame*]],
	answers = {
		{"I am pumped up! What's next?", action=entershop},
		{"Am I the only person with a name that can die here?", action=entershop}
	}
}

newChat{ id="valfren-entry",
text = [[#LIGHT_GREEN#*You suddenly realize everything has turned dark.
#LIGHT_GREEN#You look around searching for your rival. And then you notice it. Standing
#LIGHT_GREEN#right before you, a massive battle armor with an equally massive battle axe.
#LIGHT_GREEN#It wasn't there just a second ago. You step back and examine him better,
#LIGHT_GREEN#realizing it's actually a human inside that hulking, worn armor. You can't see
#LIGHT_GREEN#his eyes, but you know he's piercing your soul with his stare*
f...t...ma....ll...
#LIGHT_GREEN#*You hear a devilish voice, coming from everywhere at once!! But...you are
#LIGHT_GREEN#unable to understand anything! It doesn't seem like any language used in
#LIGHT_GREEN#Maj'Eyal!
#LIGHT_GREEN#And then...a piercing, demonic roar...you are overwhelmed by extreme
#LIGHT_GREEN#emotions invading your very soul!!*
]],
	answers = {
		{"#LIGHT_GREEN#*You valiantly stand against the darkness*"},
	}
}

newChat{ id="valfren-defeat",
text = [[#LIGHT_GREEN#*You valiantly deliver the finishing blow!*
#LIGHT_GREEN#*Valfren collapses as the light returns to this world.
#LIGHT_GREEN#You close your eyes for a brief instant. Fryjia is there when you open them*
Father... #LIGHT_GREEN#*She stands silent for a few seconds*#WHITE# You win, @playerdescriptor.race@.
You have done well. Prepare for your final battle... if you win, we will be at your service.
Good luck...
#LIGHT_GREEN#*After a few uncomfortable seconds, Valfren starts to move again.
#LIGHT_GREEN#He stands up and walks away with Fryjia. At the gates, Valfren turns his
#LIGHT_GREEN#head in your direction. You look at him, and then he looks above
#LIGHT_GREEN#the arena's walls. You follow his gaze... to meet the Master of the Arena*

#LIGHT_GREEN#*There it is. Your goal. Your heart beats fast, as the time has come*
#LIGHT_GREEN#*The Master of the Arena smiles proudly*
#RED#The final battle begins when the gate closes, just this final time!!
]],
	answers = {
		{"I will defeat you, Master of the Arena!!!", action=entershop},
		{"I will become Master of the Arena instead of the Master of the Arena!!", action=entershop},
		{"Wealth and glory! Wealth and glory!", action=entershop},
	}
}

newChat{ id="master-entry",
text = [[#LIGHT_GREEN#*Finally, the master of the arena comes into the gates!
#LIGHT_GREEN#The public roars with excitement as he faces you with confidence!*
I applaud you, @playerdescriptor.race@! You have fought with might and courage!
And now...the time for the final showdown!
#LIGHT_GREEN#*The master assumes a fighting stance. The audience cheers!*
Like you, I started from nowhere. I won't underestimate someone with such potential.
#LIGHT_GREEN#*The master smirks, you assume your fighting stance as well, and the
#LIGHT_GREEN#audience cheers you as well, making the excitement grow inside you*
Can you hear it, the public cheering? That's what this is about.
Pursue glory with all your might, @playerdescriptor.race@!!
#LIGHT_GREEN#*The master steps forward into the sand*
]],
	answers = {
		{"Wealth and glory!!!"},
	}
}

newChat{ id="master-defeat",
text = [[#LIGHT_GREEN#*After a glorious battle, the Master falls!*
Hah...haha. You did it, @playerdescriptor.race@...
#LIGHT_GREEN#*The master of the arena, defeated, stands up with a wide smile.
#LIGHT_GREEN#Feeling the master's approval, you pick up its weapon, now lying
#LIGHT_GREEN#in the blood-stained sand.*
Everyone! We got a champion today!!
#LIGHT_GREEN#*The audience rages and shouts your name repeatedly*
Congratulations, @playerdescriptor.race@. You are the Master now.
Now you shall take your rightful place as the champion.
Just remember...like me, you shall fall one day...
But meanwhile, this is your place! Welcome to paradise, @playerdescriptor.race@!
#LIGHT_GREEN#*You see several sponsors and military recruiters approach the
#LIGHT_GREEN#now defeated master, offering deals and good positions in the army.
#LIGHT_GREEN#You smile, victorious, knowing your life will be glorious from now on.
#LIGHT_GREEN#Because even if you are defeated in the future...
#LIGHT_GREEN#You can always sell your image and live large.

#YELLOW#CONGRATULATIONS!
#YELLOW#You are the new master of the arena! You are great and epic!
#YELLOW#You shall remain as the new master until someone challenges you!
#YELLOW#Next time you play, you shall battle this new champion instead!
]],
	answers = {
		{"WEALTH!! AND!! GLORYYYYY!!", action=function(npc, player) player:hasQuest("arena"):win() end},
		{"I won't need to save chicks from cults anymore!", cond=function(npc, player) if player.female == true then return false else return true end end, action=function(npc, player) player:hasQuest("arena"):win() end},
		{"I hereby stand victorious, awaiting future challenges!", action=function(npc, player) player:hasQuest("arena"):win() end},
		{"#LIGHT_GREEN#*dance*", action=function(npc, player) player:hasQuest("arena"):win() end},
	}
}