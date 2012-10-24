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

local has_staff = false
local o, item, inven_id = player:findInAllInventoriesBy("define_as", "STAFF_ABSORPTION")
if o then has_staff = true end
local o, item, inven_id = player:findInAllInventoriesBy("define_as", "STAFF_ABSORPTION_AWAKENED")
if o then has_staff = true end

local speak
if has_staff then
	speak = [["You should not be here. How di-"#{normal}# It stops abruptly, and its attention seems to turn to the staff in your hands. #{italic}#"How did you get that?! You fool, you do not know what forces you play with! Get it away from here - BEGONE!"]]
else
	speak = [["You should not be here. How did you get here?! BEGONE!"]]
end

newChat{ id="welcome",
	text = [[#{italic}#As you open the door you stare in amazement at what is beyond. A creature stands before you, with long tentacle-like appendages and a squat bump in place of a head. An intense aura of power radiates from this being unlike anything you've ever felt before. It can only be a Sher'Tul. A living Sher'Tul!

But your wonder is cut short as the Sher'Tul notices you, and you feel its intense concentration bear down on you like an unstoppable force. A voice in your head booms, #{normal}#]]..speak..[[#{italic}#

A wave of mental and magical power blasts into you with the might of a falling star. You are lifted into the air, and intense pressure bears down on every inch of your skin, threatening to crush you into nothingness. You try to resist for a moment, until--#{normal}#]],
	answers = {
		{"[continue]", jump="next", action=function(npc, player)
			game:changeLevel(1, "shertul-fortress", {direct_switch=true})
			local spot = game.level:pickSpot{type="spawn", subtype="farportal"} or {x=39, y=29}
			game.player:move(spot.x, spot.y, true)
			game.player:learnLore("shertul-fortress-caldizar")
		end},
	}
}

newChat{ id="next",
	text = [[#{italic}#You wake up suddenly next to your farportal with a pounding headache. Your cheeks feel wet, and touching them you see your fingers stained red - you have been crying tears of blood. A dark and terrible memory lurks at the back of your mind, but the more you try to remember it the harder it becomes, and slowly it fades completely, like a dream.#{normal}#]],
	answers = {
		{"[done]"},
	}
}

return "welcome"
