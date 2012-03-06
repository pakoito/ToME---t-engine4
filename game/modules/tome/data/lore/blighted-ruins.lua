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
-- Blighted Ruins
--------------------------------------------------------------------------
newLore{
	id = "blighted-ruins-note-1",
	category = "blighted ruins",
	name = "note from the Necromancer",
	lore = [[Work on my glorious project has been delayed. This displeases me. The fools from the nearby village are starting to suspect my presence, and have begun guarding their graveyards and cemeteries closely. Whatever meagre remains I can steal away are often too rotted or insubstantial to use for my project, so I have no choice but to use them as sub-par minions instead. Perhaps they will sow enough conflict and discord so that new, fresher remains will become available...]],
}

newLore{
	id = "blighted-ruins-note-2",
	category = "blighted ruins",
	name = "note from the Necromancer",
	lore = [[The cloak of deception is complete! Truly my finest work, not counting my project of course, it allows my minions to walk amongst the living without arousing their suspicions at all. Already I have taken a stroll to a nearby town alongside a ghoulish thrall, wrapped in the cloak... hah! The fools didn't even bat an eyelid! With this item, acquisition of components for my project shall be all the more simple.]],
}

newLore{
	id = "blighted-ruins-note-3",
	category = "blighted ruins",
	name = "note from the Necromancer",
	lore = function() return [[Fate smiles upon me. What did I come across today but the body of an unfortunate ]]..game.player.descriptor.subclass..[[? Unfortunate indeed, but rather fortunate for me. The body displays next to no decomposition... it shall be perfect! With this new minion and the cloak of deception, the completion of my project is all but assured. I must prepare for the ritual... my dark menagerie shall soon have a new member.]] end,
}

newLore{
	id = "blighted-ruins-note-4",
	category = "blighted ruins",
	name = "note from the Necromancer",
	lore = [[My masterpiece walks! It is glorious, beautiful. While it remains unfinished, it is finished enough to serve in its purpose of protecting my lair. No would-be hero will be able to defeat it, and once it is complete it will be nigh invulnerable! Now all that remains is to animate my newest minion and bend it to my will... then they'll see. They'll ALL see. What can possibly stop me now, I ask? What?!]],
}
