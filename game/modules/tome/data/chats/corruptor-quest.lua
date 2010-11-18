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

newChat{ id="welcome",
	text = [[Wait @playerdescriptor.subclass@!
I see you are a worthy opponent, powerful indeed. I can see, and feel, your mastery of the eldritch crafts.
We are the same.]],
	answers = {
		{"What do you mean 'the same'?", jump="quest"},
		{"I am nothing like you. Die!", quick_reply="So be it. Die, give me your power!"},
	}
}

newChat{ id="quest",
	text = [[We both know the power of the arcane, we both hunger for power. There is so much I have discovered, so much I could teach you.
This place is special, the veil of reality if thin here, forever shattered by the spellblaze. We are taking advantage of this, we can draw on the power
leeching from this place, to better ourselves, to bring forth the dominion of magic!]],
	answers = {
		{"The world suffered from the spellblaze enough, magic must serve people, not enslave them. I will not listen to you!", quick_reply="So be it. Die, give me your power!"},
		{"What do you propose then?", jump="quest2"},
	}
}

newChat{ id="quest2",
	text = [[Let us end this meaningless fight. Have you ever heard of a group of people called the Ziguranth?
These rambling madmen think magic should not be permited to exist! They fear us, they fear our powers.
Let us join forces and crush the fools!]],
	answers = {
		{"Magic shall triumph!", jump="quest3", action=function(npc, player)
			if npc:isTalentActive(npc.T_DEMON_PLANE) then npc:forceUseTalent(npc.T_DEMON_PLANE, {ignore_energy=true}) end
		end},
		{"Magic has a purpose, those men are wrong, but you seem much worse.", quick_reply="Then you must leave.... THIS WORLD! DIE!"},
	}
}

newChat{ id="quest3",
	text = [[Good. Before your... untimely arrival we were preparing an attack on the Ziguranth main training camp, on the southern beach of the sea of Sash.
Come with us, let's destroy them!
Take this stone, it should help counter the antimagic powers of the Ziguranth.
And now I will open a portal to Zigur and the massacre shall begin!]],
	answers = {
		{"I am ready!", action=function(npc, player)
			if game.zone.short_name ~= "mark-spellblaze" then return "quest3" end
			npc.invulnerable = 1
			player:grantQuest("anti-antimagic")
		end},
	}
}

return "welcome"
