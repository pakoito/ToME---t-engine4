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

local desc = {}

desc[#desc+1] = "#GOLD#Well done! You have won the Tales of Maj'Eyal: the Fourth Age#WHITE#"
desc[#desc+1] = ""
desc[#desc+1] = "The Sorcerers are dead, the Orc Prides lie in ruins, thanks to your efforts."
desc[#desc+1] = ""
if game.player.winner == "full" then
	desc[#desc+1] = "You have prevented the portal to the Void from opening and thus stopped the Creator from bringing about the end of the world."
elseif game.player.winner == "aeryn-sacrifice" then
	desc[#desc+1] = "In a selfless act, High Sun Paladin Aeryn sacrificed herself to close the portal to the Void and thus stopped the Creator from bringing about the end of the world."
elseif game.player.winner == "self-sacrifice" then
	desc[#desc+1] = "In a selfless act, you sacrificed yourself to close the portal to the Void and thus stopped the Creator from bringing about the end of the world."
end

if game.player:isQuestStatus("high-peak", engine.Quest.COMPLETED, "gates-of-morning-destroyed") then
	desc[#desc+1] = ""
	desc[#desc+1] = "The Gates of Morning have been destroyed and the Sunwall has fallen, the last remnants of the free people in the Far East will surely disminish and soon only orcs will inhabit this land."
else
	desc[#desc+1] = ""
	desc[#desc+1] = "The orc presence in the Far East has greatly been disminished by the loss of their leaders and the destruction of the Sorcerers. The free people of the Sunwall will be able to prosper and thrive on this land."
end

desc[#desc+1] = ""
desc[#desc+1] = "Maj'Eyal will once more know peace, most of its inhabitants will never know they even were on the verge of destruction, but then this is what being a true hero means, to do the right thing even though nobody will know about it."

if game.player.winner ~= "self-sacrifice" then
	desc[#desc+1] = ""
	desc[#desc+1] = "You may continue playing and enjoy the rest of the world."
end

game.player.winner_text = desc

return table.concat(desc, "\n")
