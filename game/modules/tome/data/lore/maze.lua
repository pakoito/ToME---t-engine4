-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

--------------------------------------------------------------------------
-- The Maze
--------------------------------------------------------------------------

newLore{
	id = "maze-note-1",
	category = "maze",
	name = "diary (the maze)",
	lore = [[Dear diary,

Lessons are off this week as my tutor has fallen ill, so I've decided to sneak out and have a wander round the old mazed ruins nearby. I know I'll get in trouble if I'm caught, but as long as I'm back in a couple of days no one will notice... Besides, I get so bored cooped up in those mountains! I want some fun!
]],
}

newLore{
	id = "maze-note-2",
	category = "maze",
	name = "diary (the maze)",
	lore = [[Dear diary,

My, what a dirty place this is! I've come across a few bandits and snakes in here, but nothing to threaten a grade 3 mage like me.

I remember hearing that this labyrinth used to be a prison used by the halfling king Roupar during the Age of Dusk, and that with the lawlessness of the time captives were simply sent here to rot. Some say a magical curse infected the place and turned them into bull-like monsters that patrol the halls to this day. How exciting!!]],
}

newLore{
	id = "maze-note-3",
	category = "maze",
	name = "diary (the maze)",
	lore = [[Dear diary,

Goodness this place is dull to walk round. Left, right, left, right - there's no end to it! I'm soooo bored! I think I might start using Probability Travel... I know my tutors have warned against it in dangerous places, but if I don't do something I'll just die of boredom!]],
}

newLore{
	id = "maze-note-4",
	category = "maze",
	name = "diary (the maze)",
	lore = [[Dear diary,

I'm having so much fun! Probability Travel is making this little trip a breeze. And you should have seen the look on that bandit's face when I came out one wall, disappeared through another, and came around behind him! Hee hee hee...

I still remember Archmage Tarelion's lecture about the spell - "Probability effects can be used for ease of use, but beware thee of relying on them. With ease of use comes ease of mind and a weakening of one's will and concentration. Soon one will find oneself in a situation of risk, and bereft of normal judgement of danger. Heed thee well." Bah, what tosh!!! How dumb does he really think I am?! Besides, I'm enjoying myself - I'm having an adventure!!]],
}

newLore{
	id = "maze-note-5",
	category = "maze",
	name = "diary (the maze)",
	lore = [[Dear diary,

Um, I had a bit of a near miss there. Silly of me really - I walked through a wall and saw some bandits and started blasting them, but I didn't notice some of their friends behind me. Luckily his first stab only grazed me, and I got away before he tried a second. Oh well, I'm sure it won't happen again...]],
}

newLore{
	id = "maze-note-6",
	category = "maze",
	name = "diary (the maze)",
	lore = [[Dear diary,

I saw something! I don't know what it was... but it was big and shadowy! But when I tried chasing it I got lost... Um, maybe I just imagined it? No, I'm sure it must be something cool and exciting, I just have to keep exploring!]],
}

newLore{
	id = "maze-note-7",
	category = "maze",
	name = "diary (the maze)",
	bloodstains = 7,
	lore = [[Dear diary,

#{italic}#This text is unreadable as it is thoroughly caked in blood.#{normal}#]],
}

newLore{
	id = "maze-note-trap",
	category = "maze",
	name = "the perfect killing device",
	lore = [[I have now devised the perfect trap for the horned beast that walks these halls! Truly he cannot avoid this amazing contraption - the perfect blend of technical mastery and nature's lethal gifts. Ah, how I look forward to having that monster's head mounted on my walls - it shall be the pride of my collection!

The contraption is elegant and simple, though many months I have spent getting the formula perfect. There are two vials attached together - one containing finely ground hemlock, the other containing a carefully prepared zinc compound. When the vials are broken the materials react with the air and pump out an amazing cloud of poisonous vapour! The poison is supremely effective, killing within minutes. All I have to do is carefully hide the vials beneath a thin piece of slate and wait for my prey to step upon the trap - then POOF, it's dead!

I have prepared a great many vials to last me throughout the hunting season. By this time next year I will have a trophy collection to match the kings!

I seem to have misplaced one though... I'm sure it must be close by.


No, NO! I have - I --- acci--- pain, such pa--______


#{italic}#You find a dusty case filled with many small vials of powder. They seem serviceable.#{normal}#]],
	on_learn = function(who)
		local p = game.party:findMember{main=true}
		if p:knowTalent(p.T_TRAP_MASTERY) then
			p:learnTalent(p.T_POISON_GAS_TRAP, 1)
			game.log("#LIGHT_GREEN#You have learnt to create poison gas traps!")
		end
	end,
}
