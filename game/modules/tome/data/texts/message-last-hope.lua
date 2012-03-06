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

local delivered_staff = game.player:resolveSource():isQuestStatus("staff-absorption", engine.Quest.COMPLETED, "survived-ukruk")

if delivered_staff then
return [[@playername@, this message is of utmost importance.

The staff you left at Last Hope is gone. A raid of orcs ambushed the guards that were transporting it to a secret vault.
Our troops managed to capture one of the orcs and made him talk.
He did not know much, but he did speak about "masters" in the Far East.
He spoke about Golbug -- this seems to be a warmaster in Reknor -- leading a raid to send a "package" through a portal.

This calls for urgency; should you find this Golbug or the portal, please investigate.

               #GOLD#-- Tolak, King of the Allied Kingdoms]]

else

return [[@playername@, this message is of utmost importance.

Our elders searched the old texts looking for clues about the staff of which you spoke.
It turns out to be a powerful object indeed, able to absorb the power of places, and beings.
This must not fall in the wrong hands, which certainly include orcish hands.
While you were gone, one of our patrols met a group of orcs led by Ukruk. We could not stop them, but we managed to capture one of them.
He did not know much, but he did speak about "masters" in the Far East.
He spoke about meeting with Golbug -- this seems to be a warmaster in Reknor -- to send a "package" through a portal.

This calls for urgency; should you find this Golbug or the portal, please investigate.

               #GOLD#-- Tolak, King of the Allied Kingdoms]]
end
