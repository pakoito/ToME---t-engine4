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

load("/data/general/objects/objects.lua")

newEntity{ base = "BASE_SCROLL", define_as = "NOTE_FROM_MINAS_TIRITH",
	name = "Sealed Scroll of Minas Tirith", identified=true, unique=true,
	fire_proof = true,

	use_simple = { name="open the seal and read the message", use = function(self, who)
		game:registerDialog(require("engine.dialogs.ShowText").new(self:getName{do_color=true}, "message-minas-tirith", {playername=who.name}, game.w * 0.6))
	end}
}
