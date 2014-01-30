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

newChat{ id="welcome",
	text = [[Well met, @playername@. I was sent with a message from King Tolak of Last Hope.
I followed the trail of bodies that you left - very impressive! We are lucky to have you on our side.
But enough talk; take this message.  I must go now.
#LIGHT_GREEN#He gives you a sealed scroll and vanishes into the shadows.#LAST#]],
	answers = {
		{"Thank you for your courage.", action=function(npc, player)
			local o, item, inven_id = npc:findInAllInventories("Sealed Scroll of Last Hope")
			if o then
				npc:removeObject(inven_id, item, true)
				player:addObject(player.INVEN_INVEN, o)
				player:sortInven()
				game.logPlayer(player, "The herald gives you %s.", o:getName{do_color=true})
			end

			if game.level:hasEntity(npc) then game.level:removeEntity(npc) end
		end},
	}
}

return "welcome"
