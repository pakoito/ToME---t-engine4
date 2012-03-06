-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
-- The Old Forest
--------------------------------------------------------------------------

newLore{
	id = "old-forest-note-1",
	category = "old forest",
	name = "journal entry (old forest)",
	lore = [[#{italic}#From the notes of Darwood Oakton, explorer:
#{bold}#CHAPTER ONE: THE SHER'TUL

#{normal}#The Sher'Tul. Who were they? Where did they come from? Where did they go? The mysteries surrounding this ancient race are almost infinite. What little scraps of information we have regarding them allude to a mighty and world-spanning civilisation, wielding power and magic unthinkable. Now, however, all that remains of them are forgotten, wind-swept ruins, the tiniest minutiae of their technology sealed away in the studies of reclusive sages. Does their mystery not call to your curious nature as it does mine, gentle reader?

My quest has drawn me into the Old Forest. What is there to be said about a place like "the old forest"? It is a forest, and it is old. By its unimaginative moniker you can guess how important this place is to the people of Derth; the only locals who commonly venture under its boughs are novice alchemists in search of ingredients, plus the odd hunter with his sights set low. However, the story of this old forest now takes a more interesting twist...

Rumours are growing of trees roaming in its depths, moving as you or I would. Some even claim that they now possess the spark of sentience. The Sher'Tul were rumoured to hold the power of animism... is this mere coincidence?]],
}

newLore{
	id = "old-forest-note-2",
	category = "old forest",
	name = "journal entry (old forest)",
	lore = [[#{italic}#From the notes of Darwood Oakton, explorer:
#{bold}#CHAPTER TWO: ANCIENT RUINS

#{normal}#My inquiries have paid off! It took much searching, and even more arm-twisting and cajoling once I had found my man, but a local lumberjack who plies his trade in the old forest has divulged to me an amazing secret! He speaks of ruins within the forest, a location where the living trees seem to congregate in larger numbers. He would not speak much of the place, and seemed to believe it cursed, but I did manage to squeeze out of him the appearance of the ruins, submerged in the middle of the great lake. There is no longer any doubt in my mind now: They belonged to the Sher'Tul!]],
}

newLore{
	id = "old-forest-note-3",
	category = "old forest",
	name = "journal entry (old forest)",
	lore = [[#{italic}#From the notes of Darwood Oakton, explorer:
#{bold}#CHAPTER THREE: DISASTER!

#{normal}#Does my title not tell you enough? Disaster, and again disaster! True enough, these Sher'Tul ruins exist... several hundred feet at the bottom of a mighty lake! The lake of Nur, one of the largest in the old forest, has swallowed up the ruins in its murky depths. I am hardly a strong swimmer, gentle reader, but even if I could swim like a naga-spawned beast I could not hope to explore the ruin's sunken expanses before drowning. I fear I must abandon my present expedition... the trees are paying closer attention to me, and I do not believe it is of the pleasant sort...]],
}

newLore{
	id = "old-forest-note-4",
	category = "old forest",
	name = "journal entry (old forest)",
	lore = [[#{italic}#From the notes of Darwood Oakton, explorer:
#{bold}#CHAPTER FOUR: NEEDS MUST...

#{normal}#Before I continue, I must make one thing clear: I am no great friend to the mages. Some powers simply were not meant for mortal hands or minds. As history has taught us time and again, from the sudden disappearance of the Sher'Tul to the Spellblaze and the plagues it brought in its wake, magic is wont to cause more harm than good. But I fear it is a necessity for my current task. During my stay in Derth a fellow traveller and I have become fast friends, often drinking together in the local tavern. I can't put my finger on it, but I believe him to be a mage; he has an unexplainable feeling of power surrounding him, not to mention a rather ostentatious hat. I wonder what his thoughts would be on the art of water-breathing...?]],
}

newLore{
	id = "old-forest-note-5",
	category = "old forest",
	name = "journal entry (old forest)",
	bloodstains = 12,
	lore = [[#{italic}#From the notes of Darwood Oakton, explorer:
#{bold}#CHAPTER FIVE: HORR...

#{italic}#This note seems hastily written and stained with water and blood.

#{normal}#I... I haven't got long.
The key is here, but I never ... the door.

I was unprepared! The trees I could avoid, the water I ... traverse, but beyond...
Horrors ... tentacles ... blazing light that burned in an instant ...
My flesh devoured, my mind shattered ... worms, alive, walking tog ...
... barely escaped. But my wounds are too ... blood won't stop ...

I thought the Sher'Tul wonderful, I was entranced ... every facet of knowledge I could gain ...
But this, is this their legacy? ... horrifying ... all my dreams ... Perhaps death is welcome now...

If any come after, I bid you turn ... horrors ... too much. If you are foolish enough to ... my only advice is to ...

#{italic}#You find with the note a tiny, faintly glowing orb - is this the key the note mentions?
#{normal}#]],
	on_learn = function(who)
		game.player:grantQuest("shertul-fortress")
	end,
}
