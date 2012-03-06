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
-- Trollmire
--------------------------------------------------------------------------

local check = function(who)
	local p = game:getPlayer(true)
	if p:knownLore("trollmire-note-1") and p:knownLore("trollmire-note-2") and p:knownLore("trollmire-note-3") then
		p:grantQuest("trollmire-treasure")
	end
end

newLore{
	id = "trollmire-note-1",
	category = "trollmire",
	name = "tattered paper scrap (trollmire)",
	lore = [[You find a tattered page scrap. Perhaps this is part of a diary entry.
"...is a gorgeous glade, but I could swear that looked like a part of a human femur.

...

Saw an absolutely gigantic troll, but fortunately I threw him off my scent."

Alongside the note is a part of a plan of the region.]],
	on_learn = check,
}

newLore{
	id = "trollmire-note-2",
	category = "trollmire",
	name = "tattered paper scrap (trollmire)",
	lore = [[You find a tattered page scrap. Perhaps this is part of a diary entry.
"...ack again, but he's just a stupid old troll. It'll be easy to not let him get wind of me.

...

...initely found his treasure stash further on, but had to turn back. If you get this, HELP!"

Alongside the note is a part of a plan of the region.]],
	on_learn = check,
}

newLore{
	id = "trollmire-note-3",
	category = "trollmire",
	name = "tattered paper scrap (trollmire)",
	lore = [[You find a tattered page scrap. Perhaps this is part of a diary entry.
"...writing this in a tree and he's at the bottom of it. Waiting. His club is the size of a tall dwarf. Don't think I'm going to make it..."

Alongside the note is a part of a plan of the region.]],
	bloodstains = 3,
	on_learn = check,
}
