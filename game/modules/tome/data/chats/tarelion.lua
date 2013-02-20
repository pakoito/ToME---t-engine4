-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
	text = [[I say, you there. Yes, you, young one!
You seem like the adventuring fare, up to all sorts of doo-daddle in the outside world, I imagine. Well, don't forget to pay patronage to our good library here in the city. The riches of the world are all well and good, but where would we be without the gift of knowledge? And all proceeds go towards the funding of further research. No greater cause, yes?]],
	answers = {
		{"Uh, yes, of course... I'll be moving on now."},
		{"Hold on! You... You're that apprentice mage I met in the wilds!", cond=function(npc, player) return player:isQuestStatus("mage-apprentice", engine.Quest.DONE) and player:getCun() >= 35 end, jump="apprentice"},
	}
}

newChat{ id="apprentice",
	text = [[Why, well-spotted, whippersnapper! Indeed, when the mood takes me I sometimes travel under the guise of an apprentice. It permits me to traverse the land unnoticed in my research, and if I meet any I deem worthy and sympathetic to Angolwen's cause, then so much the better. And it does provide the odd chortle, I tell you!]],
	answers = {
		{"Uh, yes, of course... I'll be moving on now."},
	}
}

return "welcome"
