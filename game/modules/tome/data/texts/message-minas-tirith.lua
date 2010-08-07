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

local delivered_staff = game.player:resolveSource():setQuestStatus("staff-absorption", engine.Quest.COMPLETED, "survived-ukruk")

if delivered_staff then
return [[@playername@, this message is of utmost importance.

The staff you left at Minas Tirith is gone, a raid of orcs ambushed the guards that were transporting it to a secret vault.
Our troups managed to capture one of the orcs and made him talk.
He did not knew much, but he did speak about "masters" in the far east.
He spoke about Golbug, this seems to be a warmaster in the Moria, leading the raid to send the "package" through a portal.

This calls for urgency, should you find this Golbug or the portal please investigate.

               #GOLD#-- Eldarion, High King of the Reunited Kingdom]]

else

return [[@playername@, this message is of utmost importance.

Our elders searched the old texts looking for clues about the staff you talked about.
It turns out to be a powerful object indeed, able to absorb the power of places, and beings.
This must not fall in the wrong hands, which certainly include orc hands.
While you where gone one of our patrols met a group of orcs led by Ukruk, we could not stop them but we managed to capture one of them.
He did not knew much, but he did speak about "masters" in the far east.
He spoke about meeting with Golbug, this seems to be a warmaster in the Moria, to send the "package" through a portal.

This calls for urgency, should you find this Golbug or the portal please investigate.

               #GOLD#-- Eldarion, High King of the Reunited Kingdom]]
end